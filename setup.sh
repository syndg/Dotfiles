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

# Clone repo (with optional recursive flag for submodules)
safe_clone() {
    local repo="$1"
    local dest="$2"
    local recursive="${3:-false}"

    if [ -d "$dest" ]; then
        warn "$dest already exists, updating..."
        cd "$dest"
        git pull --quiet
        if [ "$recursive" = "true" ]; then
            git submodule sync --recursive --quiet
            git submodule update --init --recursive --quiet
        fi
        cd - >/dev/null
    else
        log "Cloning $repo..."
        if [ "$recursive" = "true" ]; then
            git clone --recursive "$repo" "$dest"
        else
            git clone --depth 1 "$repo" "$dest"
        fi
    fi
}

# Backup existing file/symlink before replacing
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
        warn "Backing up $target to $backup"
        mv "$target" "$backup"
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
                sudo apt update && sudo apt install -y git zsh stow fzf zoxide neovim curl
            elif command -v pacman &>/dev/null; then
                log "Installing packages via pacman..."
                sudo pacman -Syu --noconfirm git zsh stow fzf zoxide neovim curl
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
        # macOS/Linux uses Prezto (requires recursive clone for submodules)
        log "Setting up Prezto..."
        safe_clone "https://github.com/sorin-ionescu/prezto.git" "${ZDOTDIR:-$HOME}/.zprezto" "true"

        # Create Prezto symlinks, backing up existing files
        log "Linking Prezto config files..."
        for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/z*; do
            target="${ZDOTDIR:-$HOME}/.${rcfile##*/}"
            if [ -L "$target" ] && [ "$(readlink "$target")" = "$rcfile" ]; then
                # Already correctly linked
                continue
            fi
            backup_if_exists "$target"
            ln -s "$rcfile" "$target"
        done

        # Set zsh as default shell if not already
        if [ "$SHELL" != "$(command -v zsh)" ]; then
            log "Setting zsh as default shell..."
            chsh -s "$(command -v zsh)" || warn "Could not change shell (run manually: chsh -s $(command -v zsh))"
        fi
    fi
}

# ============================================
# Termux font setup (Nerd Font for icons/symbols)
# ============================================

setup_termux_font() {
    if [ "$PLATFORM" != "termux" ]; then
        return
    fi

    local font_url="https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf"
    local font_dest="$HOME/.termux/font.ttf"

    if [ -f "$font_dest" ]; then
        log "Updating Termux font to JetBrainsMono Nerd Font..."
    else
        log "Installing JetBrainsMono Nerd Font..."
    fi

    curl -fsSL "$font_url" -o "$font_dest" && log "Font installed!" || warn "Failed to download font"
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
            platform_pkgs="claude lvim tmux"
            ;;
    esac

    # Stow with --adopt to handle existing files (adopts them into repo, then restow to overwrite)
    for pkg in $common $platform_pkgs; do
        if [ -d "$pkg" ]; then
            log "Stowing $pkg..."
            stow --adopt -R "$pkg" 2>/dev/null || warn "Could not stow $pkg (conflicts?)"
        fi
    done

    # Reset any adopted files to repo version
    git checkout -- . 2>/dev/null || true
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
    setup_termux_font

    echo
    log "Setup complete!"
    [ "$PLATFORM" = "termux" ] && log "Run 'termux-reload-settings' to apply font/colors"
    log "Restart your shell or run: source ~/.zshrc"
}

main "$@"
