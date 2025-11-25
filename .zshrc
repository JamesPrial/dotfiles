
. "$HOME/.local/bin/env"
export PATH="$HOME/.npm-global/bin:$PATH"

alias venv="python3 -m venv .venv && source .venv/bin/activate"

alias claude="$HOME/.claude/local/claude"

# Added by Antigravity (added env vars by james)
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

eval "$(direnv hook zsh)"