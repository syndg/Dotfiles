# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
export PATH="$HOME/.local/bin:$PATH"

source $HOME/.zsh/synhigh/zsh-syntax-highlighting.zsh
source $HOME/.zsh/aliases.zsh

# bun completions
[ -s "/home/syndg/.bun/_bun" ] && source "/home/syndg/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export LC_ALL=en_US.UTF-8
