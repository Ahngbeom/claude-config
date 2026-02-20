---
name: prefer-markdown-writer
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.(md|markdown)$
  - field: new_text
    operator: regex_match
    pattern: ^#{1,6}\s+.{20,}
action: warn
---

📝 **문서 작성 작업이 감지되었습니다!**

**`markdown-document-writer` 에이전트** 사용을 권장합니다.

## 에이전트를 사용하면

✅ **체계적인 문서 구조** - 논리적인 섹션 구성
✅ **명확한 설명과 예제** - 실용적인 코드 샘플
✅ **일관된 포맷팅** - 마크다운 모범 사례
✅ **목차 및 링크 관리** - 내부 참조 자동 생성
✅ **SEO 최적화** - 검색 가능한 구조

## 사용 방법

대신 다음과 같이 요청해주세요:
```
"markdown-document-writer 에이전트로 API 문서 작성해줘"
"설치 가이드 만들어줘"
"README 업데이트해줘"
```

Claude가 자동으로 `markdown-document-writer` 에이전트를 사용하여 전문적인 문서를 작성합니다.

## 주요 개선 사항

### 문서 구조
```markdown
# 프로젝트 제목
간단한 설명

## 목차 (자동 생성)

## 시작하기
### 설치
### 빠른 시작

## 사용법
### 기본 예제
### 고급 기능

## API 레퍼런스
...
```

### 포함되는 요소
- **배지(Badges)**: 빌드 상태, 버전, 라이센스
- **코드 예제**: 실행 가능한 샘플
- **다이어그램**: Mermaid.js 플로우차트
- **스크린샷**: 시각적 가이드
- **FAQ**: 자주 묻는 질문

### 문서 타입별 최적화

**README.md**
- 프로젝트 개요, 설치, 빠른 시작
- 기여 가이드, 라이센스

**CHANGELOG.md**
- 버전별 변경사항
- Keep a Changelog 형식

**CONTRIBUTING.md**
- 기여 프로세스
- 코드 스타일, PR 가이드

**API Documentation**
- 엔드포인트 상세
- 요청/응답 예제
- 에러 코드

---

**💡 팁**: 좋은 문서는 코드만큼 중요합니다. 에이전트를 사용하면 전문적인 문서를 빠르게 작성할 수 있습니다.

**계속 진행하시겠습니까?**
