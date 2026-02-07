export LC_ALL=en_US.UTF-8
export EDITOR=nvim
export VISUAL=nvim
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Secrets (API keys, tokens - not in git)
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

# Detect platform
if [ -n "$TERMUX_VERSION" ]; then
    _PLATFORM="termux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    _PLATFORM="macos"
else
    _PLATFORM="linux"
fi

# ============================================
# Shell Framework (Prezto or Oh-My-Zsh)
# ============================================

if [ "$_PLATFORM" = "termux" ]; then
    # Termux: Oh-My-Zsh (lighter)
    export ZSH="$HOME/.oh-my-zsh"
    ZSH_THEME=""  # Disable OMZ themes, we'll use Pure manually
    plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
    [ -s "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

    # Load Pure prompt (not a standard OMZ theme)
    fpath+=("$HOME/.oh-my-zsh/custom/pure")
    autoload -U promptinit; promptinit
    prompt pure
else
    # macOS/Linux: Prezto
    if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
        source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
    fi
    # Syntax highlighting (bundled in repo)
    [ -f "$HOME/.zsh/synhigh/zsh-syntax-highlighting.zsh" ] && source "$HOME/.zsh/synhigh/zsh-syntax-highlighting.zsh"
fi

# ============================================
# Modular Config (shared across platforms)
# ============================================

[ -f "$HOME/.zsh/aliases.zsh" ] && source "$HOME/.zsh/aliases.zsh"
[ -f "$HOME/.zsh/functions.zsh" ] && source "$HOME/.zsh/functions.zsh"

# ============================================
# SSH Agent (all platforms)
# ============================================

export GPG_TTY=$(tty)
env=~/.ssh/agent.env

agent_load_env() { test -f "$env" && . "$env" >| /dev/null; }
agent_start() {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null
}

agent_load_env
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi
unset env

# ============================================
# Tools (conditional)
# ============================================

# zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# fzf
if [ "$_PLATFORM" = "termux" ]; then
    [ -f "$PREFIX/share/fzf/key-bindings.zsh" ] && source "$PREFIX/share/fzf/key-bindings.zsh"
    [ -f "$PREFIX/share/fzf/completion.zsh" ] && source "$PREFIX/share/fzf/completion.zsh"
else
    command -v fzf &>/dev/null && source <(fzf --zsh)
fi

# direnv
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# ============================================
# Platform-specific
# ============================================

if [ "$_PLATFORM" != "termux" ]; then
    # macOS/Linux only
    export BUN_INSTALL_CACHE_DIR="/Volumes/External/bun-cache"
    ulimit -n 2147483646 2>/dev/null

    # Homebrew
    [ -d "/opt/homebrew/bin" ] && export PATH="/opt/homebrew/bin:$PATH"
    [ -d "/home/linuxbrew/.linuxbrew/bin" ] && export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

    # Bun
    export BUN_INSTALL="$HOME/.bun"
    [ -d "$BUN_INSTALL" ] && export PATH="$BUN_INSTALL/bin:$PATH"
    [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

    # pnpm
    export PNPM_HOME="$HOME/.local/share/pnpm"
    case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) [ -d "$PNPM_HOME" ] && export PATH="$PNPM_HOME:$PATH" ;;
    esac

    # nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    # Docker completions
    [ -d "$HOME/.docker/completions" ] && fpath=($HOME/.docker/completions $fpath)
    autoload -Uz compinit && compinit

    # Atuin
    [ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env" && eval "$(atuin init zsh)"

    # libpq (postgres)
    [ -d "/opt/homebrew/opt/libpq/bin" ] && export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

    # Claude Code tools
    [ -d "$HOME/.claude/tools" ] && export PATH="$HOME/.claude/tools:$PATH"
    [ -f "$HOME/.claude/tools/wt-completions.zsh" ] && source "$HOME/.claude/tools/wt-completions.zsh"
fi

# Added by GitButler installer
eval "$(but completions zsh)"
