#!/usr/bin/env bash
# Run on a NEW machine after setup.sh to pull secrets from Vaultwarden.
# Prerequisites: bw CLI installed (comes with setup.sh via Brewfile).
set -euo pipefail

VAULT_SERVER="https://vault.aspire.software"

bw_get_note() {
  local name="$1"
  bw get item "$name" 2>/dev/null | jq -r '.notes // empty'
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

# Configure server
bw config server "$VAULT_SERVER" >/dev/null

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

# SSH keys
SSH_PERSONAL=$(bw_get_note "dotfiles/ssh-personal")
if [ -n "$SSH_PERSONAL" ]; then
  write_file "$HOME/.ssh/id_ed25519" "$SSH_PERSONAL" 600
  ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null || true
fi

SSH_SEEKDA=$(bw_get_note "dotfiles/ssh-seekda")
if [ -n "$SSH_SEEKDA" ]; then
  write_file "$HOME/.ssh/id_ed25519_seekda_github" "$SSH_SEEKDA" 600
  ssh-add "$HOME/.ssh/id_ed25519_seekda_github" 2>/dev/null || true
fi

# Generate public keys from private keys if missing
[ -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.ssh/id_ed25519.pub" ] && \
  ssh-keygen -y -f "$HOME/.ssh/id_ed25519" > "$HOME/.ssh/id_ed25519.pub"
[ -f "$HOME/.ssh/id_ed25519_seekda_github" ] && [ ! -f "$HOME/.ssh/id_ed25519_seekda_github.pub" ] && \
  ssh-keygen -y -f "$HOME/.ssh/id_ed25519_seekda_github" > "$HOME/.ssh/id_ed25519_seekda_github.pub"

# Env files
DAVIDAI_ENV=$(bw_get_note "dotfiles/davidai-env")
[ -n "$DAVIDAI_ENV" ] && write_file "$HOME/davidai/.env" "$DAVIDAI_ENV" 600

ENV_PRIVATE=$(bw_get_note "dotfiles/env-private")
[ -n "$ENV_PRIVATE" ] && write_file "$HOME/.env.private" "$ENV_PRIVATE" 600

echo ""
echo "Done. Secrets restored."
echo ""
echo "Next: authenticate CLI tools"
echo "  gh auth login                          # GitHub (both accounts)"
echo "  gcloud auth login                      # Google Cloud"
echo "  git config --global user.name 'David Wischnewski'"
echo "  git config --global user.email 'david.wischnewski@seekda.com'"
