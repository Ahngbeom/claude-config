---
description: Claude Code 디렉터리 (~/.claude) 캐시·로그 정리
argument-hint: "[run|status|dry-run]"
allowed-tools:
  - Bash(~/.claude/cleanup.sh *)
---

# ~/.claude 정리

`$ARGUMENTS`로 모드를 고른다. 인수가 없으면 `status`와 `dry-run`을 보여 준 뒤, 사용자가 확인하면 `run`을 실행한다.

| 모드 | 동작 |
|------|------|
| `status` | `~/.claude`와 주요 하위 디렉터리 크기, 마지막 정리 시각 |
| `dry-run` | 삭제 대상과 크기만 출력 |
| `run` | 즉시 정리 |
| `auto` | SessionStart 훅용. 24시간에 한 번만 조용히 실행 |

실행: `~/.claude/cleanup.sh <mode>`

정리 대상은 재생성 가능한 캐시뿐이다: `debug/`, `paste-cache/`, `telemetry/`, 최신 3개를 뺀 `shell-snapshots/`, 빈 `session-env/` 하위 디렉터리, 빈 `todos/` 파일, `security_warnings_state_*.json`, `.DS_Store`, 중첩된 `~/.claude/.claude/`.

세션 기록, `file-history/`(/rewind 체크포인트), `tasks/`, `plans/`, `backups/`, `plugins/`, `projects/`는 지우지 않는다. 오래된 세션 기록은 settings의 `cleanupPeriodDays`로 Claude Code가 정리한다.

결과는 해제 용량과 삭제 항목 수로 요약한다.
