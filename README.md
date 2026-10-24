# pinger

Flashes a flat white bar on the right edge of your Mac screen when Claude Code or Codex needs you.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/AdalricP/pinger/main/install.sh | sh
```

Or clone the repo and run `./install.sh`. It needs `swiftc` (Xcode Command Line Tools).

The installer:

- builds the overlay
- adds a `pinger` skill to Claude Code and Codex
- adds hooks: Claude Code `Notification`, Codex `PermissionRequest` and `Stop`

Codex asks you to trust the new hooks on the next start.

## Use

```sh
pinger [seconds]    # default 3
```

Remove it with `./install.sh --uninstall`.
