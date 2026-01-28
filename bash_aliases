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

alias tl="tree -L"

alias shawn="(cd $HOME/code/shawnbot && npm install && npm start)"
alias reshawn='(ssh james@cb "pm2 restart shawnbot")'

alias mkvenv="python3 -m venv .venv"
alias venv='[ -d .venv ] || mkvenv; source .venv/bin/activate'

# open VSCode in a new window in cwd
alias c="code -n ."

# GitHub Actions failures checker
alias af="$HOME/.dotfiles/bin/actions-fails"

# Dotfiles installer
alias di="$HOME/.dotfiles/bin/dotfiles-install"

# git switch -c <branch> main
alias gnb="$HOME/.dotfiles/bin/git-new-branch"

# Programmer's calculator suite
alias calc="$HOME/.dotfiles/bin/bash-calc"
alias ceval="$HOME/.dotfiles/bin/bash-calc-eval"
alias cconv="$HOME/.dotfiles/bin/bash-calc-convert"

