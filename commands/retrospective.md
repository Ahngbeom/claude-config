---
description: Jira 이슈 기반 회고록 자동 생성
allowed-tools: mcp__plugin_atlassian_atlassian__*, AskUserQuestion, Write, Read, Bash(jq:*), Bash(cat:*)
---

# Jira 회고록 생성

Jira 이슈를 분석하여 회고록을 자동 생성합니다.

## Step 1: Atlassian 인증 확인

먼저 현재 Atlassian 연결 상태를 확인합니다.

## Step 2: 설정 정보 수집

사용자에게 다음 정보를 AskUserQuestion으로 질문하세요:

### 필수 정보
1. **Jira Cloud URL** (예: yourcompany.atlassian.net)
2. **담당자 선택**:
   - 내 계정 사용 (현재 로그인된 계정)
   - 다른 사용자 (이메일 또는 이름으로 검색)

### 회고록 설정
3. **기간**: 1주일, 2주일, 1개월, 직접 지정
4. **출력 형식**: Markdown 파일, 콘솔 출력
5. **프로젝트 범위**: 전체, 특정 프로젝트
6. **이슈 상태**: 완료된 이슈만, 모든 이슈

## Step 3: 이슈 검색

수집된 정보를 바탕으로 JQL 쿼리를 구성하여 이슈를 검색합니다:

```
searchJiraIssuesUsingJql:
- cloudId: {사용자 입력 Jira URL}
- jql: assignee = "{ACCOUNT_ID}" AND updated >= -{기간}d ORDER BY updated DESC
- fields: ["summary", "status", "issuetype", "priority", "created", "updated", "project"]
```

## Step 4: 회고록 생성

이슈 데이터를 분석하여 다음 구조의 Markdown 회고록을 생성합니다:

```markdown
# 주간/월간 회고록

**기간**: YYYY-MM-DD ~ YYYY-MM-DD
**담당자**: {담당자명} ({이메일})
**생성일**: YYYY-MM-DD

## 개요
- 총 이슈 수: N개
- 완료: N개 | 진행중: N개 | 대기: N개

## 프로젝트별 진행 현황
### [프로젝트명]
#### 완료된 작업
- [이슈키] 제목 (유형)

## 주요 성과
1. 성과 요약

## 통계 요약
완료율: X%
```

## Step 5: 파일 저장

기본 저장 위치: `~/.claude/retrospective_YYYY-MM-DD.md`

---

## 사용 예시

```
/retrospective
```

또는 인자와 함께:
```
/retrospective --period=2weeks --output=console
```

## 주의사항

- Atlassian 인증이 필요합니다. 인증 오류 시 `/mcp`로 재인증하세요.
- 담당자 검색 시 정확한 이메일 또는 이름을 입력하세요.
