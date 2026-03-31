# ============================================
# Git Functions (all platforms)
# ============================================

# Git commit shorthand
gcap() {
    git commit -m "$*"
}

# Semantic commit functions
gup() { gcap "🛠️ UPDATE: $@"; }
gnew() { gcap "📦 NEW: $@"; }
gimp() { gcap "👌 IMPROVE: $@"; }
gfix() { gcap "🐛 FIX: $@"; }
grlz() { gcap "🚀 RELEASE: $@"; }
gdoc() { gcap "📖 DOC: $@"; }
gtst() { gcap "🤖 TEST: $@"; }
gbrk() { gcap "‼️ BREAKING: $@"; }

gtype() {
    NORMAL='\033[0;39m'
    GREEN='\033[0;32m'
    echo -e "$GREEN gnew$NORMAL — 📦 NEW\n$GREEN gimp$NORMAL — 👌 IMPROVE\n$GREEN gfix$NORMAL — 🐛 FIX\n$GREEN grlz$NORMAL — 🚀 RELEASE\n$GREEN gdoc$NORMAL — 📖 DOC\n$GREEN gtst$NORMAL — 🤖 TEST\n$GREEN gbrk$NORMAL — ‼️ BREAKING"
}

# Search and replace string recursively in git repos
gitreplace() {
    echo -n "Replace '$1' with '$2'? (y/n) "
    read answer
    if echo "$answer" | grep -iq "^y"; then
        git grep -lz "$1" | xargs -0 sed -i "s/$1/$2/g"
    else
        echo "Cancelled"
    fi
}

# ============================================
# Utility Functions (all platforms)
# ============================================

# Make directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Compile and run C++
runcpp() {
    g++ "$1" && ./a.out
}

# ============================================
# Desktop-only Functions (macOS/Linux)
# ============================================

if [ -z "$TERMUX_VERSION" ]; then

# Generate PostgreSQL connection URL
pgconnection() {
    echo -n "Enter the PostgreSQL username: "
    read username
    echo -n "Enter the PostgreSQL password: "
    read -s password
    echo
    echo -n "Enter the database name: "
    read dbname
    echo -n "Enter the host (default: localhost): "
    read host
    echo -n "Enter the port (default: 5432): "
    read port

    host=${host:-localhost}
    port=${port:-5432}

    connection_url="postgresql://${username}:${password}@${host}:${port}/${dbname}"
    echo "Your PostgreSQL connection URL is:"
    echo $connection_url
}

generatepgurl() { pgconnection; }

# New project helper
new_project() {
    while getopts f:n: flag; do
        case "${flag}" in
            f) folder=${OPTARG};;
            n) project_name=${OPTARG};;
            *) echo "Usage: new-project -f [folder] -n [project-name]"; return 1;;
        esac
    done

    base_dir=~/coding
    target_dir="$base_dir/$folder"

    if [ ! -d "$target_dir" ]; then
        echo "Directory $target_dir does not exist. Creating it..."
        mkdir -p "$target_dir"
    fi

    cd "$target_dir" || return
    cna "$project_name"
    cd "$project_name" || return
    echo "You are now inside: $(pwd)"
}

# Wi-Fi connection (Linux with nmcli)
connect_wifi() {
    command -v nmcli &>/dev/null || { echo "nmcli not found"; return 1; }
    echo "Scanning for available Wi-Fi networks..."
    nmcli device wifi list | cat

    echo -n "Enter the SSID of the network: "
    read ssid
    echo -n "Enter the Wi-Fi password: "
    read -s password

    echo "\nConnecting to $ssid..."
    nmcli device wifi connect "$ssid" password "$password"

    if [[ $? -eq 0 ]]; then
        echo "Connected to $ssid successfully!"
    else
        echo "Failed to connect to $ssid. Please check the SSID and password."
    fi
}

