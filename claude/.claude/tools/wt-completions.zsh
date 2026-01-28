# Project-specific wt (Git Worktree Manager)
# Add to ~/.zshrc: source ~/.claude/tools/wt-completions.zsh

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
