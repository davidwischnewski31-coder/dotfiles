# Local user binaries first.
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# Load machine-specific secrets and overrides outside the public repo.
if [ -f "$HOME/.env.private" ]; then
  set -a
  source "$HOME/.env.private"
  set +a
fi

# Optional Claude Code feature flag carried over from the current setup.
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

# Lightweight AI usage shortcuts.
alias aiusage='codexbar usage --provider all'
alias claudeusage='codexbar usage --provider claude'
alias codexusage='codexbar usage --provider codex'

# Bitwarden / Vaultwarden
export BW_SERVER="https://vault.aspire.software"

# Claude Code shortcuts.
alias cc='claude'

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi
