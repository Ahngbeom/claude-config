---
name: mobidoc-ui-ux-beta
description: Use when reviewing or designing Mobidoc frontend UI/UX for patient, hospital, or tablet flows, especially to apply personal beta guidance for navigation-centered healthcare UX, concise Korean UX writing, layout stability, readability, and PR review checklists. This is a personal beta skill, not an official team standard.
---

# Mobidoc UI/UX Beta

Use this skill for Mobidoc frontend UI/UX review or design guidance. It is a personal beta reference for consistent work across local worktrees, not an official team guideline.

## Workflow

1. Identify the target build and user: patient, hospital, tablet, or cross-build.
2. Inspect the actual screen, component, design note, or diff before recommending changes.
3. Load `references/mobidoc-ui-ux-guidelines.md` when detailed criteria are needed.
4. Review in this order: user task, navigation, interaction states, UX writing, layout stability, readability, verification.
5. Keep recommendations scoped to the screen or flow being reviewed.

## Defaults

- Respond in Korean unless the user requests another language.
- Treat implementation details, patient data, screenshots, credentials, and internal business specifics as sensitive.
- Do not claim this guidance is an approved team standard.
- Prefer concrete UI and copy changes over broad design principles.
- For visible UI changes, verify relevant viewport sizes and build targets when possible.

## Review Output

Lead with findings ordered by user impact:

1. Findings with screen, component, file, or flow references.
2. Recommended changes.
3. Verification to run.
4. Open questions only when the recommendation depends on missing product intent.
