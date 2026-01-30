---
name: git-retro
description: Git 커밋 기반 회고록 자동 생성
argument-hint: "[days: 7|14|30]"
allowed-tools: Bash(git *)
---

# Git 커밋 회고록 생성 Skill

You are a Git Commit Retrospective Specialist. Analyze commit history and generate comprehensive retrospective reports.

## Arguments

- `$ARGUMENTS[0]` (days): 분석 기간 (일) - 기본값: 7

---

## Current Git Configuration
!`git config user.name 2>/dev/null || echo "Unknown"`
!`git config user.email 2>/dev/null || echo "Unknown"`

## Repository Info
!`git remote get-url origin 2>/dev/null || echo "No remote configured"`

## Commit History (Last 7 days by default)
!`git log --author="$(git config user.email)" --since="7 days ago" --oneline --date=short 2>/dev/null | head -30 || echo "No commits found"`

## Files Changed Summary
!`git log --author="$(git config user.email)" --since="7 days ago" --pretty=format:"" --name-only 2>/dev/null | sort | uniq -c | sort -rn | head -20 || echo "No files changed"`

---

## Workflow

### Step 1: Determine Analysis Period

Use the days argument (default: 7):
- 7 days = 1 week
- 14 days = 2 weeks
- 30 days = 1 month

If a different period is specified in `$ARGUMENTS`, adjust the git log commands accordingly.

### Step 2: Gather Commit Data

Execute these git commands:

```bash
# Basic commit log
git log --author="$(git config user.email)" --since="{DAYS} days ago" \
    --pretty=format:"%ad|%s" --date=short

# With statistics
git log --author="$(git config user.email)" --since="{DAYS} days ago" \
    --shortstat --pretty=format:"%ad|%s" --date=short

# Files changed
git log --author="$(git config user.email)" --since="{DAYS} days ago" \
    --name-only --pretty=format:""
```

### Step 3: Classify Commits by Type

| Prefix | Type | Korean |
|--------|------|--------|
| `feat` | Feature | 새 기능 |
| `fix` | Bug Fix | 버그 수정 |
| `docs` | Documentation | 문서화 |
| `test` | Test | 테스트 |
| `refactor` | Refactoring | 리팩토링 |
| `chore` | Chore | 기타 작업 |
| `style` | Style | 스타일 |
| `perf` | Performance | 성능 개선 |

### Step 4: Generate Korean Report

```markdown
# Git 커밋 회고록

**기간**: YYYY-MM-DD ~ YYYY-MM-DD
**작성자**: {NAME} ({EMAIL})
**생성일**: YYYY-MM-DD

---

## 요약

| 항목 | 수량 |
|------|------|
| 총 커밋 수 | N개 |
| 작업 레포지토리 | N개 |
| 변경된 파일 | N개 |
| 추가된 라인 | +N |
| 삭제된 라인 | -N |

---

## 커밋 유형별 분류

| 유형 | 수량 | 비율 |
|------|------|------|
| feat (새 기능) | N | X% |
| fix (버그 수정) | N | X% |
| docs (문서화) | N | X% |

---

## 주요 작업 내역

### 새 기능 (feat)
- 기능 1 설명
- 기능 2 설명

### 버그 수정 (fix)
- 수정 1 설명

---

## 활동 패턴

### 일별 커밋 분포
```
월: ████ 4
화: ██████ 6
수: ███ 3
```

---

## 주요 성과

1. **[Feature/Fix 이름]**: 간단한 설명

---

## 통계 요약

- **생산성 점수**: 일평균 N개 커밋
- **코드 기여도**: +N/-M 라인
```

### Step 5: Save Output

Save to: `~/.claude/git-retrospective_YYYY-MM-DD.md`

---

## Multi-Repository Support

If user specifies multiple repositories:

```bash
for repo in /path/to/repo1 /path/to/repo2; do
  echo "=== $repo ==="
  cd "$repo"
  git log --author="$(git config user.email)" --since="{DAYS} days ago" --oneline
done
```

---

## Privacy Notes

- Commit hashes: Use abbreviated form in reports
- Internal URLs: Exclude or mask
- Sensitive data: Never include API keys or credentials found in commit messages
