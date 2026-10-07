#!/usr/bin/env bash
# Regression test for scripts/sync-global.sh against a throwaway CLAUDE_DIR.
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
ok()  { echo "ok:   $*"; }
bad() { echo "FAIL: $*"; fail=1; }

DIR="skills/korean-docs"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
export CLAUDE_DIR="$tmp"

# A. push installs the directory and check reports in sync
scripts/sync-global.sh push >/dev/null
[ -f "$tmp/$DIR/SKILL.md" ] && ok "A push installs dir" || bad "A push did not install $DIR"
scripts/sync-global.sh check >/dev/null && ok "A check in sync" || bad "A check reports drift after push"

# B. check detects a modified file
echo "edit" >> "$tmp/$DIR/SKILL.md"
scripts/sync-global.sh check >/dev/null && bad "B modified file not detected" || ok "B modified file detected"

# C. push backs up the differing dir outside skills/
scripts/sync-global.sh push >/dev/null
ls -d "$tmp"/backups/skills/korean-docs-* >/dev/null 2>&1 && ok "C backup under backups/" || bad "C no backup under backups/skills/"
ls -d "$tmp"/skills/korean-docs.bak* >/dev/null 2>&1 && bad "C backup leaked into skills/" || ok "C nothing leaked into skills/"

# D. push removes files that no longer exist in the repo
touch "$tmp/$DIR/stale.md"
scripts/sync-global.sh push >/dev/null
[ -e "$tmp/$DIR/stale.md" ] && bad "D stale file survived push" || ok "D stale file removed"

# E. check detects a file added only on the ~/.claude side
touch "$tmp/$DIR/extra.md"
scripts/sync-global.sh check >/dev/null && bad "E extra file not detected" || ok "E extra file detected"
rm "$tmp/$DIR/extra.md"

# F. no backup when content is identical
before=$(ls -d "$tmp"/backups/skills/korean-docs-* | wc -l)
scripts/sync-global.sh push >/dev/null
after=$(ls -d "$tmp"/backups/skills/korean-docs-* | wc -l)
[ "$before" = "$after" ] && ok "F identical push makes no backup" || bad "F identical push made a backup"

# G. check reports a missing directory
rm -rf "$tmp/$DIR"
scripts/sync-global.sh check >/dev/null && bad "G missing dir not detected" || ok "G missing dir detected"

[ "$fail" = 0 ] && echo "SYNC TESTS PASSED" || echo "SYNC TESTS FAILED"
exit $fail
