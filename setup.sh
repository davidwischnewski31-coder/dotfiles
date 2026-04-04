#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

load_homebrew() {
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

link_file() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "$target_path")"
  ln -sfn "$source_path" "$target_path"
}

install_claude_code() {
  if command -v claude >/dev/null 2>&1; then
    return
  fi

  curl -fsSL https://claude.ai/install.sh | bash
}

install_homebrew
load_homebrew

brew bundle --file "$REPO_DIR/Brewfile"

link_file "$REPO_DIR/.zprofile" "$HOME/.zprofile"
link_file "$REPO_DIR/.zshrc" "$HOME/.zshrc"
link_file "$REPO_DIR/.gitconfig" "$HOME/.gitconfig"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/config" ]; then
  cp "$REPO_DIR/.ssh/config.template" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
fi

if [ ! -f "$HOME/.env.private" ]; then
  cat >"$HOME/.env.private" <<'EOF'
# Put machine-specific secrets and overrides here.
# Example:
# export EXAMPLE_API_KEY=""
# export EXAMPLE_OAUTH_TOKEN=""
EOF
  chmod 600 "$HOME/.env.private"
fi

install_claude_code

echo "Bootstrap complete."
