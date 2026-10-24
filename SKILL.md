---
name: pinger
description: Flash a flat white bar on the right edge of the user's Mac screen to get their attention. Use when you need the user (a decision, a permission, a question) or a long task just finished and they may be looking at another window. Also use when the user says "ping me", "flash the screen", or "pinger".
---

# pinger

Run the `pinger` script in the same folder as this SKILL.md:

```sh
<this folder>/pinger        # 3 s, three pulses
<this folder>/pinger 6      # longer
```

It returns at once, prints nothing, and does not take focus.

Use it once, right before you stop to wait for the user. Do not use it for routine progress.

Hooks also run it on their own: Claude Code `Notification` (permission prompts, idle waits) and Codex `PermissionRequest` and `Stop`.
