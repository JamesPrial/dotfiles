# Set path if required
export PATH="$GOPATH/bin:/usr/local/go/bin:$PATH"


export PATH="$HOME/.local/bin:$PATH"

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias ec="$EDITOR $HOME/.zshrc" # edit .zshrc
alias sc="source $HOME/.zshrc"  # reload zsh configuration
alias tree='nocorrect tree'
alias shawn="(cd $HOME/code/shawnbot && npm install && npm start)"
alias venv="python3 -m venv .venv && source .venv/bin/activate"

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

setopt histignorealldups sharehistory
setopt autocd              # cd by typing directory name
setopt correct             # command spelling correction
setopt interactivecomments # allow comments in interactive shell

# Keep 10000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_EXPIRE_DUPS_FIRST  # expire duplicates first
setopt HIST_IGNORE_SPACE       # don't record commands starting with space
setopt HIST_VERIFY             # show command before executing from history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# zplug - manage plugins
source /usr/share/zplug/init.zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/command-not-found", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-completions"
zplug "themes/robbyrussell", from:oh-my-zsh, as:theme   # Theme

# zplug - install/load new plugins when zsh is started or reloaded
if ! zplug check; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
zplug load

# fzf key bindings and completion
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
