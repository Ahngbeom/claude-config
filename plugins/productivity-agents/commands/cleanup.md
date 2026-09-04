---
description: Claude Code 디렉터리 (~/.claude) 정리 및 디스크 공간 확보
argument-hint: "[auto|deep|status|dry-run]"
allowed-tools:
  - Bash(~/.claude/cleanup.sh *)
  - Bash(du *)
  - Bash(ls *)
  - Read
---

# ~/.claude 정리 스킬

`$ARGUMENTS` 인수로 모드를 선택합니다. 인수가 없으면 `status → deep` 순서로 실행합니다.

## 모드

| 모드 | 설명 |
|------|------|
| `status` | 디스크 사용량 및 마지막 정리 정보 표시 |
| `dry-run` | 삭제 대상 목록만 표시 (실제 삭제 없음) |
| `auto` | 24시간 주기 체크 후 경량 정리 |
| `deep` | auto + 비활성 프로젝트 / 고아 캐시 정리 |

## 워크플로우

### 인수 없이 `/cleanup` 호출 시

1. **현재 상태 확인**
   ```
   ~/.claude/cleanup.sh status
   ```

2. **사용자에게 실행 모드 확인**
   - `dry-run`: 삭제 대상만 미리 확인
   - `deep`: 전체 정리 실행

3. **선택한 모드 실행**
   ```
   ~/.claude/cleanup.sh <mode>
   ```

4. **결과 리포트** — 해제된 공간, 삭제 항목 수 요약

### `/cleanup status`
```
~/.claude/cleanup.sh status
```
현재 디스크 사용량과 마지막 정리 시간을 표시합니다.

### `/cleanup dry-run`
```
~/.claude/cleanup.sh dry-run
```
삭제될 파일/디렉터리를 미리 보여줍니다. 실제 삭제는 없습니다.

### `/cleanup deep`
```
~/.claude/cleanup.sh deep
```
전체 정리를 실행합니다. 비활성 프로젝트(디스크에서 삭제된 경로)와 고아 캐시도 정리합니다.

### `/cleanup auto`
```
~/.claude/cleanup.sh auto
```
24시간 주기 자동 정리를 수동으로 트리거합니다.

## 보호 파일 (절대 삭제 안 됨)

- `settings.json`, `.env`, `CLAUDE.md`, `history.jsonl`
- `plugins/marketplaces/`, `retrospectives/`
- `projects/*/memory/` (회고록 및 메모리 파일)
- `cleanup.sh`, `statusline.sh`, `stats-cache.json`
