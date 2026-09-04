# Claude Code Configuration

Custom Claude Code plugin marketplace with specialized development agents.

> Mobidoc UI/UX beta guidance in this repository is a personal experiment for consistent local work. It is not an official team standard and should not contain sensitive patient data, private screenshots, credentials, or unreleased business details.

## Installation

### Marketplace Plugin (Recommended)

Install all plugins at once:
```bash
claude plugin install https://github.com/ahngbeom/claude-config
```

Or install individual plugins by category:
```bash
# Backend development
claude plugin install backend-agents@ahngbeom-claude-config

# Frontend development
claude plugin install frontend-agents@ahngbeom-claude-config

# Data science & ML
claude plugin install data-agents@ahngbeom-claude-config

# DevOps & Git workflows
claude plugin install devops-agents@ahngbeom-claude-config

# Healthcare analytics
claude plugin install healthcare-agents@ahngbeom-claude-config

# Mobile & desktop apps
claude plugin install mobile-agents@ahngbeom-claude-config

# Productivity tools
claude plugin install productivity-agents@ahngbeom-claude-config

# Agent preference hooks (optional, separate install)
claude plugin install https://github.com/Ahngbeom/claude-hookify
```

### Global Configuration (`~/.claude`)

The global instruction file and the scripts it references are tracked under `global/` and installed with the sync script:

```bash
git clone https://github.com/ahngbeom/claude-config
cd claude-config
scripts/sync-global.sh push     # global/ -> ~/.claude (backs up any file it overwrites)
scripts/sync-global.sh check    # report drift between the two
scripts/sync-global.sh pull     # ~/.claude -> global/ after editing the live file
```

| File | Installed to | Purpose |
|------|--------------|---------|
| `global/CLAUDE.md` | `~/.claude/CLAUDE.md` | Global instructions applied to every project |
| `global/hooks/guard-k8s.py` | `~/.claude/hooks/guard-k8s.py` | `PreToolUse` hook that blocks cluster-mutating `kubectl`/`helm`/`argocd` commands |
| `global/cleanup.sh` | `~/.claude/cleanup.sh` | `~/.claude` housekeeping, run by the `SessionStart` hook and `/cleanup` |

Hook registration is not synced; add the entries from `docs/settings.example.json` to `~/.claude/settings.json`.

---

## Plugin Structure

This marketplace follows the [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) structure.

```
ahngbeom-claude-config/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace metadata
├── .github/
│   └── workflows/
│       └── validate.yml          # CI validation
├── codex/
│   └── skills/                   # Codex skill source documents
├── docs/
│   ├── COMPACT-STRATEGY.md
│   ├── PROJECT-SETTINGS.md
│   ├── settings.example.json
│   └── superpowers/
├── global/                       # Tracked ~/.claude files (see Global Configuration)
│   ├── CLAUDE.md
│   ├── cleanup.sh
│   └── hooks/guard-k8s.py
├── plugins/
│   ├── backend-agents/           # 5 agents
│   ├── frontend-agents/          # 2 agents
│   ├── data-agents/              # 5 agents
│   ├── devops-agents/            # 4 agents (incl. railway-expert) + 2 commands
│   ├── healthcare-agents/        # 3 agents
│   ├── mobile-agents/            # 3 agents
│   └── productivity-agents/      # 5 agents + 4 commands
├── scripts/
│   ├── notify.sh
│   ├── stop-hook.sh
│   ├── sync-global.sh            # global/ <-> ~/.claude
│   ├── sync-shared.sh
│   └── validate.sh               # Local & CI validation
├── shared/
│   └── references/               # Canonical shared assets
└── README.md
```

---

## Plugins & Agents (27 total)

### backend-agents (5 agents)

Backend development agents for API architecture and server-side implementation.

| Agent | Description | Color |
|-------|-------------|-------|
| `backend-api-architect` | API design principles, RESTful/GraphQL patterns, authentication | purple |
| `nodejs-backend` | Node.js/Express, TypeScript, middleware patterns | green |
| `spring-boot-backend` | Spring Boot, Java, Spring Security | orange |
| `python-fastapi-backend` | FastAPI, Pydantic, async Python, uvicorn | blue |
| `database-expert` | PostgreSQL/MySQL schema design, query optimization, migration | orange |

### frontend-agents (2 agents)

