#!/bin/bash
set -e

# Dotfiles installation script for devcontainers
# Installs Oh My Zsh, Powerlevel10k, and configures the shell environment

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info() {
    echo "[INFO] $1"
}

log_success() {
    echo "[OK]   $1"
}

log_warn() {
    echo "[WARN] $1"
}

# Detect package manager and install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    
    if command -v apt-get &> /dev/null; then
        log_info "Installing dependencies via apt..."
        sudo apt-get update -qq
        sudo apt-get install -y -qq zsh git curl wget fontconfig
    elif command -v apk &> /dev/null; then
        log_info "Installing dependencies via apk..."
        sudo apk add --no-cache zsh git curl wget fontconfig
    elif command -v yum &> /dev/null; then
        log_info "Installing dependencies via yum..."
        sudo yum install -y -q zsh git curl wget fontconfig
    elif command -v dnf &> /dev/null; then
        log_info "Installing dependencies via dnf..."
        sudo dnf install -y -q zsh git curl wget fontconfig
    else
        log_warn "Could not detect package manager, skipping dependency installation"
        return
    fi
    
    log_success "Dependencies installed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Installing Oh My Zsh..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh installed"
    else
        log_success "Oh My Zsh already installed"
    fi
}

# Install Powerlevel10k theme
install_powerlevel10k() {
    local P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [ ! -d "$P10K_DIR" ]; then
        log_info "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
        log_success "Powerlevel10k installed"
    else
        log_success "Powerlevel10k already installed"
    fi
}

# Install zsh-autosuggestions plugin
install_autosuggestions() {
    local PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    if [ ! -d "$PLUGIN_DIR" ]; then
        log_info "Installing zsh-autosuggestions plugin..."
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR"
        log_success "zsh-autosuggestions installed"
    else
        log_success "zsh-autosuggestions already installed"
    fi
}

# Install zsh-syntax-highlighting plugin
install_syntax_highlighting() {
    local PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    if [ ! -d "$PLUGIN_DIR" ]; then
        log_info "Installing zsh-syntax-highlighting plugin..."
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR"
        log_success "zsh-syntax-highlighting installed"
    else
        log_success "zsh-syntax-highlighting already installed"
    fi
}

# Link dotfiles
link_dotfiles() {
    log_info "Linking configuration files..."
    
    # Backup existing files if they exist and aren't symlinks
    for file in .zshrc .p10k.zsh; do
        if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            log_info "Backing up existing $file to $file.backup"
            mv "$HOME/$file" "$HOME/$file.backup"
        fi
    done
    
    # Create symlinks
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
    
    log_success "Configuration files linked"
}

# Set zsh as default shell and configure bash to launch zsh
configure_shell() {
    log_info "Configuring shell..."
    
    # Try to set zsh as default shell
    if command -v chsh &> /dev/null; then
        sudo chsh -s "$(which zsh)" "$(whoami)" 2>/dev/null || true
    fi
    
    # Add zsh launch to .bashrc for seamless devcontainer integration
    local BASHRC="$HOME/.bashrc"
    local ZSH_LAUNCH_MARKER="# >>> oh-my-zsh-dotfiles >>>"
    
    if [ -f "$BASHRC" ]; then
        # Remove any existing dotfiles integration
        if grep -q "$ZSH_LAUNCH_MARKER" "$BASHRC" 2>/dev/null; then
            sed -i "/$ZSH_LAUNCH_MARKER/,/# <<< oh-my-zsh-dotfiles <<</d" "$BASHRC" 2>/dev/null || true
        fi
    fi
    
    # Add zsh auto-launch to bashrc
    cat >> "$BASHRC" << 'EOF'

# >>> oh-my-zsh-dotfiles >>>
# Automatically switch to zsh if available and we're in an interactive session
if [ -t 1 ] && [ -x "$(command -v zsh)" ] && [ -z "$ZSH_VERSION" ]; then
    exec zsh -l
fi
# <<< oh-my-zsh-dotfiles <<<
EOF
    
    log_success "Shell configured to use zsh"
}

# Main installation
main() {
    echo ""
    echo "========================================"
    echo "  Oh My Zsh + Powerlevel10k Setup"
    echo "========================================"
    echo ""
    
    install_dependencies
    install_oh_my_zsh
    install_powerlevel10k
    install_autosuggestions
    install_syntax_highlighting
    link_dotfiles
    configure_shell
    
    echo ""
    echo "========================================"
    echo "  Setup Complete"
    echo "========================================"
    echo ""
    echo "Start a new terminal session to apply changes."
    echo ""
    echo "For best results, use a Nerd Font in your terminal."
    echo "Recommended: MesloLGS NF"
    echo "https://github.com/romkatv/powerlevel10k#fonts"
    echo ""
}

main "$@"
