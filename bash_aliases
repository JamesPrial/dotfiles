# Aliases
if [[ "$(uname)" == "Darwin" ]]; then
    alias ls='ls -G'
    alias ll='ls -lahG'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
fi
alias grep='grep --color=auto'
alias ec="$EDITOR $HOME/.dotfiles/zshrc" # edit zshrc
alias sc="source $HOME/.zshrc"  # reload zsh configuration
alias tree='nocorrect tree'

alias shawn="(cd $HOME/code/shawnbot && npm install && npm start)"

alias mkvenv="python3 -m venv .venv"
alias venv='[ -d .venv ] || mkvenv; source .venv/bin/activate'

# VSCode alias - only on desktop platforms where code is available
if command -v code >/dev/null 2>&1; then
    alias c="code -n ."
fi

# Termux/Android-specific aliases
if [[ -n "$TERMUX_VERSION" ]]; then
    # open files with default Android app (requires termux-api package)
    if command -v termux-open >/dev/null 2>&1; then
        alias open='termux-open'
    fi
fi