Frontend development agents for modern web UI and personal Mobidoc UI/UX beta review.

| Agent | Description | Color |
|-------|-------------|-------|
| `frontend-engineer` | React/Next.js, Vue, component architecture, state management | blue |
| `mobidoc-ui-ux-reviewer` | Mobidoc patient, hospital, and tablet UI/UX review beta guidance | cyan |

### data-agents (5 agents)

Data science and machine learning agents.

| Agent | Description | Color |
|-------|-------------|-------|
| `data-analyst` | Pandas, SQL, visualization, statistical analysis, EDA | cyan |
| `data-engineer` | Data pipelines, ETL/ELT, Spark, Airflow, data warehouse | blue |
| `ml-engineer` | PyTorch, TensorFlow, model training, MLOps, LLM | pink |
| `computer-vision-engineer` | MediaPipe, OpenCV, face recognition, AR filters | purple |
| `jupyter-expert` | Jupyter Notebooks, JupyterLab, IPython, Voila dashboards, widgets | green |

### devops-agents (4 agents + 2 commands)

DevOps and CI/CD workflow automation agents. Slash commands live in `commands/`.

| Agent | Description | Color |
|-------|-------------|-------|
| `devops-engineer` | Kubernetes, CI/CD, Terraform, cloud infrastructure | red |
| `github-expert` | GitHub Actions workflow design, CI/CD pipeline configuration | blue |
| `gitlab-expert` | GitLab CI/CD pipeline design, .gitlab-ci.yml configuration | orange |
| `railway-expert` | Railway platform deployment, service management, database provisioning | purple |

Slash commands: `/railway-deploy`, `/railway-setup` (defined in `commands/`)

> **Note**: Git 커밋/푸시 작업은 공식 `commit-commands` 플러그인의 `/commit`, `/commit-push-pr` 명령을 사용하세요.

### healthcare-agents (3 agents)

Healthcare analytics and medical data processing agents.

| Agent | Description | Color |
|-------|-------------|-------|
| `healthcare-stats-normalizer` | Medical data normalization, ICD/SNOMED code mapping | cyan |
| `healthcare-stats-tester` | Medical statistics, hypothesis testing, clinical trial analysis | orange |
| `healthcare-stats-forecaster` | Healthcare time series forecasting, disease outbreak prediction | purple |

### mobile-agents (3 agents)

Mobile and desktop application development agents.

| Agent | Description | Color |
|-------|-------------|-------|
| `mobile-app-developer` | React Native, Flutter, Swift, Kotlin for iOS/Android | cyan |
| `ar-mobile-developer` | ARCore, ARKit, AR filters, Face Mesh, augmented reality | green |
| `desktop-app-developer` | Electron, Tauri for cross-platform desktop apps | yellow |

### productivity-agents (5 agents + 5 commands)

Documentation, testing, and workflow automation agents. Slash commands live in `commands/`.

| Agent | Description | Color |
|-------|-------------|-------|
| `markdown-document-writer` | Documentation writing in markdown format | cyan |
| `test-automation-engineer` | Jest/Vitest, React Testing Library, Playwright, pytest | yellow |
| `commit-retrospective` | Git commit history-based retrospective generation | cyan |
| `jira-retrospective` | Jira issue-based retrospective generation | blue |
| `retrospective-validator` | Auto-detection and validation of retrospective files | green |

Slash commands: `/git-retro`, `/jira-retro`, `/write-docs`, `/write-tests`, `/cleanup` (defined in `commands/`)

### claude-hookify (8 hooks)

Agent preference hooks that recommend specialized agents based on file and command patterns. Maintained in a **separate repository**: https://github.com/Ahngbeom/claude-hookify

```bash
claude plugin install https://github.com/Ahngbeom/claude-hookify
```

| Hook | Trigger | Recommended Agent |
|------|---------|-------------------|
| `prefer-backend-agent` | API endpoint files (controller, route, service) | backend-api-architect, nodejs-backend, spring-boot-backend |
| `prefer-database-expert` | DB schema/migration files | database-expert |
| `prefer-frontend-engineer` | Frontend component files (.tsx, .vue, .jsx) | frontend-engineer |
| `prefer-commit-commands` | `git commit/push` commands | /commit, /commit-push-pr |
| `prefer-test-automation` | Test files (.test.ts, .spec.js) | test-automation-engineer |
| `prefer-markdown-writer` | Markdown document files | markdown-document-writer |
| `prefer-jira-retrospective` | Retrospective keywords | jira-retrospective |
| `prefer-commit-retrospective` | Commit retrospective keywords | commit-retrospective |

