# Dotfiles

Cross-platform dotfiles for macOS, Linux, and Termux. Uses GNU Stow for symlink management.

## Quick Start

```bash
# Clone to home directory
git clone https://github.com/syndg/dotfiles.git ~/Dotfiles
cd ~/Dotfiles

# Run setup (auto-detects platform)
./setup.sh
```

## What's Included

| Package | Description | Platforms |
|---------|-------------|-----------|
| `zsh` | Shell config (Prezto/Oh-My-Zsh), aliases, functions | All |
| `claude` | Claude Code settings, commands, hooks, tools | macOS, Linux |
| `lvim` | LunarVim config with Codeium AI | macOS, Linux |
| `kitty` | Kitty terminal config + themes | macOS, Linux |
| `ghostty` | Ghostty terminal config | macOS |
| `tmux` | Tmux config | macOS, Linux |
| `termux` | Termux colors, font, properties | Termux |
| `nvim` | Basic Neovim config | Termux |

## Manual Stow

```bash
# Stow individual packages
stow zsh
stow claude
stow lvim
# etc.
```

## Platform Detection

The zsh config auto-detects the platform:
- **Termux**: Uses Oh-My-Zsh (lighter), Pure theme
- **macOS/Linux**: Uses Prezto, syntax highlighting bundle

## Zsh Structure

```
zsh/
├── .zshrc              # Main config (platform-aware)
├── .zpreztorc          # Prezto settings (macOS/Linux)
├── .zprofile           # Login shell config
└── .zsh/
    ├── aliases.zsh     # Git, editor, package aliases
    ├── functions.zsh   # Semantic commits, utilities
    └── synhigh/        # Syntax highlighting (bundled)
```

## LunarVim

```bash
# Install LunarVim first: https://www.lunarvim.org/docs/installation
rm -rf ~/.config/lvim
cd ~/Dotfiles && stow lvim
```

For Codeium: Run `:Codeium Auth` in lvim and follow prompts.

## wt - Git Worktree Manager

CLI tool for managing git worktrees for parallel AI coding sessions.

```bash
# Setup (in Claude Code)
/setup-wt      # Install global completions
/install-wt    # Scaffold project-specific wt script

# Usage
wt spawn feat/auth feat/api    # Create worktrees + open tabs
wt rm -fb feat/old             # Remove worktrees + branches
wt ls                          # List all worktrees
```

See `claude/.claude/commands/` for all available commands.
