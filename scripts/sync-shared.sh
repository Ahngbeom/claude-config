#!/usr/bin/env bash
# Sync shared/references canonical files into plugin/codex consumers.
# Usage: scripts/sync-shared.sh           # write copies
#        scripts/sync-shared.sh --check    # verify in sync (CI), nonzero on drift
set -euo pipefail
cd "$(dirname "$0")/.."

SRC="shared/references/mobidoc-ui-ux-guidelines.md"
DESTS=(
  "plugins/frontend-agents/references/mobidoc-ui-ux-guidelines.md"
  "codex/skills/mobidoc-ui-ux-beta/references/mobidoc-ui-ux-guidelines.md"
)
HEADER="<!-- AUTO-GENERATED from ${SRC}. DO NOT EDIT. Run scripts/sync-shared.sh. -->"

render() { printf '%s\n' "$HEADER"; cat "$SRC"; }

check=0; [ "${1:-}" = "--check" ] && check=1
rc=0
for d in "${DESTS[@]}"; do
  mkdir -p "$(dirname "$d")"
  if [ "$check" = 1 ]; then
    if ! diff -q <(render) "$d" >/dev/null 2>&1; then
      echo "DRIFT: $d out of sync with $SRC"; rc=1
    fi
  else
    render > "$d"; echo "synced: $d"
  fi
done
exit $rc
