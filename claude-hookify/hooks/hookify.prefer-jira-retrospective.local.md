---
name: prefer-jira-retrospective
enabled: true
event: user_prompt
pattern: (회고록|회고|retrospective|주간\s*정리|월간\s*정리|[Jj]ira\s*이슈\s*정리|업무\s*정리|이번\s*주\s*정리)
action: suggest
---

# Jira 회고록 자동화 도구 사용을 권장합니다

**jira-retrospective** 에이전트 또는 `/retrospective` 명령어를 사용하면 더 효율적입니다!

## 기능

- Jira 이슈 자동 검색 및 분류
- 프로젝트별 진행 현황 정리
- 완료율/진행률 통계 자동 계산
- Markdown 형식 회고록 자동 생성

## 사용 방법

### 명령어 사용
```
/retrospective
```

### 자연어 요청
- "회고록 작성해줘"
- "지난 주 업무 정리해줘"
- "Jira 이슈 기반으로 회고 만들어줘"

## 회고록에 포함되는 내용

| 섹션 | 내용 |
|------|------|
| 개요 | 총 이슈 수, 완료/진행중/대기 통계 |
| 프로젝트별 현황 | 이슈 유형별, 상태별 분류 |
| 주요 성과 | AI 분석 기반 성과 요약 |
| 다음 계획 | 진행 예정 및 모니터링 필요 항목 |

---

**이 도구를 사용하시겠습니까?**
