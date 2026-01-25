# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Utility scripts added to PATH via `zshrc`. Scripts here are available as commands after shell reload.

## Directory Structure

- `bin/` - Main dotfiles management scripts (dotfiles-install, dotfiles-sync, dotfiles-fix-perms)
- `claudescripts/` - Claude Code wrapper scripts (separate directory at repo root, symlinked to `~/.claudescripts`)

PATH includes: `$HOME/.claudescripts:$HOME/.dotfiles/bin`

## Adding New Scripts

1. Create executable script (no extension needed for shell scripts)
2. Add shebang (`#!/usr/bin/env bash` or `#!/bin/sh`)
3. Add chmod line to `bin/dotfiles-fix-perms`
4. Reload shell: `source ~/.zshrc`

## Existing Scripts

- `dotfiles-install` - Bootstrap script for new machines
- `dotfiles-sync` - Pull latest and fix permissions
- `dotfiles-fix-perms` - Fix file permissions
- `actions-fails` - Check workspace repos for GitHub Actions failures (JSON output)

Claude Code wrappers are in `claudescripts/`:
- `push` - Quick commit/push (Haiku)
- `ghcli` - GitHub CLI operations (Sonnet)
- `support` - Bash debugging (Opus)
