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

# Claude Code shortcuts.
alias cc='claude'
if [ -f "$HOME/.claude/playwright-mcp.json" ]; then
  alias ccb='claude --mcp-config ~/.claude/playwright-mcp.json'
fi
