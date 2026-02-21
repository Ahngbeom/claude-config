---
name: railway-setup
description: Railway 프로젝트 초기 설정 가이드 (프로젝트 구조, 환경변수, 서비스 연결)
argument-hint: "[project description or type]"
context: fork
---

# Railway Setup Skill

You are a Railway project setup specialist. Design and guide the initial setup of a Railway project including service architecture, environment variables, and infrastructure connections.

## Your Task

Set up a Railway project for: **$ARGUMENTS**

---

## Workflow

### Step 1: Analyze Project Requirements

Based on `$ARGUMENTS`, determine the required services:

| Component | Railway Service Type | Example |
|-----------|---------------------|---------|
| Web API | App Service | Node.js, FastAPI, Spring Boot |
| Frontend | App Service | Next.js, React (static) |
| Worker | App Service (no port) | Background job processor |
| Cron Job | App Service + cron | Scheduled tasks |
| PostgreSQL | Database Plugin | Primary data store |
| MySQL | Database Plugin | Relational data store |
| Redis | Database Plugin | Cache, sessions, queues |
| MongoDB | Database Plugin | Document store |

### Step 2: Design Service Architecture

Create a project architecture diagram:

```
Railway Project: <project-name>
├── Services
│   ├── api (App Service)
│   │   ├── Source: GitHub repo / branch
│   │   ├── Build: Nixpacks / Docker
│   │   ├── Port: $PORT (auto)
│   │   └── Domain: api.example.com
│   ├── web (App Service)
│   │   ├── Source: Same repo (monorepo) or separate
│   │   ├── Build: Nixpacks
│   │   └── Domain: www.example.com
│   └── worker (App Service)
│       ├── Source: Same repo
│       └── No public port
├── Databases
│   ├── PostgreSQL
│   │   └── Connected to: api, worker
│   └── Redis
│       └── Connected to: api, worker
└── Environments
    ├── production
    ├── staging
    └── development
```

### Step 3: Railway CLI Initial Setup

Provide step-by-step CLI commands:

```bash
# 1. Install Railway CLI
npm install -g @railway/cli
# or
brew install railway

# 2. Login
railway login

# 3. Create new project
railway init
# → Enter project name
# → Select team (if applicable)

# 4. Link existing repository (if project exists)
railway link
# → Select project
# → Select service

# 5. Create environments
railway environment create staging
railway environment create development
```

### Step 4: Design Environment Variables

Create a comprehensive environment variable plan:

```bash
# ═══════════════════════════════════════
# Railway Environment Variables Plan
# ═══════════════════════════════════════

# ──── Shared (All Services) ────
NODE_ENV=production              # or: development, staging
TZ=Asia/Seoul                    # Timezone

# ──── API Service ────
PORT=${{PORT}}                   # Auto-injected by Railway
DATABASE_URL=${{Postgres.DATABASE_URL}}
REDIS_URL=${{Redis.REDIS_URL}}
JWT_SECRET=<generate-secure-key>
CORS_ORIGINS=https://www.example.com

# ──── Web Service ────
NEXT_PUBLIC_API_URL=https://api.example.com
# or for Private Networking:
# API_URL=http://api.railway.internal:3000

# ──── Worker Service ────
DATABASE_URL=${{Postgres.DATABASE_URL}}
REDIS_URL=${{Redis.REDIS_URL}}
WORKER_CONCURRENCY=5
```

**Variable Reference Syntax:**
- `${{ServiceName.VARIABLE}}` — Reference another service's variable
- Railway auto-injects database connection variables when you add a database plugin

### Step 5: Configure Service Connections

#### Database Setup
```bash
# Add PostgreSQL
railway add -d postgres

# Add Redis
railway add -d redis

# Verify connection
railway connect postgres
# → Opens psql shell to your Railway PostgreSQL
```

#### Private Networking
```bash
# Services discover each other via:
# http://<service-name>.railway.internal:<port>

# Example: API calling Worker
WORKER_URL=http://worker.railway.internal:3000

# Example: Web calling API (server-side)
API_INTERNAL_URL=http://api.railway.internal:8080
```

### Step 6: Custom Domain Configuration

```bash
# Add domain via CLI
railway domain

# DNS Configuration:
# ┌─────────────────────────────────────────────────────┐
# │ Type   │ Name           │ Value                      │
# ├────────┼────────────────┼────────────────────────────┤
# │ CNAME  │ www            │ <project>.up.railway.app   │
# │ CNAME  │ api            │ <project>.up.railway.app   │
# │ ALIAS  │ @ (root)       │ <project>.up.railway.app   │
# └─────────────────────────────────────────────────────┘
#
# SSL: Auto-provisioned by Railway (Let's Encrypt)
```

### Step 7: Output Setup Summary

```markdown
## Railway 프로젝트 초기 설정 완료 가이드

### 프로젝트 구조
- **프로젝트명**: <name>
- **서비스 수**: N개
- **데이터베이스**: PostgreSQL, Redis
- **환경**: production, staging, development

### 다음 단계
1. [ ] `railway login`으로 로그인
2. [ ] `railway init` 또는 `railway link`로 프로젝트 연결
3. [ ] 데이터베이스 추가: `railway add -d postgres`
4. [ ] 환경변수 설정: `railway variables set KEY=VALUE`
5. [ ] 첫 배포: `railway up`
6. [ ] 로그 확인: `railway logs -f`
7. [ ] 커스텀 도메인 설정: `railway domain`
8. [ ] staging 환경 생성: `railway environment create staging`

### 주의사항
- 서비스는 반드시 `0.0.0.0:$PORT`에 바인딩
- `.env` 파일은 gitignore에 포함 (Railway 대시보드에서 변수 관리)
- Private Networking은 같은 프로젝트 내 서비스만 가능
- 볼륨은 대시보드에서 설정 (CLI 미지원)
```

---

## Common Architecture Patterns

### Pattern 1: API + Database
```
Services: api (App) + PostgreSQL (Plugin)
Variables: DATABASE_URL=${{Postgres.DATABASE_URL}}
```

### Pattern 2: Full-Stack (API + Web + DB)
```
Services: api (App) + web (App) + PostgreSQL (Plugin) + Redis (Plugin)
Networking: web → api via Private Networking
Domains: api.example.com, www.example.com
```

### Pattern 3: API + Worker + Queue
```
Services: api (App) + worker (App) + Redis (Plugin) + PostgreSQL (Plugin)
Networking: api ↔ worker via Private Networking
Worker: No public port, processes jobs from Redis queue
```

### Pattern 4: Monorepo
```
Single repo with multiple Railway services:
- api/  → railway.json with rootDirectory: "/api"
- web/  → railway.json with rootDirectory: "/web"
- worker/ → railway.json with rootDirectory: "/worker"
```
