#!/bin/bash
# alert.sh - Show macOS alert when Claude Code needs attention
# Part of claude-code-alerts: https://github.com/christianaltt/claude-code-alerts

# Read hook input from stdin
INPUT=$(cat)

# Extract info from JSON
CWD=$(echo "$INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
MESSAGE=$(echo "$INPUT" | grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
HOOK_EVENT=$(echo "$INPUT" | grep -o '"hook_event_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
NOTIFICATION_TYPE=$(echo "$INPUT" | grep -o '"notification_type"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')

# Detect terminal from environment
if [ "$TERM_PROGRAM" = "vscode" ]; then
    TERMINAL_APP="Visual Studio Code"
elif [ "$TERM_PROGRAM" = "ghostty" ]; then
    TERMINAL_APP="Ghostty"
elif [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
    TERMINAL_APP="Terminal"
elif [ "$TERM_PROGRAM" = "iTerm.app" ]; then
    TERMINAL_APP="iTerm"
else
    # Default fallback - change this to your preferred terminal
    TERMINAL_APP="Terminal"
fi

# Get project name from cwd
PROJECT_NAME=$(basename "$CWD")

# Icon path (relative to this script's location)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ICON_PATH="$SCRIPT_DIR/../assets/claude-logo.icns"

# Set title, sound, and buttons based on event type
if [ "$HOOK_EVENT" = "Stop" ]; then
    TITLE="Claude Code Finished"
    SOUND="/System/Library/Sounds/Glass.aiff"
    DEFAULT_MSG="Task completed"
    BUTTONS='{"Go to Session"}'
    SHOW_APPROVE="false"
else
    TITLE="Claude Code"
    SOUND="/System/Library/Sounds/Ping.aiff"
    DEFAULT_MSG="Needs your attention"
    # Show Approve button for permission prompts
    if [ "$NOTIFICATION_TYPE" = "permission_prompt" ]; then
        BUTTONS='{"Approve", "Go to Session", "Close"}'
        SHOW_APPROVE="true"
    else
        BUTTONS='{"Go to Session", "Close"}'
        SHOW_APPROVE="false"
    fi
fi

# Use message from hook or default
if [ -z "$MESSAGE" ]; then
    MESSAGE="$DEFAULT_MSG"
fi

# Build alert message
ALERT_MSG="$PROJECT_NAME

$MESSAGE"

# Play sound
afplay "$SOUND" &

# Show dialog and handle button clicks
if [ "$SHOW_APPROVE" = "true" ]; then
    osascript << EOF
set iconPath to POSIX file "$ICON_PATH"
set dialogResult to display dialog "$ALERT_MSG" with title "$TITLE" buttons $BUTTONS default button 1 with icon iconPath

if button returned of dialogResult is "Approve" then
    tell application "$TERMINAL_APP" to activate
    delay 0.3
    tell application "System Events"
        keystroke return
    end tell
else if button returned of dialogResult is "Go to Session" then
    tell application "$TERMINAL_APP" to activate
end if
EOF
else
    osascript << EOF
set iconPath to POSIX file "$ICON_PATH"
set dialogResult to display dialog "$ALERT_MSG" with title "$TITLE" buttons $BUTTONS default button 1 with icon iconPath

if button returned of dialogResult is "Go to Session" then
    tell application "$TERMINAL_APP" to activate
end if
EOF
fi
