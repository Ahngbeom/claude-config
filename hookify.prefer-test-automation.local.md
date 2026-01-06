---
name: prefer-test-automation
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.(test|spec)\.(ts|js|tsx|jsx)$
action: warn
---

🧪 **테스트 코드 작업이 감지되었습니다!**

**`test-automation-engineer` 에이전트** 사용을 권장합니다.

## 에이전트를 사용하면

✅ **TDD 모범 사례** 적용 - Red-Green-Refactor
✅ **적절한 테스트 커버리지** - 핵심 로직 100% 커버
✅ **테스트 전략** - 단위/통합/E2E 테스트 분리
✅ **Mock/Stub 패턴** - 외부 의존성 격리
✅ **테스트 가독성** - Given-When-Then, AAA 패턴

## 사용 방법

대신 다음과 같이 요청해주세요:
```
"test-automation-engineer 에이전트로 로그인 API 테스트 작성해줘"
"방금 만든 컴포넌트에 대한 테스트 추가해줘"
"E2E 테스트 시나리오 작성해줘"
```

Claude가 자동으로 `test-automation-engineer` 에이전트를 사용하여 포괄적인 테스트를 작성합니다.

## 주요 개선 사항

### 테스트 품질
- **명확한 테스트 이름**: 무엇을 테스트하는지 한눈에 파악
- **독립적인 테스트**: 다른 테스트에 영향받지 않음
- **빠른 피드백**: 실행 시간 최소화

### 테스트 패턴
- **React Testing Library**: 사용자 관점 테스트
- **Jest/Vitest**: 스냅샷, 모킹, 커버리지
- **Playwright/Cypress**: E2E 시나리오

### 커버리지 전략
```
단위 테스트 (70-80%)
  ↓
통합 테스트 (15-20%)
  ↓
E2E 테스트 (5-10%)
```

## 예시: 좋은 테스트 vs 나쁜 테스트

### ❌ 나쁜 테스트
```typescript
it('test 1', () => {
  expect(true).toBe(true)  // 아무것도 테스트하지 않음
})
```

### ✅ 좋은 테스트
```typescript
describe('LoginForm', () => {
  it('should display error message when password is too short', async () => {
    // Given: 로그인 폼이 렌더링됨
    render(<LoginForm />)

    // When: 짧은 비밀번호 입력
    await userEvent.type(screen.getByLabelText('Password'), '123')
    await userEvent.click(screen.getByRole('button', { name: 'Login' }))

    // Then: 에러 메시지 표시
    expect(screen.getByText('Password must be at least 8 characters')).toBeInTheDocument()
  })
})
```

---

**계속 진행하시겠습니까?**
