---
description: Jira 이슈 기반 회고록 자동 생성 (주간/월간)
argument-hint: "[period: 1w|2w|1m] [assignee-email]"
allowed-tools: mcp__plugin_atlassian_atlassian__*
---

# Jira 회고록 생성

입력을 모아 `productivity-agents:jira-retrospective` 에이전트에 위임하고, 돌아온 결과를 사용자와 마무리한다. 이슈 조회·보고서 형식·마스킹·저장 규칙은 에이전트가 갖고 있으니 여기서 직접 하지 않는다.

## 1. 입력 모으기

| 입력 | 값 |
|---|---|
| 기간 | `$ARGUMENTS[0]` (`1w`, `2w`, `1m`). 없으면 `1w` |
| 담당자 | `$ARGUMENTS[1]` (이메일 또는 계정 ID). 없으면 현재 사용자 |
| Jira Cloud URL | `~/.claude/productivity-agents.json`의 `atlassian.defaultUrl`. 없으면 `mcp__plugin_atlassian_atlassian__getAccessibleAtlassianResources`로 찾는다 |
| 저장 디렉터리 | 같은 파일의 `output.retrospectivePath`. 없으면 에이전트 기본값 |

Jira 사이트가 여러 개이거나 하나도 정해지지 않을 때만 AskUserQuestion으로 묻는다. 정해진 값은 다시 묻지 않는다.

## 2. 위임

```
Agent(
  subagent_type="productivity-agents:jira-retrospective",
  description="Jira retrospective",
  prompt="Jira Cloud URL: {URL}\nPeriod: {PERIOD}\nAssignee: {ASSIGNEE 또는 current user}\nOutput: file\nOutput directory: {DIR 또는 default}"
)
```

결과가 올 때까지 기다린다.

## 3. 결과 처리

`${CLAUDE_PLUGIN_ROOT}/references/retro-result-handling.md`를 읽고 그 순서대로 처리한다.

## 오류

- 인증 실패: `/mcp`로 Atlassian을 다시 인증하라고 안내한다
- 이슈 없음: 다른 기간을 제안한다
