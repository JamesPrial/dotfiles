# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Utility scripts added to PATH via `zshrc`. Scripts here are available as commands after shell reload.

## Directory Structure

- `bin/` - General utilities (direct commands)
- `bin/claude/` - Claude Code wrapper scripts

Both directories are in PATH: `$HOME/.dotfiles/bin/claude:$HOME/.dotfiles/bin`

## Adding New Scripts

1. Create executable script (no extension needed for shell scripts)
2. Add shebang (`#!/usr/bin/env bash` or `#!/bin/sh`)
3. Make executable: `chmod 700 <script>`
4. Reload shell: `source ~/.zshrc`

## Existing Scripts

- `claude/push [msg]` - Commits and pushes using Claude Code with conventional commit format. Optional message arg defaults to "commit and push all changes".

## Claude Code Wrappers

Scripts in `claude/` invoke `claude` CLI with preconfigured options:
```bash
claude --model haiku \
  --allowedTools Bash,Read \
  --append-system-prompt "..." \
  -p "${1:-default prompt}"
```

Pattern: `--model haiku` for fast/cheap operations, restrict tools to minimum needed.
