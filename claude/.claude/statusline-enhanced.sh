#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract all fields in a single jq call
eval "$(echo "$input" | jq -r '
  @sh "dir=\(.workspace.current_dir)",
  @sh "model=\(.model.display_name)",
  @sh "context_size=\(.context_window.context_window_size)",
  @sh "cost_usd=\(.cost.total_cost_usd // 0)",
  @sh "usage_null=\(if .context_window.current_usage == null then "yes" else "no" end)",
  @sh "input_tokens=\(.context_window.current_usage.input_tokens // 0)",
  @sh "cache_creation=\(.context_window.current_usage.cache_creation_input_tokens // 0)",
  @sh "cache_read=\(.context_window.current_usage.cache_read_input_tokens // 0)",
  @sh "output_tokens=\(.context_window.current_usage.output_tokens // 0)"
')"

dir_name=$(basename "$dir")

# Get git branch
branch=$(git -C "$dir" -c core.fileMode=false rev-parse --abbrev-ref HEAD 2>/dev/null)

# ANSI colors
green='\033[32m'
yellow='\033[33m'
red='\033[31m'
dim='\033[2m'
reset='\033[0m'

if [ "$usage_null" = "no" ]; then
  # Context percentage
  current_context=$((input_tokens + cache_creation + cache_read + output_tokens))
  context_pct=$((current_context * 100 / context_size))

  # Color based on usage
  if [ "$context_pct" -le 50 ]; then
    bar_color="$green"
  elif [ "$context_pct" -le 75 ]; then
    bar_color="$yellow"
  else
    bar_color="$red"
  fi

  # Progress bar: 10 segments
  bar_width=10
  filled=$((context_pct * bar_width / 100))
  [ "$filled" -gt "$bar_width" ] && filled=$bar_width
  empty=$((bar_width - filled))

  bar="${bar_color}"
  for ((i=0; i<filled; i++)); do bar+="▓"; done
  bar+="${dim}"
  for ((i=0; i<empty; i++)); do bar+="░"; done
  bar+="${reset}"

  cost_formatted=$(echo "$cost_usd" | awk '{printf "$%.2f", $1}')

  # Build status line
  if [ -n "$branch" ]; then
    printf '%s (%s) | %s | %b %d%% | %s' \
      "$dir_name" "$branch" "$model" "$bar" "$context_pct" "$cost_formatted"
  else
    printf '%s | %s | %b %d%% | %s' \
      "$dir_name" "$model" "$bar" "$context_pct" "$cost_formatted"
  fi
else
  # No usage data yet
  if [ -n "$branch" ]; then
    printf '%s (%s) | %s' "$dir_name" "$branch" "$model"
  else
    printf '%s | %s' "$dir_name" "$model"
  fi
fi
