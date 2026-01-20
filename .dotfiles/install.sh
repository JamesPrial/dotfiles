#!/bin/sh
# Dotfiles Bootstrap Script
# Usage: curl -fsSL https://raw.githubusercontent.com/JamesPrial/dotfiles/main/.dotfiles/install.sh | sh
#
# This script is safe to run multiple times (idempotent)

set -e

# Configuration
DOTFILES_REPO="https://github.com/JamesPrial/dotfiles.git"
DOTFILES_DIR="$HOME/code/dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Colors (only if terminal supports it)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

log_info()    { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_success() { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
log_warn()    { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
log_error()   { printf "${RED}[ERROR]${NC} %s\n" "$1" >&2; }

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Backup a file before replacing
backup_file() {
    file="$1"
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$file" "$BACKUP_DIR/"
        log_info "Backed up $file to $BACKUP_DIR/"
    fi
}

# Create a symlink, backing up existing file if needed
create_symlink() {
    src="$1"
    dest="$2"

    # If symlink already points to correct location, skip
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        log_success "Symlink already exists: $dest -> $src"
        return 0
    fi

    # Backup existing file if it's not a symlink
    backup_file "$dest"

    # Remove existing file/symlink
    rm -f "$dest"

    # Create symlink
    ln -s "$src" "$dest"
    log_success "Created symlink: $dest -> $src"
}

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin)
            OS="macos"
            log_info "Detected macOS"
            ;;
        Linux)
            if [ -f /etc/debian_version ]; then
                OS="debian"
                log_info "Detected Debian/Ubuntu Linux"
            elif [ -f /etc/redhat-release ]; then
                OS="redhat"
                log_info "Detected RHEL/CentOS/Fedora Linux"
            else
                OS="linux"
                log_warn "Detected unknown Linux distribution"
            fi
            ;;
        *)
            log_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
}

# Install Homebrew (macOS only)
install_homebrew() {
    if ! command_exists brew; then
        log_info "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for this session
        if [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        log_success "Homebrew installed"
    else
        log_success "Homebrew already installed"
    fi
}

# Install git
install_git() {
    if command_exists git; then
        log_success "git already installed"
        return 0
    fi

    log_info "Installing git..."
    case "$OS" in
        macos)
            xcode-select --install 2>/dev/null || true
            ;;
        debian)
            sudo apt-get update
            sudo apt-get install -y git
            ;;
        redhat)
            sudo dnf install -y git || sudo yum install -y git
            ;;
    esac
    log_success "git installed"
}

# Install zsh
install_zsh() {
    if command_exists zsh; then
        log_success "zsh already installed"
        return 0
    fi

    log_info "Installing zsh..."
    case "$OS" in
        macos)
            brew install zsh
            ;;
        debian)
            sudo apt-get update
            sudo apt-get install -y zsh
            ;;
        redhat)
            sudo dnf install -y zsh || sudo yum install -y zsh
            ;;
        *)
            log_error "Cannot install zsh on this platform automatically"
            exit 1
            ;;
    esac
    log_success "zsh installed"
}

# Install zplug
install_zplug() {
    log_info "Checking zplug..."

    case "$OS" in
        macos)
            if [ ! -d "/opt/homebrew/opt/zplug" ] && [ ! -d "/usr/local/opt/zplug" ]; then
                brew install zplug
                log_success "zplug installed via Homebrew"
            else
                log_success "zplug already installed"
            fi
            ;;
        debian)
            if [ ! -f "/usr/share/zplug/init.zsh" ]; then
                if apt-cache show zplug >/dev/null 2>&1; then
                    sudo apt-get install -y zplug
                    log_success "zplug installed via apt"
                else
                    log_info "zplug not in repos, installing via git..."
                    sudo mkdir -p /usr/share/zplug
                    sudo git clone https://github.com/zplug/zplug /usr/share/zplug
                    log_success "zplug installed via git clone"
                fi
            else
                log_success "zplug already installed"
            fi
            ;;
        *)
            if [ ! -d "$HOME/.zplug" ] && [ ! -f "/usr/share/zplug/init.zsh" ]; then
                git clone https://github.com/zplug/zplug "$HOME/.zplug"
                log_warn "zplug installed to ~/.zplug - you may need to update .zshrc paths"
            else
                log_success "zplug already installed"
            fi
            ;;
    esac
}