---

## Validation

Run the local validation script to verify the plugin structure is correct:

```bash
scripts/validate.sh
```

This same script is used by `.github/workflows/validate.yml` for CI checks.

---

## Usage

### Using Plugin Namespace

After installing a plugin, use the namespace prefix:

```bash
# Backend agents
"backend-agents:nodejs-backend, Express 미들웨어를 구현해줘"
"backend-agents:database-expert, 쿼리 최적화해줘"

# Data agents
"data-agents:ml-engineer, PyTorch 모델 학습 파이프라인 구현해줘"
"data-agents:data-analyst, 매출 데이터 EDA 분석해줘"

# DevOps agents
"devops-agents:github-expert, GitHub Actions 워크플로우 만들어줘"

# Mobidoc UI/UX beta review
"frontend-agents:mobidoc-ui-ux-reviewer, Mobidoc 예약 화면 UX 리뷰해줘"

# Productivity agents
"productivity-agents:jira-retrospective, 지난 주 회고록 작성해줘"
```

### Slash Commands

| Command | Plugin | Description | Example |
|---------|--------|-------------|---------|
| `/commit` | `commit-commands` (official) | Analyze changes and create a commit in the repo's style | `/commit` |
| `/commit-push-pr` | `commit-commands` (official) | Commit, push, and open a PR in one step | `/commit-push-pr` |
| `/clean_gone` | `commit-commands` (official) | Delete local branches whose remote is gone | `/clean_gone` |
| `/jira-retro` | `productivity-agents` | Retrospective from Jira issues | `/jira-retro 2w` |
| `/git-retro` | `productivity-agents` | Retrospective from git commits | `/git-retro 14` |
| `/write-docs` | `productivity-agents` | Write a markdown document | `/write-docs API.md` |
| `/write-tests` | `productivity-agents` | Generate tests for a file | `/write-tests src/auth.ts` |
| `/cleanup` | `productivity-agents` | Reclaim disk space under `~/.claude` | `/cleanup dry-run` |
| `/railway-deploy` | `devops-agents` | Generate Railway deployment config | `/railway-deploy fastapi` |
| `/railway-setup` | `devops-agents` | Initialize a Railway project | `/railway-setup "Node.js + PostgreSQL"` |

### Agent Routing

Applies only where the plugin is installed and enabled (`~/.claude/plugins/installed_plugins.json`, `enabledPlugins` in `~/.claude/settings.json`).

