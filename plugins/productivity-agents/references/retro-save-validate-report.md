# 회고록 저장·검증·보고

회고 에이전트가 보고서를 만든 뒤 따르는 순서다. 1 → 2 → 3을 건너뛰지 않는다.

## 1. 파일 저장 규칙 (REQUIRED)

**1. 파일명 표준 (MANDATORY)**

**필수 형식**: `YYYY-MM-DD-YYYY-MM-DD-{type}-retrospective.md`

- `{type}`: `weekly`, `monthly`, `quarterly`
- 예시:
  - 주간: `2026-02-03-2026-02-09-weekly-retrospective.md`
  - 월간: `2026-01-01-2026-01-31-monthly-retrospective.md`
  - 분기: `2026-01-01-2026-03-31-quarterly-retrospective.md`

**금지 형식** (Legacy, 새 회고록에 사용 금지):
- ❌ `2025-10-monthly-retrospective.md` (날짜 범위 누락)
- ❌ `retrospective_YYYY-MM-DD.md` (기간 정보 부족)

**2. 중복 파일 검사 (MUST)**

저장 전 **반드시** 기존 파일 확인:

```bash
# 동일 기간 파일 검색
EXISTING_FILE=$(ls "$OUTPUT_DIR" | grep -E "^${START_DATE}-${END_DATE}-(weekly|monthly|quarterly)-retrospective\.md$")
```

같은 기간 파일이 있으면 덮어쓰지 않는다. 파일명 끝에 비어 있는 버전 번호를 붙여 새 파일로 저장한다(`...-retrospective-v2.md`, `-v3` …). 결과 보고에 기존 파일명과 새 파일명을 함께 적어, 덮어쓸지 호출한 쪽이 사용자에게 묻게 한다.

**3. Front Matter 필수 필드**

모든 회고록 파일은 다음 Front Matter를 **반드시** 포함:

```yaml
---
title: "{제목}"  # 형식은 에이전트 본문이 정한다
date: "YYYY-MM-DD"  # 회고록 생성일 (종료일 사용)
tags: [...]  # 에이전트 본문이 정한다
version: "1.0"  # 재생성 시 증가 (1.0, 1.1, 1.2 ...)
generated_by: "{에이전트 이름}"  # commit-retrospective 또는 jira-retrospective
---
```

**예시** (`jira-retrospective`):
```yaml
---
title: "월간 회고록 (2026.01.01 ~ 2026.01.31)"
date: "2026-01-31"
tags: [회고, 모비닥, 월간회고]
version: "1.0"
generated_by: "jira-retrospective"
---
```

**4. 기본 저장 경로**

```
Default: ~/.claude/retrospectives/YYYY/YYYY-MM-DD-YYYY-MM-DD-{type}-retrospective.md
```

- 연도별 디렉토리 자동 생성 (`mkdir -p ~/.claude/retrospectives/YYYY`)
- 디렉토리가 없으면 자동 생성
- 사용자가 다른 경로 지정 시 해당 경로 사용

**예시**:
```
~/.claude/retrospectives/
├── 2024/
│   ├── 2024-01-01-2024-01-31-monthly-retrospective.md
│   ├── 2024-04-01-2024-04-30-monthly-retrospective.md
│   └── 2024-07-01-2024-07-31-monthly-retrospective.md
└── 2026/
    ├── 2026-01-01-2026-01-31-monthly-retrospective.md
    └── 2026-02-01-2026-02-29-monthly-retrospective.md
```

**5. 출력 옵션**

- **파일 저장** (기본): 위 규칙에 따라 파일 생성
- **콘솔 출력**: 파일 저장 없이 Markdown 출력
- **Confluence 페이지 생성**: Atlassian MCP 사용 (사용자 요청 시)

## 2. 검증

파일 저장이나 Confluence 게시를 할 때 실행한다. Confluence에 게시하기 전에도 먼저 파일로 저장한다. 저장한 직후, 게시하거나 결과를 보고하기 전에 `retrospective-validator`로 민감정보(Jira 키, 이메일, 병원·고객사명, 개인정보, Git author 정보 등)를 검사한다.

```
Agent(
  subagent_type="productivity-agents:retrospective-validator",
  prompt="Validate file: {저장한_파일_경로}",
  description="Validate retrospective"
)
```

- 검출이 없으면 그대로 결과를 보고한다
- 검출이 있으면 파일을 고치지 않고, Confluence 출력이 요청됐어도 게시하지 않는다. 검증 결과를 결과 보고에 그대로 넣는다. 자동 수정·그대로 유지·삭제 중 무엇을 할지는 호출한 쪽이 사용자에게 묻는다

## 3. 호출한 쪽에 보고

마지막 응답은 호출한 쪽(메인 대화)이 읽는다. 다음만 담는다.

1. 저장한 파일 경로 (같은 기간 기존 파일이 있었으면 그 파일명도)
2. 통계 요약
3. `retrospective-validator` 결과: 검출 건수와 줄별 항목·권장 조치. 검출이 있으면 "사용자 확인 필요"로 시작한다
