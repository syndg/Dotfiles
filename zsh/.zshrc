export LC_ALL=en_US.UTF-8

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
export PATH="$HOME/.local/bin:$PATH"

# HOMEBREW
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

source $HOME/.zsh/synhigh/zsh-syntax-highlighting.zsh
source $HOME/.zsh/aliases.zsh
source $HOME/.zsh/functions.zsh

# bun completions
[ -s "/home/syndg/.bun/_bun" ] && source "/home/syndg/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ssh-agent
env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env

# nvm
source /usr/share/nvm/init-nvm.sh

# zoxide
eval "$(zoxide init zsh)"

PATH=~/.console-ninja/.bin:$PATH

# pnpm
export PNPM_HOME="/home/syndg/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

