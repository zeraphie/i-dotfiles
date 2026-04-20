# CLAUDE.md

This file is loaded automatically by Claude Code at the start of every session.

## Who

Izzy (zeraphie). TypeScript/JavaScript, Bun, Rust, Python, Bash. Zed editor.

## Style

See `STYLE.md` in this directory (or project root if linked via `dotfiles link .`) for the full style guide. Key rules:

- 2-space indent, single quotes, always semicolons, always `{}`
- `if (condition)` — space before paren, body always on its own line (no one-liners)
- `const` by default, never `var`
- Guards and early returns over ternaries and nesting
- Blank lines between logical paragraphs
- Named `function` declarations top-level, arrow functions for callbacks
- `kebab-case` files, `PascalCase` components/classes, `camelCase` functions/vars, `SCREAMING_SNAKE_CASE` constants
- `_camelCase` prefix for private/internal methods
- Explicit `.js` extensions on ESM imports
- File header comment on line 1: `// filename.js -- brief description`
- Section dividers in longer files: `// -- Section name ----`
- JSDoc on all public API code with `@param`, `@returns`, `@complexity`
- SCSS for personal projects (no Tailwind, no CSS-in-JS). Match existing approach in work repos.

## Workflow

1. **Research** -- read relevant files, ask if anything is unclear
2. **Plan** -- present numbered steps, wait for approval
3. **Execute** -- one step at a time, confirm after each
4. **Lint & format** -- run oxlint + oxfmt after every change (check justfile/package.json for commands)
5. **Flag issues** -- security, privacy, GDPR, performance at end of every response

## Tooling

| Purpose | Tool |
|---|---|
| Package manager | bun |
| Task runner | just |
| Linter | oxlint (never ESLint) |
| Formatter | oxfmt (never Prettier) |
| Testing | vitest |
| Styles | SCSS |

## Project Context

Infer from git remote:
- `Advisa` org = fintech (strict security, audit logging, data minimisation)
- `zeraphie` org = personal (standard security, GDPR awareness)
- Other = treat as personal unless told otherwise

## Flagged Issues

End every response where code was written with:

```
## Flagged Issues

CRITICAL -- security vulnerabilities, broken auth, data leaks (must fix before shipping)
WARNING -- privacy risks, perf issues, missing protections (fix soon)
INFO -- complexity notes, future considerations (monitor)
```

Or `No issues identified.` if clean.

## Don'ts

- Don't skip the plan step
- Don't write one-liner ifs — body always goes on its own line
- Don't use `var`, `eval()`, `dangerouslySetInnerHTML` without justification
- Don't store tokens in localStorage
- Don't log PII or sensitive data
- Don't write tests purely for coverage
- Don't use ESLint or Prettier
- Don't assume -- ask first
