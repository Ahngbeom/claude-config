#!/bin/bash
# ~/.claude/cleanup.sh - Claude Code 디렉터리 자동 정리 스크립트
# 모드: auto | deep | status | dry-run
# 참조: statusline.sh (jq 패턴), validate.sh (컬러 출력)

set -uo pipefail

CLAUDE_DIR="$HOME/.claude"
STATE_FILE="$CLAUDE_DIR/.cleanup-state.json"
AUTO_INTERVAL=86400  # 24시간

# ---- 컬러 출력 ----
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_GREEN=$'\033[38;5;150m'
  C_YELLOW=$'\033[38;5;222m'
  C_RED=$'\033[38;5;203m'
  C_BLUE=$'\033[38;5;117m'
  C_GRAY=$'\033[38;5;245m'
  C_BOLD=$'\033[1m'
  C_RST=$'\033[0m'
else
  C_GREEN="" C_YELLOW="" C_RED="" C_BLUE="" C_GRAY="" C_BOLD="" C_RST=""
fi

# ---- 유틸리티 ----
format_bytes() {
  local bytes="$1"
  if ! [[ "$bytes" =~ ^[0-9]+$ ]]; then echo "0B"; return; fi
  if   [ "$bytes" -ge 1073741824 ]; then printf '%.1fGB' "$(echo "scale=1; $bytes/1073741824" | bc)"
  elif [ "$bytes" -ge 1048576 ];    then printf '%.1fMB' "$(echo "scale=1; $bytes/1048576" | bc)"
  elif [ "$bytes" -ge 1024 ];       then printf '%.1fKB' "$(echo "scale=1; $bytes/1024" | bc)"
  else echo "${bytes}B"
  fi
}

dir_size_bytes() {
  local path="$1"
  [ -e "$path" ] || { echo 0; return; }
  du -sk "$path" 2>/dev/null | awk '{print $1 * 1024}' || echo 0
}

now_epoch() { date +%s; }

log_info()  { printf '  %s%s%s\n' "$C_BLUE"   "$1" "$C_RST" >&2; }
log_ok()    { printf '  %s✓ %s%s\n' "$C_GREEN"  "$1" "$C_RST" >&2; }
log_skip()  { printf '  %s- %s%s\n' "$C_GRAY"   "$1" "$C_RST" >&2; }
log_warn()  { printf '  %s⚠ %s%s\n' "$C_YELLOW" "$1" "$C_RST" >&2; }
log_error() { printf '  %s✗ %s%s\n' "$C_RED"    "$1" "$C_RST" >&2; }

# ---- 상태 파일 I/O ----
read_state() {
  if [ -f "$STATE_FILE" ] && command -v jq >/dev/null 2>&1; then
    jq '.' "$STATE_FILE" 2>/dev/null || echo '{}'
  else
    echo '{}'
  fi
}

save_state() {
  local freed_bytes="$1" items="$2" mode="$3"
  local now
  now=$(now_epoch)
  local prev_state
  prev_state=$(read_state)

  local last_auto last_deep
  last_auto=$(echo "$prev_state" | jq -r '.last_auto_cleanup // 0' 2>/dev/null || echo 0)
  last_deep=$(echo "$prev_state" | jq -r '.last_deep_cleanup // 0' 2>/dev/null || echo 0)

  if [ "$mode" = "auto" ]; then last_auto=$now; fi
  if [ "$mode" = "deep" ]; then last_auto=$now; last_deep=$now; fi

  if command -v jq >/dev/null 2>&1; then
    jq -n \
      --argjson last_auto "$last_auto" \
      --argjson last_deep "$last_deep" \
      --argjson interval "$AUTO_INTERVAL" \
      --argjson freed "$freed_bytes" \
      --argjson items "$items" \
      --argjson ts "$now" \
      '{
        last_auto_cleanup: $last_auto,
        last_deep_cleanup: $last_deep,
        auto_interval_seconds: $interval,
        last_result: {freed_bytes: $freed, items_removed: $items, timestamp: $ts}
      }' > "$STATE_FILE" 2>/dev/null
  fi
}

