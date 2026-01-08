# 플러그인 관리 가이드

Claude Code 플러그인의 설치, 관리, 개발에 대한 가이드입니다.

## 목차

- [플러그인 개요](#플러그인-개요)
- [설치된 플러그인](#설치된-플러그인)
- [마켓플레이스](#마켓플레이스)
- [플러그인 관리 명령어](#플러그인-관리-명령어)
- [플러그인 활성화/비활성화](#플러그인-활성화비활성화)
- [커스텀 플러그인 개발](#커스텀-플러그인-개발)
- [MCP 서버 연동](#mcp-서버-연동)
- [트러블슈팅](#트러블슈팅)

---

## 플러그인 개요

Claude Code 플러그인은 기능을 확장하는 모듈입니다:

- **에이전트**: 전문 지식을 가진 서브에이전트
- **스킬**: 슬래시 명령어로 호출하는 기능 (`/commit`, `/hookify`)
- **훅**: 특정 이벤트에 반응하는 자동화

### 플러그인 구조

```
plugin/
├── plugin.json         # 플러그인 메타데이터
├── agents/             # 에이전트 정의
│   └── *.md
├── skills/             # 스킬 정의
│   └── *.md
└── hooks/              # 훅 정의
    └── *.md
```

---

## 설치된 플러그인

### 현재 활성화된 플러그인 (18개)

#### 커스텀 플러그인

| 플러그인 | 마켓플레이스 | 용도 |
|---------|-------------|------|
| `ahngbeom-dev-agents` | ahngbeom-claude-config | 전문 개발 에이전트 모음 |
| `i18n-automation` | mobidoc-plugins | Vue i18n 자동화 |

#### 공식 플러그인 (claude-plugins-official)

| 플러그인 | 카테고리 | 용도 |
|---------|----------|------|
| `commit-commands` | Git | `/commit`, `/commit-push-pr` 스킬 |
| `code-review` | 리뷰 | 코드 리뷰 자동화 |
| `pr-review-toolkit` | 리뷰 | PR 리뷰 전문 에이전트 모음 |
| `feature-dev` | 개발 | 기능 개발 가이드 |
| `hookify` | 자동화 | 커스텀 훅 규칙 관리 |
| `plugin-dev` | 개발도구 | 플러그인 개발 가이드 |
| `frontend-design` | 디자인 | 프론트엔드 UI 디자인 |
| `atlassian` | 통합 | Jira/Confluence 연동 |
| `figma` | 디자인 | Figma 디자인 연동 |
| `greptile` | 검색 | 코드베이스 검색 |
| `playwright` | 테스트 | 브라우저 자동화 |
| `security-guidance` | 보안 | 보안 가이드라인 |
| `explanatory-output-style` | 스타일 | 설명적 출력 스타일 |

#### LSP 플러그인

| 플러그인 | 언어 |
|---------|------|
| `typescript-lsp` | TypeScript/JavaScript |
| `jdtls-lsp` | Java |
| `swift-lsp` | Swift |

---

## 마켓플레이스

마켓플레이스는 플러그인을 배포하는 저장소입니다.

### 등록된 마켓플레이스

| 마켓플레이스 | 소스 | 용도 |
|-------------|------|------|
| `claude-plugins-official` | GitHub (anthropics) | 공식 플러그인 |
| `ahngbeom-claude-config` | GitHub (개인) | 커스텀 에이전트 |
| `mobidoc-plugins` | 로컬 디렉토리 | 프로젝트 전용 |

### 마켓플레이스 구조

```
~/.claude/plugins/
├── marketplaces/
│   ├── claude-plugins-official/    # 공식 마켓플레이스
│   │   ├── plugins/                # 플러그인 목록
│   │   └── external_plugins/       # 외부 플러그인
│   └── ahngbeom-claude-config/     # 커스텀 마켓플레이스
│       ├── agents/
│       └── plugins/
├── cache/                          # 설치된 플러그인 캐시
├── installed_plugins.json          # 설치 정보
└── known_marketplaces.json         # 마켓플레이스 정보
```

### 마켓플레이스 추가

```bash
# Git 저장소에서 추가
claude marketplace add https://github.com/username/my-plugins.git

# 로컬 디렉토리에서 추가
claude marketplace add /path/to/local/plugins
```

---

## 플러그인 관리 명령어

### 목록 확인

```bash
# 설치된 플러그인 목록
claude plugin list

# 특정 마켓플레이스의 플러그인
claude plugin list --marketplace claude-plugins-official
```

### 설치

```bash
# 기본 설치
claude plugin install <plugin-name>@<marketplace>

# 예시
claude plugin install commit-commands@claude-plugins-official
claude plugin install ahngbeom-dev-agents@ahngbeom-claude-config
```

### 업데이트

```bash
# 모든 플러그인 업데이트
claude plugin update

# 특정 플러그인 업데이트
claude plugin update commit-commands@claude-plugins-official
```

### 제거

```bash
claude plugin uninstall <plugin-name>@<marketplace>
```

---

## 플러그인 활성화/비활성화

### settings.json에서 관리

```json
{
  "enabledPlugins": {
    "ahngbeom-dev-agents@ahngbeom-claude-config": true,
    "commit-commands@claude-plugins-official": true,
    "hookify@claude-plugins-official": true,
    "some-plugin@marketplace": false  // 비활성화
  }
}
```

### CLI로 관리

```bash
# 활성화
claude plugin enable <plugin-name>@<marketplace>

# 비활성화
claude plugin disable <plugin-name>@<marketplace>
```

---

## 커스텀 플러그인 개발

### 1. 플러그인 구조 생성

```bash
mkdir -p my-plugin/{agents,skills,hooks}
```

### 2. plugin.json 작성

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "My custom plugin",
  "agents": ["agents/*.md"],
  "skills": ["skills/*.md"],
  "hooks": ["hooks/*.md"]
}
```

### 3. 에이전트 정의

`agents/my-agent.md`:

```markdown
---
name: my-agent
description: |
  Description of when to use this agent.
  Use when: keyword1, keyword2, keyword3
model: sonnet
color: blue
---

# My Agent System Prompt

You are an expert in...

## Core Knowledge
- Point 1
- Point 2

## Working Principles
1. Principle 1
2. Principle 2
```

### 4. 스킬 정의

`skills/my-skill.md`:

```markdown
---
name: my-skill
description: Description of the skill
---

# My Skill

Instructions for the skill...
```

### 5. 훅 정의

`hooks/my-hook.md`:

```markdown
---
name: my-hook
event: PreToolUse
matcher:
  tool: Bash
  command_pattern: "rm -rf"
action: block
---

위험한 명령어가 감지되었습니다!
```

### 6. 로컬 테스트

```bash
# 로컬 마켓플레이스로 추가
claude marketplace add /path/to/my-plugin

# 플러그인 설치
claude plugin install my-plugin@my-marketplace
```

---

## MCP 서버 연동

MCP (Model Context Protocol) 서버로 외부 도구를 연동할 수 있습니다.

### MCP 서버 추가

```bash
# NPX 패키지
claude mcp add anthropic-agent-skills -- npx -y @anthropic-ai/claude-code-mcp

# 로컬 서버
claude mcp add my-server -- node /path/to/server.js
```

### .mcp.json 설정

프로젝트 루트에 `.mcp.json` 생성:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["/path/to/server.js"],
      "env": {
        "API_KEY": "${MY_API_KEY}"
      }
    }
  }
}
```

### 추천 MCP 서버

| 서버 | 용도 | 설치 |
|------|------|------|
| `anthropic-agent-skills` | 문서 처리 (xlsx, docx, pdf) | `npx -y @anthropic-ai/claude-code-mcp` |
| `playwright` | 브라우저 자동화 | 플러그인에 포함 |
| `figma` | Figma 연동 | 플러그인에 포함 |

---

## 공식 플러그인 상세

### commit-commands

Git 커밋 자동화 스킬:

```
/commit              # 변경사항 커밋
/commit-push-pr      # 커밋 + 푸시 + PR
/clean_gone          # 삭제된 원격 브랜치 정리
```

### hookify

커스텀 훅 규칙 관리:

```
/hookify list        # 규칙 목록
/hookify configure   # 규칙 설정
/hookify help        # 도움말
```

### pr-review-toolkit

PR 리뷰 전문 에이전트:

- `code-reviewer`: 코드 품질 리뷰
- `silent-failure-hunter`: 에러 처리 검토
- `code-simplifier`: 코드 단순화
- `comment-analyzer`: 주석 분석
- `pr-test-analyzer`: 테스트 커버리지 분석
- `type-design-analyzer`: 타입 설계 분석

### feature-dev

기능 개발 가이드:

- `code-explorer`: 코드베이스 분석
- `code-architect`: 아키텍처 설계
- `code-reviewer`: 코드 리뷰

---

## 트러블슈팅

### Q: 플러그인이 목록에 없어요

**A: 마켓플레이스 업데이트**
```bash
claude marketplace update
```

**A: 캐시 삭제 후 재설치**
```bash
rm -rf ~/.claude/plugins/cache/<plugin-name>
claude plugin install <plugin-name>@<marketplace>
```

### Q: 플러그인이 작동하지 않아요

**A: 활성화 상태 확인**
```bash
claude plugin list
# 또는 settings.json의 enabledPlugins 확인
```

**A: 플러그인 재설치**
```bash
claude plugin uninstall <plugin-name>@<marketplace>
claude plugin install <plugin-name>@<marketplace>
```

### Q: 마켓플레이스 추가가 안돼요

**A: Git URL 확인**
- HTTPS URL 사용: `https://github.com/user/repo.git`
- SSH 키 설정 필요 시: `git@github.com:user/repo.git`

**A: 로컬 경로 확인**
- 절대 경로 사용
- `plugin.json` 또는 `.claude-plugin/` 디렉토리 존재 확인

### Q: 에이전트가 호출되지 않아요

**A: 에이전트 description 확인**
- description에 트리거 키워드가 명확히 포함되어야 함
- "Use when:" 패턴 권장

**A: 명시적 호출 테스트**
```
"<agent-name> 에이전트로 작업해줘"
```

### Q: 스킬 명령어가 없어요

**A: 플러그인 활성화 확인**
```bash
claude plugin enable <plugin-name>@<marketplace>
```

**A: 스킬 목록 확인**
```
/help
```

---

## 파일 위치 참조

| 파일 | 위치 | 용도 |
|------|------|------|
| 설치 정보 | `~/.claude/plugins/installed_plugins.json` | 설치된 플러그인 목록 |
| 마켓플레이스 | `~/.claude/plugins/known_marketplaces.json` | 등록된 마켓플레이스 |
| 플러그인 캐시 | `~/.claude/plugins/cache/` | 설치된 플러그인 파일 |
| 활성화 설정 | `~/.claude/settings.json` | enabledPlugins |

---

## 참고 자료

- [에이전트 활용 가이드](./agent-usage-guide.md)
- [Hookify 규칙 가이드](./hookify-rules-guide.md)
- [Claude Code 공식 문서](https://docs.anthropic.com/claude-code)

---

*문서 작성일: 2026-01-07*
*위치: ~/.claude/docs/plugin-management.md*
