#!/bin/bash
# ~/.claude/cleanup.sh - ~/.claude 캐시/로그 정리
# 모드: auto | run | status | dry-run
#
# 삭제 대상은 아래 TARGETS의 재생성 가능한 캐시뿐이다. 세션 기록, file-history(/rewind),
# tasks, plans, backups, plugins 는 Claude Code가 직접 관리하므로 건드리지 않는다.

set -uo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
STAMP="$CLAUDE_DIR/.cleanup-stamp"
AUTO_INTERVAL_MIN=1440
KEEP_SHELL_SNAPSHOTS=3

DRY_RUN=0
FREED_KB=0
ITEMS=0

kb_of() { du -sk "$1" 2>/dev/null | awk '{print $1}'; }
human() { awk -v k="${1:-0}" 'BEGIN{ if (k>=1048576) printf "%.1fGB", k/1048576; else if (k>=1024) printf "%.1fMB", k/1024; else printf "%dKB", k }'; }

remove() {
  local target="$1" kb
  [ -e "$target" ] || return 0
  kb=$(kb_of "$target"); kb=${kb:-0}
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '  [dry-run] %s (%s)\n' "$target" "$(human "$kb")" >&2
  else
    rm -rf "$target"
  fi
  FREED_KB=$(( FREED_KB + kb )); ITEMS=$(( ITEMS + 1 ))
}

empty_dir_contents() {
  local dir="$CLAUDE_DIR/$1" f
  [ -d "$dir" ] || return 0
  for f in "$dir"/* "$dir"/.[!.]*; do [ -e "$f" ] && remove "$f"; done
}

keep_newest() {
  local dir="$CLAUDE_DIR/$1" keep="$2" name
  [ -d "$dir" ] || return 0
  while IFS= read -r name; do
    remove "$dir/$name"
  done < <(ls -t "$dir" 2>/dev/null | tail -n +$(( keep + 1 )))
}

clean() {
  local f
  empty_dir_contents debug
  empty_dir_contents paste-cache
  empty_dir_contents telemetry
  keep_newest shell-snapshots "$KEEP_SHELL_SNAPSHOTS"
  if [ -d "$CLAUDE_DIR/session-env" ]; then
    for f in "$CLAUDE_DIR"/session-env/*/; do
      [ -d "$f" ] && [ -z "$(ls -A "$f" 2>/dev/null)" ] && remove "$f"
    done
  fi
  if [ -d "$CLAUDE_DIR/todos" ]; then
    while IFS= read -r -d '' f; do
      case "$(cat "$f" 2>/dev/null)" in ""|"[]") remove "$f" ;; esac
    done < <(find "$CLAUDE_DIR/todos" -type f -print0 2>/dev/null)
  fi
  for f in "$CLAUDE_DIR"/security_warnings_state_*.json; do [ -f "$f" ] && remove "$f"; done
  while IFS= read -r -d '' f; do remove "$f"; done < <(find "$CLAUDE_DIR" -name .DS_Store -print0 2>/dev/null)
  # 프로젝트 경로를 잘못 잡아 생기는 ~/.claude/.claude
  remove "$CLAUDE_DIR/.claude"
}

report() {
  printf '%s: %d items, %s\n' "$1" "$ITEMS" "$(human "$FREED_KB")" >&2
}

status() {
  local d
  printf '~/.claude total: %s\n' "$(human "$(kb_of "$CLAUDE_DIR")")"
  for d in debug paste-cache telemetry shell-snapshots session-env todos file-history projects; do
    [ -d "$CLAUDE_DIR/$d" ] && printf '  %-18s %s\n' "$d/" "$(human "$(kb_of "$CLAUDE_DIR/$d")")"
  done
  if [ -f "$STAMP" ]; then
    printf 'last cleanup: %s\n' "$(date -r "$STAMP" '+%Y-%m-%d %H:%M' 2>/dev/null || echo unknown)"
  else
    printf 'last cleanup: never\n'
  fi
}

case "${1:-auto}" in
  auto)
    # SessionStart 훅용: 24시간에 한 번만, 출력 없이
    [ -f "$STAMP" ] && [ -n "$(find "$STAMP" -mmin -"$AUTO_INTERVAL_MIN" 2>/dev/null)" ] && exit 0
    clean; touch "$STAMP" ;;
  run)     clean; touch "$STAMP"; report "freed" ;;
  dry-run) DRY_RUN=1; clean; report "would free" ;;
  status)  status ;;
  *) printf 'Usage: %s [auto|run|status|dry-run]\n' "$(basename "$0")" >&2; exit 1 ;;
esac
