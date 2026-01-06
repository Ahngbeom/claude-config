# 에이전트 활용 가이드

## 1. 기본 원칙

### ✅ DO: 에이전트를 적극적으로 사용하세요

**좋은 예:**
```
User: "로그인 API 구현해줘"
Claude: backend-api-architect 에이전트를 사용하여 API를 설계하겠습니다.
[Task tool 호출]
```

**나쁜 예:**
```
User: "로그인 API 구현해줘"
Claude: 직접 코드를 작성하겠습니다.
[직접 Write tool 사용] ← 이렇게 하면 안됨!
```

### ❌ DON'T: 에이전트 없이 직접 처리하지 마세요

특히 다음 작업은 **반드시** 에이전트를 사용:
- Git commit/push
- API 설계 및 구현
- Frontend 컴포넌트 작성
- 데이터베이스 스키마 변경
- 테스트 코드 작성
- 문서 작성

## 2. 작업별 에이전트 선택 가이드

### Git 작업
```bash
# 사용자 요청
"변경사항을 커밋하고 푸시해줘"

# Claude 응답
git-committer 에이전트를 사용하여 안전하게 커밋하겠습니다.
```

**에이전트를 사용해야 하는 이유:**
- ✅ 프로젝트 컨벤션에 맞는 커밋 메시지
- ✅ 변경사항 검토 및 검증
- ✅ 안전한 푸시 프로세스
- ✅ CLAUDE.md 자동 업데이트

### Frontend 개발

```bash
# 사용자 요청
"사용자 프로필 카드 컴포넌트 만들어줘"

# Claude 응답
frontend-engineer 에이전트로 React 컴포넌트를 구현하겠습니다.
```

**에이전트를 사용해야 하는 이유:**
- ✅ 최신 React/Vue 패턴 적용
- ✅ 성능 최적화 (memoization, code splitting)
- ✅ 접근성(A11y) 자동 고려
- ✅ TypeScript 타입 안전성

### Backend API 개발

```bash
# 사용자 요청
"회원가입 API 엔드포인트 만들어줘"

# Claude 응답
backend-api-architect 에이전트로 API를 설계하겠습니다.
```

**에이전트를 사용해야 하는 이유:**
- ✅ RESTful 설계 원칙
- ✅ 에러 핸들링 전략
- ✅ 보안 고려 (인증, 권한, validation)
- ✅ OpenAPI/Swagger 문서 생성

### 데이터베이스

```bash
# 사용자 요청
"유저 테이블에 이메일 인증 필드 추가"

# Claude 응답
database-expert 에이전트로 안전한 마이그레이션을 생성하겠습니다.
```

**에이전트를 사용해야 하는 이유:**
- ✅ 무중단 마이그레이션 전략
- ✅ 인덱스 최적화
- ✅ 데이터 무결성 보장
- ✅ 롤백 계획 자동 생성

### 테스트 작성

```bash
# 사용자 요청
"방금 만든 API에 대한 테스트 작성해줘"

# Claude 응답
test-automation-engineer 에이전트로 테스트를 작성하겠습니다.
```

**에이전트를 사용해야 하는 이유:**
- ✅ TDD 모범 사례
- ✅ 적절한 테스트 커버리지
- ✅ Mock/Stub 패턴
- ✅ E2E/통합/단위 테스트 전략

## 3. 에이전트 체인 활용

복잡한 작업은 여러 에이전트를 순차적으로 사용:

### 예시: 완전한 기능 구현

```bash
User: "회원가입 기능을 완전히 구현해줘"

Claude:
1️⃣ backend-api-architect로 API 설계
   → POST /api/auth/register 엔드포인트
   → 요청/응답 스키마 정의

2️⃣ database-expert로 스키마 생성
   → users 테이블 마이그레이션
   → 이메일 유니크 인덱스

3️⃣ nodejs-backend로 API 구현
   → 비즈니스 로직
   → 에러 핸들링

4️⃣ test-automation-engineer로 테스트 작성
   → 단위 테스트
   → E2E 테스트

5️⃣ git-committer로 커밋
   → "feat: Implement user registration"
```

## 4. Hookify 활성화

Hookify 규칙을 활성화하면 특정 작업 시 자동으로 에이전트 사용을 권장합니다:

```bash
# Hookify 규칙 확인
/hookify list

# Hookify 규칙 활성화/비활성화
/hookify configure
```

### 활성화된 규칙 (agent-usage-enforcer.yaml)

- ✅ **Git 작업**: `git commit/push` 감지 → git-committer 권장
- ✅ **Frontend**: `.tsx/.vue` 파일 수정 → frontend-engineer 권장
- ✅ **Backend**: API 파일 수정 → backend 에이전트 권장
- ✅ **Database**: 마이그레이션 파일 → database-expert 권장
- ✅ **Test**: `.test.ts` 파일 → test-automation-engineer 권장
- ✅ **Docs**: `.md` 파일 → markdown-document-writer 권장

## 5. 효과 측정

### 에이전트 사용 전 vs 후

**Before (에이전트 미사용):**
```
User: "로그인 API 만들어줘"
Claude: [직접 코드 작성]
  ❌ 보안 취약점 (SQL injection 가능)
  ❌ 에러 핸들링 누락
  ❌ 테스트 없음
  ❌ 문서화 없음
```

**After (에이전트 사용):**
```
User: "로그인 API 만들어줘"
Claude: [backend-api-architect 에이전트 사용]
  ✅ 보안 모범 사례 적용
  ✅ 포괄적인 에러 핸들링
  ✅ 자동 테스트 생성
  ✅ OpenAPI 문서 자동 생성
  ✅ 일관된 코드 스타일
```

## 6. 문제 해결

### Q: 에이전트가 여전히 사용되지 않는 경우

**A: CLAUDE.md 재확인**
```bash
# CLAUDE.md에 다음 섹션이 있는지 확인
cat ~/.claude/CLAUDE.md | grep "Agent Activation Rules"
```

**A: 명시적으로 에이전트 요청**
```
User: "frontend-engineer 에이전트를 사용해서 버튼 컴포넌트 만들어줘"
```

### Q: Hookify 규칙이 작동하지 않는 경우

**A: Hookify 상태 확인**
```bash
/hookify list
/hookify configure
```

**A: 규칙 파일 확인**
```bash
ls -la ~/.claude/.hooks/
cat ~/.claude/.hooks/agent-usage-enforcer.yaml
```

## 7. 베스트 프랙티스

### ✅ 항상 에이전트를 먼저 고려하세요

```
좋은 습관:
1. 작업 요청 받음
2. 어떤 에이전트가 적합한지 확인
3. 에이전트 사용
4. 결과 확인
```

### ✅ 에이전트 체인으로 복잡한 작업 처리

```
Feature 구현 → backend-api-architect
     ↓
Test 작성 → test-automation-engineer
     ↓
Commit → git-committer
```

### ✅ 에이전트 결과를 신뢰하세요

에이전트는 전문 지식을 가진 시니어 개발자처럼 작동하도록 설계되었습니다.

---

## 참고 자료

- [Agent Selection Matrix (CLAUDE.md)](/Users/bahn/.claude/CLAUDE.md#agent-selection-matrix)
- [Hookify 규칙](/Users/bahn/.claude/.hooks/agent-usage-enforcer.yaml)
- [개별 에이전트 문서](/Users/bahn/.claude/plugins/marketplaces/ahngbeom-claude-config/agents/)
