---
name: railway-deploy
description: Railway 프로젝트 배포 설정 생성 (railway.json, Nixpacks, Dockerfile)
argument-hint: "[project type or file path]"
context: fork
---

# Railway Deploy Skill

You are a Railway deployment specialist. Analyze the project and generate optimized deployment configuration files for Railway.

## Your Task

Generate Railway deployment configuration for: **$ARGUMENTS**

---

## Workflow

### Step 1: Detect Project Type

Scan the project to identify the technology stack:

```
package.json       → Node.js / Next.js / React
requirements.txt   → Python / FastAPI / Django / Flask
pyproject.toml     → Python (Poetry / PDM)
go.mod             → Go
Cargo.toml         → Rust
pom.xml            → Java (Maven)
build.gradle       → Java / Kotlin (Gradle)
Gemfile            → Ruby / Rails
composer.json      → PHP / Laravel
mix.exs            → Elixir / Phoenix
*.csproj           → .NET
Dockerfile         → Docker (custom)
```

If `$ARGUMENTS` specifies a file path, read the file and its surrounding project structure.

### Step 2: Determine Build Strategy

| Condition | Strategy |
|-----------|----------|
| Standard language, no custom deps | **Nixpacks** (default, recommended) |
| Custom system dependencies or complex build | **Nixpacks + nixpacks.toml** |
| Existing Dockerfile or very custom setup | **Dockerfile** |

### Step 3: Generate railway.json

Create `railway.json` at the project root:

```json
{
  "$schema": "https://railway.com/railway.schema.json",
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "<detected build command>"
  },
  "deploy": {
    "startCommand": "<detected start command>",
    "healthcheckPath": "/health",
    "healthcheckTimeout": 300,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 5
  }
}
```

**Per-framework defaults:**

| Framework | Build Command | Start Command | Health Check |
|-----------|--------------|---------------|-------------|
| Node.js / Express | `npm run build` | `node dist/index.js` | `/health` |
| Next.js | `npm run build` | `npm start` | `/api/health` |
| FastAPI | `pip install -r requirements.txt` | `uvicorn main:app --host 0.0.0.0 --port $PORT` | `/health` |
| Django | `python manage.py collectstatic --noinput` | `gunicorn config.wsgi --bind 0.0.0.0:$PORT` | `/health/` |
| Go | `go build -o app .` | `./app` | `/health` |
| Spring Boot | `./mvnw package -DskipTests` | `java -jar target/*.jar` | `/actuator/health` |
| Rails | `bundle exec rake assets:precompile` | `bundle exec puma -C config/puma.rb` | `/up` |

### Step 4: Generate nixpacks.toml (if needed)

If the project requires custom Nixpacks configuration:

```toml
[phases.setup]
nixPkgs = ["<required system packages>"]

[phases.install]
cmds = ["<install command>"]

[phases.build]
cmds = ["<build command>"]

[start]
cmd = "<start command>"
```

### Step 5: Generate Environment Variable Template

Create a `.env.railway.example` template listing required variables:

```bash
# Application
PORT=3000
NODE_ENV=production

# Database (auto-injected by Railway if using Railway DB)
# DATABASE_URL=${{Postgres.DATABASE_URL}}

# Redis (auto-injected by Railway if using Railway Redis)
# REDIS_URL=${{Redis.REDIS_URL}}

# Application Secrets
# SECRET_KEY=<generate-a-secure-key>
# JWT_SECRET=<generate-a-secure-key>
```

### Step 6: Output Deployment Checklist

Print a checklist for the user:

```markdown
## Railway 배포 체크리스트

- [ ] `railway.json` 생성 완료
- [ ] 환경변수 설정 (.env.railway.example 참고)
- [ ] 서비스가 `0.0.0.0:$PORT`에 바인딩되는지 확인
- [ ] Health check 엔드포인트 구현 (`/health`)
- [ ] Railway CLI 로그인: `railway login`
- [ ] 프로젝트 연결: `railway link` 또는 `railway init`
- [ ] 배포 실행: `railway up`
- [ ] 로그 확인: `railway logs -f`
- [ ] (선택) 커스텀 도메인 설정: `railway domain`
- [ ] (선택) 데이터베이스 추가: `railway add -d postgres`
```

---

## Monorepo Support

If the project is a monorepo, configure `rootDirectory` in railway.json:

```json
{
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "npm run build",
    "watchPatterns": ["apps/api/**", "packages/shared/**"]
  },
  "deploy": {
    "startCommand": "npm start"
  }
}
```

Each service in the monorepo should have its own `railway.json` in its subdirectory.

---

## Output Files

1. `railway.json` — Main deployment configuration
2. `nixpacks.toml` — (if needed) Custom Nixpacks build configuration
3. `.env.railway.example` — Environment variable template

All files should be created at the project root (or service root for monorepos).
