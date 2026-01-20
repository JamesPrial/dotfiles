#!/bin/sh
# Sync dotfiles from GitHub and fix permissions
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/code/dotfiles}"

cd "$DOTFILES_DIR" || exit 1
git pull --ff-only origin main 2>/dev/null || true
"$DOTFILES_DIR/.dotfiles/fix-perms.sh"
