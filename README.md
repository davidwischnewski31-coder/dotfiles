# dotfiles

Sanitized macOS shell environment and bootstrap script.

## Included

- `Brewfile`
- `.zprofile`
- `.zshrc`
- `.gitconfig`
- `.ssh/config.template`
- `setup.sh`
- `seekda-setup.sh`

## Key apps installed by Homebrew

- Claude desktop
- Codex + Codexbar
- ChatGPT
- cmux
- Docker Desktop
- Granola
- Msty
- Notion
- Obsidian
- Raycast
- Google Chrome
- Visual Studio Code
- Spotify
- Tailscale
- Telegram
- Tunnelblick
- WhatsApp
- Wispr Flow
- Ghostty

## What was intentionally left out

- API keys, OAuth tokens, and other secrets
- private SSH keys
- project-specific helpers tied to `~/davidai`
- auto-`cd` behavior into a personal workspace

## Bootstrap

```bash
./setup.sh
```

The script:

- installs Homebrew if needed
- installs the Brew bundle
- symlinks shell and Git config
- creates `~/.ssh/config` from the template if one does not exist
- creates `~/.env.private` if missing
- installs Claude Code

## Seekda work setup

After `setup.sh`, run `seekda-setup.sh` to:

- generate the Seekda GitHub SSH key (`~/.ssh/id_ed25519_seekda_github`)
- clone `seekda-main`
- write the Cursor MCP config (Jira/Atlassian + Pylon)

```bash
./seekda-setup.sh
```

## Companion private repo

This repo is the public install/bootstrap layer.

For machine-specific restore state like Claude, Codex, Raycast, Docker, and editor preferences, run the private companion repo after this setup completes.

## Private secrets

Put machine-specific secrets in:

```bash
~/.env.private
```
