## IMPORTANT RULES

- When reporting information to me, be extremely concise. Sacrifice grammar for the sake of concision.
- Always use Bun instead of npm or pnpm for package management and script execution.
- Use standard `git` commands by default for git operations.

## DAMAGE CONTROL HOOK

A PreToolUse hook (`~/.claude/hooks/damage-control/damage-control.ts`) intercepts all Bash, Edit, and Write tool calls before execution. It pattern-matches commands and file paths against rules defined in `~/.claude/hooks/damage-control/patterns.yaml`.

**What it blocks (exit code 2 = hard block):**
- Destructive bash commands: `rm -rf`, `rm --force`, `sudo rm`, `git reset --hard`, `git push --force`, `git clean -fd`, `git stash clear`, `mkfs`, `dd of=/dev/`, `kill -9 -1`
- Cloud/infra destruction: AWS (`terminate-instances`, `delete-db-instance`, `delete-stack`), GCP (`projects delete`, `instances delete`), Vercel/Netlify/Cloudflare/Heroku/Fly.io delete ops, `terraform destroy`, `pulumi destroy`
- Database destruction: `DROP TABLE/DATABASE`, `TRUNCATE TABLE`, `DELETE FROM` without WHERE, `FLUSHALL/FLUSHDB`, `dropdb`, Prisma `migrate reset`/`--force-reset`/`--accept-data-loss`
- Docker/K8s destruction: `system prune -a`, `volume rm/prune`, `kubectl delete namespace/all --all`, `helm uninstall`
- Zero-access paths (no read/write/any access): `.env*`, `~/.ssh/`, `~/.aws/`, `~/.config/gcloud/`, `~/.kube/`, `~/.docker/`, `*.pem`, `*.key`, `*.tfstate`, credential files
- Read-only paths (no write/edit/delete via Bash sed/tee/mv/cp/rm or Edit/Write tools): `/etc/`, `/usr/`, lock files, `node_modules/`, build dirs (`dist/`, `.next/`, `build/`), shell configs, minified files
- No-delete paths (can read/write but not `rm`): `~/.claude/`, `CLAUDE.md`, `.git/`, `.github/`, LICENSE, README, Dockerfiles, CI configs

**What it asks about (permissionDecision: "ask"):**
- `git checkout -- .`, `git restore .`, `git stash drop`, `git branch -D`, `git push --delete`, `prisma db push`, `prisma migrate dev`, `DELETE FROM ... WHERE id=`

**When a command is blocked or you know it will be blocked:**
- Do NOT attempt the command. Instead, provide the exact command to the user and ask them to run it manually.
- Example: "This command will be blocked by damage control: `rm -rf dist/`. Please run it yourself if intended."