check_interval() {
  # 24시간 경과 여부 확인. 경과했으면 0(true), 아직이면 1(false)
  local state now last_auto elapsed
  state=$(read_state)
  now=$(now_epoch)
  last_auto=$(echo "$state" | jq -r '.last_auto_cleanup // 0' 2>/dev/null || echo 0)
  elapsed=$(( now - last_auto ))
  [ "$elapsed" -ge "$AUTO_INTERVAL" ]
}

# ---- 안전 목록 (절대 삭제 불가) ----
is_protected() {
  local path="$1"
  case "$path" in
    */settings.json|*/settings.json.backup|*/settings.example.json) return 0 ;;
    */.env|*/productivity-agents.json|*/CLAUDE.md|*/.gitignore)     return 0 ;;
    */history.jsonl|*/stats-cache.json|*/cleanup.sh|*/statusline.sh) return 0 ;;
    */activate-hooks.sh|*/.cleanup-state.json)                       return 0 ;;
    */plugins/marketplaces/*|*/plugins/installed_plugins.json)       return 0 ;;
    */plugins/installed_plugins_v2.json|*/plugins/known_marketplaces.json) return 0 ;;
    */retrospectives/*|*/projects/*/memory/*)                        return 0 ;;
    */memory/MEMORY.md|*/memory/*.md)                                return 0 ;;
  esac
  return 1
}

# ---- dry-run 지원 삭제 래퍼 ----
DRY_RUN=0
FREED_BYTES=0
ITEMS_REMOVED=0

safe_rm() {
  local target="$1"
  [ -e "$target" ] || return 0
  is_protected "$target" && { log_warn "보호됨: $target"; return 0; }

  local size
  size=$(dir_size_bytes "$target")

  if [ "$DRY_RUN" -eq 1 ]; then
    printf '  %s[dry-run]%s rm -rf %s  (%s)\n' "$C_YELLOW" "$C_RST" "$target" "$(format_bytes "$size")" >&2
  else
    rm -rf "$target"
    FREED_BYTES=$(( FREED_BYTES + size ))
    ITEMS_REMOVED=$(( ITEMS_REMOVED + 1 ))
  fi
}

safe_rm_glob() {
  # 글로브 패턴 삭제 (빈 결과 무시)
  local pattern="$1"
  for f in $pattern; do
    [ -e "$f" ] || continue
    safe_rm "$f"
  done
  return 0
}

# ============================================================
# auto 모드 정리 함수들
# ============================================================

clean_debug() {
  local dir="$CLAUDE_DIR/debug"
  if [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
    local size; size=$(dir_size_bytes "$dir")
    safe_rm_glob "$dir/*"
    log_ok "debug/  $(format_bytes "$size") 해제"
  else
    log_skip "debug/  (비어있음)"
  fi
}

clean_file_history() {
  local dir="$CLAUDE_DIR/file-history"
  if [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
    local size; size=$(dir_size_bytes "$dir")
    safe_rm_glob "$dir/*"
    log_ok "file-history/  $(format_bytes "$size") 해제"
  else
    log_skip "file-history/  (비어있음)"
  fi
}

clean_paste_cache() {
  local dir="$CLAUDE_DIR/paste-cache"
  if [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
    local size; size=$(dir_size_bytes "$dir")
    safe_rm_glob "$dir/*"
    log_ok "paste-cache/  $(format_bytes "$size") 해제"
  else
    log_skip "paste-cache/  (비어있음)"
  fi
}

clean_telemetry() {
  local dir="$CLAUDE_DIR/telemetry"
  if [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
    local size; size=$(dir_size_bytes "$dir")
    safe_rm_glob "$dir/*"
    log_ok "telemetry/  $(format_bytes "$size") 해제"
  else
    log_skip "telemetry/  (비어있음)"
  fi
}

clean_session_env() {
  local dir="$CLAUDE_DIR/session-env"
  [ -d "$dir" ] || { log_skip "session-env/  (없음)"; return; }
  local count=0
  for subdir in "$dir"/*/; do
    [ -d "$subdir" ] || continue
    if [ -z "$(ls -A "$subdir" 2>/dev/null)" ]; then
      safe_rm "$subdir"
      count=$(( count + 1 ))
    fi
  done
  [ "$count" -gt 0 ] && log_ok "session-env/  빈 디렉터리 ${count}개 삭제" || log_skip "session-env/  (빈 서브디렉터리 없음)"
}

