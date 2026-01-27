#!/bin/bash
# Claude Code macOS Notification Hook
# Displays system notifications when Claude needs input

# Read JSON input from stdin
INPUT=$(cat)

# Parse fields from JSON
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude Code needs your attention"')
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // "unknown"')

# Set title and sound based on notification type
case "$NOTIFICATION_TYPE" in
  "permission_prompt")
    TITLE="Permission Required"
    SOUND="Ping"
    ;;
  "idle_prompt")
    TITLE="Waiting for Input"
    SOUND="Pop"
    ;;
  "elicitation_dialog")
    TITLE="Input Needed"
    SOUND="Ping"
    ;;
  *)
    TITLE="Notification"
    SOUND="default"
    ;;
esac

# Send notification using terminal-notifier
# -activate: brings kitty to foreground when clicked
terminal-notifier \
  -title "Claude Code" \
  -subtitle "$TITLE" \
  -message "$MESSAGE" \
  -sound "$SOUND" \
  -activate "com.mitchellh.ghostty" \
  -ignoreDnD \
  > /dev/null 2>&1

exit 0