# PostgreSQL utilities
_parse_pg_conn_string() {
    local conn_string="$1"
    if [[ ! "$conn_string" =~ ^postgresql:// ]]; then
        echo "Error: Invalid PostgreSQL connection string format." >&2
        return 1
    fi

    local clean_string="${conn_string#postgresql://}"

    if [[ "$clean_string" =~ ^([^:]+):([^@]+)@(.+)$ ]]; then
        PG_USER="${match[1]}"
        PG_PASSWORD="${match[2]}"
        local rest="${match[3]}"
    else
        if [[ "$clean_string" =~ ^([^@]+)@(.+)$ ]]; then
            PG_USER="${match[1]}"
            local rest="${match[2]}"
        else
            PG_USER="postgres"
            local rest="$clean_string"
        fi
        PG_PASSWORD=""
    fi

    if [[ "$rest" =~ ^([^:/]+):([0-9]+)/(.+)$ ]]; then
        PG_HOST="${match[1]}"
        PG_PORT="${match[2]}"
        PG_DBNAME="${match[3]}"
    elif [[ "$rest" =~ ^([^/]+)/(.+)$ ]]; then
        PG_HOST="${match[1]}"
        PG_PORT="5432"
        PG_DBNAME="${match[2]}"
    else
        echo "Error: Could not parse connection string." >&2
        return 1
    fi

    PG_PASSWORD=$(echo "$PG_PASSWORD" | perl -MURI::Escape -ne 'print uri_unescape($_)' 2>/dev/null || echo "$PG_PASSWORD")
    return 0
}

pg_dump_from_conn() {
    if [ -z "$1" ]; then
        echo "Usage: pg_dump_from_conn <connection_string> [output_file.sql]"
        return 1
    fi

    local source_conn="$1"
    local output_file="${2:-dump.sql}"

    _parse_pg_conn_string "$source_conn" || return 1

    echo "Dumping '$PG_DBNAME' from '$PG_HOST:$PG_PORT'..."
    PGPASSWORD="$PG_PASSWORD" pg_dump -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DBNAME" -Fc -f "$output_file"

    [ $? -eq 0 ] && echo "Dump successful: $output_file" || echo "Error: pg_dump failed."
}

pg_restore_to_conn() {
    if [ -z "$1" ]; then
        echo "Usage: pg_restore_to_conn <connection_string> [input_file.sql]"
        return 1
    fi

    local target_conn="$1"
    local input_file="${2:-dump.sql}"

    [ ! -f "$input_file" ] && { echo "Error: '$input_file' not found."; return 1; }

    _parse_pg_conn_string "$target_conn" || return 1

    echo "Restoring '$input_file' to '$PG_DBNAME' on '$PG_HOST:$PG_PORT'..."
    PGPASSWORD="$PG_PASSWORD" pg_restore -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$PG_DBNAME" -c "$input_file"

    [ $? -eq 0 ] && echo "Restore successful!" || echo "Error: pg_restore failed."
}

# Redis URL parser for n8n
redis_url_to_n8n() {
    local url="$1"
    local proto host port db password ssl

    proto="${url%%://*}"
    [[ "$proto" == "rediss" ]] && ssl="true" || ssl="false"

    local rest="${url#*://}"
    if [[ "$rest" == :* ]]; then
        password="${rest%%@*}"
        password="${password#:}"
        rest="${rest#*@}"
    else
        password=""
        rest="${rest#*@}"
    fi

    local hostportdb="${url#*://}"
    hostportdb="${hostportdb#*@}"
    host="${hostportdb%%:*}"
    local portdb="${hostportdb#*:}"
    port="${portdb%%/*}"
    db="${portdb#*/}"
    [[ "$db" == "$portdb" ]] && db="0"

    echo "Host: $host"
    echo "Port: $port"
    echo "Password: $password"
    echo "Database: $db"
    echo "SSL: $ssl"
}

# Run n8n in Docker
run_n8n() {
    command -v docker &>/dev/null || { echo "Docker not found"; return 1; }
    echo "Starting n8n Docker container..."
    docker run -it --rm \
        --name n8n \
        -p 5678:5678 \
        -e GENERIC_TIMEZONE="Asia/Kolkata" \
        -e TZ="Asia/Kolkata" \
        -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
        -e N8N_RUNNERS_ENABLED=true \
        -v n8n_data:/home/node/.n8n \
        docker.n8n.io/n8nio/n8n
}

fi # End desktop-only functions

# ============================================
# Worktrunk + cmux Functions
# ============================================

# Spawn a worktree with Claude in a new cmux pane (quad layout)
# Usage: wt-spawn <branch> [-- 'task description']
wt-spawn() {
  if [[ -z "$1" ]]; then
    echo "Usage: wt-spawn <branch> [-- 'task description']"
    return 1
  fi

  local branch="$1"; shift
  local task_args=""
  if [[ "$1" == "--" ]]; then
    shift
    task_args="-- '${*}'"
  fi

  # Determine split direction for quad layout (TL, TR, BL, BR)
  local pane_count
  pane_count=$(cmux list-panes 2>/dev/null | grep -c '^')

  local direction
  case $pane_count in
    1) direction="right" ;;
    2) direction="down" ;;
    3) direction="down" ;;
    *) direction="right" ;;
  esac

  local output
  output=$(cmux new-pane --direction "$direction" 2>&1)

  # Extract surface ref (e.g., "surface:6" from "OK surface:6 pane:5 workspace:1")
  local surface_ref
  surface_ref=$(echo "$output" | grep -oE 'surface:[0-9]+' | head -1)

  if [[ -z "$surface_ref" ]]; then
    echo "Failed to create cmux pane: $output"
    return 1
  fi

  sleep 0.3
  cmux send-panel --panel "$surface_ref" \
    "wt switch --create $branch -x claude $task_args\n"
}

