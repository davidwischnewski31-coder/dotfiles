#!/usr/bin/env bash
# Run on a NEW machine after setup.sh to pull secrets from Vaultwarden.
# Prerequisites: bw CLI installed (comes with setup.sh via Brewfile).
set -euo pipefail

VAULT_SERVER="https://vault.aspire.software"

bw_get_note() {
  local name="$1"
  bw get item "$name" 2>/dev/null | jq -r '.notes // empty'
}

bw_get_attachment() {
  local name="$1"
  local outpath="$2"

  local item
  item=$(bw get item "$name" 2>/dev/null)
  local item_id attachment_id
  item_id=$(echo "$item" | jq -r '.id')
  attachment_id=$(echo "$item" | jq -r '.attachments[0].id // empty')

  if [ -z "$attachment_id" ]; then
    echo "  WARNING: no attachment found for $name"
    return
  fi

  mkdir -p "$(dirname "$outpath")"
  bw get attachment "$attachment_id" --itemid "$item_id" --output "$outpath" >/dev/null
  chmod 600 "$outpath"
  echo "  wrote $outpath"
}

write_file() {
  local path="$1"
  local content="$2"
  local mode="${3:-644}"

  mkdir -p "$(dirname "$path")"
  printf '%s' "$content" > "$path"
  chmod "$mode" "$path"
  echo "  wrote $path"
}

# Configure server (no-op if already logged in)
bw config server "$VAULT_SERVER" 2>/dev/null || true

# Require an active session
if [ -z "${BW_SESSION:-}" ]; then
  echo "No BW_SESSION. Run:"
  echo "  bw config server $VAULT_SERVER"
  echo "  bw login"
  echo "  export BW_SESSION=\$(bw unlock --raw)"
  exit 1
fi

bw sync >/dev/null
echo "Restoring secrets from $VAULT_SERVER..."

# SSH keys (stored as secure notes)
SSH_PERSONAL=$(bw_get_note "dotfiles/ssh-personal")
if [ -n "$SSH_PERSONAL" ]; then
  write_file "$HOME/.ssh/id_ed25519" "$SSH_PERSONAL" 600
  ssh-keygen -y -f "$HOME/.ssh/id_ed25519" > "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || true
  ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null || true
fi

SSH_SEEKDA=$(bw_get_note "dotfiles/ssh-seekda")
if [ -n "$SSH_SEEKDA" ]; then
  write_file "$HOME/.ssh/id_ed25519_seekda_github" "$SSH_SEEKDA" 600
  ssh-keygen -y -f "$HOME/.ssh/id_ed25519_seekda_github" > "$HOME/.ssh/id_ed25519_seekda_github.pub" 2>/dev/null || true
  ssh-add "$HOME/.ssh/id_ed25519_seekda_github" 2>/dev/null || true
fi

# Env files (stored as attachments)
bw_get_attachment "dotfiles/davidai-env" "$HOME/davidai/.env"
bw_get_attachment "dotfiles/env-private" "$HOME/.env.private"

echo ""
echo "Done. Secrets restored."
echo ""
echo "Next: authenticate CLI tools"
echo "  gh auth login                          # GitHub (repeat for both accounts)"
echo "  gcloud auth login                      # Google Cloud"
echo "  git config --global user.name 'David Wischnewski'"
echo "  git config --global user.email 'david.wischnewski@seekda.com'"
