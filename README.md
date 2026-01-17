# Claude Code Configuration

Custom Claude Code agents for backend/frontend development.

## Installation

### Method 1: Marketplace Plugin

```bash
claude plugin install https://github.com/ahngbeom/claude-config
```

### Method 2: Direct Installation

```bash
git clone https://github.com/ahngbeom/claude-config
cd claude-config
./install.sh
```

### Method 3: Sparse Checkout (agents/ 제외)

플러그인으로 에이전트를 사용하면서 `~/.claude`를 이 레포로 관리할 때, `agents/` 중복을 방지하려면:

```bash
# 1. Clone
git clone https://github.com/ahngbeom/claude-config ~/.claude
cd ~/.claude

# 2. Sparse checkout 설정
git sparse-checkout init
echo -e '/*\n!/agents/' > .git/info/sparse-checkout
git read-tree -mu HEAD

# 3. 확인
git status  # "sparse checkout with X% of tracked files present"
```

이 설정으로:
- `agents/` 디렉토리가 로컬에 체크아웃되지 않음
- 에이전트는 플러그인(`dev-agents:*`)으로 사용
- 원격 레포의 `agents/`는 그대로 유지됨

---

## Agents (21개)

### 개발 에이전트

| Agent | Description | Color |
|-------|-------------|-------|
| `backend-api-architect` | API design principles, RESTful/GraphQL patterns, authentication concepts | purple |
| `nodejs-backend` | Node.js/Express, TypeScript, middleware patterns | green |
| `spring-boot-backend` | Spring Boot, Java, Spring Security | orange |
| `frontend-engineer` | React/Next.js, component architecture, state management | blue |
| `mobile-app-developer` | React Native, Flutter, Swift, Kotlin for iOS/Android | cyan |
| `desktop-app-developer` | Electron, Tauri for cross-platform desktop apps | yellow |

### 인프라/데이터 에이전트

| Agent | Description | Color |
|-------|-------------|-------|
| `database-expert` | PostgreSQL/MySQL schema design, query optimization, migration | orange |
| `devops-engineer` | ELK Stack, Kubernetes, CI/CD, Terraform, cloud infrastructure | red |
| `data-engineer` | Data pipelines, ETL/ELT, Spark, Airflow, data warehouse | indigo |
| `ml-engineer` | PyTorch, TensorFlow, model training, MLOps, LLM | pink |
| `data-analyst` | Pandas, SQL, visualization, statistical analysis, EDA | teal |

### 개발 도구 에이전트

| Agent | Description | Color |
|-------|-------------|-------|
| `git-committer` | Git commit and push automation | green |
| `test-automation-engineer` | Jest/Vitest, React Testing Library, Playwright | yellow |
| `markdown-document-writer` | Documentation writing in markdown format | cyan |
| `github-expert` | GitHub Actions workflows, CI/CD automation, GitHub CLI | gray |
| `gitlab-expert` | GitLab CI/CD pipelines, .gitlab-ci.yml configuration | orange |

### 회고 에이전트

| Agent | Description | Color |
|-------|-------------|-------|
| `jira-retrospective` | Jira 이슈 기반 회고록 자동 생성 | blue |
| `commit-retrospective` | Git 커밋 히스토리 기반 회고록 자동 생성 | cyan |

### 헬스케어 특화 에이전트

| Agent | Description | Color |
|-------|-------------|-------|
| `healthcare-stats-normalizer` | Medical data normalization, ICD/SNOMED code mapping | cyan |
| `healthcare-stats-tester` | Medical statistics, hypothesis testing, clinical trial analysis | orange |
| `healthcare-stats-forecaster` | Healthcare time series forecasting, disease outbreak prediction | purple |

## Usage

Claude와 대화할 때 에이전트 이름을 언급하면 자동으로 활성화됩니다:

```
# 개발 에이전트
"frontend-engineer, 이 컴포넌트를 최적화해줘"
"backend-api-architect, RESTful API를 설계해줘"
"nodejs-backend, Express 미들웨어를 구현해줘"
"spring-boot-backend, Spring Security 설정해줘"
"mobile-app-developer, React Native 앱을 만들어줘"
"desktop-app-developer, Electron 앱을 구성해줘"

# 인프라/데이터 에이전트
"database-expert, 쿼리 최적화해줘"
"devops-engineer, Kubernetes 배포 설정해줘"
"data-engineer, Airflow DAG 작성해줘"
"ml-engineer, PyTorch 모델 학습 파이프라인 구현해줘"
"data-analyst, 매출 데이터 EDA 분석해줘"

# 개발 도구 에이전트
"git-committer, 변경사항 커밋해줘"
"test-automation-engineer, 테스트 코드 작성해줘"
"github-expert, GitHub Actions 워크플로우 만들어줘"
"gitlab-expert, GitLab CI 파이프라인 설정해줘"

# 회고 에이전트
"jira-retrospective, 지난 주 회고록 작성해줘"
"commit-retrospective, 이번 주 커밋 회고록 작성해줘"
```

### Priority

1. **Project Level**: `./project/.claude/agents/` (highest)
2. **Global Level**: `~/.claude/agents/` (fallback)

## Multi-Agent Collaboration

### Sequential Workflow
```
1. database-expert: Schema design
2. backend-api-architect: API design
3. nodejs-backend (or spring-boot-backend): Implementation
4. frontend-engineer: UI development
5. test-automation-engineer: Test writing
```

### Parallel Execution
```
"database-expert와 backend-api-architect와 frontend-engineer,
각자 영역에서 성능을 최적화해줘"
```

---

## Additional Plugins

For extra skills (document processing, design, etc.):

```bash
claude mcp add anthropic-agent-skills -- npx -y @anthropic-ai/claude-code-mcp
```

## Adding New Agents

1. Create `.md` file in `~/.claude/agents/`
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
