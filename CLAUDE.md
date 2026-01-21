# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository for cross-platform shell configuration (macOS and Linux). Manages zsh configuration, shell aliases, and SSH config via symlinks from `~/.zshrc`, `~/.bash_aliases`, and `~/.ssh/config` to files in this repo.

## Key Commands

```bash
# Bootstrap on a new machine (installs deps, clones repo, creates symlinks)
curl -fsSL https://raw.githubusercontent.com/JamesPrial/dotfiles/main/.dotfiles/install.sh | sh

# Sync dotfiles (pulls latest and fixes permissions)
.dotfiles/sync.sh

# Fix file permissions manually
.dotfiles/fix-perms.sh
```

## Repository Structure

- `.dotfiles/` - The actual configuration files
  - `install.sh` - Idempotent bootstrap script (installs zsh, fzf, nvm, go, zplug)
  - `sync.sh` - Pulls updates and runs fix-perms
  - `fix-perms.sh` - Sets owner-only permissions (700 for dirs/scripts, 600 for configs)
  - `.zshrc` - Zsh configuration with zplug plugins
  - `.bash_aliases` - Shell aliases (sourced by zshrc)
  - `ssh/config` - SSH host configurations
  - `ssh/id_ed25519` - Placeholder only (actual keys are NOT stored in repo)

## Platform Detection

The install script and configs detect OS via `uname -s`:
- **macOS**: Uses Homebrew for package management, zplug from `/opt/homebrew/opt/zplug`
- **Debian/Ubuntu**: Uses apt, zplug from `/usr/share/zplug`
- **RHEL/CentOS/Fedora**: Uses dnf/yum

## Permissions Model

All files in `.dotfiles/` use owner-only permissions enforced by `fix-perms.sh`:
- Directories and scripts: `700`
- Config files: `600`

Git hooks (`post-merge`, `post-checkout`) automatically run `fix-perms.sh` after pulls.

## Zplug Plugins

The zshrc uses these zplug plugins:
- zsh-sudo, command-not-found, zsh-syntax-highlighting
- zsh-autosuggestions, zsh-history-substring-search, zsh-completions
- robbyrussell theme
