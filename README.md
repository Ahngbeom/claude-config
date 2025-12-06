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

---

## Agents

| Agent | Description | Color |
|-------|-------------|-------|
| `backend-api-architect` | API design principles, RESTful/GraphQL patterns, authentication concepts | purple |
| `nodejs-backend` | Node.js/Express, TypeScript, middleware patterns | green |
| `spring-boot-backend` | Spring Boot, Java, Spring Security | orange |
| `database-expert` | PostgreSQL/MySQL schema design, query optimization | - |
| `frontend-engineer` | React/Next.js, component architecture, state management | blue |
| `mobile-app-developer` | React Native, Flutter, Swift, Kotlin for iOS/Android | cyan |
| `desktop-app-developer` | Electron, Tauri for cross-platform desktop apps | yellow |
| `devops-engineer` | ELK Stack, Kubernetes, CI/CD, Terraform, cloud infrastructure | red |
| `git-committer` | Git commit and push automation | - |
| `markdown-document-writer` | Documentation writing in markdown format | - |
| `test-automation-engineer` | Jest/Vitest, React Testing Library, Playwright | - |

## Usage

Claude와 대화할 때 에이전트 이름을 언급하면 자동으로 활성화됩니다:

```
"frontend-engineer, 이 컴포넌트를 최적화해줘"
"backend-api-architect, RESTful API를 설계해줘"
"nodejs-backend, Express 미들웨어를 구현해줘"
"spring-boot-backend, Spring Security 설정해줘"
"mobile-app-developer, React Native 앱을 만들어줘"
"desktop-app-developer, Electron 앱을 구성해줘"
"devops-engineer, Kubernetes 배포 설정해줘"
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
