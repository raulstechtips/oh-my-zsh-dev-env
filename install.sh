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

# Run command with elevated privileges if needed
run_privileged() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo &> /dev/null; then
        sudo "$@"
    else
        log_warn "Need root privileges but sudo not available"
        return 1
    fi
}

# Detect package manager and install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    
    if command -v apt-get &> /dev/null; then
        log_info "Installing dependencies via apt..."
        run_privileged apt-get update -qq
        run_privileged apt-get install -y -qq zsh git curl wget fontconfig tmux
    elif command -v apk &> /dev/null; then
        log_info "Installing dependencies via apk..."
        run_privileged apk add --no-cache zsh git curl wget fontconfig tmux
    elif command -v yum &> /dev/null; then
        log_info "Installing dependencies via yum..."
        run_privileged yum install -y -q zsh git curl wget fontconfig tmux
    elif command -v dnf &> /dev/null; then
        log_info "Installing dependencies via dnf..."
        run_privileged dnf install -y -q zsh git curl wget fontconfig tmux
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

# Install Tmux Plugin Manager (TPM)
install_tpm() {
    local TPM_DIR="$HOME/.tmux/plugins/tpm"
    if [ ! -d "$TPM_DIR" ]; then
        log_info "Installing Tmux Plugin Manager..."
        git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
        log_success "TPM installed"
    else
        log_success "TPM already installed"
    fi
}

# Install Tmux plugins
install_tmux_plugins() {
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        log_info "Installing tmux plugins..."
        # Run TPM plugin installer
        "$HOME/.tmux/plugins/tpm/bin/install_plugins"
        log_success "Tmux plugins installed"
    else
        log_warn "TPM not found, skipping plugin installation"
    fi
}

# Link dotfiles
link_dotfiles() {
    log_info "Linking configuration files..."
    
    # Backup existing files if they exist and aren't symlinks
    for file in .zshrc .p10k.zsh .tmux.conf; do
        if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            log_info "Backing up existing $file to $file.backup"
            mv "$HOME/$file" "$HOME/$file.backup"
        fi
    done
    
    # Create symlinks
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
    ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
    
    log_success "Configuration files linked"
}

# Configure tmux to use the correct zsh path
configure_tmux_shell() {
    local ZSH_PATH
    ZSH_PATH=$(which zsh)
    
    if [ -z "$ZSH_PATH" ]; then
        log_warn "Could not find zsh path, tmux may not use zsh"
        return
    fi
    
    log_info "Configuring tmux to use zsh at: $ZSH_PATH"
    
    # Update tmux.conf with the correct zsh path
    if [ -f "$HOME/.tmux.conf" ]; then
        # Check if the line already exists
        if grep -q "^set-option -g default-shell" "$HOME/.tmux.conf"; then
            # Update existing line
            if command -v sed &> /dev/null; then
                sed -i.bak "s|^set-option -g default-shell.*|set-option -g default-shell $ZSH_PATH|" "$HOME/.tmux.conf"
                rm -f "$HOME/.tmux.conf.bak"
            fi
        else
            # Add line at the beginning
            echo "set-option -g default-shell $ZSH_PATH" | cat - "$HOME/.tmux.conf" > "$HOME/.tmux.conf.tmp"
            mv "$HOME/.tmux.conf.tmp" "$HOME/.tmux.conf"
        fi
        log_success "Tmux configured to use zsh at $ZSH_PATH"
    fi
}

# Set zsh as default shell and configure bash to launch zsh
configure_shell() {
    log_info "Configuring shell..."
    
    # Try to set zsh as default shell
    if command -v chsh &> /dev/null; then
        run_privileged chsh -s "$(which zsh)" "$(whoami)" 2>/dev/null || true
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
    install_tpm
    link_dotfiles
    configure_tmux_shell
    install_tmux_plugins
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
