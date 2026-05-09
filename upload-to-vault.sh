#!/usr/bin/env bash
# Run on your CURRENT machine to push secrets into Vaultwarden.
# Prerequisites: bw CLI installed (brew install bitwarden-cli), logged in and unlocked.
set -euo pipefail

VAULT_SERVER="https://vault.aspire.software"
DAVIDAI_ENV="$HOME/davidai/.env"
ENV_PRIVATE="$HOME/.env.private"
SSH_PERSONAL="$HOME/.ssh/id_ed25519"
SSH_SEEKDA="$HOME/.ssh/id_ed25519_seekda_github"

bw_upsert() {
  local name="$1"
  local content="$2"

  local existing_id
  existing_id=$(bw list items --search "$name" 2>/dev/null | jq -r --arg n "$name" '.[] | select(.name == $n) | .id' | head -1)

  local item_json
  item_json=$(jq -n \
    --arg name "$name" \
    --arg notes "$content" \
    '{type: 2, name: $name, notes: $notes, secureNote: {type: 0}}')

  if [ -n "$existing_id" ]; then
    echo "Updating: $name"
    bw edit item "$existing_id" "$item_json" >/dev/null
  else
    echo "Creating: $name"
    bw create item "$item_json" >/dev/null
  fi
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

# SSH keys
[ -f "$SSH_PERSONAL" ]  && bw_upsert "dotfiles/ssh-personal"  "$(cat "$SSH_PERSONAL")"
[ -f "$SSH_SEEKDA" ]    && bw_upsert "dotfiles/ssh-seekda"     "$(cat "$SSH_SEEKDA")"

# Env files
[ -f "$DAVIDAI_ENV" ]   && bw_upsert "dotfiles/davidai-env"   "$(cat "$DAVIDAI_ENV")"
[ -f "$ENV_PRIVATE" ] && grep -qE '\S' "$ENV_PRIVATE" 2>/dev/null && \
  bw_upsert "dotfiles/env-private" "$(cat "$ENV_PRIVATE")"

bw sync >/dev/null
echo ""
echo "Done. All secrets pushed to $VAULT_SERVER"
