# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository for cross-platform shell configuration (macOS and Linux). Manages zsh configuration, shell aliases, SSH config, and neovim config via a directory symlink at `~/.dotfiles` pointing to this repo.

## Key Commands

```bash
# Bootstrap on a new machine
curl -fsSL https://raw.githubusercontent.com/JamesPrial/dotfiles/main/bin/dotfiles-install | sh

# Install to a specific location
./bin/dotfiles-install /path/to/destination
DOTFILES_TARGET=/path/to/dest curl -fsSL ... | sh

# Sync dotfiles (pulls latest and fixes permissions)
~/.dotfiles/bin/dotfiles-sync
```

## Symlink Structure

After installation:
```
~/.dotfiles -> <repo>
~/.zshrc                           # Bootstrap file that sources ~/.dotfiles/zshrc
~/.ssh/config -> ~/.dotfiles/ssh/config
~/.config/nvim -> ~/.dotfiles/nvim
~/.claudescripts -> ~/.dotfiles/claudescripts
```

## Platform Detection

OS detected via `uname -s`:
- **macOS**: Homebrew, zplug from `/opt/homebrew/opt/zplug`
- **Debian/Ubuntu**: apt, zplug from `/usr/share/zplug`
- **RHEL/CentOS/Fedora**: dnf/yum

## Permissions

All files use owner-only permissions (700 for dirs/scripts, 600 for configs). Git hooks automatically run `bin/dotfiles-fix-perms`.

## Cross-Platform Patterns

- Shebang: `#!/usr/bin/env bash` (not `#!/bin/bash`)
- JSON parsing fallback: `sed` (not `grep -oP` - unavailable on macOS)
- Use `uname -s` for OS detection, not `/etc/os-release` alone

## Testing

```bash
# Run all bats tests
bats bin/tests/

# Run specific test file
bats bin/tests/test-actions-fails.bats

# Reload shell config (manual testing)
source ~/.zshrc
```

CI runs on both macOS and Linux via GitHub Actions (`.github/workflows/test.yml`).

## Scripts

Core scripts in `bin/`:
- `dotfiles-install` - Idempotent bootstrap (safe to re-run)
- `dotfiles-sync` - Pulls latest and fixes permissions
- `dotfiles-fix-perms` - Sets 700 for dirs/scripts, 600 for configs
- `actions-fails` - Check workspace repos for GitHub Actions failures (alias: `af`)
- `bash-calc` - Programmer's calculator with `ceval` (expressions) and `cconv` (base conversion)

Claude Code wrappers in `claudescripts/` (symlinked to `~/.claudescripts`):
- `push` - Quick commit/push (Haiku)
- `ghcli` - GitHub CLI operations (Sonnet)
- `support` - Bash debugging with web search (Opus)
- `askclaude` - Quick bash Q&A (Haiku)

## Claude Code Configuration

- `.claude/agents/` - Custom subagent definitions
- `.claude/skills/` - Project-specific skills
- `.claude/todos.json` - task tracking

## Required: Use dotfiles-development Skill

**ALWAYS invoke the `dotfiles-development` skill when working in this repo.** The skill contains authoritative guidance for agent selection, testing, permissions, and bash patterns. CLAUDE.md is intentionally minimal - the skill is the source of truth.
