# CLAUDE.md

Global Claude Code guidance for `~/.claude`. Repository-local `CLAUDE.md` files override this file when they are more specific.

## Core Workflow

- Default to the loop: inspect real state -> plan or clarify -> set test criteria -> implement narrowly -> verify -> summarize.
- Ground conclusions in files, diffs, logs, commands, and tests. Do not infer repository shape from memory when the workspace can answer it.
- For feature or bugfix work, prefer test-first or test-near implementation. Add focused regression coverage where behavior could break again.
- For review requests, use a code-review stance: findings first, ordered by severity, with file/line references and test gaps.
- Keep implementations pragmatic. Add abstractions only when they remove real complexity, encode meaningful domain rules, or match an existing local pattern.

## Comments vs. Other Channels

A comment is the only artifact that reaches the reader **without being sought** — same field of view, same diff, no lookup. That is its entire justification, and it is paid for by everyone who opens the file, forever. Route everything else to the channel that actually delivers it.

| Information | Destination |
|---|---|
| Why this change happened; alternatives tried or rejected; measurements, dates, rollout state; ticket/MR references | commit message |
| Review points, deploy order, how it was verified, risk notes | MR/PR body |
| Architecture, domain rules, runbooks, "never do X" | repo docs (`AGENTS.md`, `docs/`) |
| Unfinished work — the gap in the code, not the remediation plan | `TODO(owner): reason` + ticket |
| What to tell a human at runtime when they got it wrong | exception / log message |
| What to tell an operator before they run something | task/parameter `description`, `--help` |
| Contracts and invariants | types, signatures, test names |
| What *quietly* breaks the next edit at this exact line | comment |

That last row is narrow on purpose. In practice it is: magic-number and sizing rationale, an environment difference (glibc vs musl, dev vs prod), a workaround tied to a specific named bug, or an ordering some tool silently depends on.

**Three filters. A comment line must survive all three.**

1. **Falsifiability.** Ask "what would have to change for this to become false?" If the answer lies outside the code — a deploy schedule, when it was measured, another repo, a ticket closing — it is commit-message content. Conversely, if the line would still read true after the surrounding code is renamed or refactored, it is filler.
2. **Silent failure.** If getting this wrong breaks the build, fails CI, or crashes at startup, write nothing — the failure teaches faster and cannot be skipped. Comment only what goes wrong *quietly*: a lost cache hit, a stale measurement, a clobbered global config.
3. **No second copy.** If `AGENTS.md`, a repo `CLAUDE.md`, a task `description`, an exception message, or a test name already says it, do not restate it. Two copies always diverge, and the code copy is the one that rots. Grep the docs before writing the comment.

Never:

- Diff voice — "same as before", "the builder stage is gone", "kept so we don't re-investigate". You can see the before/after; the reader who opens this file in a year cannot.
- A comment written because you doubt the commit message will be read. Write the commit message.
- A second line that restates the first from a new angle. If it genuinely needs two lines, it is a docs entry — put it there and leave a pointer, or leave nothing.
- The same comment in N files. **The duplication is the defect; fix the structure.**

**Moving a line out is not the same as deleting it.** Strip a number and the "why is it shaped this way" leaves with it — replace it with a reason that stays true inside the code, or file the whole thing in the docs and point at it.

**Sweep the staged diff's added comment lines as a separate pass before committing.** While writing, attention goes to the content and the classification gets deferred — and a deferred classification does not come back. In config, build, and infra files, comment lines above roughly 15% are a signal that filter 3 is being skipped.

Existing comments in the repository that break these rules are not precedent. Follow a local convention only where a repo-local instruction file states it.

## Audience by Channel

The same change reads differently in each channel because each has a different reader. Rewrite for that reader; never paste one channel's text into another. Link across channels instead (Jira issue <-> MR/PR).

| Channel | Reader | Lead with | Leave out |
|---|---|---|---|
| Jira issue body / comment | Reviewer, QA, PM with no code open | What changed for the user, where to see it, how to verify (steps, expected result, environment), what is still open | File paths, class/function names, diffs, refactoring detail, implementation narrative. Link the MR/PR for those |
| Commit message | Developer reading history | Why the change happened, what was tried or rejected (see table above) | Process narrative, restating the diff |
| MR/PR body | Developer reviewer | Summary, what to review first, how it was verified, deploy order, risk | Empty template sections, a repeated commit list, user-facing narrative that belongs in Jira |
| Claude Artifact | Reviewer and developer together | A plain-language summary anyone can act on, first. Developer detail in its own section below it | Undefined jargon, raw logs or dumps in the main flow, terminal-style narration |

- Structure over prose: headings, numbered verification steps, tables, before/after. The reader should find their answer by scanning.
- Order is outcome, then how to confirm it, then caveats. A Jira comment that opens with a class name has the wrong reader in mind.
- Any "done" in Jira or an MR/PR body names how it was verified. If it was not, say so.
- Check the reader before posting. Jira: "Can they act on this without opening the code?" MR/PR: "Can they review this without asking me?" Artifact: "Can both readers use this without asking the other?"

## Git Commits

- Commit only when asked. One reviewable unit of work is one commit; no `wip` or `fix typo` checkpoint commits.
- Before committing, run `git log --oneline -10` and decide whether the change belongs to a commit already on this branch rather than to a new one.
- If it extends the previous unpushed commit, use `git commit --amend`. If it belongs to an earlier unpushed commit, propose `git commit --fixup=<sha>` and run `git rebase --autosquash <base>` only after explicit approval, never as a side effect of committing.
- Never rewrite a commit that is already pushed or on a shared branch. Add a new commit instead.
- Interactive git flows (`git rebase -i`, `git add -i`) do not run in this environment. When history needs work beyond amend or autosquash, state the exact commands and let the human run them.

