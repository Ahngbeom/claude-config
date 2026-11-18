# Claude Code Configuration

Custom Claude Code plugin marketplace: retrospective agents and slash commands, plus the tracked global `~/.claude` files.

> Mobidoc UI/UX beta guidance in this repository is a personal experiment for consistent local work. It is not an official team standard and should not contain sensitive patient data, private screenshots, credentials, or unreleased business details.

## Installation

### Marketplace Plugin (Recommended)

Install all plugins at once:
```bash
claude plugin install https://github.com/ahngbeom/claude-config
```

Or install individual plugins by category:
```bash
# Railway commands
claude plugin install devops-agents@ahngbeom-claude-config

# Retrospectives, test writing, cleanup
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
| `global/hooks/canonical_pin.py` | `~/.claude/hooks/canonical_pin.py` | git `reference-transaction` hook that keeps each `~/work` canonical checkout on its pinned branch (no detach, switch, rewind, or delete) |
| `global/hooks/install-canonical-pin.sh` | `~/.claude/hooks/install-canonical-pin.sh` | Links `canonical_pin.py` into every `~/work/*` checkout; `--check` reports status only |
| `global/hooks/guard-work-checkout.py` | `~/.claude/hooks/guard-work-checkout.py` | `PreToolUse` hook that blocks edits and mutating `git` commands in a `~/work` canonical checkout; work happens in `~/work/.worktrees/` |
| `global/hooks/tests/guard_work_checkout_test.py` | `~/.claude/hooks/tests/guard_work_checkout_test.py` | Tests for `guard-work-checkout.py`, run by `scripts/validate.sh` |
| `global/hooks/tests/canonical_pin_test.py` | `~/.claude/hooks/tests/canonical_pin_test.py` | Tests for `canonical_pin.py` against real git commands, run by `scripts/validate.sh` |
| `global/cleanup.sh` | `~/.claude/cleanup.sh` | `~/.claude` housekeeping, run by the `SessionStart` hook and `/cleanup` |
| `global/skills/korean-docs/` | `~/.claude/skills/korean-docs/` | Korean writing skill: channel templates (MR/PR, Jira, reports, tech docs), style, and review checklist |

Hook registration is not synced; add the entries from `docs/settings.example.json` to `~/.claude/settings.json`. `canonical_pin.py` is a git hook, not a Claude Code hook: run `~/.claude/hooks/install-canonical-pin.sh` after pushing.

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
│   ├── settings.example.json
│   └── superpowers/
├── global/                       # Tracked ~/.claude files (see Global Configuration)
│   ├── CLAUDE.md
│   ├── cleanup.sh
│   ├── hooks/                    # guard-k8s.py, guard-work-checkout.py, canonical_pin.py + installer and tests
│   └── skills/korean-docs/       # Global Korean writing skill
├── plugins/
│   ├── devops-agents/            # 2 commands
│   └── productivity-agents/      # 3 agents + 4 commands
├── scripts/
│   ├── notify.sh
│   ├── sync-global.sh            # global/ <-> ~/.claude
│   ├── sync-shared.sh
│   └── validate.sh               # Local & CI validation
├── shared/
│   └── references/               # Canonical shared assets
└── README.md
```

---

## Plugins & Agents (3 total)

### devops-agents (2 commands)

Slash commands: `/railway-deploy`, `/railway-setup` (defined in `commands/`)

> **Note**: Git 커밋/푸시 작업은 공식 `commit-commands` 플러그인의 `/commit`, `/commit-push-pr` 명령을 사용하세요.

### productivity-agents (3 agents + 4 commands)

Retrospective agents. Slash commands live in `commands/`.

| Agent | Description | Color |
|-------|-------------|-------|
| `commit-retrospective` | Git commit history-based retrospective generation | cyan |
| `jira-retrospective` | Jira issue-based retrospective generation | blue |
| `retrospective-validator` | Sensitive-information scan of generated retrospectives (called by the two retrospective agents) | red |

Slash commands: `/git-retro`, `/jira-retro`, `/write-tests`, `/cleanup` (defined in `commands/`)

### claude-hookify (7 hooks)

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
| `prefer-jira-retrospective` | Retrospective keywords | jira-retrospective |
| `prefer-commit-retrospective` | Commit retrospective keywords | commit-retrospective |

> `prefer-backend-agent`, `prefer-database-expert`, `prefer-frontend-engineer`, and `prefer-test-automation` recommend agents this marketplace no longer ships.

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
| `/write-tests` | `productivity-agents` | Generate tests for a file | `/write-tests src/auth.ts` |
| `/cleanup` | `productivity-agents` | Reclaim disk space under `~/.claude` | `/cleanup dry-run` |
| `/railway-deploy` | `devops-agents` | Generate Railway deployment config | `/railway-deploy fastapi` |
| `/railway-setup` | `devops-agents` | Initialize a Railway project | `/railway-setup "Node.js + PostgreSQL"` |

### Agent Routing

Applies only where the plugin is installed and enabled (`~/.claude/plugins/installed_plugins.json`, `enabledPlugins` in `~/.claude/settings.json`).

| Task Type | Plugin:Agent | Trigger Keywords |
|-----------|--------------|------------------|
| Jira Retrospective | `productivity-agents:jira-retrospective` | "회고록", "회고", "retrospective", "주간 정리", "Jira 이슈 정리" |
| Commit Retrospective | `productivity-agents:commit-retrospective` | "커밋 회고", "Git 회고", "GitHub 회고", "GitLab 회고", "작업 이력 정리" |
| Retrospective Validation | `productivity-agents:retrospective-validator` | "회고 검증", "retrospective 감지", "회고 자동화" |

### Official vs Local Plugins

| Task | Official plugin (`claude-plugins-official`) | Local agent |
|------|---------------------------------------------|-------------|
| Git commit/push/PR | `/commit`, `/commit-push-pr`, `/clean_gone` (`commit-commands`) | - |
| Code review | `code-review`, `pr-review-toolkit` | - |
| Feature workflow | `feature-dev` (generic 7-step workflow) | - |
| GitHub API / issues / PRs | `github` (MCP) | - |
| GitLab API | `gitlab` (MCP) | - |
| Frontend design aesthetics | `frontend-design` | - |
| Playwright browser automation | `playwright` (MCP) | - |
| Test writing | - | `/write-tests` |
| Railway deploy/setup | - | `/railway-deploy`, `/railway-setup` |
| Retrospectives | - | `/jira-retro`, `/git-retro` |

### Codex Skill Source

The Mobidoc UI/UX beta Codex skill source lives in `codex/skills/mobidoc-ui-ux-beta/`. It is intentionally not registered in the Claude marketplace. Install it into a personal Codex environment by copying or symlinking that directory when needed.

---

## Adding New Agents

1. Create `.md` file in the appropriate plugin's `agents/` folder
2. Add YAML frontmatter:
   ```yaml
   ---
   name: my-agent
   description: |
     One or two sentences on when to delegate to this agent.
     Keywords: trigger, 키워드
   model: sonnet
   color: red
   ---
   ```
3. Write agent prompt (expertise, core knowledge, working principles)
4. Add the agent to its plugin table above and update the counts; `scripts/validate.sh` fails while the README and the files disagree

---

## License

MIT
