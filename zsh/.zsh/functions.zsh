# Git Commit, Add all — in one step.
gcap() {
    git commit -m "$*"
}

# UPDATE
gup() {
    gcap "🛠️ UPDATE: $@"
}

# NEW.
gnew() {
    gcap "📦 NEW: $@"
}

# IMPROVE.
gimp() {
    gcap "👌 IMPROVE: $@"
}

# FIX.
gfix() {
    gcap "🐛 FIX: $@"
}

# RELEASE.
grlz() {
    gcap "🚀 RELEASE: $@"
}

# DOC.
gdoc() {
    gcap "📖 DOC: $@"
}

# TEST.
gtst() {
    gcap "🤖 TEST: $@"
}

# BREAKING CHANGE.
gbrk() {
    gcap "‼️ BREAKING: $@"
}

gtype() {
    NORMAL='\033[0;39m'
    GREEN='\033[0;32m'
    echo -e "$GREEN gnew$NORMAL — 📦 NEW\n$GREEN gimp$NORMAL — 👌 IMPROVE\n$GREEN gfix$NORMAL — 🐛 FIX\n$GREEN grlz$NORMAL — 🚀 RELEASE\n$GREEN gdoc$NORMAL — 📖 DOC\n$GREEN gtst$NORMAL — 🤖 TEST\n$GREEN gbrk$NORMAL — ‼️ BREAKING"
}

# Compile and run CPP
runcpp() {
    g++ "$1" && ./a.out
}

# Generate PostgreSQL connection URL
pgconnection() {
    # Prompt the user for the database connection details
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

    # Set default values if host or port are empty
    host=${host:-localhost}
    port=${port:-5432}

    # Construct the connection URL
    connection_url="postgresql://${username}:${password}@${host}:${port}/${dbname}"

    # Display the connection URL
    echo "Your PostgreSQL connection URL is:"
    echo $connection_url
}

# Alternative name for generating PostgreSQL connection URL
generatepgurl() {
    pgconnection
}

# Make a directory and z into it:
mkcd() {
  mkdir -p "$1" && z "$1"
}

new_project() {
  while getopts f:n: flag
  do
    case "${flag}" in
      f) folder=${OPTARG};;
      n) project_name=${OPTARG};;
      *) echo "Usage: new-project -f [folder] -n [project-name]"; return 1;;
    esac
  done

  # Define the base directory
  base_dir=~/coding

  # Create the target directory path
  target_dir="$base_dir/$folder"

  # Check if the directory exists, if not create it
  if [ ! -d "$target_dir" ]; then
    echo "Directory $target_dir does not exist. Creating it..."
    mkdir -p "$target_dir"
  fi

  # Navigate to the target directory
  cd "$target_dir" || return

  # Call the alias to create a new Next.js project with the provided name
  cna "$project_name"

  # Navigate to the newly created project folder after cna finishes
  cd "$project_name" || return
  echo "You are now inside: $(pwd)"
}

# Usage example:
# new_project -f freelance -n New-Project


# Source this file in your shell configuration to make the functions available
# For example, add the following line to your ~/.bashrc or ~/.bash_profile:
# source /path/to/this/file.sh

# Function to list Wi-Fi networks and connect to one
function connect_wifi() {
  # List available Wi-Fi networks
  echo "Scanning for available Wi-Fi networks..."
  nmcli device wifi list | cat
  
  # Prompt user for the SSID and password
  echo -n "Enter the SSID of the network: "
  read ssid
  
  echo -n "Enter the Wi-Fi password: "
  read -s password  # -s makes the input silent
  
  echo "\nConnecting to $ssid..."
  
  # Attempt to connect to the network
  nmcli device wifi connect "$ssid" password "$password"
  
  if [[ $? -eq 0 ]]; then
    echo "Connected to $ssid successfully!"
  else
    echo "Failed to connect to $ssid. Please check the SSID and password."
  fi
}

