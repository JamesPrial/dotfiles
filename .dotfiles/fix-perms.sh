#!/bin/sh
# Fix permissions on dotfiles - owner-only access

# Use ~/.dotfiles symlink (works regardless of repo location)
DF="$HOME/.dotfiles"

# Fallback: if ~/.dotfiles doesn't exist, try DOTFILES_DIR
if [ ! -d "$DF" ] && [ -n "$DOTFILES_DIR" ]; then
    DF="$DOTFILES_DIR/.dotfiles"
fi

# Directories: 700
chmod 700 "$DF" 2>/dev/null
chmod 700 "$DF/ssh" 2>/dev/null

# Executables: 700
chmod 700 "$DF/fix-perms.sh" 2>/dev/null
chmod 700 "$DF/install.sh" 2>/dev/null
chmod 700 "$DF/sync.sh" 2>/dev/null

# Config files: 600 (no dot prefix)
chmod 600 "$DF/zshrc" 2>/dev/null
chmod 600 "$DF/bash_aliases" 2>/dev/null
chmod 600 "$DF/sh_functions" 2>/dev/null
chmod 600 "$DF/ssh/config" 2>/dev/null
chmod 600 "$DF/ssh/id_ed25519" 2>/dev/null

# Neovim config
chmod 700 "$DF/nvim" 2>/dev/null
find "$DF/nvim" -type d -exec chmod 700 {} \; 2>/dev/null
find "$DF/nvim" -type f -exec chmod 600 {} \; 2>/dev/null

# Home directory files
[ -f "$HOME/.zshrc" ] && chmod 600 "$HOME/.zshrc" 2>/dev/null
[ -f "$HOME/.ssh/config" ] && chmod 600 "$HOME/.ssh/config" 2>/dev/null
[ -d "$HOME/.ssh" ] && chmod 700 "$HOME/.ssh" 2>/dev/null