clean_ds_store() {
  local count=0
  while IFS= read -r -d '' f; do
    safe_rm "$f"
    count=$(( count + 1 ))
  done < <(find "$CLAUDE_DIR" -name ".DS_Store" -print0 2>/dev/null)
  [ "$count" -gt 0 ] && log_ok ".DS_Store  ${count}개 삭제" || log_skip ".DS_Store  (없음)"
}

clean_empty_todos() {
  local dir="$CLAUDE_DIR/todos"
  [ -d "$dir" ] || { log_skip "todos/  (없음)"; return; }
  local count=0
  # 2바이트 = "[]" 만 있는 빈 파일
  while IFS= read -r -d '' f; do
    local content; content=$(cat "$f" 2>/dev/null || echo "")
    if [ "$content" = "[]" ] || [ -z "$content" ]; then
      safe_rm "$f"
      count=$(( count + 1 ))
    fi
  done < <(find "$dir" -type f -print0 2>/dev/null)
  [ "$count" -gt 0 ] && log_ok "todos/  빈 파일 ${count}개 삭제" || log_skip "todos/  (삭제 대상 없음)"
}

clean_backups() {
  local dir="$CLAUDE_DIR/backups"
  [ -d "$dir" ] || { log_skip "backups/  (없음)"; return; }
  # 최신 1개만 보존
  local count=0
  while IFS= read -r -d '' f; do
    safe_rm "$f"
    count=$(( count + 1 ))
  done < <(ls -t "$dir" 2>/dev/null | tail -n +2 | while IFS= read -r name; do printf '%s\0' "$dir/$name"; done)
  [ "$count" -gt 0 ] && log_ok "backups/  최신 1개 제외 ${count}개 삭제" || log_skip "backups/  (1개 이하)"
}

clean_plans() {
  local dir="$CLAUDE_DIR/plans"
  [ -d "$dir" ] || { log_skip "plans/  (없음)"; return; }
  # 최신 5개만 보존
  local count=0
  while IFS= read -r -d '' f; do
    safe_rm "$f"
    count=$(( count + 1 ))
  done < <(ls -t "$dir" 2>/dev/null | tail -n +6 | while IFS= read -r name; do printf '%s\0' "$dir/$name"; done)
  [ "$count" -gt 0 ] && log_ok "plans/  최신 5개 제외 ${count}개 삭제" || log_skip "plans/  (5개 이하)"
}

