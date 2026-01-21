# Aliases
if [[ "$(uname)" == "Darwin" ]]; then
    alias ls='ls -G'
    alias ll='ls -lahG'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
fi
alias grep='grep --color=auto'
alias ec="$EDITOR $HOME/.zshrc" # edit .zshrc
alias sc="source $HOME/.zshrc"  # reload zsh configuration
alias tree='nocorrect tree'

alias shawn="(cd $HOME/code/shawnbot && npm install && npm start)"

alias mkvenv="python3 -m venv .venv"
alias venv='[ -d .venv ] || mkvenv; source .venv/bin/activate'

# cdir - create directory with optional permissions and cd into it
cdir() {
    if [ -z "$1" ]; then
        echo "Usage: cdir <directory> [permissions]" >&2
        return 1
    fi
    mkdir -p "$1" || return 1
    [ -n "$2" ] && chmod "$2" "$1"
    cd "$1"
}
