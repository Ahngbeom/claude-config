# Claude Code Sub Agents

전문화된 AI 에이전트 카탈로그입니다. 각 에이전트는 특정 영역의 전문가로, 복잡한 개발 작업을 효율적으로 처리합니다.

## 전체 에이전트 목록 (10개)

---

### 1. git-committer 🟢
**파일**: `git-committer.md`
**전문 분야**: Git 워크플로우, 버전 관리, 배포 프로세스

**주요 역할**:
- Git 변경사항 분석 및 커밋 메시지 작성
- 의미 있는 커밋 단위 구성
- 안전한 푸시 프로세스

**사용 예시**:
```
"I've finished adding the new authentication system. Can you commit and push these changes?"
"변경사항을 git commit, push 수행"
"README updated, please commit this"
```

**사용 시기**:
- API 구현 완료 후
- 테스트 코드 작성 후
- 문서 업데이트 후
- 버그 수정 후

---

### 2. markdown-document-writer 🔵
**파일**: `markdown-document-writer.md`
**전문 분야**: 기술 문서 작성, 정보 아키텍처, 마크다운 베스트 프랙티스

**주요 역할**:
- 구조화된 마크다운 문서 생성
- 기술 가이드 및 튜토리얼 작성
- 프로젝트 README 및 CLAUDE.md 작성

**사용 예시**:
```
"Can you help me create documentation for the authentication system I just built?"
"I need to organize these meeting notes into a clear markdown document"
"Please create a guide on how to set up the development environment"
```

**사용 시기**:
- 새 기능 문서화
- 회의록 정리
- 개발 가이드 작성

---

### 3. frontend-engineer 🔵
**파일**: `frontend-engineer.md`
**전문 분야**: React/Next.js, 상태 관리, UI/UX, 성능 최적화

**주요 역할**:
- React 컴포넌트 아키텍처 설계
- 상태 관리 (Redux, Zustand, TanStack Query)
- Tailwind CSS, Styled Components 스타일링
- 성능 최적화 (useMemo, lazy loading)
- 접근성 (A11y) 구현

**사용 예시**:
```
"frontend-engineer, 이 폼을 react-hook-form으로 리팩토링해줘"
"Next.js App Router로 새 페이지를 만들어줘"
"이 컴포넌트의 렌더링 성능을 최적화해줘"
```

**협업**:
- `backend-api-architect`: API 타입 정의 공유
- `test-automation-engineer`: data-testid 속성 추가

---

### 4. backend-api-architect 🟣
**파일**: `backend-api-architect.md`
**전문 분야**: Node.js/Express, Spring Boot, API 설계, 인증/인가

**주요 역할**:
- RESTful/GraphQL API 설계
- Express 미들웨어 체인 구성
- Spring Boot Controller/Service/Repository 패턴
- JWT 인증 및 OAuth2 구현
- 에러 핸들링 및 로깅

**사용 예시**:
```
"backend-api-architect, OpenAPI 스펙을 작성하고 Express 라우터를 만들어줘"
"Spring Boot로 사용자 인증 API를 구현해줘"
"이 API에 권한 체크 미들웨어를 추가해줘"
```

**협업**:
- `database-expert`: ORM 엔티티 정의 협의
- `frontend-engineer`: API 계약 (TypeScript 타입) 공유

---

### 5. database-expert 🟠
**파일**: `database-expert.md`
**전문 분야**: PostgreSQL/MySQL, 스키마 설계, 쿼리 최적화, 마이그레이션

**주요 역할**:
- 정규화된 스키마 설계
- 인덱스 전략 (B-Tree, GIN, GiST)
- 쿼리 성능 분석 (EXPLAIN ANALYZE)
- 무중단 마이그레이션
- 트랜잭션 및 동시성 제어

**사용 예시**:
```
"database-expert, 이 쿼리를 EXPLAIN으로 분석해줘"
"블로그 포스트 스키마를 설계해줘"
"이 테이블에 인덱스를 추가하되 무중단으로 진행해줘"
```

**협업**:
- `backend-api-architect`: 트랜잭션 범위 조율
- `test-automation-engineer`: 테스트 데이터 시드 작성

---

### 6. test-automation-engineer 🟡
**파일**: `test-automation-engineer.md`
**전문 분야**: Jest/Vitest, React Testing Library, Playwright, TDD

**주요 역할**:
- 유닛 테스트 작성 (Jest/Vitest)
- 컴포넌트 테스트 (React Testing Library)
- E2E 테스트 (Playwright)
- 모킹 전략 및 테스트 격리
- TDD Red-Green-Refactor 워크플로우

