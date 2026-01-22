# Set path if required
export PATH="$GOPATH/bin:/usr/local/go/bin:$PATH"

export PATH="$HOME/.nvm/versions/node/v25.4.0/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

# Dotfiles scripts
export PATH="$HOME/.claudescripts:$HOME/.dotfiles/bin:$HOME/.dotfiles:$PATH"

# Load aliases and functions
[ -f ~/.dotfiles/bash_aliases ] && source ~/.dotfiles/bash_aliases
[ -f ~/.dotfiles/sh_functions ] && source ~/.dotfiles/sh_functions

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
if [[ "$(uname)" == "Darwin" ]]; then
    export ZPLUG_HOME=/opt/homebrew/opt/zplug
    source $ZPLUG_HOME/init.zsh
else
    source /usr/share/zplug/init.zsh
fi
zplug "hcgraf/zsh-sudo"
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
if [[ "$(uname)" == "Darwin" ]]; then
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
else
    [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Auto-fetch git repos silently in background on new terminal
(git-fetch-all &) >/dev/null 2>&1

# Check for git updates on demand
alias gfu='git-fetch-all'