| Task Type | Plugin:Agent | Trigger Keywords |
|-----------|--------------|------------------|
| Frontend/React | `frontend-agents:frontend-engineer` | "컴포넌트", "리액트", "Vue", "UI", component architecture |
| Mobidoc UI/UX | `frontend-agents:mobidoc-ui-ux-reviewer` | "Mobidoc", "모비닥", "의료 UX", "환자앱", "병원앱", "태블릿" |
| Backend API | `backend-agents:backend-api-architect` | "API", "엔드포인트", "REST", "GraphQL" |
| Node.js Backend | `backend-agents:nodejs-backend` | "Express", "Node.js", "미들웨어" |
| Spring Boot | `backend-agents:spring-boot-backend` | "Spring", "Java", "JPA" |
| Python/FastAPI | `backend-agents:python-fastapi-backend` | "FastAPI", "Pydantic", "uvicorn", "Python API", "async Python" |
| Database | `backend-agents:database-expert` | "스키마", "쿼리", "migration", "인덱스", "DB" |
| Testing | `productivity-agents:test-automation-engineer` | "테스트", "test", "Jest", "Playwright", "pytest" |
| Documentation | `productivity-agents:markdown-document-writer` | "문서 작성", "README", "가이드" |
| Data Analysis | `data-agents:data-analyst` | "데이터 분석", "통계", "Pandas", "시각화" |
| Data Engineering | `data-agents:data-engineer` | "ETL", "파이프라인", "Spark", "Airflow", "데이터 웨어하우스" |
| ML/AI | `data-agents:ml-engineer` | "모델 학습", "PyTorch", "TensorFlow", "MLOps", "LLM" |
| Computer Vision | `data-agents:computer-vision-engineer` | "얼굴 인식", "MediaPipe", "OpenCV", "face_recognition", "랜드마크", "AR 필터" |
| Jupyter/Notebooks | `data-agents:jupyter-expert` | "Jupyter", "노트북", "notebook", "IPython", "widget", "nbconvert", "JupyterLab" |
| DevOps | `devops-agents:devops-engineer` | "배포", "CI/CD", "Docker", "Kubernetes", "Terraform" |
| GitHub CI/CD | `devops-agents:github-expert` | "GitHub Actions", "workflow", ".github/workflows" (workflow design; API work uses the official `github` plugin) |
| GitLab CI/CD | `devops-agents:gitlab-expert` | "GitLab CI", ".gitlab-ci.yml", "GitLab Runner" (pipeline design; API work uses the official `gitlab` plugin) |
| Railway | `devops-agents:railway-expert` | "Railway", "railway.json", "Nixpacks", "Railway 배포" |
| Mobile App | `mobile-agents:mobile-app-developer` | "React Native", "Flutter", "iOS", "Android", "모바일 앱" |
| AR Mobile | `mobile-agents:ar-mobile-developer` | "ARCore", "ARKit", "AR 필터", "얼굴 필터", "증강현실", "Face Mesh" |
| Desktop App | `mobile-agents:desktop-app-developer` | "Electron", "Tauri", "데스크톱 앱" |
| Healthcare Stats | `healthcare-agents:healthcare-stats-*` | "의료 데이터", "ICD", "SNOMED", "임상 통계", "헬스케어" |
| Jira Retrospective | `productivity-agents:jira-retrospective` | "회고록", "회고", "retrospective", "주간 정리", "Jira 이슈 정리" |
| Commit Retrospective | `productivity-agents:commit-retrospective` | "커밋 회고", "Git 회고", "GitHub 회고", "GitLab 회고", "작업 이력 정리" |
| Retrospective Validation | `productivity-agents:retrospective-validator` | "회고 검증", "retrospective 감지", "회고 자동화" |

### Official vs Local Plugins

| Task | Official plugin (`claude-plugins-official`) | Local agent |
|------|---------------------------------------------|-------------|
| Git commit/push/PR | `/commit`, `/commit-push-pr`, `/clean_gone` (`commit-commands`) | - |
| Code review | `code-review`, `pr-review-toolkit` | - |
| Feature workflow | `feature-dev` (generic 7-step workflow) | Domain agents (backend, frontend, data, ...) |
| GitHub API / issues / PRs | `github` (MCP) | - |
| GitHub Actions workflow design | - | `devops-agents:github-expert` |
| GitLab API | `gitlab` (MCP) | - |
| GitLab CI/CD pipeline design | - | `devops-agents:gitlab-expert` |
| Frontend design aesthetics | `frontend-design` | - |
| React/Next.js engineering | - | `frontend-agents:frontend-engineer` |
| Playwright browser automation | `playwright` (MCP) | - |
| Test writing | - | `productivity-agents:test-automation-engineer`, `/write-tests` |
| Railway deploy/manage | - | `devops-agents:railway-expert`, `/railway-deploy`, `/railway-setup` |

### Codex Skill Source

The Mobidoc UI/UX beta Codex skill source lives in `codex/skills/mobidoc-ui-ux-beta/`. It is intentionally not registered in the Claude marketplace. Install it into a personal Codex environment by copying or symlinking that directory when needed.

---

## Multi-Agent Collaboration

### Sequential Workflow
```
1. database-expert: Schema design
2. backend-api-architect: API design
3. nodejs-backend (or spring-boot-backend): Implementation
4. frontend-engineer: UI development
5. test-automation-engineer: Test writing
6. /commit or /commit-push-pr: Commit and push changes
```

### Parallel Execution
```
"database-expert와 backend-api-architect와 frontend-engineer,
각자 영역에서 성능을 최적화해줘"
```

---

## Adding New Agents

1. Create `.md` file in the appropriate plugin's `agents/` folder
2. Add YAML frontmatter:
   ```yaml
   ---
   name: my-agent
   description: Agent description with use cases
   model: sonnet
   color: red
   ---
   ```
3. Write agent prompt (expertise, core knowledge, working principles)

---

## License

MIT
