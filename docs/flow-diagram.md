# How Claude Code Alerts Works

## Flow Diagram

```mermaid
flowchart TD
    A[Claude Code Session] --> B{Needs Permission?}
    B -->|Yes| C[Notification Hook Fires]
    B -->|Task Complete| D[Stop Hook Fires]

    C --> E[alert.sh]
    D --> E

    E --> F[Parse JSON Payload]
    F --> G[Detect Terminal App]
    G --> H[Play Sound]
    H --> I[Show macOS Dialog]

    I --> J{User Action}

    J -->|Approve| K[Focus Terminal]
    K --> L[Send Enter Keystroke]
    L --> M[Permission Granted]

    J -->|Go to Session| N[Focus Terminal]

    J -->|Close| O[Dismiss Dialog]
```

## Sequence Diagram

```mermaid
sequenceDiagram
    participant CC as Claude Code
    participant Hook as Notification Hook
    participant Script as alert.sh
    participant macOS as macOS
    participant User as User
    participant Term as Terminal

    CC->>Hook: Permission needed (JSON payload)
    Hook->>Script: Execute with stdin
    Script->>Script: Parse JSON (cwd, message, type)
    Script->>Script: Detect terminal from $TERM_PROGRAM
    Script->>macOS: afplay Ping.aiff
    Script->>macOS: osascript (display dialog)
    macOS->>User: Show alert dialog

    alt User clicks Approve
        User->>macOS: Click "Approve"
        macOS->>Term: Activate terminal
        macOS->>Term: Send Enter keystroke
        Term->>CC: Permission granted
    else User clicks Go to Session
        User->>macOS: Click "Go to Session"
        macOS->>Term: Activate terminal
    else User clicks Close
        User->>macOS: Click "Close"
        Note over macOS: Dialog dismissed
    end
```

## Hook Payload Example

When Claude Code needs permission, it sends JSON like this to the hook:

```json
{
  "hook_event_name": "Notification",
  "notification_type": "permission_prompt",
  "message": "Claude wants to run: npm install",
  "cwd": "/Users/you/projects/my-app",
  "session_id": "abc123"
}
```

The script extracts:
- `cwd` → Project name for the alert
- `message` → What Claude wants to do
- `notification_type` → Whether to show Approve button
- `hook_event_name` → Which sound to play
