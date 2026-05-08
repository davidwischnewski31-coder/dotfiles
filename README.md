# dotfiles

Sanitized macOS shell environment and bootstrap script.

## Included

- `Brewfile`
- `.zprofile`
- `.zshrc`
- `.gitconfig`
- `.ssh/config.template`
- `setup.sh`
- `vault-restore.sh`
- `seekda-setup.sh`
- `npm-globals.sh`
- `upload-to-vault.sh`

## Full setup sequence (new machine)

```bash
# 1. Clone this repo
git clone https://github.com/davidwischnewski31-coder/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Install everything (Homebrew + all apps + shell config + Claude Code)
./setup.sh

# 3. Restore secrets from Vaultwarden (SSH keys, .env files)
bw config server https://vault.aspire.software
bw login
export BW_SESSION=$(bw unlock --raw)
./vault-restore.sh

# 4. Seekda work setup (clone seekda-main + Cursor MCP config)
./seekda-setup.sh

# 5. npm tools
./npm-globals.sh
```

## Manual steps after scripts

These can't be automated — do them once:

- [ ] `gh auth login` — authenticate GitHub CLI (personal account: `davidwischnewski31-coder`)
- [ ] `gh auth login` again for work account: `DavidSeekda`
- [ ] `gcloud auth login` — Google Cloud
- [ ] `git config --global user.name 'David Wischnewski'`
- [ ] `git config --global user.email 'david.wischnewski@seekda.com'`
- [ ] Open Cursor → Settings → Tools → MCP → connect Atlassian + Pylon (OAuth in browser)
- [ ] Open Obsidian → open vault → point to `~/davidai` (personal) or Seekda vault

## Key apps installed by Homebrew

- Bitwarden CLI (`bw`)
- Claude desktop
- Codex + Codexbar
- ChatGPT
- cmux
- Docker Desktop
- Granola
- Handy
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
- Ghostty

## Secrets management

Secrets live in Vaultwarden at `https://vault.aspire.software`.

**To push secrets from current machine to vault:**
```bash
export BW_SESSION=$(bw unlock --raw)
./upload-to-vault.sh
```

**Vault entries managed:**
- `dotfiles/ssh-personal` — `~/.ssh/id_ed25519`
- `dotfiles/ssh-seekda` — `~/.ssh/id_ed25519_seekda_github`
- `dotfiles/davidai-env` — `~/davidai/.env`
- `dotfiles/env-private` — `~/.env.private`

## What was intentionally left out

- The vault password itself (you need to remember this)
- Raycast / Cursor / VS Code extension configs
- Docker registry credentials
