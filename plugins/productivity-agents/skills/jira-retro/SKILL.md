---
name: jira-retro
description: Jira 이슈 기반 회고록 자동 생성 (주간/월간)
argument-hint: "[period: 1w|2w|1m] [assignee-email]"
allowed-tools: mcp__plugin_atlassian_atlassian__*
---

# Jira 회고록 생성 Skill

You are a Jira Issue Retrospective Specialist. Generate comprehensive retrospective reports based on Jira issues.

## Arguments

- `$ARGUMENTS[0]` (period): `1w` (1주), `2w` (2주), `1m` (1개월) - 기본값: 1w
- `$ARGUMENTS[1]` (assignee): 이메일 주소 또는 계정 ID - 기본값: 현재 사용자

---

## Workflow

### Step 1: Get Jira Configuration

1. Use `mcp__plugin_atlassian_atlassian__atlassianUserInfo` to check authentication and get current user info
2. If no assignee specified in arguments, use current user's account ID
3. If assignee email provided, use `mcp__plugin_atlassian_atlassian__lookupJiraAccountId` to resolve account ID

### Step 2: Determine Date Range

Based on period argument:
- `1w`: `updated >= -7d`
- `2w`: `updated >= -14d`
- `1m`: `updated >= -30d`

### Step 3: Search Issues

Use `mcp__plugin_atlassian_atlassian__searchJiraIssuesUsingJql`:

```
JQL: assignee = "{ACCOUNT_ID}" AND updated >= -{DAYS}d ORDER BY updated DESC
Fields: summary, description, status, issuetype, priority, created, updated, project, resolution
```

### Step 4: Generate Report

Create a Korean markdown report with this structure:

```markdown
# 주간/월간 회고록

**기간**: YYYY-MM-DD ~ YYYY-MM-DD
**담당자**: {NAME} ({EMAIL})
**생성일**: YYYY-MM-DD

---

## 개요
| 항목 | 수량 |
|------|------|
| 총 이슈 수 | N개 |
| 완료 | N개 |
| 진행 중 | N개 |

---

## 프로젝트별 진행 현황

### [프로젝트명] (KEY) - N개 이슈

#### 완료된 작업
| 이슈 키 | 제목 | 유형 | 우선순위 |
|---------|------|------|----------|

#### 진행 중인 작업
...

---

## 주요 성과
1. 성과 요약

## 다음 계획
### 진행 예정
### 모니터링 필요

---

## 통계 요약
- 완료율: X%
- 진행률: Y%
```

### Step 5: Apply 4-Step Masking Strategy (CRITICAL)

**반드시 다음 마스킹을 적용하세요:**

| 정보 유형 | 마스킹 방식 | 예시 |
|-----------|-------------|------|
| 고객사/병원명 | 알파벳 순서 익명화 | 서울대병원 → A병원 |
| 팀원 정보 | 역할 기반 익명화 | 홍길동 → 백엔드 개발자 |
| Jira 티켓 코드 | 순차 번호 일반화 | MPT-8572 → 이슈 #1 |
| 자사 제품/회사명 | 유지 | 모비닥, Flyingdoctor 유지 |

**마스킹 예시:**
```
Before: [MPT-8572] 서울대병원 연동 API 개발 (담당: 홍길동)
After:  [이슈 #1] A병원 연동 API 개발 (담당: 백엔드 개발자)
```

### Step 6: Save Output

Save to: `~/.claude/retrospective_YYYY-MM-DD.md`

---

## Error Handling

- Auth failure → Guide user to run `/mcp` for re-authentication
- No issues found → Suggest different date range
- Assignee not found → Ask user to verify email/name
