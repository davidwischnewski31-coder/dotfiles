#!/usr/bin/env bash
# Run this after vault-restore.sh to configure the Seekda work environment.
set -euo pipefail

SEEKDA_KEY="$HOME/.ssh/id_ed25519_seekda_github"
SEEKDA_DIR="$HOME/seekda-main"

# 1. Verify SSH key exists (should have been restored by vault-restore.sh)
if [ ! -f "$SEEKDA_KEY" ]; then
  echo "ERROR: $SEEKDA_KEY not found."
  echo "Run vault-restore.sh first to restore your SSH keys from Vaultwarden."
  exit 1
fi

# 2. Clone seekda-main
if [ ! -d "$SEEKDA_DIR" ]; then
  echo "Cloning seekda-main..."
  git clone git@github-seekda:seekda/seekda-main.git "$SEEKDA_DIR"
else
  echo "seekda-main already cloned at $SEEKDA_DIR"
fi

# 3. Drop in Cursor MCP config
MCP_DIR="$SEEKDA_DIR/.cursor"
MCP_FILE="$MCP_DIR/mcp.json"
mkdir -p "$MCP_DIR"

if [ ! -f "$MCP_FILE" ]; then
  cat >"$MCP_FILE" <<'EOF'
{
  "mcpServers": {
    "Atlassian-MCP-Server": {
      "url": "https://mcp.atlassian.com/v1/mcp"
    },
    "pylon": {
      "url": "https://mcp.usepylon.com/"
    }
  }
}
EOF
  echo "MCP config written to $MCP_FILE"
else
  echo "MCP config already exists at $MCP_FILE"
fi

echo ""
echo "Seekda setup complete."
echo ""
echo "Next steps:"
echo "  1. Open Cursor → Settings → Tools → MCP → enable Atlassian-MCP-Server and Pylon → click Connect"
echo "  2. Complete OAuth in the browser for each"
