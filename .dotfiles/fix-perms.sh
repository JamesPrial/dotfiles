#!/bin/sh
# Fix permissions on dotfiles - owner-only access
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/code/dotfiles}"
DF="$DOTFILES_DIR/.dotfiles"

# Directories: 700
chmod 700 "$DF" 2>/dev/null
chmod 700 "$DF/ssh" 2>/dev/null

# Executables: 700
chmod 700 "$DF/fix-perms.sh" 2>/dev/null
chmod 700 "$DF/install.sh" 2>/dev/null
chmod 700 "$DF/sync.sh" 2>/dev/null
chmod 700 "$DF/cdir.sh" 2>/dev/null

# Config files: 600
chmod 600 "$DF/.zshrc" 2>/dev/null
chmod 600 "$DF/.bash_aliases" 2>/dev/null
chmod 600 "$DF/ssh/config" 2>/dev/null
chmod 600 "$DF/ssh/id_ed25519" 2>/dev/null

# Also fix symlink targets in $HOME
[ -f "$HOME/.zshrc" ] && chmod 600 "$HOME/.zshrc" 2>/dev/null
[ -f "$HOME/.ssh/config" ] && chmod 600 "$HOME/.ssh/config" 2>/dev/null
[ -d "$HOME/.ssh" ] && chmod 700 "$HOME/.ssh" 2>/dev/null