# === PostgreSQL Database Utilities ===

# Function to parse a PostgreSQL connection string
# Usage: _parse_pg_conn_string "postgresql://user:password@host:port/dbname"
# Sets: PG_HOST, PG_PORT, PG_USER, PG_PASSWORD, PG_DBNAME
_parse_pg_conn_string() {
  local conn_string="$1"
  if [[ ! "$conn_string" =~ ^postgresql:// ]]; then
    echo "Error: Invalid PostgreSQL connection string format. Must start with 'postgresql://'" >&2
    return 1
  fi

  # Remove "postgresql://" prefix
  local clean_string="${conn_string#postgresql://}"

  # Extract password if present
  if [[ "$clean_string" =~ ^([^:]+):([^@]+)@(.+)$ ]]; then
    PG_USER="${match[1]}"
    PG_PASSWORD="${match[2]}"
    local rest="${match[3]}"
  else
    # No password, or invalid user:pass format. Try to parse user@host/db
    if [[ "$clean_string" =~ ^([^@]+)@(.+)$ ]]; then
      PG_USER="${match[1]}"
      local rest="${match[2]}"
    else
      # Fallback: assume user is "postgres" and rest is host/db
      PG_USER="postgres"
      local rest="$clean_string"
    fi
    PG_PASSWORD="" # Ensure it's empty
  fi

  # Extract host, port, dbname
  if [[ "$rest" =~ ^([^:/]+):([0-9]+)/(.+)$ ]]; then
    PG_HOST="${match[1]}"
    PG_PORT="${match[2]}"
    PG_DBNAME="${match[3]}"
  elif [[ "$rest" =~ ^([^/]+)/(.+)$ ]]; then # No port specified, assume 5432
    PG_HOST="${match[1]}"
    PG_PORT="5432"
    PG_DBNAME="${match[2]}"
  else
    echo "Error: Could not parse host/port/dbname from connection string." >&2
    return 1
  fi

  # Handle URL-encoded characters in password (if any, though usually not for simple strings)
  PG_PASSWORD=$(echo "$PG_PASSWORD" | perl -MURI::Escape -ne 'print uri_unescape($_)')

  # Echo parsed details (for debugging)
  # echo "Parsed: Host=$PG_HOST, Port=$PG_PORT, User=$PG_USER, DBName=$PG_DBNAME, Password_Set=${PG_PASSWORD:+true}" >&2
  return 0
}

# Function to dump a PostgreSQL database
# Usage: pg_dump_from_conn "postgresql://user:pass@host:port/dbname" [output_file.sql]
# Default output_file.sql is "dump.sql"
pg_dump_from_conn() {
  if [ -z "$1" ]; then
    echo "Usage: pg_dump_from_conn <source_connection_string> [output_file.sql]"
    echo "  Example: pg_dump_from_conn \"postgresql://supabase_user:pass@db.proj.supabase.co:5432/postgres\" \"supabase_backup.sql\""
    return 1
  fi

  local source_conn="$1"
  local output_file="${2:-dump.sql}" # Default to dump.sql if not provided

  # Parse source connection string
  if ! _parse_pg_conn_string "$source_conn"; then
    return 1
  fi

  echo "Attempting to dump database '$PG_DBNAME' from '$PG_HOST:$PG_PORT' with user '$PG_USER'..."
  echo "Output will be saved to: $output_file"

  # Set PGPASSWORD environment variable securely for the command
  PGPASSWORD="$PG_PASSWORD" pg_dump \
    -h "$PG_HOST" \
    -p "$PG_PORT" \
    -U "$PG_USER" \
    -d "$PG_DBNAME" \
    -Fc \
    -f "$output_file"

  local exit_code=$?
  if [ $exit_code -eq 0 ]; then
    echo "Dump successful: $output_file"
  else
    echo "Error: pg_dump failed with exit code $exit_code."
  fi
  return $exit_code
}

# Function to restore a PostgreSQL database
# Usage: pg_restore_to_conn "postgresql://user:pass@host:port/dbname" [input_file.sql] [options]
# Default input_file.sql is "dump.sql"
# Default options include -c (clean/drop objects before recreating)
pg_restore_to_conn() {
  if [ -z "$1" ]; then
    echo "Usage: pg_restore_to_conn <target_connection_string> [input_file.sql] [options]"
    echo "  Example: pg_restore_to_conn \"postgresql://neon_user:pass@ep.neon.tech:5432/main\" \"supabase_backup.sql\""
    echo "  Options: -c (clean), --no-clean (don't clean, default if not specified is clean)"
    return 1
  fi

  local target_conn="$1"
  local input_file="${2:-dump.sql}" # Default to dump.sql if not provided
  local restore_options="-c"         # Default to cleaning (dropping objects first)

  # Check for --no-clean option
  for arg in "${@:3}"; do # Loop through arguments from the 3rd one onwards
    if [[ "$arg" == "--no-clean" ]]; then
      restore_options="" # Disable cleaning
      echo "Note: --no-clean specified. Existing objects will NOT be dropped before restore."
    elif [[ "$arg" == "-c" ]]; then
      restore_options="-c" # Explicitly enable clean (useful if overriding previous --no-clean)
      echo "Note: -c specified. Existing objects WILL be dropped before restore."
    else
      echo "Warning: Unknown option '$arg' ignored." >&2
    fi
  done

  if [ ! -f "$input_file" ]; then
    echo "Error: Input dump file '$input_file' not found." >&2
    return 1
  fi

  # Parse target connection string
  if ! _parse_pg_conn_string "$target_conn"; then
    return 1
  fi

  echo "Attempting to restore '$input_file' to database '$PG_DBNAME' on '$PG_HOST:$PG_PORT' with user '$PG_USER'..."

  # Set PGPASSWORD environment variable securely for the command
  PGPASSWORD="$PG_PASSWORD" pg_restore \
    -h "$PG_HOST" \
    -p "$PG_PORT" \
    -U "$PG_USER" \
    -d "$PG_DBNAME" \
    $restore_options \
    "$input_file"

  local exit_code=$?
  if [ $exit_code -eq 0 ]; then
    echo "Restore successful!"
  else
    echo "Error: pg_restore failed with exit code $exit_code."
  fi
  return $exit_code
}

# redis_url_to_n8n.sh

redis_url_to_n8n() {
    local url="$1"

    # Default values
    local proto host port db password ssl

    # Extract protocol
    proto="${url%%://*}"
    if [[ "$proto" == "rediss" ]]; then
        ssl="true"
    else
        ssl="false"
    fi

    # Remove protocol
    local rest="${url#*://}"

    # Extract password (if any)
    if [[ "$rest" == :* ]]; then
        password="${rest%%@*}"
        password="${password#:}"
        rest="${rest#*:}"
        rest="${rest#*@}"
    else
        password=""
        rest="${rest#*@}"
    fi

    # Extract host and port
    hostportdb="${url#*://}"
    hostportdb="${hostportdb#*@}"
    host="${hostportdb%%:*}"
    portdb="${hostportdb#*:}"
    port="${portdb%%/*}"
    db="${portdb#*/}"

    # If db is missing, default to 0
    if [[ "$db" == "$portdb" ]]; then
        db="0"
    fi

    # Output in n8n format
    echo "Host: $host"
    echo "Port: $port"
    echo "Password: $password"
    echo "Database: $db"
    echo "SSL: $ssl"
}

# Example usage:
# redis_url_to_n8n "redis://:mypassword@redis.example.com:6380/2"


# Optional: Unset PGPASSWORD after operations (if you exported it manually before calling functions)
# The functions set PGPASSWORD for the command only, so it shouldn't persist globally.
#

# Function to run n8n in Docker container
run_n8n() {
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
