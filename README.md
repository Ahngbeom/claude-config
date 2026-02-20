# Claude Code Configuration

Custom Claude Code plugin marketplace with specialized development agents.

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
```

### Direct Installation

```bash
git clone https://github.com/ahngbeom/claude-config
cd claude-config
./install.sh
```

---

## Plugin Structure

This marketplace follows the [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) structure.

```
ahngbeom-claude-config/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace metadata
├── plugins/
│   ├── backend-agents/           # 5 agents
│   ├── frontend-agents/          # 1 agent
│   ├── data-agents/              # 4 agents
│   ├── devops-agents/            # 4 agents
│   ├── healthcare-agents/        # 3 agents
│   ├── mobile-agents/            # 3 agents
│   └── productivity-agents/      # 4 agents
└── README.md
```

---

## Plugins & Agents (24 total)

### backend-agents (5 agents)

Backend development agents for API architecture and server-side implementation.

| Agent | Description | Color |
|-------|-------------|-------|
| `backend-api-architect` | API design principles, RESTful/GraphQL patterns, authentication | purple |
| `nodejs-backend` | Node.js/Express, TypeScript, middleware patterns | green |
| `spring-boot-backend` | Spring Boot, Java, Spring Security | orange |
| `python-fastapi-backend` | FastAPI, Pydantic, async Python, uvicorn | blue |
| `database-expert` | PostgreSQL/MySQL schema design, query optimization, migration | orange |

### frontend-agents (1 agent)

Frontend development agents for modern web UI.

| Agent | Description | Color |
|-------|-------------|-------|
| `frontend-engineer` | React/Next.js, Vue, component architecture, state management | blue |

### data-agents (4 agents)

Data science and machine learning agents.

| Agent | Description | Color |
|-------|-------------|-------|
| `data-analyst` | Pandas, SQL, visualization, statistical analysis, EDA | teal |
| `data-engineer` | Data pipelines, ETL/ELT, Spark, Airflow, data warehouse | indigo |
| `ml-engineer` | PyTorch, TensorFlow, model training, MLOps, LLM | pink |
| `computer-vision-engineer` | MediaPipe, OpenCV, face recognition, AR filters | cyan |

### devops-agents (3 agents)

DevOps and CI/CD workflow automation agents.

| Agent | Description | Color |
|-------|-------------|-------|
| `devops-engineer` | Kubernetes, CI/CD, Terraform, cloud infrastructure | red |
| `github-expert` | GitHub Actions workflow design, CI/CD pipeline configuration | gray |
| `gitlab-expert` | GitLab CI/CD pipeline design, .gitlab-ci.yml configuration | orange |

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
| `ar-mobile-developer` | ARCore, ARKit, AR filters, Face Mesh, augmented reality | magenta |
| `desktop-app-developer` | Electron, Tauri for cross-platform desktop apps | yellow |

### productivity-agents (4 agents)

Documentation, testing, and workflow automation agents.

| Agent | Description | Color |
|-------|-------------|-------|
| `markdown-document-writer` | Documentation writing in markdown format | cyan |
| `test-automation-engineer` | Jest/Vitest, React Testing Library, Playwright, pytest | yellow |
| `commit-retrospective` | Git commit history-based retrospective generation | cyan |
| `jira-retrospective` | Jira issue-based retrospective generation | blue |

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

# Productivity agents
"productivity-agents:jira-retrospective, 지난 주 회고록 작성해줘"
```

### Auto-Trigger Keywords

Agents are automatically activated based on keywords:

| Keywords | Activated Agent |
|----------|-----------------|
| "API", "REST", "GraphQL" | backend-api-architect |
| "컴포넌트", "React", "Vue" | frontend-engineer |
| "테스트", "Jest", "Playwright" | test-automation-engineer |
| "Docker", "Kubernetes", "CI/CD" | devops-engineer |
| "Pandas", "시각화", "EDA" | data-analyst |
| "PyTorch", "모델 학습", "MLOps" | ml-engineer |

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