**사용 예시**:
```
"test-automation-engineer, 이 컴포넌트 테스트를 작성해줘"
"API 엔드포인트에 대한 통합 테스트를 추가해줘"
"E2E 로그인 플로우 테스트를 Playwright로 만들어줘"
```

**협업**:
- `frontend-engineer`: 테스트 가능한 컴포넌트 구조
- `backend-api-architect`: API 모킹 전략

---

### 7. healthcare-stats-normalizer 🔵
**파일**: `healthcare-stats-normalizer.md`
**전문 분야**: 의료 데이터 정규화, 표준화, 코드 매핑, 데이터 품질

**주요 역할**:
- 의료 코드 매핑 (ICD-10, ICD-11, SNOMED CT, LOINC, CPT)
- 데이터 정규화 및 표준화 (Z-score, Min-Max, Clinical Range)
- 결측치 처리 (KNN, MICE, 도메인 기반 대체)
- 이상치 탐지 (IQR, Z-score, 임상 범위 기반)
- 의료 단위 변환 (mg/dL ↔ mmol/L 등)

**사용 예시**:
```
"healthcare-stats-normalizer, 이 검사 결과 데이터를 정규화해줘"
"ICD-10 코드를 검증하고 카테고리별로 분류해줘"
"환자 데이터의 결측치를 임상적으로 적절하게 처리해줘"
```

**협업**:
- `data-analyst`: 정규화된 데이터셋 제공
- `healthcare-stats-tester`: 데이터 품질 메트릭 공유
- `healthcare-stats-forecaster`: 시계열 데이터 전처리

---

### 8. healthcare-stats-tester 🟠
**파일**: `healthcare-stats-tester.md`
**전문 분야**: 생물통계학, 가설 검정, 임상 시험 분석, 진단 평가

**주요 역할**:
- 통계적 가설 검정 (t-test, ANOVA, Chi-square, Mann-Whitney)
- 검정력 분석 및 표본 크기 계산
- 생존 분석 (Kaplan-Meier, Cox regression, Log-rank test)
- 진단 검사 평가 (ROC, AUC, Sensitivity, Specificity)
- 의료 데이터 품질 테스트

**사용 예시**:
```
"healthcare-stats-tester, 두 치료군 간 효과 차이를 검정해줘"
"이 진단 모델의 ROC 분석을 수행해줘"
"임상 시험에 필요한 표본 크기를 계산해줘"
```

**협업**:
- `healthcare-stats-normalizer`: 데이터 품질 검증
- `healthcare-stats-forecaster`: 예측 모델 검증
- `data-analyst`: 통계 방법론 조율

---

### 9. healthcare-stats-forecaster 🟣
**파일**: `healthcare-stats-forecaster.md`
**전문 분야**: 의료 시계열 예측, 수요 예측, 임상 결과 예측, 역학 모델링

**주요 역할**:
- 시계열 예측 (ARIMA, SARIMA, Prophet, LSTM)
- 환자 수요 예측 (응급실 방문, 입원, 병상 수요)
- 임상 결과 예측 (재입원 위험, 사망률 예측)
- 역학 모델링 (SEIR 모델, 감염병 발생 예측)
- 리스크 스코어 계산 (LACE Index 등)

**사용 예시**:
```
"healthcare-stats-forecaster, 다음 주 응급실 환자 수를 예측해줘"
"환자의 30일 재입원 위험도를 계산해줘"
"독감 시즌 피크를 예측하고 자원 계획을 세워줘"
```

**협업**:
- `healthcare-stats-normalizer`: 시계열 데이터 전처리
- `healthcare-stats-tester`: 예측 정확도 검증
- `devops-engineer`: 예측 모델 배포

---

### 10. commit-retrospective 🔵
**파일**: `commit-retrospective.md`
**전문 분야**: Git 커밋 히스토리 분석, 회고록 자동 생성, 작업 이력 추적

**주요 역할**:
- Git 커밋 히스토리 수집 및 분석
- 커밋 유형별 분류 (feat, fix, docs, refactor 등)
- 레포지토리별 작업 내역 정리
- 코드 변경 통계 계산 (파일 수, 라인 수)
- Markdown 형식 회고록 자동 생성

**사용 예시**:
```
"이번 주 내 커밋 회고록 작성해줘"
"지난 달 GitHub 작업 내역 정리해줘"
"mobidoc-front 레포지토리 커밋 분석해줘"
```

**사용 시기**:
- 주간/월간 업무 회고 작성 시
- 다중 레포지토리 작업 내역 종합 시
- 코드 기여도 분석이 필요할 때
- Git 기반 업무 보고서 작성 시

**협업**:
- `jira-retrospective`: Jira 이슈와 커밋을 함께 분석
- `git-committer`: 커밋 컨벤션 참조
- `markdown-document-writer`: 회고록 포맷 개선