# Create a cmux workspace for a project
# Usage: wt-project <path> [name]
wt-project() {
  local project_path="${1:?Usage: wt-project <path> [name]}"
  local name="${2:-$(basename "$project_path")}"

  local output
  output=$(cmux new-workspace --command "cd $project_path && exec zsh" 2>&1)
  local ws_id
  ws_id=$(echo "$output" | grep -oE '[A-F0-9-]{36}' | head -1)

  if [[ -n "$ws_id" ]]; then
    cmux rename-workspace --workspace "$ws_id" "$name"
  fi
}

# Stage + LLM commit with review
# Usage: wt-commit
wt-commit() {
  git add -A

  if git diff --cached --quiet; then
    echo "Nothing to commit."
    return 0
  fi

  echo "── Staged changes ──"
  git diff --cached --stat
  echo ""

  echo "Generating commit message..."
  local msg
  msg=$(wt step commit --show-prompt 2>/dev/null | \
    CLAUDECODE= MAX_THINKING_TOKENS=0 claude -p --model=haiku \
    --tools='' --disable-slash-commands --setting-sources='' --system-prompt='')

  echo "── Generated message ──"
  echo "$msg"
  echo ""

  read -q "REPLY?Commit with this message? [y/N] "
  echo ""
  if [[ "$REPLY" == "y" ]]; then
    git commit -m "$(cat <<EOF
$msg
EOF
)"
    echo "Committed."
  else
    echo "Aborted. Changes remain staged."
  fi
}

# Push branch + create PR with LLM description
# Usage: wt-pr
wt-pr() {
  local branch
  branch=$(git branch --show-current)
  local default_branch
  default_branch=$(wt config state default-branch 2>/dev/null || echo "main")

  if [[ "$branch" == "$default_branch" ]]; then
    echo "Can't create PR from $default_branch."
    return 1
  fi

  # Push if needed
  if ! git rev-parse --abbrev-ref "@{u}" &>/dev/null; then
    echo "Pushing $branch to origin..."
    git push -u origin "$branch"
  else
    local ahead
    ahead=$(git rev-list "@{u}..HEAD" --count)
    if [[ "$ahead" -gt 0 ]]; then
      echo "Pushing $ahead commit(s)..."
      git push
    fi
  fi

  # Generate PR content from diff
  echo "Generating PR description..."
  local diff_input
  diff_input=$(printf '%s\n---\n%s' \
    "$(git log "$default_branch..HEAD" --pretty=format:"%s%n%b")" \
    "$(git diff "$default_branch..HEAD" --stat)")

  local pr_content
  pr_content=$(echo "$diff_input" | \
    CLAUDECODE= MAX_THINKING_TOKENS=0 claude -p --model=haiku \
    --tools='' --disable-slash-commands --setting-sources='' --system-prompt='' \
    --append-system-prompt 'Generate a PR title on line 1, then a blank line, then a markdown PR body with ## Summary and ## Changes sections. Be concise.')

  local pr_title
  pr_title=$(echo "$pr_content" | head -1)
  local pr_body
  pr_body=$(echo "$pr_content" | tail -n +3)

  echo "── PR Title ──"
  echo "$pr_title"
  echo ""
  echo "── PR Body ──"
  echo "$pr_body"
  echo ""

  read -q "REPLY?Create PR? [y/N] "
  echo ""
  if [[ "$REPLY" == "y" ]]; then
    local url
    url=$(gh pr create --title "$pr_title" --body "$(cat <<EOF
$pr_body
EOF
)")
    echo "$url"
  else
    echo "Aborted. Branch is pushed, create PR manually."
  fi
}

# Clean up worktree after PR merged, back to main
# Usage: wt-done
wt-done() {
  local branch
  branch=$(git branch --show-current)
  local default_branch
  default_branch=$(wt config state default-branch 2>/dev/null || echo "main")

  if [[ "$branch" == "$default_branch" ]]; then
    echo "Already on $default_branch."
    return 0
  fi

  wt remove "$branch"
  echo "Cleaned up $branch."
}
