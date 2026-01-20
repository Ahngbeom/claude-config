---
name: prefer-frontend-engineer
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.(tsx?|vue|jsx)$
  - field: new_text
    operator: regex_match
    pattern: (component|useState|useEffect|reactive|ref\(|computed\(|defineComponent)
action: warn
---

🎨 **Frontend 컴포넌트 작업이 감지되었습니다!**

**`frontend-engineer` 에이전트** 사용을 권장합니다.

## 에이전트를 사용하면

✅ **최신 React/Vue 패턴** 적용 (Server Components, Composition API 등)
✅ **성능 최적화** - useMemo, useCallback, 코드 스플리팅
✅ **접근성(A11y)** 자동 고려 - ARIA, 키보드 네비게이션
✅ **타입 안전성** 보장 - TypeScript strict mode
✅ **일관된 스타일링** - Tailwind, CSS-in-JS 모범 사례

## 사용 방법

대신 다음과 같이 요청해주세요:
```
"frontend-engineer 에이전트로 버튼 컴포넌트 만들어줘"
"사용자 프로필 카드 컴포넌트 구현해줘"
```

Claude가 자동으로 `frontend-engineer` 에이전트를 사용하여 모범 사례에 따라 구현합니다.

## 주요 개선 사항

- **Server Components 우선** (Next.js 13+)
- **상태 관리 최적화** (TanStack Query, Zustand)
- **컴포넌트 재사용성** 향상
- **번들 크기 최적화**

---

**계속 진행하시겠습니까?**
