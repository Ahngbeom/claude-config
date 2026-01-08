# Claude Code Global Configuration

## Summary Instructions

When using compact, focus on:
- Code changes and implementations
- Test output and error messages
- API modifications
- Architectural decisions
- Current task progress and next steps

## Token Optimization Guidelines

### Preferred Patterns
- Use `@file_path` for direct file references
- Specify exact file paths and function names in queries
- Use `/compact` when context reaches 80%+
- Use `/clear` when switching to completely different tasks

### Session Management
- Same project, different feature: `/compact`
- Different project: `/clear`
- Long session (2h+): periodic `/compact` to avoid premium pricing

### Context Monitoring
- Monitor with `/context` command
- Target: keep below 80% before manual compact
- Auto-compact triggers at 95%

## Language Preference

Respond in Korean (한국어) unless explicitly requested otherwise.

## Agent Activation Rules

### Proactive Agent Usage
**CRITICAL**: Always use specialized agents for their respective domains. Do NOT handle these tasks directly.

### Agent Selection Matrix

| Task Type | Agent | Auto-Trigger Keywords |
|-----------|-------|----------------------|
| **Git Operations** | `git-committer` | "commit", "push", "커밋", "푸시", after completing features |
| **Frontend/React** | `frontend-engineer` | "컴포넌트", "리액트", "Vue", "UI", component architecture |
| **Backend API** | `backend-api-architect` or `nodejs-backend` or `spring-boot-backend` | "API", "엔드포인트", "REST", "GraphQL" |
| **Database** | `database-expert` | "스키마", "쿼리", "migration", "인덱스", "DB" |
| **Testing** | `test-automation-engineer` | "테스트", "test", "Jest", "Playwright" |
| **Documentation** | `markdown-document-writer` | "문서 작성", "README", "가이드" |
| **Data Analysis** | `data-analyst` | "데이터 분석", "통계", "Pandas", "시각화" |
| **DevOps** | `devops-engineer` | "배포", "CI/CD", "Docker", "Kubernetes" |
| **GitHub** | `github-expert` | "GitHub Actions", "workflow", "gh", "GitHub CLI" |
| **GitLab** | `gitlab-expert` | "GitLab CI", ".gitlab-ci.yml", "GitLab Runner" |
| **Jira 회고록** | `jira-retrospective` | "회고록", "회고", "retrospective", "주간 정리", "Jira 이슈 정리" |

### Mandatory Agent Usage

1. **After Code Completion**
   - Feature implementation → `git-committer` (자동으로 commit & push)
   - API changes → `backend-api-architect` 또는 해당 백엔드 에이전트로 리뷰
   - Frontend changes → `frontend-engineer`로 리뷰

2. **Code Quality**
   - 코드 리뷰 필요 시 → `pr-review-toolkit:code-reviewer`
   - 테스트 작성 → `test-automation-engineer`

3. **Documentation**
   - 문서화 작업 → `markdown-document-writer`
   - README, CLAUDE.md 업데이트 시

### Agent Workflow Examples

**Example 1: Feature Implementation**
```
User: "로그인 API 구현해줘"
→ 1. backend-api-architect로 API 설계 및 구현
→ 2. test-automation-engineer로 테스트 작성
→ 3. git-committer로 자동 commit & push
```

**Example 2: Frontend Component**
```
User: "사용자 프로필 컴포넌트 만들어줘"
→ 1. frontend-engineer로 컴포넌트 구현
→ 2. test-automation-engineer로 테스트 추가
→ 3. git-committer로 커밋
```

**Example 3: Database Schema Change**
```
User: "유저 테이블에 프로필 이미지 필드 추가"
→ 1. database-expert로 마이그레이션 생성 및 스키마 수정
→ 2. git-committer로 커밋
```

**Example 4: Jira 회고록 생성**
```
User: "지난 주 회고록 작성해줘"
→ 1. jira-retrospective로 Jira 이슈 검색 및 분석
→ 2. 프로젝트별 진행 현황 분류
→ 3. Markdown 회고록 파일 자동 생성
```

또는 `/retrospective` 명령어 사용:
```
/retrospective
→ Jira 설정 입력 (URL, 담당자)
→ 기간 및 출력 형식 선택
→ 회고록 자동 생성
```

## Project References

### Mobidoc 프론트엔드 (환자용 웹)
- **경로**: `/Users/bahn/Flyingdoctor/mobidoc-front/front-patient`
- **용도**: Flutter WebView에서 표시하는 웹 화면 소스코드
- Flutter 앱과 웹 연동 작업 시 함께 참조
