#!/bin/bash

# Unified dotfiles setup script - works on macOS, Linux, and Termux

set -e

# Colors
G='\033[1;32m'
Y='\033[1;33m'
R='\033[1;31m'
NC='\033[0m'

log() { echo -e "${G}[*]${NC} $1"; }
warn() { echo -e "${Y}[!]${NC} $1"; }
err() { echo -e "${R}[x]${NC} $1"; exit 1; }

DOTS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Detect platform
if [ -n "$TERMUX_VERSION" ]; then
    PLATFORM="termux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
else
    PLATFORM="linux"
fi

log "Detected platform: $PLATFORM"

# Clone only if directory doesn't exist
safe_clone() {
    local repo="$1"
    local dest="$2"
    if [ -d "$dest" ]; then
        warn "$dest already exists, skipping"
    else
        log "Cloning $repo..."
        git clone --depth 1 "$repo" "$dest"
    fi
}

# ============================================
# Platform-specific package installation
# ============================================

install_packages() {
    case "$PLATFORM" in
        termux)
            log "Installing Termux packages..."
            pkg upgrade -y
            pkg install -y git python openssh stow zsh neovim nodejs-lts fzf zoxide
            ;;
        macos)
            if ! command -v brew &>/dev/null; then
                warn "Homebrew not found, skipping package installation"
                return
            fi
            log "Installing macOS packages..."
            brew install stow fzf zoxide neovim
            ;;
        linux)
            if command -v apt &>/dev/null; then
                log "Installing packages via apt..."
                sudo apt update && sudo apt install -y stow fzf zoxide neovim
            elif command -v pacman &>/dev/null; then
                log "Installing packages via pacman..."
                sudo pacman -Syu --noconfirm stow fzf zoxide neovim
            else
                warn "Unknown package manager, skipping package installation"
            fi
            ;;
    esac
}

# ============================================
# Zsh framework setup
# ============================================

setup_zsh() {
    if [ "$PLATFORM" = "termux" ]; then
        # Termux uses Oh-My-Zsh (lighter)
        log "Setting up Oh-My-Zsh for Termux..."
        safe_clone "https://github.com/ohmyzsh/ohmyzsh.git" "$HOME/.oh-my-zsh"

        ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
        safe_clone "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        safe_clone "https://github.com/zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

        # Pure prompt (loaded via fpath in .zshrc, not as OMZ theme)
        safe_clone "https://github.com/sindresorhus/pure" "$ZSH_CUSTOM/pure"

        chsh -s zsh
    else
        # macOS/Linux uses Prezto
        log "Setting up Prezto..."
        safe_clone "https://github.com/sorin-ionescu/prezto.git" "${ZDOTDIR:-$HOME}/.zprezto"

        # Create Prezto symlinks if they don't exist
        for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/z*; do
            target="${ZDOTDIR:-$HOME}/.${rcfile:t}"
            [ -e "$target" ] || ln -s "$rcfile" "$target"
        done
    fi
}

# ============================================
# Neovim setup (Termux only - macOS/Linux use LunarVim)
# ============================================

setup_nvim() {
    if [ "$PLATFORM" = "termux" ]; then
        log "Setting up Neovim providers..."
        pip install pynvim
        npm install -g neovim
    fi
}

# ============================================
# Stow dotfiles
# ============================================

stow_packages() {
    log "Stowing dotfiles..."
    cd "$DOTS_DIR"

    # Common packages for all platforms
    local common="zsh"

    # Platform-specific packages
    local platform_pkgs=""
    case "$PLATFORM" in
        termux)
            platform_pkgs="termux nvim"
            ;;
        macos)
            platform_pkgs="claude ghostty kitty lvim tmux"
            ;;
        linux)
            platform_pkgs="claude kitty lvim tmux"
            ;;
    esac

    # Backup and stow
    for pkg in $common $platform_pkgs; do
        if [ -d "$pkg" ]; then
            log "Stowing $pkg..."
            stow -R "$pkg" 2>/dev/null || warn "Could not stow $pkg (conflicts?)"
        fi
    done
}

# ============================================
# Main
# ============================================

main() {
    log "Starting dotfiles setup..."

    install_packages
    setup_zsh
    setup_nvim
    stow_packages

    echo
    log "Setup complete!"
    log "Restart your shell or run: source ~/.zshrc"
}

main "$@"
