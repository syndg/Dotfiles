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