## Tool Use

- Use `rg` and `rg --files` first for search. Fall back only when unavailable.
- Run focused tests before broad suites when possible, then broaden verification if the touched surface is shared or risky.
- Prefer dry-run modes before commands that rewrite notes, generated files, migrations, workspace state, or automation outputs.
- Check `git status --short` before and after meaningful work in repositories with existing user changes.
- Prefer project-native tools and documented plugin commands. If slash commands, skills, hooks, or plugin behavior are relevant, inspect the owning plugin documentation before relying on remembered behavior.
- Bound output at the source: `git log --oneline -N`, `git diff --stat` before a full diff, `| head`, quiet or summary test reporters. Read file ranges (`sed -n`, `rg -n -C`) instead of whole large files.
- Delegate broad multi-file sweeps to a search subagent and keep only its conclusion. A subagent's reads are discarded; the main thread's are not.

## Planning & Reviews

- If the task is ambiguous but discoverable, inspect the repo before asking. Ask only for product intent, risk tradeoffs, or missing information that cannot be derived locally.
- Plans should be implementation-ready: goal, exact scope, behavior changes, edge cases, verification, and assumptions.
- During implementation, keep updates short and concrete: what is being inspected, what was learned, and what will be changed next.
- For code reviews, do not rewrite the code unless asked. Identify bugs, regressions, unsafe assumptions, and missing tests before style comments.
- For receiving review feedback, verify the feedback against the code before accepting it as true.

## Repository Safety

- Preserve user work. Never reset, discard, overwrite, or clean unrelated changes unless explicitly requested.
- Keep edits scoped to the requested behavior and the local patterns already present in the repository.
- Avoid broad formatting or generated churn unless it is part of the requested task or required by verification.
- Do not expose secrets in Markdown, logs, commits, or final responses. Environment variable names are acceptable; token values are not.
- Prefer non-destructive git commands. Avoid interactive git flows when a non-interactive equivalent is available.
- Stating a principle at the top of a file is not the same as the file honoring it. When you write one, verify the actual column list, body, or output separately.

## Kubernetes / External Infrastructure Safety

- Do NOT run cluster-mutating commands. This includes `kubectl apply/create/delete/edit/patch/replace/scale/set/label/annotate/drain/cordon/uncordon/taint/exec/cp/attach/port-forward/run/debug` and `kubectl rollout restart|undo|pause|resume`, `helm install/upgrade/uninstall/delete/rollback`, and `argocd app sync/delete/create/...`. A global `PreToolUse` hook (`~/.claude/hooks/guard-k8s.py`) hard-blocks these.
- Read-only inspection IS allowed by default (`kubectl get/describe/logs/top/explain`, `kubectl rollout status`, `helm list/status`, `argocd app get/list`). Use these freely to diagnose.
- **A stricter workspace or repo rule always wins over the default above.** Where a local `AGENTS.md`/`CLAUDE.md` requires approval for read-only cluster access, ask first — even when the `guard-k8s.py` hook would allow the command. A permissive hook is not permission.
- If a cluster change is genuinely needed, explain the exact command and its effect, then let the human run it directly (`!` prefix in the prompt, or their own terminal). Never try to bypass the hook via shell chaining, encoding, or alternate binaries.
- If a Kubernetes MCP server is connected, add its write tools to `permissions.deny` in `~/.claude/settings.json`. The hook covers `Bash` only.

## Scope Boundaries

- Repository/workspace-specific rules belong in local `AGENTS.md`, local `CLAUDE.md`, or task-specific skills.
- Repository-specific automation should be governed by repo-local instruction files and available task-specific skills.
- Keep global guidance focused on always-applicable collaboration, safety, git, and verification principles.
- When reviewing or changing AI instruction files, check every rule against three tests: it is executable in this environment, it points at something that actually exists, and it belongs at this level rather than in a repo-local file.

## Verification Defaults

- Backend/Spring work: run the narrow Gradle test or module task first, then broader checks when shared behavior changed.
- Frontend work: run the focused unit/integration suite or type/build check tied to the touched component. Use browser verification for visible UI behavior.
- Automation or content-generation work: run the relevant script in dry-run mode when available, then targeted tests for changed behavior.
- CI or infrastructure work: validate syntax/config locally where possible and document any remote checks that could not be run.

## Claude Code Notes

- Read active settings, registered marketplaces, and installed plugins from `~/.claude/settings.json`, `~/.claude/plugins/known_marketplaces.json`, and `~/.claude/plugins/installed_plugins.json` rather than from memory.
- For custom agent routing and plugin-specific workflows, inspect `~/.claude/plugins/marketplaces/ahngbeom-claude-config/README.md`. The global files themselves are tracked in that repo under `global/` and synced with `scripts/sync-global.sh`.
- For productivity setup scripts, inspect `~/.claude/plugins/marketplaces/ahngbeom-claude-config/plugins/productivity-agents/setup/`.
- Do not duplicate plugin inventories, credential examples, command catalogs, or generated runtime snapshots in this global guidance file.
- `MEMORY.md` is loaded into every session. Keep it to one line per memory, and delete a superseded entry in the same edit that adds its replacement.

## Final Responses

- Keep final answers concise and factual. Mention changed files, verification performed, and risks or skipped checks.
- Do not paste large command outputs; summarize the important lines.
- Do not end by asking whether to proceed when the requested work is already complete.
