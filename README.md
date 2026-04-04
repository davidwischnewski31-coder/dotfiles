# dotfiles

Sanitized macOS shell environment and bootstrap script.

## Included

- `Brewfile`
- `.zprofile`
- `.zshrc`
- `.gitconfig`
- `.ssh/config.template`
- `setup.sh`

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

## Private secrets

Put machine-specific secrets in:

```bash
~/.env.private
```