---

## 다중 에이전트 협업 시나리오

### 시나리오 1: 완전한 기능 구현 (블로그 포스트 CRUD)

**순차적 실행**:
```
1️⃣ database-expert
   "블로그 포스트 스키마를 설계해줘 (제목, 내용, 작성자, 작성일)"

2️⃣ backend-api-architect
   "위 스키마로 블로그 포스트 CRUD API를 만들어줘 (Express + TypeORM)"

3️⃣ frontend-engineer
   "블로그 포스트 목록 페이지를 만들어줘 (Next.js + TanStack Query)"

4️⃣ test-automation-engineer
   "전체 CRUD 플로우에 대한 E2E 테스트를 작성해줘"

5️⃣ git-committer
   "블로그 포스트 기능을 커밋하고 푸시해줘"
```

### 시나리오 2: 성능 최적화 (병렬 실행)

```
"database-expert와 backend-api-architect와 frontend-engineer,
각자 영역에서 애플리케이션 성능을 최적화해줘"

→ database-expert: 쿼리 최적화, 인덱스 추가
→ backend-api-architect: 캐싱, N+1 쿼리 제거
→ frontend-engineer: 번들 크기 축소, lazy loading
```

### 시나리오 3: 새 API 엔드포인트 추가

```
1️⃣ backend-api-architect
   "POST /api/users 엔드포인트를 설계해줘 (validation, 인증)"

2️⃣ database-expert
   "users 테이블 스키마를 검토하고 필요한 마이그레이션을 작성해줘"

3️⃣ test-automation-engineer
   "API 통합 테스트를 작성해줘"

4️⃣ frontend-engineer
   "회원가입 폼을 만들고 API와 연결해줘"
```

---

## 에이전트 선택 가이드

| 작업 유형 | 추천 에이전트 |
|---------|------------|
| UI 컴포넌트 개발 | `frontend-engineer` |
| API 엔드포인트 설계 | `backend-api-architect` |
| 데이터베이스 스키마 | `database-expert` |
| 테스트 작성 | `test-automation-engineer` |
| 코드 커밋/푸시 | `git-committer` |
| 문서 작성 | `markdown-document-writer` |
| 쿼리 최적화 | `database-expert` |
| 인증 구현 | `backend-api-architect` |
| 상태 관리 | `frontend-engineer` |
| E2E 테스트 | `test-automation-engineer` |
| 의료 데이터 정규화 | `healthcare-stats-normalizer` |
| 의료 데이터 품질 검증 | `healthcare-stats-normalizer` |
| 통계적 가설 검정 | `healthcare-stats-tester` |
| 임상 시험 분석 | `healthcare-stats-tester` |
| 진단 모델 평가 | `healthcare-stats-tester` |
| 환자 수요 예측 | `healthcare-stats-forecaster` |
| 재입원 위험 예측 | `healthcare-stats-forecaster` |
| 역학 모델링 | `healthcare-stats-forecaster` |
| Git 커밋 회고록 | `commit-retrospective` |
| 작업 이력 분석 | `commit-retrospective` |

---

## 팁과 베스트 프랙티스

### 1. 명확한 컨텍스트 제공
```
❌ "이 코드를 최적화해줘"
✅ "frontend-engineer, 이 React 컴포넌트의 불필요한 리렌더링을 방지해줘"
```

### 2. 단계별 요청
큰 작업은 작은 단계로 나누기:
```
1. 스키마 설계 → 2. API 구현 → 3. UI 개발 → 4. 테스트
```

### 3. 협업 명시
여러 에이전트가 필요한 경우 명확히 요청:
```
"backend-api-architect와 database-expert, 함께 인증 시스템을 설계해줘"
```

### 4. 검증 요청
작업 후 검증:
```
"test-automation-engineer, 위 코드에 대한 테스트를 작성해서 검증해줘"
```

---

## 문제 해결

**Q: 에이전트가 활성화되지 않아요**
A: 에이전트 이름을 정확히 입력했는지 확인하세요. 대소문자는 구분하지 않지만 하이픈(`-`)은 정확해야 합니다.

**Q: 여러 에이전트를 동시에 사용할 수 있나요?**
A: 네! "X와 Y, 함께 Z를 해줘" 형식으로 요청하면 협업합니다.

**Q: 프로젝트별로 다른 에이전트를 만들 수 있나요?**
A: 네! 프로젝트 루트에 `.claude/agents/` 디렉토리를 만들면 프로젝트별 에이전트가 우선합니다.

---

**마지막 업데이트**: 2026-01-14
**총 에이전트 수**: 10개
