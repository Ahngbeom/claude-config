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
| **Backend API** | `backend-api-architect` or `nodejs-backend` or `spring-boot-backend` or `python-fastapi-backend` | "API", "엔드포인트", "REST", "GraphQL" |
| **Python/FastAPI** | `python-fastapi-backend` | "FastAPI", "Pydantic", "uvicorn", "Python API", "async Python" |
| **Database** | `database-expert` | "스키마", "쿼리", "migration", "인덱스", "DB" |
| **Testing** | `test-automation-engineer` | "테스트", "test", "Jest", "Playwright" |
| **Documentation** | `markdown-document-writer` | "문서 작성", "README", "가이드" |
| **Data Analysis** | `data-analyst` | "데이터 분석", "통계", "Pandas", "시각화" |
| **Data Engineering** | `data-engineer` | "ETL", "파이프라인", "Spark", "Airflow", "데이터 웨어하우스" |
| **ML/AI** | `ml-engineer` | "모델 학습", "PyTorch", "TensorFlow", "MLOps", "LLM" |
| **Computer Vision** | `computer-vision-engineer` | "얼굴 인식", "MediaPipe", "OpenCV", "face_recognition", "랜드마크", "AR 필터" |
| **DevOps** | `devops-engineer` | "배포", "CI/CD", "Docker", "Kubernetes", "Terraform" |
| **GitHub** | `github-expert` | "GitHub Actions", "workflow", "gh", "GitHub CLI" |
| **GitLab** | `gitlab-expert` | "GitLab CI", ".gitlab-ci.yml", "GitLab Runner" |
| **Mobile App** | `mobile-app-developer` | "React Native", "Flutter", "iOS", "Android", "모바일 앱" |
| **AR Mobile** | `ar-mobile-developer` | "ARCore", "ARKit", "AR 필터", "얼굴 필터", "증강현실", "Face Mesh" |
| **Desktop App** | `desktop-app-developer` | "Electron", "Tauri", "데스크톱 앱" |
| **Healthcare Stats** | `healthcare-stats-normalizer`, `healthcare-stats-tester`, `healthcare-stats-forecaster` | "의료 데이터", "ICD", "SNOMED", "임상 통계", "헬스케어" |
| **Jira 회고록** | `jira-retrospective` | "회고록", "회고", "retrospective", "주간 정리", "Jira 이슈 정리" |
| **Git 커밋 회고록** | `commit-retrospective` | "커밋 회고", "Git 회고", "GitHub 회고", "GitLab 회고", "작업 이력 정리" |

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

**Example 5: Git 커밋 기반 회고록 생성**
```
User: "이번 주 내 커밋 회고록 작성해줘"
→ 1. commit-retrospective로 Git 커밋 히스토리 수집
→ 2. 커밋 유형별 분류 (feat, fix, docs 등)
→ 3. 레포지토리별 작업 내역 정리
→ 4. Markdown 회고록 파일 자동 생성
```

**Example 6: FastAPI 백엔드 개발**
```
User: "얼굴 분석 API 만들어줘 (FastAPI)"
→ 1. python-fastapi-backend로 API 엔드포인트 설계 및 구현
→ 2. Pydantic 스키마 정의
→ 3. test-automation-engineer로 pytest 테스트 작성
→ 4. git-committer로 커밋
```

**Example 7: 컴퓨터 비전/얼굴 분석**
```
User: "얼굴 랜드마크 분석 기능 구현해줘"
→ 1. computer-vision-engineer로 MediaPipe Face Mesh 연동
→ 2. 랜드마크 기반 측정 로직 구현
→ 3. python-fastapi-backend로 API 엔드포인트 연동
→ 4. git-committer로 커밋
```

**Example 8: AR 얼굴 필터 개발**
```
User: "실시간 AR 메이크업 필터 만들어줘"
→ 1. ar-mobile-developer로 ARKit/ARCore 연동
→ 2. computer-vision-engineer로 얼굴 랜드마크 매핑
→ 3. 필터 렌더링 및 오버레이 구현
→ 4. git-committer로 커밋
```

## Project References

프로젝트별 참조 경로는 각 프로젝트의 `.claude/settings.local.json`에서 설정하세요.
