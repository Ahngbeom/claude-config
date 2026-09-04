#!/usr/bin/env bash
# Sync tracked ~/.claude files between global/ and the live ~/.claude directory.
# Usage: scripts/sync-global.sh push     # global/ -> ~/.claude (backs up files it overwrites)
#        scripts/sync-global.sh pull     # ~/.claude -> global/
#        scripts/sync-global.sh check    # verify in sync, nonzero on drift (local only)
set -euo pipefail
cd "$(dirname "$0")/.."

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
FILES=(
  "CLAUDE.md"
  "hooks/guard-k8s.py"
  "cleanup.sh"
)

mode="${1:-check}"
case "$mode" in push|pull|check) ;; *) echo "usage: $0 push|pull|check" >&2; exit 2 ;; esac

rc=0
for f in "${FILES[@]}"; do
  src="global/$f"; dst="$CLAUDE_DIR/$f"
  case "$mode" in
    push)
      mkdir -p "$(dirname "$dst")"
      if [ -f "$dst" ] && ! cmp -s "$src" "$dst"; then
        cp -p "$dst" "$dst.bak-$(date +%Y%m%d-%H%M%S)"
      fi
      cp -p "$src" "$dst"; echo "pushed: $dst" ;;
    pull)
      if [ -f "$dst" ]; then cp -p "$dst" "$src"; echo "pulled: $src"
      else echo "MISSING: $dst"; rc=1; fi ;;
    check)
      if [ ! -f "$dst" ]; then echo "MISSING: $dst"; rc=1
      elif ! cmp -s "$src" "$dst"; then echo "DRIFT: $dst differs from $src"; rc=1
      fi ;;
  esac
done
[ "$mode" = check ] && [ "$rc" = 0 ] && echo "global in sync"
exit $rc
