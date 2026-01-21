# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

See `../CLAUDE.md` for repository overview, installation, and symlink structure.

## Scripts

- `install.sh` - Idempotent bootstrap (safe to re-run). Installs: zsh, zplug, fzf, nvm, go
- `sync.sh` - Pulls latest from origin and runs fix-perms
- `fix-perms.sh` - Sets 700 for dirs/scripts, 600 for configs. Run after adding new files.

## Adding New Config Files

1. Add the file to this directory (no dot prefix needed)
2. Add chmod line to `fix-perms.sh`
3. If it needs a symlink, add to `setup_symlinks()` in `install.sh`

## Adding New Shell Aliases/Functions

- Aliases go in `bash_aliases`
- Functions go in `sh_functions`
- Both are sourced by `zshrc`

## Testing Changes

```bash
# Reload shell config without restarting
source ~/.zshrc

# Test install script changes (safe - idempotent)
./install.sh

# Verify permissions
ls -la
```

## Platform-Specific Code

Use `uname -s` for detection:
```bash
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
else
    # Linux
fi
```

For package installation in `install.sh`, use the `$OS` variable set by `detect_os()`.
