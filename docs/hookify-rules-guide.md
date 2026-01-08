# Hookify 규칙 가이드

Hookify는 Claude Code의 특정 동작을 감지하고 에이전트 사용을 권장하는 시스템입니다.

## 목차

- [현재 활성화된 규칙](#현재-활성화된-규칙)
- [규칙 파일 구조](#규칙-파일-구조)
- [이벤트 타입](#이벤트-타입)
- [조건 연산자](#조건-연산자)
- [규칙 상세](#규칙-상세)
- [커스텀 규칙 작성](#커스텀-규칙-작성)
- [관리 명령어](#관리-명령어)
- [트러블슈팅](#트러블슈팅)

---

## 현재 활성화된 규칙

| 규칙 | 이벤트 | 트리거 | 권장 에이전트 |
|------|--------|--------|--------------|
| `prefer-git-committer` | bash | `git commit/push` | `/commit`, `/commit-push-pr` |
| `prefer-frontend-engineer` | file | `.tsx/.vue/.jsx` 파일 수정 | `frontend-engineer` |
| `prefer-backend-agent` | file | API/컨트롤러 파일 수정 | `backend-api-architect`, `nodejs-backend` |
| `prefer-database-expert` | file | migration/schema 파일 | `database-expert` |
| `prefer-test-automation` | file | `.test.ts/.spec.ts` 파일 | `test-automation-engineer` |
| `prefer-markdown-writer` | file | `.md` 파일 (긴 내용) | `markdown-document-writer` |
| `prefer-code-simplifier` | file | 코드 정의문 작성 | `code-simplifier` |

---

## 규칙 파일 구조

Hookify 규칙은 **YAML frontmatter + Markdown** 형식입니다.

```markdown
---
name: rule-name           # 규칙 고유 이름
enabled: true             # 활성화 여부
event: bash|file          # 이벤트 타입
pattern: regex            # (bash 이벤트) 명령어 패턴
conditions:               # (file 이벤트) 조건 목록
  - field: file_path|new_text
    operator: regex_match
    pattern: regex
action: warn              # 동작 (warn 권장)
---

# 경고 메시지 제목

경고 내용 (Markdown)
```

### 파일 위치

```
~/.claude/hookify.{rule-name}.local.md
```

- **`.local.md`** 접미사: 로컬 전용 규칙 (Git 추적 가능)
- 규칙 이름은 `hookify.` 접두사 뒤에 위치

---

## 이벤트 타입

### `bash` 이벤트

Bash 명령어 실행 시 트리거됩니다.

```yaml
event: bash
pattern: git\s+(commit|push)
```

**사용 예:**
- Git 명령어 감지
- npm/yarn 명령어 감지
- 시스템 명령어 감지

### `file` 이벤트

파일 생성/수정 시 트리거됩니다.

```yaml
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.(tsx|vue)$
  - field: new_text
    operator: regex_match
    pattern: (useState|useEffect)
```

**사용 가능한 field:**
- `file_path`: 파일 경로
- `new_text`: 새로 작성된 내용

---

## 조건 연산자

| 연산자 | 설명 | 예시 |
|--------|------|------|
| `regex_match` | 정규식 일치 | `pattern: \\.tsx$` |
| `contains` | 문자열 포함 | `pattern: useState` |
| `equals` | 정확히 일치 | `pattern: index.ts` |
| `starts_with` | 접두사 일치 | `pattern: src/` |
| `ends_with` | 접미사 일치 | `pattern: .test.ts` |

### 다중 조건

여러 조건은 **AND** 로직으로 처리됩니다:

```yaml
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.(ts|js)$        # 조건 1: TypeScript/JavaScript 파일
  - field: new_text
    operator: regex_match
    pattern: router\.(get|post) # 조건 2: Express 라우터 코드
```

→ 두 조건이 **모두** 만족해야 트리거

---

## 규칙 상세

### 1. prefer-git-committer

**목적:** 직접 git 명령어 대신 `/commit` 스킬 권장

```yaml
event: bash
pattern: git\s+(commit|push|add\s+.*&&.*commit)
```

**트리거 예:**
- `git commit -m "message"`
- `git push origin main`
- `git add . && git commit`

**권장 대안:**
```
/commit              # 커밋만
/commit-push-pr      # 커밋 + 푸시 + PR
```

---

### 2. prefer-frontend-engineer

**목적:** React/Vue 컴포넌트 작성 시 전문 에이전트 권장

```yaml
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.(tsx?|vue|jsx)$
  - field: new_text
    operator: regex_match
    pattern: (component|useState|useEffect|reactive|ref\(|computed\(|defineComponent)
```

**트리거 예:**
- `Button.tsx` 파일에 `useState` 작성
- `UserCard.vue` 파일에 `ref()` 작성

---

### 3. prefer-backend-agent

**목적:** API 엔드포인트 작성 시 백엔드 에이전트 권장

```yaml
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: (controller|route|api|endpoint|service)\.(ts|js)$
  - field: new_text
    operator: regex_match
    pattern: (router\.|app\.(get|post|put|delete)|@(Get|Post|Put|Delete)|@Controller)
```

**트리거 예:**
- `userController.ts`에 `@Get()` 데코레이터
- `api/auth.js`에 `router.post()` 작성

---

### 4. prefer-database-expert

**목적:** DB 스키마/마이그레이션 작업 시 에이전트 권장

```yaml
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: (migration|schema|seed|model)\.(ts|js|sql)$
```

**트리거 예:**
- `20240101_create_users.ts` 마이그레이션 파일 생성
- `schema.prisma` 수정
- `User.model.ts` 작성

---

### 5. prefer-test-automation

**목적:** 테스트 코드 작성 시 에이전트 권장

```yaml
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.(test|spec)\.(ts|js|tsx|jsx)$
```

**트리거 예:**
- `Login.test.tsx` 파일 수정
- `auth.spec.ts` 파일 생성

---

### 6. prefer-markdown-writer

**목적:** 문서 작성 시 에이전트 권장

```yaml
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.(md|markdown)$
  - field: new_text
    operator: regex_match
    pattern: ^#{1,6}\s+.{20,}  # 20자 이상의 긴 헤딩
```

**트리거 예:**
- `README.md`에 긴 섹션 헤딩 추가
- `API.md` 문서 작성

---

### 7. prefer-code-simplifier

**목적:** 코드 작성 후 단순화 에이전트 권장

```yaml
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.(ts|tsx|js|jsx|py|java|kt|go|rs|c|cpp|cs|php|rb|swift)$
  - field: new_text
    operator: regex_match
    pattern: (function|class|def |const |let |var |interface |type |enum )
```

**트리거 예:**
- 새로운 `function` 정의
- `class` 선언
- `interface` 타입 정의

---

## 커스텀 규칙 작성

### 예시: Docker 명령어 감지

```markdown
---
name: prefer-devops-agent
enabled: true
event: bash
pattern: docker\s+(build|run|compose)
action: warn
---

🐳 **Docker 작업이 감지되었습니다!**

**`devops-engineer` 에이전트** 사용을 권장합니다.

## 에이전트를 사용하면

✅ Dockerfile 최적화 (멀티스테이지 빌드)
✅ docker-compose 모범 사례
✅ 보안 설정 (non-root user, secrets)

**계속 진행하시겠습니까?**
```

저장 위치: `~/.claude/hookify.prefer-devops-agent.local.md`

### 예시: 환경변수 파일 감지

```markdown
---
name: warn-env-file
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.env(\..+)?$
action: warn
---

⚠️ **환경변수 파일 수정이 감지되었습니다!**

민감한 정보가 포함될 수 있습니다:
- API 키, 시크릿은 절대 커밋하지 마세요
- `.gitignore`에 포함되어 있는지 확인하세요

**계속 진행하시겠습니까?**
```

---

## 관리 명령어

### 규칙 목록 확인

```
/hookify list
```

### 규칙 활성화/비활성화

```
/hookify configure
```

대화형으로 규칙을 켜고 끌 수 있습니다.

### 규칙 도움말

```
/hookify help
```

---

## 트러블슈팅

### Q: 규칙이 트리거되지 않는 경우

**A: 파일 경로 확인**
```bash
# 파일 경로가 정규식과 일치하는지 확인
echo "src/components/Button.tsx" | grep -E '\.(tsx?|vue|jsx)$'
```

**A: enabled 확인**
```yaml
enabled: true  # false가 아닌지 확인
```

**A: 조건 로직 확인**
- 다중 조건은 AND 로직
- 모든 조건이 만족해야 트리거

### Q: 규칙을 일시적으로 무시하고 싶은 경우

경고 메시지에서 **"계속 진행"** 을 선택하면 해당 동작이 실행됩니다.

### Q: 특정 프로젝트에서만 규칙 적용

프로젝트별 규칙은 해당 프로젝트의 `.claude/` 디렉토리에 저장:
```
/project-root/.claude/hookify.custom-rule.local.md
```

---

## 참고 자료

- [에이전트 활용 가이드](./agent-usage-guide.md)
- [CLAUDE.md Agent Selection Matrix](../CLAUDE.md#agent-selection-matrix)
- [개별 에이전트 문서](../plugins/marketplaces/ahngbeom-claude-config/agents/)

---

*문서 작성일: 2026-01-07*
*위치: ~/.claude/docs/hookify-rules-guide.md*
