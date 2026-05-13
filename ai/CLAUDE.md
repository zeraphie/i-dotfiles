# {{PROJECT_NAME}} — CLAUDE.md

<!-- Copied by `dotfiles link`. Edit freely — this is your project's copy. -->

{{PROJECT_NOTES}}

## Key paths

{{KEY_PATHS}}

## Style

See [.ai/STYLE.md](.ai/STYLE.md) for code style rules.

Mechanical formatting is handled by **oxfmt** (`.oxfmtrc.json`). Mechanical linting is handled by **oxlint** (`.oxlintrc.json`). Use `/enforce-style` to review code against the style guide.

## Security

See [.ai/SECURITY.md](.ai/SECURITY.md) for security and privacy rules.

Use `/review-security` to audit code for vulnerabilities.

## Tooling

- Package manager: **bun**
- Task runner: **just**
- Linter: **oxlint** (never ESLint)
- Formatter: **oxfmt** (never Prettier)

## Commits

Conventional commits via commitlint. Branches: `feat/thing`, `fix/thing`, `chore/thing`.

## Shell scripts

Any shell scripts in this repo must run on **Bash 3.2** (macOS default). No Bash 4+ features:
no `${var,,}`, no `mapfile`, no associative arrays. Use `tr` for case conversion and
`while IFS= read -r line` for reading lines.

## Slash commands

- `/enforce-style` — review code against `.ai/STYLE.md` and apply fixes
- `/review-security` — audit code using `.ai/SECURITY.md` (auto-detects fintech context from git remote)
- `/setup-project` — run `dotfiles link .` to copy shared config into this project