# Git Commit, Add all and Push — in one step.
gcap() {
    git commit -m "$*"
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

# Source this file in your shell configuration to make the functions available
# For example, add the following line to your ~/.bashrc or ~/.bash_profile:
# source /path/to/this/file.sh
