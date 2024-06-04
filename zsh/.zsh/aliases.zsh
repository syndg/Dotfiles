# git aliases.
alias clone="git clone"
alias gs="git status"
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit"
alias gcp="git cherry-pick"
alias gl="git log | bat"
alias gra="git remote add"
alias grm="git remote rm"
alias grv="git remote -v"
alias gd="git diff"
alias gpl="git pull"
alias gpu="git push -u"
alias gst="git stash"
alias gsta="git stash apply"
alias gstd="git stash drop"
alias gstl="git stash list"
alias gstp="git stash pop"
alias gsts="git stash save"
alias gagst="git add . && git stash"

# npm, pnpm, bun
alias brun="bun run"
alias pnpmrun="pnpm run"
alias npmrun="npm run"

# Package aliases
alias install="yay -S"

# source zshrc
alias zsource="source ~/.zshrc"

# lvim aliases
alias lv="lvim"
alias zconfig="lvim ~/.zshrc"
alias aliases="lvim ~/.zsh/aliases.zsh"

# lazygit
alias lg="lazygit"

# tmux aliases
alias tx="tmux"
alias txa="tmux attach -t"

# Web-dev aliases
alias shadcn="bunx --bun shadcn-ui@latest"
alias cna="bunx --bun create-next-app@latest"
