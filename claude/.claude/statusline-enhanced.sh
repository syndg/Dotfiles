#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract basic info
user=$(whoami)
dir=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$dir")
model=$(echo "$input" | jq -r '.model.display_name')

# Get git branch (skip optional locks for performance)
branch=$(git -C "$dir" -c core.fileMode=false rev-parse --abbrev-ref HEAD 2>/dev/null)

# Get context window info
usage=$(echo "$input" | jq '.context_window.current_usage')
context_size=$(echo "$input" | jq '.context_window.context_window_size // 200000')

# Get cost directly from JSON (provided by Claude Code)
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

if [ "$usage" != "null" ]; then
  # Current context tokens - include ALL tokens that count toward context
  # input_tokens: regular input tokens
  # cache_creation_input_tokens: tokens being cached (still count toward context)
  # cache_read_input_tokens: tokens read from cache (still count toward context)
  # output_tokens: model's output tokens (also count toward context window)
  current_input=$(echo "$usage" | jq '.input_tokens // 0')
  cache_creation=$(echo "$usage" | jq '.cache_creation_input_tokens // 0')
  cache_read=$(echo "$usage" | jq '.cache_read_input_tokens // 0')
  output_tokens=$(echo "$usage" | jq '.output_tokens // 0')

  # Total context = all input types + output (output counts toward context too)
  current_context=$((current_input + cache_creation + cache_read + output_tokens))

  # Context percentage
  if [ "$context_size" -gt 0 ]; then
    context_pct=$((current_context * 100 / context_size))
  else
    context_pct=0
  fi

  # Circular progress indicator (radial fill)
  # ○ = empty, ◔ = 25%, ◑ = 50%, ◕ = 75%, ● = full
  get_progress_circle() {
    local pct=$1
    if [ "$pct" -le 10 ]; then
      echo "○"
    elif [ "$pct" -le 30 ]; then
      echo "◔"
    elif [ "$pct" -le 55 ]; then
      echo "◑"
    elif [ "$pct" -le 80 ]; then
      echo "◕"
    else
      echo "●"
    fi
  }

  context_circle=$(get_progress_circle "$context_pct")

  # Session totals for display (cumulative across conversation)
  total_input=$(echo "$input" | jq '.context_window.total_input_tokens // 0')
  total_output=$(echo "$input" | jq '.context_window.total_output_tokens // 0')

  # Format tokens with K/M suffix
  format_tokens() {
    local tokens=$1
    if [ "$tokens" -ge 1000000 ]; then
      echo "$((tokens / 1000000))M"
    elif [ "$tokens" -ge 1000 ]; then
      echo "$((tokens / 1000))K"
    else
      echo "$tokens"
    fi
  }

  input_display=$(format_tokens "$total_input")
  output_display=$(format_tokens "$total_output")

  # Format cost - use awk for proper floating point formatting
  cost_formatted=$(echo "$cost_usd" | awk '{printf "$%.2f", $1}')

  # Build status line
  if [ -n "$branch" ]; then
    printf '%s %s (%s) | %s | %s %d%% | %s↓ %s↑ | %s' \
      "$user" "$dir_name" "$branch" "$model" "$context_circle" "$context_pct" \
      "$input_display" "$output_display" "$cost_formatted"
  else
    printf '%s %s | %s | %s %d%% | %s↓ %s↑ | %s' \
      "$user" "$dir_name" "$model" "$context_circle" "$context_pct" \
      "$input_display" "$output_display" "$cost_formatted"
  fi
else
  # No usage data yet
  if [ -n "$branch" ]; then
    printf '%s %s (%s) | %s' "$user" "$dir_name" "$branch" "$model"
  else
    printf '%s %s | %s' "$user" "$dir_name" "$model"
  fi
fi
