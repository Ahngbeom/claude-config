---
name: prefer-git-committer
enabled: true
event: bash
pattern: git\s+(commit|push|add\s+.*&&.*commit)
action: warn
---

🤖 **Git 작업이 감지되었습니다!**

더 나은 커밋 메시지와 안전한 푸시를 위해 **`git-committer` 에이전트** 사용을 권장합니다.

## 에이전트를 사용하면

✅ **프로젝트 컨벤션에 맞는 커밋 메시지** 자동 생성
✅ **변경사항 검토 및 검증** - 의도하지 않은 파일 커밋 방지
✅ **안전한 푸시 프로세스** - 브랜치 확인, 충돌 체크
✅ **CLAUDE.md 작업 이력 자동 업데이트**

## 사용 방법

대신 다음과 같이 요청해주세요:
```
"변경사항을 커밋하고 푸시해줘"
"git-committer 에이전트로 커밋해줘"
```

Claude가 자동으로 `git-committer` 에이전트를 사용하여 안전하게 처리합니다.

---

**계속 진행하시겠습니까?** (이 경고는 권장사항이며, 직접 git 명령을 실행할 수도 있습니다)
