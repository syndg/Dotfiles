# Dotfiles

- Zsh
- Tmux
- LunarVim
- Kitty

## Installation

- Clone this repository in your **home directory**.

```bash
git clone https://github.com/syndg/dotfiles.git
```

- Install [stow](https://www.gnu.org/software/stow/manual/stow.html) using a package manager of your choice or based on your Linux/Mac distro.

```bash
# For Debian-based distros
sudo apt install stow

# For Arch-based distros
sudo pacman -S stow

# For MacOS
brew install stow
```

- Run `stow <appName>` to install the respective dotfiles.

For example, if you want to install the zsh config files, run:

```bash
stow zsh
```

## Install LunarVim

**MAKE SURE YOU CLONE THIS REPO IN YOUR HOME DIRECTORY**

Otherwise stow wont be able to symlink the config files to the right place.

Install LunarVim from [here](https://www.lunarvim.org/docs/installation)

The installation is pretty simple using the official script, but if you still wanna refer to a video tutorial, check out this one:
[LunarVim Installation](https://www.youtube.com/watch?v=sFA9kX-Ud_c)

To install my LunarVim config files, first clone **this repository** and run the following commands in your **home directory**:

```bash
# home directory
rm -rf ~/.config/lvim
cd dotfiles
stow lvim
```

### What this config contains:

- Codeium AI for code auto-completion
- Different plugins for color highlighting, smooth scrolling and more.
- Different color-schemes that you can choose from.
- A few custom keybindings.
- Relative line numbers enabled by default.

#### Codeium Setup

For Codeium to work, you need to do the following steps:

- Head over to [Codeium's website](https://codeium.com/) and create an account.
- Install LunarVim and install my config files.
- After the installation, run lvim.
- While in normal mode enter the command, `:Codeium Auth`
- You'll be redirected to Codeium's website for authentication and you'll get an API key which you have to paste it in lvim.
- Voila you're done.

Since the `<tab>` key is already taken by lvim for LSP completions, I have configured Codeium to use `<CTRL>+g` for appending the completions.

## wt - Git Worktree Manager

A CLI tool for managing git worktrees, designed for parallel AI coding sessions. Spawn multiple worktrees with a single command and open terminal tabs for each.

### Features

- **Batch operations** - All commands support multiple arguments
- **Ghostty integration** - Automatically opens tabs for each worktree
- **fzf multi-select** - When no args provided, select interactively
- **Project-specific config** - Package manager, env files, post-setup hooks
- **Global completions** - One completion file works across all projects

### Quick Start

#### Option 1: Automated (Recommended)

Copy the commands folder to your Claude Code config, then run:

```bash
# Copy commands to your Claude Code config
cp -r claude/.claude/commands ~/.claude/
```

Then in Claude Code:

```
/setup-wt
```

This installs global completions and updates your `.zshrc`. After restarting your terminal, navigate to any git repo and run:

```
/install-wt
```

This creates a project-specific `wt` script with your config (package manager, env files, etc).

#### Option 2: Manual

1. **Copy the global completions:**

```bash
mkdir -p ~/.claude/tools
cp claude/.claude/tools/wt-completions.zsh ~/.claude/tools/
```

2. **Add to your `.zshrc`:**

```bash
echo 'source "$HOME/.claude/tools/wt-completions.zsh"' >> ~/.zshrc
source ~/.zshrc
```

3. **In any git repo**, copy the `install-wt.md` command and run `/install-wt` in Claude Code to scaffold the project-specific `wt` script.

### Usage

```bash
# Spawn worktrees + open Ghostty tabs
wt spawn feat/auth feat/api feat/ui

# Create worktrees (without tabs)
wt new feat/one feat/two --base=main

# Setup worktrees (env, deps, direnv)
wt setup feat/auth feat/api

# Open tabs for existing worktrees
wt tab feat/auth feat/api

# Remove worktrees + delete branches
wt rm -fb feat/old test/wip

# Interactive multi-select (requires fzf)
wt rm     # opens fzf to select
wt tab    # opens fzf to select
wt setup  # opens fzf to select

# List all worktrees
wt ls
```

### Configuration

Each project's `.claude/tools/wt` script has a config section:

```bash
# === CONFIGURATION ===
PACKAGE_MANAGER="bun"     # bun | pnpm | yarn | npm
USE_DIRENV=true           # auto-allow direnv
ENV_FILES=(
  ".env"
  ".env.local"
)
POST_SETUP_COMMANDS=(
  "bun run prisma generate"
)
# === END CONFIGURATION ===
```

### How It Works

The global `wt-completions.zsh` defines a `wt()` function that:
1. Finds the git repo root
2. Looks for `.claude/tools/wt` in that repo
3. Executes the project-specific script with your args

This means completions and the `wt` command work in any project that has the script installed.
