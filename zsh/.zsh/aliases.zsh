# Git aliases
alias clone="git clone"
alias gs="git status"
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit"
alias gcp="git cherry-pick"
alias gswi="git switch"
alias gra="git remote add"
alias grm="git remote rm"
alias grv="git remote -v"
alias gd="git diff"
alias gpl="git pull"
alias gpu="git push -u"
alias gpf="git push -f"
alias gst="git stash"
alias gsta="git stash apply"
alias gstd="git stash drop"
alias gstl="git stash list"
alias gstp="git stash pop"
alias gsts="git stash save"
alias gagst="git add . && git stash"
alias gbn="git checkout -b"
alias gbd="git branch -D"
alias gr="git rebase"
alias gri="git rebase -i"
alias gco="git checkout"

# Git log (use bat if available)
if command -v bat &>/dev/null; then
    alias gl="git log | bat"
else
    alias gl="git log"
fi

# Source zshrc
alias zsource="source ~/.zshrc"

# Clear
alias c="clear"

# Lazygit
alias lg="lazygit"

# Tmux
alias tx="tmux"
alias txa="tmux attach -t"

# Claude Code
alias cc="claude"
alias ccyolo="claude --dangerously-skip-permissions"

# ============================================
# Platform-specific aliases
# ============================================

if [ -n "$TERMUX_VERSION" ]; then
    # Termux
    alias install="pkg install"
    alias update="pkg upgrade"
    alias n="nvim"
    alias zconfig="nvim ~/.zshrc"
    alias aliases="nvim ~/.zsh/aliases.zsh"
else
    # macOS/Linux
    alias lv="lvim"
    alias n="nvim"
    alias zconfig="lvim ~/.zshrc"
    alias aliases="lvim ~/.zsh/aliases.zsh"
    alias kittyconfig="lvim ~/.config/kitty/kitty.conf"

    # Bun
    alias br="bun run"
    alias brb="bun run build"
    alias brd="bun run dev"

    # Web dev
    alias shadcn="bunx --bun shadcn-ui@latest"
    alias cna="bunx --bun create-next-app@latest"
    alias np="new_project"

    # Package manager (detect)
    if command -v yay &>/dev/null; then
        alias install="yay -S"
    elif command -v brew &>/dev/null; then
        alias install="brew install"
    elif command -v apt &>/dev/null; then
        alias install="sudo apt install"
    fi
fi
