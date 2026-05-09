#!/usr/bin/env bash
# Run on your CURRENT machine to push secrets into Vaultwarden.
# Prerequisites: bw CLI installed (brew install bitwarden-cli), logged in and unlocked.
set -euo pipefail

VAULT_SERVER="https://vault.aspire.software"
DAVIDAI_ENV="$HOME/davidai/.env"
ENV_PRIVATE="$HOME/.env.private"
SSH_PERSONAL="$HOME/.ssh/id_ed25519"
SSH_SEEKDA="$HOME/.ssh/id_ed25519_seekda_github"

# Store small content (SSH keys) as secure note
bw_upsert_note() {
  local name="$1"
  local content="$2"

  local existing_id
  existing_id=$(bw list items --search "$name" 2>/dev/null | jq -r --arg n "$name" '.[] | select(.name == $n) | .id' | head -1)

  local item_json encoded
  item_json=$(jq -n --arg name "$name" --arg notes "$content" \
    '{type: 2, name: $name, notes: $notes, secureNote: {type: 0}}')
  encoded=$(echo "$item_json" | base64)

  if [ -n "$existing_id" ]; then
    echo "Updating: $name"
    bw edit item "$existing_id" "$encoded" >/dev/null
  else
    echo "Creating: $name"
    bw create item "$encoded" >/dev/null
  fi
}

# Store large content (env files) as file attachment
bw_upsert_attachment() {
  local name="$1"
  local filepath="$2"

  local existing_id
  existing_id=$(bw list items --search "$name" 2>/dev/null | jq -r --arg n "$name" '.[] | select(.name == $n) | .id' | head -1)

  if [ -z "$existing_id" ]; then
    echo "Creating: $name"
    local item_json encoded
    item_json=$(jq -n --arg name "$name" '{type: 2, name: $name, notes: "", secureNote: {type: 0}}')
    encoded=$(echo "$item_json" | base64)
    existing_id=$(bw create item "$encoded" | jq -r '.id')
  else
    echo "Updating: $name"
    # Delete old attachment if exists
    local old_attachment_id
    old_attachment_id=$(bw get item "$existing_id" 2>/dev/null | jq -r '.attachments[0].id // empty')
    [ -n "$old_attachment_id" ] && bw delete attachment "$old_attachment_id" --itemid "$existing_id" >/dev/null || true
  fi

  bw create attachment --file "$filepath" --itemid "$existing_id" >/dev/null
}

# Configure server (no-op if already logged in)
bw config server "$VAULT_SERVER" 2>/dev/null || true

# Require an active session
if [ -z "${BW_SESSION:-}" ]; then
  echo "No BW_SESSION found. Run:"
  echo "  export BW_SESSION=\$(bw unlock --raw)"
  exit 1
fi

bw sync >/dev/null

# SSH keys (small — stored as secure notes)
[ -f "$SSH_PERSONAL" ] && bw_upsert_note "dotfiles/ssh-personal" "$(cat "$SSH_PERSONAL")"
[ -f "$SSH_SEEKDA" ]   && bw_upsert_note "dotfiles/ssh-seekda"   "$(cat "$SSH_SEEKDA")"

# Env files (large — stored as attachments)
[ -f "$DAVIDAI_ENV" ] && bw_upsert_attachment "dotfiles/davidai-env" "$DAVIDAI_ENV"
[ -f "$ENV_PRIVATE" ] && grep -qE '\S' "$ENV_PRIVATE" 2>/dev/null && \
  bw_upsert_attachment "dotfiles/env-private" "$ENV_PRIVATE"

bw sync >/dev/null
echo ""
echo "Done. All secrets pushed to $VAULT_SERVER"
