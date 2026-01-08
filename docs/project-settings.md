# 프로젝트별 설정 가이드

프로젝트별 Claude Code 환경을 커스터마이징하는 방법입니다.

## 목차

- [개요](#개요)
- [디렉토리 구조](#디렉토리-구조)
- [프로젝트별 CLAUDE.md](#프로젝트별-claudemd)
- [프로젝트별 에이전트](#프로젝트별-에이전트)
- [도구 제한 설정](#도구-제한-설정)
- [MCP 서버 연동](#mcp-서버-연동)
- [프로젝트 템플릿](#프로젝트-템플릿)
- [실전 예시](#실전-예시)
- [트러블슈팅](#트러블슈팅)

---

## 개요

### 설정 우선순위

Claude Code는 다음 순서로 설정을 적용합니다:

```
1. 프로젝트 레벨 (.claude/ in project root)  ← 최우선
2. 전역 레벨 (~/.claude/)                      ← 기본값
```

프로젝트별 설정이 전역 설정을 **오버라이드**합니다.

### 언제 사용하나요?

- 프로젝트마다 다른 에이전트 필요
- 특정 프로젝트에서만 사용하는 도구
- 프로젝트별 코딩 컨벤션
- 보안/권한이 다른 환경

---

## 디렉토리 구조

### 기본 구조

```
project-root/
├── .claude/
│   ├── CLAUDE.md              # 프로젝트 지침
│   ├── .mcp.json              # MCP 서버 설정
│   ├── settings.json          # 프로젝트 설정
│   ├── agents/                # 프로젝트 전용 에이전트
│   │   └── custom-agent.md
│   ├── skills/                # 프로젝트 전용 스킬
│   │   └── custom-skill.md
│   └── hooks/                 # 프로젝트 전용 훅
│       └── custom-hook.md
├── src/
└── package.json
```

### projects/ 디렉토리 (자동 생성)

```
~/.claude/projects/
├── -project-path-encoded/     # 프로젝트별 세션 데이터
│   ├── session-id-1.jsonl
│   ├── session-id-2.jsonl
│   └── ...
└── ...
```

---

## 프로젝트별 CLAUDE.md

### 생성

```bash
mkdir -p /path/to/project/.claude
touch /path/to/project/.claude/CLAUDE.md
```

### 기본 템플릿

```markdown
# Project Name - Claude Code Configuration

## 프로젝트 개요

간단한 프로젝트 설명

## 기술 스택

- **Frontend**: React 18, TypeScript, Tailwind CSS
- **Backend**: Node.js, Express, PostgreSQL
- **Testing**: Jest, Playwright

## 코딩 컨벤션

### 네이밍 규칙
- 컴포넌트: PascalCase (`UserProfile.tsx`)
- 함수: camelCase (`getUserData()`)
- 상수: UPPER_SNAKE_CASE (`API_BASE_URL`)

### 파일 구조
\`\`\`
src/
├── components/
├── hooks/
├── services/
└── utils/
\`\`\`

## 에이전트 우선순위

이 프로젝트에서는 다음 에이전트를 우선 사용:
- `frontend-engineer`: React 컴포넌트 작업
- `nodejs-backend`: Express API 작업
- `database-expert`: PostgreSQL 스키마

## 주의사항

- API 키는 절대 커밋하지 마세요
- 모든 PR은 테스트 통과 필수
- Prettier 포맷팅 필수

## 참고 문서

- [API 문서](./docs/API.md)
- [컴포넌트 가이드](./docs/COMPONENTS.md)
```

### 고급 설정

```markdown
## Summary Instructions

When compacting, focus on:
- API endpoint changes
- Database schema modifications
- Component architecture decisions

## Allowed Tools

Only these tools are allowed in this project:
- Read, Write, Edit
- Bash (git commands only)
- Grep, Glob

## Forbidden Actions

- Never modify production database
- Never commit to main branch directly
- Never expose API keys
```

---

## 프로젝트별 에이전트

### 커스텀 에이전트 생성

```bash
mkdir -p /path/to/project/.claude/agents
```

**예시: `project-reviewer.md`**

```markdown
---
name: project-reviewer
description: |
  Reviews code changes specific to this project's architecture.
  Use when: code review, PR review, architectural validation
model: sonnet
color: purple
---

# Project-Specific Code Reviewer

You are a code reviewer specialized in this project's architecture.

## Project Context

- **Architecture**: Clean Architecture with DDD
- **Patterns**: Repository pattern, CQRS
- **Testing**: TDD with 80%+ coverage

## Review Checklist

1. **Architecture Compliance**
   - Domain logic in domain layer
   - No infrastructure code in domain
   - Proper dependency injection

2. **Testing**
   - Unit tests for business logic
   - Integration tests for repositories
   - E2E tests for critical flows

3. **Code Quality**
   - No magic numbers
   - Proper error handling
   - Meaningful variable names

## Working Principles

1. Check architecture boundaries first
2. Verify test coverage
3. Review for security issues
4. Ensure coding conventions
```

---

## 도구 제한 설정

### settings.json

프로젝트 루트에 `.claude/settings.json` 생성:

```json
{
  "allowedTools": [
    "Read",
    "Write",
    "Edit",
    "Grep",
    "Glob",
    "Bash"
  ],
  "permissions": {
    "allowFileSystemWrites": true,
    "allowNetworkAccess": false,
    "allowBashCommands": ["git", "npm", "yarn"]
  }
}
```

### 도구 제한 예시

#### 읽기 전용 프로젝트

```json
{
  "allowedTools": ["Read", "Grep", "Glob"],
  "permissions": {
    "allowFileSystemWrites": false
  }
}
```

#### 보안 중요 프로젝트

```json
{
  "allowedTools": ["Read", "Write", "Edit"],
  "permissions": {
    "allowBashCommands": ["git"],
    "forbiddenPaths": [
      "/secrets/",
      "/.env",
      "/config/production.json"
    ]
  }
}
```

---

## MCP 서버 연동

### .mcp.json

프로젝트 루트에 `.mcp.json` 생성:

```json
{
  "mcpServers": {
    "project-database": {
      "command": "node",
      "args": ["./scripts/mcp-db-server.js"],
      "env": {
        "DB_HOST": "localhost",
        "DB_NAME": "${PROJECT_DB_NAME}"
      }
    },
    "project-api": {
      "command": "npx",
      "args": ["-y", "@my-org/api-mcp-server"],
      "env": {
        "API_KEY": "${PROJECT_API_KEY}"
      }
    }
  }
}
```

### 환경 변수

`.env.local` 파일 (Git 제외):

```bash
PROJECT_DB_NAME=myproject_dev
PROJECT_API_KEY=sk-test-xxxxx
```

### MCP 서버 예시

**데이터베이스 스키마 서버:**

```javascript
// scripts/mcp-db-server.js
const { Server } = require('@modelcontextprotocol/sdk/server/index.js');

const server = new Server({
  name: 'project-database',
  version: '1.0.0'
}, {
  capabilities: {
    tools: {}
  }
});

server.setRequestHandler('tools/list', async () => {
  return {
    tools: [
      {
        name: 'get_schema',
        description: 'Get database schema',
        inputSchema: {
          type: 'object',
          properties: {
            table: { type: 'string' }
          }
        }
      }
    ]
  };
});

server.connect();
```

---

## 프로젝트 템플릿

### React 프로젝트

```bash
mkdir -p myproject/.claude/agents
cd myproject/.claude

# CLAUDE.md
cat > CLAUDE.md << 'EOF'
# My React Project

## Tech Stack
- React 18, TypeScript, Vite
- TanStack Query, Zustand
- Tailwind CSS

## Agent Priority
1. frontend-engineer (React components)
2. test-automation-engineer (Jest, RTL)

## Coding Style
- Functional components only
- Custom hooks for reusable logic
- Tailwind for styling
EOF

# settings.json
cat > settings.json << 'EOF'
{
  "allowedTools": ["Read", "Write", "Edit", "Grep", "Glob", "Bash"],
  "permissions": {
    "allowBashCommands": ["npm", "git"]
  }
}
EOF
```

### Node.js API 프로젝트

```bash
mkdir -p api-project/.claude

cat > api-project/.claude/CLAUDE.md << 'EOF'
# API Project

## Tech Stack
- Node.js 20, Express, TypeScript
- PostgreSQL, Prisma ORM
- Jest, Supertest

## Agent Priority
1. nodejs-backend (Express APIs)
2. database-expert (Prisma schema)
3. test-automation-engineer (API tests)

## Architecture
- Clean Architecture
- Repository pattern
- Dependency injection

## Security
- Never expose secrets
- Validate all inputs
- Rate limiting on all endpoints
EOF
```

### Full-stack Monorepo

```bash
mkdir -p monorepo/.claude/{agents,skills}

cat > monorepo/.claude/CLAUDE.md << 'EOF'
# Monorepo Project

## Structure
\`\`\`
apps/
├── web/        # Next.js
├── mobile/     # React Native
└── api/        # NestJS

packages/
├── ui/         # Shared UI components
├── utils/      # Shared utilities
└── types/      # Shared TypeScript types
\`\`\`

## Agent Priority
- **apps/web**: frontend-engineer
- **apps/mobile**: mobile-app-developer
- **apps/api**: nodejs-backend
- **packages/ui**: frontend-engineer

## Workspace Commands
- `npm run dev` - Start all apps
- `npm run test` - Run all tests
- `npm run build` - Build all apps
EOF
```

---

## 실전 예시

### 예시 1: 보안 프로젝트

```markdown
# Security-Critical Project

## Allowed Tools
Only read operations and git:
- Read, Grep, Glob
- Bash (git only)

## Forbidden
- No Write/Edit without approval
- No network access
- No external MCP servers

## Settings
\`\`\`json
{
  "allowedTools": ["Read", "Grep", "Glob", "Bash"],
  "permissions": {
    "allowFileSystemWrites": false,
    "allowBashCommands": ["git"]
  }
}
\`\`\`
```

### 예시 2: 멀티 언어 프로젝트

```markdown
# Multi-Language Project

## Languages
- **Backend**: Java (Spring Boot)
- **Frontend**: TypeScript (React)
- **Mobile**: Kotlin (Android), Swift (iOS)

## Agent Routing
\`\`\`
src/backend/**     → spring-boot-backend
src/frontend/**    → frontend-engineer
src/android/**     → mobile-app-developer (Kotlin)
src/ios/**         → mobile-app-developer (Swift)
\`\`\`

## Custom Agents
- `api-gateway-expert` (Spring Cloud Gateway)
- `mobile-bridge-engineer` (React Native Bridge)
```

### 예시 3: 레거시 프로젝트

```markdown
# Legacy Codebase Modernization

## Current State
- jQuery 1.x, PHP 5.6
- MySQL 5.5
- No tests

## Migration Plan
1. Add tests first (test-automation-engineer)
2. Modernize frontend (frontend-engineer)
3. Upgrade backend (nodejs-backend)

## Constraints
- No breaking changes to API
- Maintain backward compatibility
- Incremental migration only

## Custom Agent: legacy-migrator
Specializes in:
- jQuery → React migration
- PHP → Node.js conversion
- Test coverage for legacy code
```

---

## 트러블슈팅

### Q: 프로젝트 설정이 적용되지 않아요

**A: .claude/ 위치 확인**
```bash
# 프로젝트 루트에 있어야 함
ls -la /path/to/project/.claude
```

**A: Claude Code 재시작**
```bash
# 프로젝트에서 새 세션 시작
cd /path/to/project
claude
```

### Q: 전역 에이전트가 우선 사용돼요

**A: 프로젝트 에이전트 이름 확인**
- 프로젝트 에이전트 이름이 전역과 다른지 확인
- 같은 이름이면 프로젝트 에이전트가 우선됨

**A: CLAUDE.md에서 명시**
```markdown
## Agent Priority
Only use project-specific agents:
- my-custom-agent (not frontend-engineer)
```

### Q: .mcp.json이 작동하지 않아요

**A: JSON 문법 확인**
```bash
jq . /path/to/project/.claude/.mcp.json
```

**A: 환경 변수 확인**
```bash
echo $PROJECT_API_KEY
# 없으면 .env.local 로드
source .env.local
```

**A: MCP 서버 로그 확인**
```bash
# MCP 서버 수동 실행 테스트
node ./scripts/mcp-db-server.js
```

### Q: settings.json 권한이 작동하지 않아요

**A: allowedTools vs permissions 구분**
- `allowedTools`: 사용 가능한 도구 목록
- `permissions`: 세밀한 권한 제어

**A: 전역 설정과 병합 확인**
- 프로젝트 설정이 전역 설정을 **완전히 대체**하지 않음
- 명시적으로 제한해야 함

---

## 파일 위치 참조

| 설정 | 전역 | 프로젝트 |
|------|------|----------|
| 지침 | `~/.claude/CLAUDE.md` | `./.claude/CLAUDE.md` |
| 설정 | `~/.claude/settings.json` | `./.claude/settings.json` |
| 에이전트 | `~/.claude/agents/` | `./.claude/agents/` |
| MCP | `~/.claude/.mcp.json` | `./.claude/.mcp.json` |
| 세션 데이터 | `~/.claude/projects/-project-path/` | (자동 생성) |

---

## 참고 자료

- [빠른 시작 가이드](./quick-start.md)
- [플러그인 관리 가이드](./plugin-management.md)
- [에이전트 활용 가이드](./agent-usage-guide.md)
- [MCP 서버 개발 가이드](https://modelcontextprotocol.io/)

---

*문서 작성일: 2026-01-07*
*위치: ~/.claude/docs/project-settings.md*
