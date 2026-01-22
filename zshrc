# Go paths - add if they exist
[[ -d "$HOME/go/bin" ]] && export PATH="$HOME/go/bin:$PATH"
[[ -d "/usr/local/go/bin" ]] && export PATH="/usr/local/go/bin:$PATH"
[[ -n "$PREFIX" && -d "$PREFIX/bin" ]] && export PATH="$PREFIX/bin:$PATH"

export PATH="$HOME/.nvm/versions/node/v25.4.0/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

# Dotfiles scripts
export PATH="$HOME/.dotfiles/bin:$HOME/.dotfiles:$PATH"

# Load Claude Code configuration
[ -f ~/.dotfiles/claudescripts/profile ] && source ~/.dotfiles/claudescripts/profile

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

# zplug - check user install first, then system paths
if [[ -f "$HOME/.zplug/init.zsh" ]]; then
    source "$HOME/.zplug/init.zsh"
elif [[ "$(uname -s)" == "Darwin" ]]; then
    if [[ -f "/opt/homebrew/opt/zplug/init.zsh" ]]; then
        source /opt/homebrew/opt/zplug/init.zsh
    fi
elif [[ -f "/usr/share/zplug/init.zsh" ]]; then
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

# fzf - check multiple possible locations
if [[ -f "$HOME/.fzf.zsh" ]]; then
    source "$HOME/.fzf.zsh"
elif [[ -n "$PREFIX" && -d "$PREFIX/share/fzf" ]]; then
    # Termux
    [[ -f "$PREFIX/share/fzf/completion.zsh" ]] && source "$PREFIX/share/fzf/completion.zsh"
    [[ -f "$PREFIX/share/fzf/key-bindings.zsh" ]] && source "$PREFIX/share/fzf/key-bindings.zsh"
elif [[ -d "/usr/share/doc/fzf/examples" ]]; then
    # Debian/Ubuntu
    source /usr/share/doc/fzf/examples/completion.zsh
    source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Auto-fetch git repos silently in background on new terminal
(git-fetch-all &) >/dev/null 2>&1

# Check for git updates on demand
alias gfu='git-fetch-all'
