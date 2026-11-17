---
description: Git 커밋 기반 회고록 자동 생성
argument-hint: "[days: 7|14|30]"
allowed-tools: Bash(git *)
---

# Git 커밋 회고록 생성

입력을 모아 `productivity-agents:commit-retrospective` 에이전트에 위임하고, 돌아온 결과를 사용자와 마무리한다. 커밋 수집·분류·보고서 형식·마스킹·저장 규칙은 에이전트가 갖고 있으니 여기서 직접 하지 않는다.

## 현재 저장소

- 경로: !`git rev-parse --show-toplevel 2>/dev/null || echo "Git 저장소 아님"`
- 작성자 이름: !`git config user.name 2>/dev/null || echo "Unknown"`
- 작성자 이메일: !`git config user.email 2>/dev/null || echo "Unknown"`

## 1. 입력 모으기

| 입력 | 값 |
|---|---|
| 기간 | `$ARGUMENTS[0]` (일). 없으면 7. 7·14·30은 `1w`·`2w`·`1m`으로, 그 밖의 값은 오늘까지의 날짜 범위 `YYYY-MM-DD ~ YYYY-MM-DD`로 넘긴다 |
| 저장소 | 위 경로. 사용자가 다른 저장소나 여러 저장소를 말했으면 그 경로들 |
| 작성자 | 위 이메일 |
| 저장 디렉터리 | `~/.claude/productivity-agents.json`의 `output.retrospectivePath`. 없으면 에이전트 기본값 |

현재 디렉터리가 Git 저장소가 아니고 저장소도 지정되지 않았거나, 작성자가 `Unknown`일 때만 AskUserQuestion으로 묻는다.

## 2. 위임

```
Agent(
  subagent_type="productivity-agents:commit-retrospective",
  description="Commit retrospective",
  prompt="Repository: {PATHS}\nAuthor: {EMAIL}\nPeriod: {PERIOD}\nOutput: file\nOutput directory: {DIR 또는 default}"
)
```

결과가 올 때까지 기다린다.

## 3. 결과 처리

`${CLAUDE_PLUGIN_ROOT}/references/retro-result-handling.md`를 읽고 그 순서대로 처리한다.
