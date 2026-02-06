---
name: synclaw-server
description: Direct SSH access to synclaw server. Use for running commands, reading/writing files, git operations on the server. Triggers on "run on server", "server command", "on synclaw", "remote file", or any task requiring direct server execution without talking to Synclaw AI.
---

# Synclaw Server (SSH)

Direct SSH access to the `synclaw` server for executing commands and file operations.

## When to Use

- Running commands on the server
- Reading/writing files on the server
- Git operations on server repos
- Any direct server task that doesn't need Synclaw AI's judgment

**For talking to Synclaw AI** (conversations, sub-agents, memory search), use the `openclaw` skill instead.

## SSH Access

The server is accessible via SSH as `synclaw` (configured in ~/.ssh/config).

```bash
ssh synclaw "<command>"
```

## Common Operations

### Run a command

```bash
ssh synclaw "ls -la ~/Coding"
```

### Read a file

```bash
ssh synclaw "cat /home/syndg/agents/synclaw/COLLAB.md"
```

### Write a file

```bash
ssh synclaw "cat > /home/syndg/file.txt << 'EOF'
content here
EOF"
```

### Git operations

```bash
ssh synclaw "cd ~/Coding/resumatchweb && git status"
ssh synclaw "cd ~/Coding/resumatchweb && git pull origin main"
```

### Multiple commands

```bash
ssh synclaw "cd ~/Coding/resumatchweb && git fetch upstream && git log --oneline -5"
```

## Server Details

- **Host:** synclaw
- **User:** syndg
- **Home:** /home/syndg
- **Coding directory:** ~/Coding (aligned with local /Volumes/External/Coding)
- **Agents directory:** ~/agents
- **Synclaw workspace:** ~/agents/synclaw
- **Git identity:** Synclaw / 259127377+the-synclaw@users.noreply.github.com
- **GitHub account:** the-synclaw

## Tips

- Use single quotes around heredocs to prevent local variable expansion
- For long outputs, pipe through `head` or `tail`
- The server is Ubuntu Linux
- Git is configured with the-synclaw identity
