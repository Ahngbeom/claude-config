# Project Settings Guide

프로젝트별 Claude Code 설정 가이드입니다.

## 프로젝트 구조

```
your-project/
├── .claude/
│   ├── settings.local.json   # 프로젝트별 설정
│   └── CLAUDE.md             # 프로젝트별 지침 (선택)
├── .mcp.json                 # MCP 서버 설정 (선택)
└── ...
```

---

## 프로젝트별 CLAUDE.md

프로젝트 루트에 `CLAUDE.md` 파일을 생성하면 해당 프로젝트에서만 적용됩니다.

### 예시: React 프로젝트

```markdown
# Project Instructions

## Tech Stack
- React 18 + TypeScript
- TanStack Query for data fetching
- Tailwind CSS for styling

## Conventions
- 컴포넌트: PascalCase (UserCard.tsx)
- 훅: camelCase with use prefix (useAuth.ts)
- 유틸: camelCase (formatDate.ts)

## Testing
- Jest + React Testing Library
- E2E: Playwright
```

### 예시: Backend 프로젝트

```markdown
# Project Instructions

## Tech Stack
- Node.js + Express + TypeScript
- PostgreSQL + Prisma ORM

## API Conventions
- RESTful endpoints
- Response format: { success, data, error }
- Error codes: HTTP status codes

## Database
- Migrations: prisma migrate
- Naming: snake_case for tables/columns
```

---

## settings.local.json

프로젝트별 Claude Code 설정입니다.

### 위치

```
your-project/.claude/settings.local.json
```

### 예시

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(pnpm *)",
      "Bash(git *)"
    ],
    "deny": [
      "Bash(rm -rf /)"
    ]
  }
}
```

---

## MCP 서버 설정

프로젝트별 MCP 서버는 `.mcp.json`에 설정합니다.

### 위치

```
your-project/.mcp.json
```

### 예시

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/claude-code-supabase-mcp"],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "${SUPABASE_ACCESS_TOKEN}"
      }
    },
    "custom-server": {
      "command": "node",
      "args": ["./scripts/mcp-server.js"]
    }
  }
}
```

### 환경변수

MCP 서버에서 환경변수를 사용할 때:
- `${VAR_NAME}` 형식으로 참조
- 실제 값은 시스템 환경변수에서 로드

---

## 우선순위

Claude Code는 다음 순서로 설정을 적용합니다:

1. **프로젝트 CLAUDE.md** (최우선)
2. **전역 CLAUDE.md** (`~/.claude/CLAUDE.md`)
3. **프로젝트 settings.local.json**
4. **전역 settings.json** (`~/.claude/settings.json`)

---

## 권장 설정

### Frontend 프로젝트

```markdown
# CLAUDE.md

## Agent Preferences
- UI 작업: frontend-engineer
- 테스트: test-automation-engineer

## Build Commands
- Dev: pnpm dev
- Build: pnpm build
- Test: pnpm test
```

### Backend 프로젝트

```markdown
# CLAUDE.md

## Agent Preferences
- API 설계: backend-api-architect
- DB 작업: database-expert

## Commands
- Dev: pnpm dev
- Test: pnpm test
- Migration: pnpm prisma migrate dev
```

### Monorepo 프로젝트

```markdown
# CLAUDE.md

## Structure
- apps/web: Next.js frontend
- apps/api: Express backend
- packages/shared: Shared utilities

## Commands
- Root: pnpm -w <command>
- Package: pnpm --filter <package> <command>
```

---

## 팁

### 1. 민감한 정보 분리

```bash
# .gitignore
.claude/settings.local.json  # API 키 등 포함 시
```

### 2. 팀 공유 설정

```bash
# Git에 포함
CLAUDE.md                    # 프로젝트 컨벤션
.mcp.json                    # MCP 서버 (env 변수 사용)

# Git에서 제외
.claude/settings.local.json  # 개인 설정
```

### 3. 환경별 MCP 설정

```json
{
  "mcpServers": {
    "db-dev": {
      "command": "...",
      "env": { "DB_URL": "${DEV_DB_URL}" }
    },
    "db-prod": {
      "command": "...",
      "env": { "DB_URL": "${PROD_DB_URL}" }
    }
  }
}
```

---

*위치: ~/.claude/PROJECT-SETTINGS.md*
