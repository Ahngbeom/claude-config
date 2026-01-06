---
name: prefer-code-simplifier
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.(ts|tsx|js|jsx|py|java|kt|go|rs|c|cpp|cs|php|rb|swift)$
  - field: new_text
    operator: regex_match
    pattern: (function|class|def |const |let |var |interface |type |enum |impl |struct |trait )
action: warn
---

🧹 **코드 작성/수정이 감지되었습니다!**

코드 품질 향상을 위해 **`code-simplifier` 에이전트** 사용을 권장합니다.

## 에이전트를 사용하면

✅ **복잡한 코드 단순화** - 가독성과 유지보수성 향상
✅ **일관성 있는 코드 스타일** - 프로젝트 컨벤션 준수
✅ **불필요한 추상화 제거** - YAGNI 원칙 적용
✅ **중복 코드 감지 및 제거**
✅ **모든 기능 보존** - 동작은 그대로, 코드만 개선

## 사용 방법

코드 작성 후 다음과 같이 요청해주세요:
```
"작성한 코드를 단순화해줘"
"code-simplifier로 코드 리뷰해줘"
```

또는 자동으로 적용하려면:
```
"기능 구현하고 코드 단순화까지 해줘"
```

## 주요 개선 사항

- **과도한 추상화 제거** - 한 번만 사용되는 헬퍼 함수 인라인화
- **불필요한 복잡성 제거** - 발생할 수 없는 에러 처리 제거
- **명확한 코드 구조** - 중첩 감소, 조기 반환 패턴
- **타입 안전성 유지** - 기능은 보존하되 코드는 단순화

---

**계속 진행하시겠습니까?** (이 경고는 권장사항이며, 나중에 코드를 단순화할 수도 있습니다)
