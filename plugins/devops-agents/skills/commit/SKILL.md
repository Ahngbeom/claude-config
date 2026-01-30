---
name: commit
description: Git commit with smart message generation and optional Jira ticket linkage
argument-hint: "[jira-ticket]"
allowed-tools: Bash(git *)
---

# Git Commit Skill

## Current Git Status
!`git status --short 2>/dev/null || echo "Not a git repository"`

## Recent Commits (for style reference)
!`git log --oneline -5 2>/dev/null || echo "No commits yet"`

## Staged Changes
!`git diff --cached --stat 2>/dev/null || echo "No staged changes"`

## Unstaged Changes
!`git diff --stat 2>/dev/null || echo "No unstaged changes"`

---

## Your Task

You are a Git workflow specialist. Analyze the changes above and help the user commit them properly.

### Step 1: Jira Ticket Check

**If `$ARGUMENTS` contains a Jira ticket (e.g., PROJ-123):**
- Use the provided ticket in the commit message prefix

**If `$ARGUMENTS` is empty:**
- Ask the user: "관련 Jira 이슈 티켓이 있나요? (예: PROJ-123, 없으면 'n' 입력)"
- Wait for response before proceeding

### Step 2: Analyze Changes

1. Review the git status and diff output above
2. Identify the type of change:
   - `feat`: New feature
   - `fix`: Bug fix
   - `docs`: Documentation
   - `test`: Test code
   - `refactor`: Code refactoring
   - `chore`: Build, config, dependencies

### Step 3: Generate Commit Message

**Format with Jira ticket:**
```
[TICKET-123] [type] Brief summary (max 50 chars)

- Detailed change 1
- Detailed change 2

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Format without Jira ticket:**
```
[type] Brief summary (max 50 chars)

- Detailed change 1
- Detailed change 2

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Step 4: Execute Commit

1. Stage relevant files (prefer specific files over `git add -A`)
2. Create the commit with the generated message
3. Push to remote repository

### Step 5: Report Results

After successful commit:
- Show commit hash
- Show branch name
- If Jira ticket was provided, show link: `https://yourcompany.atlassian.net/browse/TICKET-123`

## Important Notes

- Never force push without explicit permission
- Never commit sensitive files (.env, credentials, API keys)
- If pre-commit hooks fail, fix issues and create a NEW commit (don't amend)
- Always verify the current branch before pushing
