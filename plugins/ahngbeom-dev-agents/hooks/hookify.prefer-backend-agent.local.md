---
name: prefer-backend-agent
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: (controller|route|api|endpoint|service)\.(ts|js)$
  - field: new_text
    operator: regex_match
    pattern: (router\.|app\.(get|post|put|delete|patch)|@(Get|Post|Put|Delete|Patch)|@Controller|express\(\))
action: warn
---

🔧 **API 엔드포인트 작업이 감지되었습니다!**

백엔드 아키텍처 에이전트 사용을 권장합니다:
- **`backend-api-architect`** (API 설계)
- **`nodejs-backend`** (Node.js/Express)
- **`spring-boot-backend`** (Spring Boot)

## 에이전트를 사용하면

✅ **RESTful API 설계 원칙** 적용
✅ **에러 핸들링 및 보안** 고려 (인증, 권한, validation)
✅ **일관된 API 구조** - 표준화된 응답 형식
✅ **OpenAPI/Swagger 문서** 자동 생성
✅ **미들웨어 패턴** - 인증, 로깅, CORS

## 사용 방법

대신 다음과 같이 요청해주세요:

**Node.js/Express:**
```
"nodejs-backend 에이전트로 로그인 API 만들어줘"
"회원가입 엔드포인트 구현해줘"
```

**Spring Boot:**
```
"spring-boot-backend 에이전트로 게시글 CRUD API 만들어줘"
```

**API 설계:**
```
"backend-api-architect로 결제 시스템 API 설계해줘"
```

## 주요 개선 사항

- **보안 강화**: JWT, 입력 검증, SQL injection 방지
- **에러 처리**: 통일된 에러 응답 형식
- **성능 최적화**: 캐싱, 페이지네이션
- **문서화**: 자동 API 문서 생성

---

**계속 진행하시겠습니까?**
