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

# C. push backs up the differing dir outside skills/ and outside cleanup.sh's pruned backups/
BAK="$tmp/sync-global-backups/skills"
scripts/sync-global.sh push >/dev/null
ls -d "$BAK"/korean-docs-* >/dev/null 2>&1 && ok "C backup under sync-global-backups/" || bad "C no backup under sync-global-backups/skills/"
[ "$(ls "$tmp/skills")" = "korean-docs" ] && ok "C nothing leaked into skills/" || bad "C extra entries in skills/: $(ls "$tmp/skills" | tr '\n' ' ')"
[ -e "$tmp/backups" ] && bad "C backup written to cleanup-pruned backups/" || ok "C backups/ untouched"

# D. push removes files that no longer exist in the repo
touch "$tmp/$DIR/stale.md"
scripts/sync-global.sh push >/dev/null
[ -e "$tmp/$DIR/stale.md" ] && bad "D stale file survived push" || ok "D stale file removed"

# E. check detects a file added only on the ~/.claude side
touch "$tmp/$DIR/extra.md"
scripts/sync-global.sh check >/dev/null && bad "E extra file not detected" || ok "E extra file detected"
rm "$tmp/$DIR/extra.md"

# F. no backup when content is identical
before=$(ls -d "$BAK"/korean-docs-* | wc -l)
scripts/sync-global.sh push >/dev/null
after=$(ls -d "$BAK"/korean-docs-* | wc -l)
[ "$before" = "$after" ] && ok "F identical push makes no backup" || bad "F identical push made a backup"

# G. check reports a missing directory
rm -rf "$tmp/$DIR"
scripts/sync-global.sh check >/dev/null && bad "G missing dir not detected" || ok "G missing dir detected"

# H. pull refuses to overwrite uncommitted repo work in a tracked dir
scripts/sync-global.sh push >/dev/null
probe="global/$DIR/.pull-guard-probe.md"
echo probe > "$probe"
scripts/sync-global.sh pull >/dev/null 2>&1 && bad "H pull ran over uncommitted work" || ok "H pull refused"
[ -f "$probe" ] && ok "H uncommitted file survived" || bad "H uncommitted file deleted by pull"
rm -f "$probe"

# I. pull mirrors cleanly when the repo dir has no local changes
if [ -z "$(git status --porcelain -- "global/$DIR")" ]; then
  scripts/sync-global.sh pull >/dev/null && ok "I clean pull succeeds" || bad "I clean pull failed"
  [ -z "$(git status --porcelain -- "global/$DIR")" ] && ok "I clean pull leaves repo unchanged" || bad "I clean pull changed repo"
else
  echo "skip: I (global/$DIR has local changes)"
fi

[ "$fail" = 0 ] && echo "SYNC TESTS PASSED" || echo "SYNC TESTS FAILED"
exit $fail
