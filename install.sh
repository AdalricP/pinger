#!/bin/sh
# Install pinger: build it, add the skill to Claude Code and Codex, add hooks.
#   ./install.sh              install (or re-install) from this folder
#   ./install.sh --uninstall  remove skills and hooks
# Run through curl it clones the repo to ~/.pinger first.
set -e
REPO="https://github.com/AdalricP/pinger.git"
DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
if [ ! -f "$DIR/pinger.swift" ]; then
  DIR="$HOME/.pinger"
  if [ -d "$DIR/.git" ]; then git -C "$DIR" pull -q; else git clone -q "$REPO" "$DIR"; fi
fi
CODEX="${CODEX_HOME:-$HOME/.codex}"
MODE="${1:-install}"

if [ "$MODE" != "--uninstall" ]; then
  command -v swiftc >/dev/null || { echo "swiftc not found: run xcode-select --install"; exit 1; }
  mkdir -p "$DIR/bin"
  swiftc -O "$DIR/pinger.swift" -o "$DIR/bin/pinger-overlay"
  chmod +x "$DIR/pinger"
fi

for home in "$HOME/.claude" "$CODEX"; do
  [ -d "$home" ] || continue
  rm -f "$home/skills/pinger"
  if [ "$MODE" != "--uninstall" ]; then
    mkdir -p "$home/skills" && ln -s "$DIR" "$home/skills/pinger"
  fi
done

# Hooks: Claude Code Notification; Codex PermissionRequest + Stop.
python3 - "$DIR/pinger" "$MODE" "$HOME/.claude/settings.json" "$CODEX/hooks.json" <<'PY'
import json, os, sys
cmd, mode, claude, codex = sys.argv[1:]
def mine(entry):
    return any(h.get("command", "").rstrip().endswith(("/pinger", "/pinger/ping")) for h in entry.get("hooks", []))
for path, events in ((claude, ["Notification"]), (codex, ["PermissionRequest", "Stop"])):
    if not os.path.isdir(os.path.dirname(path)):
        continue
    d = json.load(open(path)) if os.path.exists(path) else {}
    hooks = d.setdefault("hooks", {})
    for ev in events:
        hooks[ev] = [e for e in hooks.get(ev, []) if not mine(e)]
        if mode != "--uninstall":
            hooks[ev].append({"hooks": [{"type": "command", "command": cmd, "timeout": 5}]})
        if not hooks[ev]:
            del hooks[ev]
    json.dump(d, open(path, "w"), indent=2)
PY

if [ "$MODE" = "--uninstall" ]; then echo "pinger removed"; exit 0; fi
"$DIR/pinger"
echo "pinger installed from $DIR. You should see a white bar on the right edge now."
echo "Codex asks you to trust new hooks on next start (or run /hooks)."
