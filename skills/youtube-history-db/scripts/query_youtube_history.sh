#!/usr/bin/env bash
set -euo pipefail

DB_PATH="/Volumes/External/Coding/youtube-history/youtube-history.db"

if [ ! -f "$DB_PATH" ]; then
  printf 'Database not found: %s\n' "$DB_PATH" >&2
  exit 1
fi

if [ "$#" -lt 1 ]; then
  printf 'Usage: %s "<sql>"\n' "$0" >&2
  exit 1
fi

sqlite3 -readonly -header -box "$DB_PATH" "$1"
