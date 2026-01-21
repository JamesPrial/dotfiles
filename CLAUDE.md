# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository for cross-platform shell configuration (macOS and Linux). Manages zsh configuration, shell aliases, SSH config, and neovim config via a directory symlink at `~/.dotfiles` pointing to this repo's `.dotfiles/` directory.

## Key Commands

```bash
# Bootstrap on a new machine
curl -fsSL https://raw.githubusercontent.com/JamesPrial/dotfiles/main/.dotfiles/install.sh | sh

# Install to a specific location
./install.sh /path/to/destination
DOTFILES_TARGET=/path/to/dest curl -fsSL ... | sh

# Sync dotfiles (pulls latest and fixes permissions)
~/.dotfiles/sync.sh
```

## Symlink Structure

After installation:
```
~/.dotfiles -> <repo>/.dotfiles
~/.zshrc                           # Bootstrap file that sources ~/.dotfiles/zshrc
~/.ssh/config -> ~/.dotfiles/ssh/config
~/.config/nvim -> ~/.dotfiles/nvim
```

## Platform Detection

OS detected via `uname -s`:
- **macOS**: Homebrew, zplug from `/opt/homebrew/opt/zplug`
- **Debian/Ubuntu**: apt, zplug from `/usr/share/zplug`
- **RHEL/CentOS/Fedora**: dnf/yum

## Permissions

All files use owner-only permissions (700 for dirs/scripts, 600 for configs). Git hooks automatically run `fix-perms.sh`.

## Development

See `.dotfiles/CLAUDE.md` for development guidance (adding configs, testing changes, etc).
