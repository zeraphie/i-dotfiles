# Project

Read the project's own README or PLAN file for goals and architecture.

## Rules

- **Style & judgment calls** → `STYLE.md`
- **Workflow, security, privacy, flagging** → `.rules` (SYSTEM_PROMPT)
- **Mechanical formatting** → `.oxfmtrc.json` (oxfmt enforces it)
- **Mechanical lint rules** → `.oxlintrc.json` (oxlint enforces it)

Do not duplicate what the linter/formatter already enforces. The prompt is for judgment calls only.

## Hooks

**PostToolUse (Write|Edit):** Runs `node --check` on any `.js` file after it's written or edited. Catches syntax errors immediately.

## Useful skills

- `/simplify` — review a module for quality and efficiency
