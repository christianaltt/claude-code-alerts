# Claude Code macOS Alerts System

Native macOS alerts for [Claude Code](https://docs.anthropic.com/en/docs/build-with-claude/claude-code/overview). Get notified instantly when Claude needs your attention.

![Alert Screenshot](assets/claude-logo.png)

## Features

- **Instant notifications** - Ping sound + visual alert when Claude needs approval
- **Project context** - Shows which project needs attention
- **One-click approve** - Hit "Approve" to auto-send Enter keystroke
- **Quick navigation** - "Go to Session" focuses your terminal

## Prerequisites

- macOS (uses native `osascript` and `afplay`)
- [Claude Code](https://docs.anthropic.com/en/docs/build-with-claude/claude-code/overview) installed
- Accessibility permissions for System Events (prompted on first use)

## Setup

### 1. Clone the repo

```bash
git clone https://github.com/christianaltt/claude-code-alerts.git ~/.claude-code-alerts
```

### 2. Make the script executable

```bash
chmod +x ~/.claude-code-alerts/scripts/alert.sh
```

### 3. Add hooks to your Claude Code settings

Open `~/.claude/settings.json` and add:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude-code-alerts/scripts/alert.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude-code-alerts/scripts/alert.sh"
          }
        ]
      }
    ]
  }
}
```

See [examples/settings.json](examples/settings.json) for a complete example.

## How It Works

```
Claude Code Session
        │
        ▼
  Needs Permission ──────────────────┐
        │                            │
        ▼                            ▼
  Notification Hook              Stop Hook
        │                            │
        └──────────┬─────────────────┘
                   ▼
               alert.sh
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
   Play Sound   Show Dialog   Detect Terminal
    (Ping!)        │
                   ▼
        ┌──────────┼──────────┐
        ▼          ▼          ▼
     Approve   Go to Session  Close
        │          │
        ▼          ▼
  Send Enter    Focus
  Keystroke    Terminal
```

When Claude needs permission, the `Notification` hook triggers. The script:

1. Parses the JSON payload from Claude Code
2. Detects your terminal app from `$TERM_PROGRAM`
3. Plays a system sound (`Ping.aiff` or `Glass.aiff`)
4. Shows a native macOS dialog with action buttons
5. Handles button clicks (approve, navigate, or dismiss)

## Customization

### Change the notification sound

Edit `alert.sh` and modify the `SOUND` variables:

```bash
SOUND="/System/Library/Sounds/Ping.aiff"  # For notifications
SOUND="/System/Library/Sounds/Glass.aiff" # For completion
```

Available sounds in `/System/Library/Sounds/`:
- `Ping.aiff`, `Glass.aiff`, `Blow.aiff`, `Bottle.aiff`, `Frog.aiff`, `Funk.aiff`, `Hero.aiff`, `Morse.aiff`, `Pop.aiff`, `Purr.aiff`, `Sosumi.aiff`, `Submarine.aiff`, `Tink.aiff`

### Set a default terminal

If terminal detection isn't working, set your default in `alert.sh`:

```bash
# Change the fallback at the end of the terminal detection block
else
    TERMINAL_APP="Ghostty"  # or "iTerm", "Terminal", etc.
fi
```

### Supported terminals

Auto-detected via `$TERM_PROGRAM`:
- **VS Code** / Cursor / similar forks
- **Ghostty**
- **Terminal.app**
- **iTerm2**

## Troubleshooting

### "System Events" permission error

On first run, macOS will ask for Accessibility permissions. Grant access in:
**System Preferences → Privacy & Security → Accessibility**

### Alert appears but approve doesn't work

The "Approve" button sends an Enter keystroke via System Events. Make sure:
1. The terminal app name matches exactly (case-sensitive)
2. Accessibility permissions are granted
3. The Claude Code prompt is focused

### No sound plays

Check that your system volume is up and sounds aren't muted. The script uses `afplay` which respects system audio settings.

## License

MIT