# Install fzf
install_fzf() {
    if command_exists fzf; then
        log_success "fzf already installed"
        return 0
    fi

    log_info "Installing fzf..."
    case "$OS" in
        macos)
            brew install fzf
            # Install key bindings and completion non-interactively
            "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish </dev/null
            ;;
        debian)
            sudo apt-get install -y fzf
            ;;
        redhat)
            sudo dnf install -y fzf || sudo yum install -y fzf
            ;;
        *)
            log_warn "Cannot install fzf automatically on this platform"
            return 1
            ;;
    esac
    log_success "fzf installed"
}

# Install NVM (Node Version Manager)
install_nvm() {
    if [ -d "$HOME/.nvm" ]; then
        log_success "NVM already installed"
        return 0
    fi

    log_info "Installing NVM..."
    PROFILE=/dev/null curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

    # Source NVM for this session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    log_success "NVM installed"
    log_info "To install Node.js, run: nvm install --lts"
}

# Install Go
install_go() {
    if command_exists go; then
        log_success "Go already installed: $(go version)"
        return 0
    fi

    log_info "Installing Go..."
    case "$OS" in
        macos)
            brew install go
            ;;
        debian)
            sudo apt-get install -y golang
            ;;
        redhat)
            sudo dnf install -y golang || sudo yum install -y golang
            ;;
        *)
            log_warn "Cannot install Go automatically on this platform"
            log_info "Download from: https://go.dev/dl/"
            return 1
            ;;
    esac
    log_success "Go installed"
}

# Install all dependencies
install_dependencies() {
    log_info "Installing dependencies..."

    case "$OS" in
        macos)
            install_homebrew
            ;;
    esac

    install_git
    install_zsh
    install_zplug
    install_fzf
    install_nvm
    install_go
}

# Clone or update the dotfiles repository
clone_repo() {
    log_info "Setting up dotfiles repository..."

    # Create ~/code directory if needed
    if [ ! -d "$HOME/code" ]; then
        mkdir -p "$HOME/code"
        log_info "Created ~/code directory"
    fi

    # Clone or update repository
    if [ -d "$DOTFILES_DIR" ]; then
        if [ -d "$DOTFILES_DIR/.git" ]; then
            log_info "Dotfiles already cloned, updating..."
            cd "$DOTFILES_DIR"
            git pull --ff-only || log_warn "Could not update dotfiles (local changes?)"
            cd - >/dev/null
        else
            log_error "$DOTFILES_DIR exists but is not a git repository"
            exit 1
        fi
    else
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        log_success "Cloned dotfiles to $DOTFILES_DIR"
    fi
}

# Set up symlinks
setup_symlinks() {
    log_info "Setting up symlinks..."

    # Main .zshrc symlink
    create_symlink "$DOTFILES_DIR/.dotfiles/.zshrc" "$HOME/.zshrc"

    # Bash aliases
    create_symlink "$DOTFILES_DIR/.dotfiles/.bash_aliases" "$HOME/.bash_aliases"

    # SSH config
    if [ -f "$DOTFILES_DIR/.dotfiles/ssh/config" ]; then
        # Ensure ~/.ssh exists with proper permissions
        if [ ! -d "$HOME/.ssh" ]; then
            mkdir -p "$HOME/.ssh"
            chmod 700 "$HOME/.ssh"
            log_info "Created ~/.ssh directory"
        fi

        create_symlink "$DOTFILES_DIR/.dotfiles/ssh/config" "$HOME/.ssh/config"

        # Ensure proper permissions on ssh config
        chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
    fi

    # NOTE: We do NOT symlink ssh/id_ed25519 - it's a placeholder
}

# Set up git hooks to fix permissions after pulls
setup_hooks() {
    log_info "Setting up git hooks..."

    hooks_dir="$DOTFILES_DIR/.git/hooks"

    # Create post-merge hook
    cat > "$hooks_dir/post-merge" << 'EOF'
#!/bin/sh
"$HOME/code/dotfiles/.dotfiles/fix-perms.sh"
EOF
    chmod +x "$hooks_dir/post-merge"

    # Create post-checkout hook
    cat > "$hooks_dir/post-checkout" << 'EOF'
#!/bin/sh
"$HOME/code/dotfiles/.dotfiles/fix-perms.sh"
EOF
    chmod +x "$hooks_dir/post-checkout"

    log_success "Git hooks installed"

    # Run fix-perms now
    if [ -x "$DOTFILES_DIR/.dotfiles/fix-perms.sh" ]; then
        "$DOTFILES_DIR/.dotfiles/fix-perms.sh"
        log_success "Permissions fixed"
    fi
}