clean_tasks() {
  local dir="$CLAUDE_DIR/tasks"
  if [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
    local size; size=$(dir_size_bytes "$dir")
    safe_rm_glob "$dir/*"
    log_ok "tasks/  $(format_bytes "$size") 해제"
  else
    log_skip "tasks/  (비어있음)"
  fi
}

clean_shell_snapshots() {
  local dir="$CLAUDE_DIR/shell-snapshots"
  [ -d "$dir" ] || { log_skip "shell-snapshots/  (없음)"; return; }
  # 최신 3개만 보존
  local count=0
  while IFS= read -r -d '' f; do
    safe_rm "$f"
    count=$(( count + 1 ))
  done < <(ls -t "$dir" 2>/dev/null | tail -n +4 | while IFS= read -r name; do printf '%s\0' "$dir/$name"; done)
  [ "$count" -gt 0 ] && log_ok "shell-snapshots/  최신 3개 제외 ${count}개 삭제" || log_skip "shell-snapshots/  (3개 이하)"
}

clean_misc() {
  # security_warnings_state_*.json 삭제
  local count=0
  for f in "$CLAUDE_DIR"/security_warnings_state_*.json; do
    [ -f "$f" ] || continue
    safe_rm "$f"
    count=$(( count + 1 ))
  done
  [ "$count" -gt 0 ] && log_ok "security_warnings  ${count}개 삭제" || log_skip "security_warnings  (없음)"

  # 중첩 .claude 디렉터리 삭제 (실수로 생긴 ~/.claude/.claude/)
  local nested="$CLAUDE_DIR/.claude"
  if [ -d "$nested" ]; then
    safe_rm "$nested"
    log_ok ".claude/ 중첩 디렉터리 삭제"
  fi
}

# ============================================================
# deep 모드 추가 정리 함수들
# ============================================================

clean_stale_projects() {
  local projects_dir="$CLAUDE_DIR/projects"
  [ -d "$projects_dir" ] || { log_skip "projects/  (없음)"; return; }

  local deleted=0 warned=0 total_freed=0

  for dir in "$projects_dir"/*/; do
    [ -d "$dir" ] || continue
    local sessions_index="$dir/sessions-index.json"
    [ -f "$sessions_index" ] || continue

    # projectPath 추출
    local project_path
    project_path=$(jq -r '.. | .projectPath? // empty' "$sessions_index" 2>/dev/null | head -1)

    [ -z "$project_path" ] && continue
    # 실제 경로가 존재하면 건너뜀
    [ -d "$project_path" ] && continue

    # memory/ 있으면 경고만
    if [ -d "${dir}memory" ]; then
      log_warn "비활성 프로젝트 (memory 있음, 스킵): $(basename "$dir")  → $project_path"
      warned=$(( warned + 1 ))
    else
      local size; size=$(dir_size_bytes "$dir")
      safe_rm "$dir"
      total_freed=$(( total_freed + size ))
      deleted=$(( deleted + 1 ))
    fi
  done

  if [ "$deleted" -gt 0 ]; then
    log_ok "비활성 프로젝트  ${deleted}개 삭제, $(format_bytes "$total_freed") 해제"
  fi
  [ "$warned" -gt 0 ] && log_warn "memory 있는 비활성 프로젝트  ${warned}개 (수동 확인 필요)"
  [ "$deleted" -eq 0 ] && [ "$warned" -eq 0 ] && log_skip "비활성 프로젝트  (없음)"
}

clean_orphaned_cache() {
  local cache_dir="$CLAUDE_DIR/plugins/cache"
  [ -d "$cache_dir" ] || { log_skip "plugins/cache/  (없음)"; return; }

  local count=0
  for dir in "$cache_dir"/*/; do
    [ -d "$dir" ] || continue
    # .orphaned_at 마커 파일이 있으면 삭제
    if [ -f "${dir}.orphaned_at" ]; then
      safe_rm "$dir"
      count=$(( count + 1 ))
    fi
  done
  [ "$count" -gt 0 ] && log_ok "orphaned cache  ${count}개 삭제" || log_skip "plugins/cache/  (orphaned 없음)"
}

# ============================================================
# 메인 모드 함수들
# ============================================================

run_auto() {
  local before_size
  before_size=$(dir_size_bytes "$CLAUDE_DIR")

  clean_debug
  clean_file_history
  clean_paste_cache
  clean_telemetry
  clean_session_env
  clean_ds_store
  clean_empty_todos
  clean_backups
  clean_plans
  clean_tasks
  clean_shell_snapshots
  clean_misc

  save_state "$FREED_BYTES" "$ITEMS_REMOVED" "auto"

  # auto 모드: stdout에 JSON 출력 (훅용)
  local freed_mb
  freed_mb=$(echo "scale=1; $FREED_BYTES/1048576" | bc 2>/dev/null || echo "0")
  printf '{"cleanup_ran":true,"freed_mb":%s,"items":%d}\n' "$freed_mb" "$ITEMS_REMOVED"
}

run_deep() {
  printf '%s=== Claude Code 디렉터리 정리 (deep) ===%s\n' "$C_BOLD" "$C_RST" >&2

  local before_size
  before_size=$(dir_size_bytes "$CLAUDE_DIR")

  # auto 작업 먼저
  printf '\n%s[auto 단계]%s\n' "$C_BLUE" "$C_RST" >&2
  clean_debug
  clean_file_history
  clean_paste_cache
  clean_telemetry
  clean_session_env
  clean_ds_store
  clean_empty_todos
  clean_backups
  clean_plans
  clean_tasks
  clean_shell_snapshots
  clean_misc

  # deep 추가 작업
  printf '\n%s[deep 단계]%s\n' "$C_BLUE" "$C_RST" >&2
  clean_stale_projects
  clean_orphaned_cache

  save_state "$FREED_BYTES" "$ITEMS_REMOVED" "deep"

  local after_size
  after_size=$(dir_size_bytes "$CLAUDE_DIR")

  printf '\n%s=== 총 해제: %s (%s → %s) ===%s\n' \
    "$C_BOLD" \
    "$(format_bytes "$FREED_BYTES")" \
    "$(format_bytes "$before_size")" \
    "$(format_bytes "$after_size")" \
    "$C_RST" >&2
}

run_dry_run() {
  DRY_RUN=1
  printf '%s=== dry-run: 삭제 대상 목록 (실제 삭제 안 함) ===%s\n' "$C_BOLD" "$C_RST" >&2

  clean_debug
  clean_file_history
  clean_paste_cache
  clean_telemetry
  clean_session_env
  clean_ds_store
  clean_empty_todos
  clean_backups
  clean_plans
  clean_tasks
  clean_shell_snapshots
  clean_misc
  clean_stale_projects
  clean_orphaned_cache

  printf '\n%s=== dry-run 완료 (실제 삭제 없음) ===%s\n' "$C_BOLD" "$C_RST" >&2
}

run_status() {
  local state; state=$(read_state)
  local last_auto last_deep freed items
  last_auto=$(echo "$state" | jq -r '.last_auto_cleanup // 0' 2>/dev/null || echo 0)
  last_deep=$(echo "$state" | jq -r '.last_deep_cleanup // 0' 2>/dev/null || echo 0)
  freed=$(echo "$state" | jq -r '.last_result.freed_bytes // 0' 2>/dev/null || echo 0)
  items=$(echo "$state" | jq -r '.last_result.items_removed // 0' 2>/dev/null || echo 0)

  printf '%s=== ~/.claude 정리 상태 ===%s\n' "$C_BOLD" "$C_RST"

  # 디스크 사용량
  local total_size; total_size=$(dir_size_bytes "$CLAUDE_DIR")
  printf '\n%s디스크 사용량%s\n' "$C_BLUE" "$C_RST"
  printf '  ~/.claude 전체:  %s\n' "$(format_bytes "$total_size")"

  for subdir in debug file-history paste-cache telemetry tasks plans shell-snapshots backups; do
    local d="$CLAUDE_DIR/$subdir"
    [ -d "$d" ] && printf '  %-20s %s\n' "${subdir}/" "$(format_bytes "$(dir_size_bytes "$d")")"
  done

  # 마지막 정리 시간
  printf '\n%s마지막 정리%s\n' "$C_BLUE" "$C_RST"
  if [ "$last_auto" -gt 0 ]; then
    local auto_str; auto_str=$(date -r "$last_auto" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -d "@$last_auto" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "알 수 없음")
    printf '  auto:  %s\n' "$auto_str"
    local elapsed=$(( $(now_epoch) - last_auto ))
    local next=$(( AUTO_INTERVAL - elapsed ))
    if [ "$next" -gt 0 ]; then
      printf '  다음 auto 정리까지:  %dh %dm\n' "$(( next / 3600 ))" "$(( (next % 3600) / 60 ))"
    else
      printf '  %s다음 정리: 지금 실행 가능%s\n' "$C_GREEN" "$C_RST"
    fi
  else
    printf '  auto:  아직 실행 안 됨\n'
  fi

  if [ "$last_deep" -gt 0 ]; then
    local deep_str; deep_str=$(date -r "$last_deep" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -d "@$last_deep" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "알 수 없음")
    printf '  deep:  %s\n' "$deep_str"
  else
    printf '  deep:  아직 실행 안 됨\n'
  fi

  if [ "$freed" -gt 0 ]; then
    printf '\n%s마지막 정리 결과%s  %s 해제, %s개 항목\n' "$C_BLUE" "$C_RST" "$(format_bytes "$freed")" "$items"
  fi
}

# ============================================================
# main
# ============================================================

main() {
  local mode="${1:-auto}"

  case "$mode" in
    auto)
      if check_interval; then
        run_auto
      else
        # 24시간 미경과 — 아무것도 하지 않음 (stdout 없음)
        :
      fi
      ;;
    deep)
      run_deep
      ;;
    status)
      run_status
      ;;
    dry-run)
      run_dry_run
      ;;
    *)
      printf 'Usage: %s [auto|deep|status|dry-run]\n' "$(basename "$0")" >&2
      exit 1
      ;;
  esac
}

main "$@"
