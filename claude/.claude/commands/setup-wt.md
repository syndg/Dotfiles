---
description: Setup global wt (worktree manager) completions
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

# Setup WT - Global Completions Installer

Installs the global `wt` completions so the `wt` command works across all projects.

## What This Does

1. Creates `~/.claude/tools/` directory
2. Copies `wt-completions.zsh` to `~/.claude/tools/`
3. Adds source line to `~/.zshrc`

## Process

### 1. Check if Already Installed

```bash
if [[ -f "$HOME/.claude/tools/wt-completions.zsh" ]]; then
    echo "wt completions already installed"
    # Ask if they want to reinstall/update
fi
```

### 2. Create Directory

```bash
mkdir -p "$HOME/.claude/tools"
```

### 3. Write Completions File

Write the following to `~/.claude/tools/wt-completions.zsh`:

```zsh
# Project-specific wt (Git Worktree Manager)
# Sourced from ~/.zshrc

# wt function - finds and runs project-specific .claude/tools/wt
wt() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null)

    if [[ -z "$root" ]]; then
        echo "Error: Not inside a git repository"
        return 1
    fi

    local wt_tool="$root/.claude/tools/wt"

    if [[ -x "$wt_tool" ]]; then
        "$wt_tool" "$@"
    else
        echo "Error: No wt tool found in this project"
        echo "Run '/install-wt' in Claude Code to scaffold one"
        return 1
    fi
}

# Completions
_wt_get_worktrees() {
    local root wt_dir
    root=$(git rev-parse --show-toplevel 2>/dev/null) || return
    wt_dir="$root/.worktrees"
    [[ -d "$wt_dir" ]] || return

    find "$wt_dir" -mindepth 1 -maxdepth 3 \( -name ".git" -o -type f -name ".git" \) 2>/dev/null | \
        xargs -I {} dirname {} 2>/dev/null | \
        sed "s|$wt_dir/||" | \
        sort -u
}

_wt_get_branches() {
    git branch --format='%(refname:short)' 2>/dev/null | sort
}

_wt() {
    local -a commands worktrees flags

    commands=(
        'new:Create new worktree(s)'
        'list:List all worktrees'
        'ls:List all worktrees'
        'remove:Remove worktree(s)'
        'rm:Remove worktree(s)'
        'open:Print cd command for worktree'
        'cd:Print cd command for worktree'
        'setup:Setup worktree(s)'
        'spawn:Create worktree(s) + open tabs'
        'tab:Open tab(s) for worktree(s)'
        'help:Show usage help'
    )

    # Get worktrees for completion
    worktrees=(${(f)"$(_wt_get_worktrees)"})

    if (( CURRENT == 2 )); then
        _describe 'command' commands
    else
        case "${words[2]}" in
            new|spawn)
                _message 'branch name(s)'
                ;;
            remove|rm)
                flags=('-f' '-b' '-fb')
                if [[ "${words[CURRENT]}" == -* ]]; then
                    _describe 'flags' flags
                elif (( ${#worktrees} )); then
                    _describe 'worktree' worktrees
                else
                    _message 'worktree name(s)'
                fi
                ;;
            setup|tab|open|cd)
                if (( ${#worktrees} )); then
                    _describe 'worktree' worktrees
                else
                    _message 'worktree name'
                fi
                ;;
            *)
                _message 'argument'
                ;;
        esac
    fi
}

compdef _wt wt
```

### 4. Update .zshrc

Check if source line already exists:

```bash
if ! grep -q 'wt-completions.zsh' "$HOME/.zshrc"; then
    echo '' >> "$HOME/.zshrc"
    echo '# wt - Git Worktree Manager' >> "$HOME/.zshrc"
    echo 'source "$HOME/.claude/tools/wt-completions.zsh"' >> "$HOME/.zshrc"
fi
```

### 5. Output

```
✓ Created ~/.claude/tools/wt-completions.zsh
✓ Added source to ~/.zshrc

Global setup complete!

Next steps:
1. Restart your terminal (or run: source ~/.zshrc)
2. Navigate to any git repo
3. Run /install-wt to create a project-specific wt script

The wt command will then work in that project.
```
