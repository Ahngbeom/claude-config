# Claude Code 빠른 시작 가이드

새 환경에서 Claude Code 설정을 빠르게 시작하기 위한 가이드입니다.

## 목차

- [설치](#설치)
- [필수 설정](#필수-설정)
- [자주 사용하는 명령어](#자주-사용하는-명령어)
- [에이전트 사용법](#에이전트-사용법)
- [세션 관리](#세션-관리)
- [설정 체크리스트](#설정-체크리스트)
- [트러블슈팅 FAQ](#트러블슈팅-faq)

---

## 설치

### 방법 1: 플러그인 설치 (권장)

```bash
# 에이전트 플러그인 설치
claude plugin install ahngbeom-dev-agents@ahngbeom-claude-config

# 공식 플러그인 설치
claude plugin install commit-commands@claude-plugins-official
claude plugin install hookify@claude-plugins-official
```

### 방법 2: Git Clone

```bash
# 설정 레포지토리 클론
git clone https://github.com/ahngbeom/claude-config ~/.claude
cd ~/.claude

# 스크립트 실행 권한 부여
chmod +x *.sh
```

### 방법 3: Sparse Checkout (플러그인 + 설정 병행)

플러그인으로 에이전트를 사용하면서 `~/.claude`를 Git으로 관리할 때:

```bash
git clone https://github.com/ahngbeom/claude-config ~/.claude
cd ~/.claude

# agents/ 제외 (플러그인에서 사용)
git sparse-checkout init
echo -e '/*\n!/agents/' > .git/info/sparse-checkout
git read-tree -mu HEAD
```

---

## 필수 설정

### 1. settings.json 설정

```bash
# 기본 설정 파일 생성
cp ~/.claude/settings.example.json ~/.claude/settings.json
```

**주요 설정 항목:**

```json
{
  "hooks": {
    "Stop": [{ "hooks": [{ "type": "command", "command": "~/.claude/stop-hook.sh" }] }],
    "Notification": [{ "hooks": [{ "type": "command", "command": "~/.claude/notify.sh '제목' '메시지'" }] }]
  },
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  },
  "enabledPlugins": {
    "ahngbeom-dev-agents@ahngbeom-claude-config": true,
    "commit-commands@claude-plugins-official": true,
    "hookify@claude-plugins-official": true
  }
}
```

### 2. CLAUDE.md 확인

전역 지침 파일 위치: `~/.claude/CLAUDE.md`

주요 내용:
- 언어 설정 (한국어 응답)
- 에이전트 활성화 규칙
- 토큰 최적화 가이드라인

### 3. 플러그인 활성화 확인

```bash
# 설치된 플러그인 목록
claude plugin list

# 플러그인 활성화
claude plugin enable ahngbeom-dev-agents@ahngbeom-claude-config
```

---

## 자주 사용하는 명령어

### 세션 관리

| 명령어 | 설명 |
|--------|------|
| `claude` | 새 세션 시작 |
| `claude --resume` | 이전 세션 재개 |
| `claude --resume <id>` | 특정 세션 재개 |
| `/clear` | 세션 초기화 (컨텍스트 삭제) |
| `/compact` | 컨텍스트 요약 (공간 확보) |
| `/compact [지침]` | 특정 내용 보존하며 요약 |

### 컨텍스트 확인

| 명령어 | 설명 |
|--------|------|
| `/cost` | 현재 세션 비용 |
| `/context` | 컨텍스트 사용량 시각화 |

### Git 작업

| 명령어 | 설명 |
|--------|------|
| `/commit` | 변경사항 커밋 |
| `/commit-push-pr` | 커밋 + 푸시 + PR 생성 |

### Hookify

| 명령어 | 설명 |
|--------|------|
| `/hookify list` | 규칙 목록 확인 |
| `/hookify configure` | 규칙 활성화/비활성화 |

### 도움말

| 명령어 | 설명 |
|--------|------|
| `/help` | 전체 도움말 |
| `/help <명령어>` | 특정 명령어 도움말 |

---

## 에이전트 사용법

### 명시적 호출

```
"frontend-engineer 에이전트로 버튼 컴포넌트 만들어줘"
"database-expert로 마이그레이션 생성해줘"
"test-automation-engineer로 테스트 작성해줘"
```

### 자동 트리거 (Hookify)

특정 작업 시 자동으로 에이전트 사용 권장:

| 트리거 | 권장 에이전트 |
|--------|--------------|
| `.tsx` 파일 수정 | `frontend-engineer` |
| API 파일 수정 | `backend-api-architect` |
| 마이그레이션 파일 | `database-expert` |
| `.test.ts` 파일 | `test-automation-engineer` |
| `git commit` 명령 | `/commit` 스킬 |

### 에이전트 체인

```
User: "회원가입 기능 전체 구현해줘"

Claude 작업 흐름:
1. backend-api-architect → API 설계
2. database-expert → 스키마 생성
3. nodejs-backend → API 구현
4. test-automation-engineer → 테스트 작성
5. /commit → 커밋
```

---

## 세션 관리

### 언제 `/compact` 사용?

- 컨텍스트 80% 이상 사용 시
- 같은 프로젝트 내 다른 기능으로 전환 시
- 긴 세션 (2시간+) 진행 시

```bash
# 기본 compact
/compact

# 특정 내용 보존
/compact 코드 변경사항과 에러 메시지 위주로 보존해줘
```

### 언제 `/clear` 사용?

- 완전히 다른 프로젝트로 전환 시
- 이전 컨텍스트가 불필요할 때

### 세션 재개

```bash
# 가장 최근 세션 재개
claude --resume

# 세션 목록 확인 후 특정 세션 재개
claude --resume abc123
```

---

## 설정 체크리스트

### 신규 환경 설정

- [ ] Claude Code 설치 (`npm install -g @anthropic-ai/claude-code`)
- [ ] 설정 레포 클론 또는 플러그인 설치
- [ ] `settings.json` 생성 및 설정
- [ ] 쉘 스크립트 실행 권한 부여 (`chmod +x ~/.claude/*.sh`)
- [ ] 플러그인 활성화 확인 (`claude plugin list`)
- [ ] Hookify 규칙 확인 (`/hookify list`)

### 프로젝트별 설정 (선택)

- [ ] 프로젝트 루트에 `.claude/` 디렉토리 생성
- [ ] 프로젝트용 `CLAUDE.md` 작성
- [ ] 프로젝트별 MCP 서버 설정 (`.mcp.json`)

### 일일 체크

- [ ] 세션 시작 전 컨텍스트 확인 (`/context`)
- [ ] 작업 완료 후 커밋 (`/commit`)
- [ ] 긴 세션 시 주기적 compact

---

## 트러블슈팅 FAQ

### Q: 에이전트가 활성화되지 않아요

**A: 플러그인 설치 확인**
```bash
claude plugin list
claude plugin enable ahngbeom-dev-agents@ahngbeom-claude-config
```

**A: CLAUDE.md 확인**
- `~/.claude/CLAUDE.md`에 Agent Activation Rules 섹션 존재 여부 확인

### Q: Hookify 규칙이 작동하지 않아요

**A: 규칙 활성화 확인**
```
/hookify list
/hookify configure
```

**A: 규칙 파일 확인**
```bash
ls ~/.claude/hookify.*.local.md
```

### Q: 컨텍스트가 너무 빨리 차요

**A: 토큰 절약 팁**
- 파일 직접 참조: `@src/components/Button.tsx`
- 명확한 질의: "Button.tsx:25 라인 수정해줘"
- 불필요한 파일 스캔 최소화

**A: 주기적 compact**
```
/compact 현재 작업 관련 내용만 보존해줘
```

### Q: 세션을 재개하고 싶어요

**A: 가장 최근 세션**
```bash
claude --resume
```

**A: 특정 세션**
```bash
# 세션 ID는 이전 세션 종료 시 표시됨
claude --resume <session-id>
```

### Q: 알림이 오지 않아요

**A: notify.sh 권한 확인**
```bash
chmod +x ~/.claude/notify.sh
~/.claude/notify.sh "테스트" "알림 테스트"
```

**A: macOS 알림 권한**
- 시스템 환경설정 → 알림 → 터미널 앱 허용

### Q: statusline이 표시되지 않아요

**A: 스크립트 권한 확인**
```bash
chmod +x ~/.claude/statusline.sh
~/.claude/statusline.sh
```

**A: settings.json 확인**
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

---

## 다음 단계

1. [에이전트 활용 가이드](./agent-usage-guide.md) - 에이전트 상세 사용법
2. [Hookify 규칙 가이드](./hookify-rules-guide.md) - 커스텀 규칙 작성
3. [Compact 전략](./compact-strategy.md) - 토큰 최적화

---

*문서 작성일: 2026-01-07*
*위치: ~/.claude/docs/quick-start.md*
