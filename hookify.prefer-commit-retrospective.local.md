# Hookify: Prefer commit-retrospective Agent

## Purpose
Git 커밋 히스토리 기반 회고록 작성이 필요한 경우 `commit-retrospective` 에이전트를 자동으로 활성화합니다.

## Trigger Keywords
다음 키워드가 감지되면 commit-retrospective 에이전트를 우선 사용합니다:
- "커밋 회고", "commit retrospective"
- "Git 회고록", "GitHub 회고", "GitLab 회고"
- "작업 이력 정리", "커밋 정리", "커밋 분석"
- "내 커밋", "my commits"

## Agent Selection Rules
| 상황 | 사용할 에이전트 |
|------|---------------|
| Jira 이슈 기반 회고 | `jira-retrospective` |
| Git 커밋 기반 회고 | `commit-retrospective` |
| 두 가지 모두 필요 | 두 에이전트 순차 실행 |

## Usage Examples

### 기본 사용
```
User: "이번 주 내 커밋 회고록 작성해줘"
→ commit-retrospective 에이전트 활성화
```

### 특정 레포지토리 지정
```
User: "mobidoc-front 레포지토리 커밋 회고록 만들어줘"
→ commit-retrospective 에이전트 활성화 (경로 지정)
```

### 기간 지정
```
User: "지난 달 내 GitHub 작업 내역 정리해줘"
→ commit-retrospective 에이전트 활성화 (30일 기간)
```

## Integration
- `jira-retrospective`: Jira 이슈와 커밋을 함께 분석할 때 협업
- `git-committer`: 커밋 컨벤션 참조
- `markdown-document-writer`: 회고록 포맷 개선
