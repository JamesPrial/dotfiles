#!/bin/sh
# Sync dotfiles from GitHub and fix permissions

# Resolve the actual repo location from the symlink
if [ -L "$HOME/.dotfiles" ]; then
    DOTFILES_DIR="$(dirname "$(readlink -f "$HOME/.dotfiles")")"
else
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/code/dotfiles}"
fi

cd "$DOTFILES_DIR" || exit 1
git pull --ff-only origin main 2>/dev/null || true
"$HOME/.dotfiles/fix-perms.sh"
