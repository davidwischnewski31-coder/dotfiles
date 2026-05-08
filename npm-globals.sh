#!/usr/bin/env bash
# Install stable global npm tools. Run once after setup.sh.
set -euo pipefail

npm install -g \
  @openai/codex \
  @playwright/mcp

echo "npm globals installed."