# Set up cron job for startup sync (optional)
setup_cron() {
    log_info "Checking cron setup..."

    cron_entry="@reboot $DOTFILES_DIR/.dotfiles/sync.sh"

    # Check if already set up
    if crontab -l 2>/dev/null | grep -q "sync.sh"; then
        log_success "Cron job already configured"
        return 0
    fi

    # Ask user if they want cron
    printf "${YELLOW}Would you like to sync dotfiles on startup? [y/N] ${NC}"
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY])
            (crontab -l 2>/dev/null || true; echo "$cron_entry") | crontab -
            log_success "Cron job added for startup sync"
            ;;
        *)
            log_info "Skipping cron setup"
            ;;
    esac
}

# Switch default shell to zsh
switch_to_zsh() {
    zsh_path="$(command -v zsh)"

    # Check if zsh is already the default shell
    if [ "$SHELL" = "$zsh_path" ]; then
        log_success "zsh is already the default shell"
        return 0
    fi

    log_info "Switching default shell to zsh..."

    # Ensure zsh is in /etc/shells
    if ! grep -q "^$zsh_path$" /etc/shells 2>/dev/null; then
        log_info "Adding $zsh_path to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    # Try to change shell
    if command_exists chsh; then
        if chsh -s "$zsh_path" 2>/dev/null; then
            log_success "Default shell changed to zsh"
        else
            log_warn "Could not change shell with chsh (may require password)"
            log_info "To change manually, run: chsh -s $zsh_path"

            # Fallback: Add exec zsh to .profile
            if [ -f "$HOME/.profile" ] && ! grep -q "exec zsh" "$HOME/.profile" 2>/dev/null; then
                printf '\n# Start zsh if available\nif [ -x "$(command -v zsh)" ]; then exec zsh; fi\n' >> "$HOME/.profile"
                log_info "Added zsh exec to ~/.profile as fallback"
            fi
        fi
    else
        log_warn "chsh not found - cannot change default shell"
        log_info "To change manually, edit /etc/passwd or use usermod"
    fi
}

# Post-installation summary
post_install() {
    echo ""
    echo "=========================================="
    log_success "Dotfiles installation complete!"
    echo "=========================================="
    echo ""
    echo "What was set up:"
    echo "  - Dotfiles cloned to: $DOTFILES_DIR"
    echo "  - Symlinked: ~/.zshrc"
    echo "  - Symlinked: ~/.bash_aliases"
    [ -L "$HOME/.ssh/config" ] && echo "  - Symlinked: ~/.ssh/config"
    echo "  - Git hooks: permissions auto-fix on pull"
    echo ""
    echo "Installed:"
    command_exists zsh && echo "  - zsh: $(zsh --version 2>&1 | head -1)"
    command_exists fzf && echo "  - fzf: $(fzf --version 2>&1 | head -1)"
    [ -d "$HOME/.nvm" ] && echo "  - nvm: installed"
    command_exists go && echo "  - go: $(go version 2>&1)"
    echo "  - zplug: installed"
    echo ""

    if [ -d "$BACKUP_DIR" ]; then
        echo "Backups saved to: $BACKUP_DIR"
        echo ""
    fi

    echo "To start using zsh now, run:"
    echo "  exec zsh"
    echo ""
    echo "On first run, zplug will prompt to install plugins."
    echo ""
}

# Main execution
main() {
    echo ""
    echo "=========================================="
    echo "  Dotfiles Bootstrap Script"
    echo "  https://github.com/JamesPrial/dotfiles"
    echo "=========================================="
    echo ""

    # Ensure we're not running as root
    if [ "$(id -u)" = "0" ]; then
        log_error "Do not run this script as root"
        exit 1
    fi

    detect_os
    install_dependencies
    clone_repo
    setup_symlinks
    setup_hooks
    switch_to_zsh
    setup_cron
    post_install
}

main "$@"
