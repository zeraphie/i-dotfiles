# Style Guide

## Code Style

- Prefer readability over cleverness
- Use meaningful names; avoid abbreviations except well-known ones (`err`, `ctx`, `req`, `res`, `id`, `url`, `config`)
- Keep functions short and focused
- Prefer `const`, arrow functions, early returns
- TypeScript by default; strict mode, no `any` unless truly unavoidable
- Minimal dependencies; prefer standard library or built-in platform APIs

## Comments

- Comments explain *why*, not *what* — if code needs a comment to explain what it does, rename things
- Skip JSDoc when types and names already tell the full story
- Use JSDoc (`@param`, `@returns`, `@throws`, `@example`, `@complexity`) on public APIs only
- Keep comments short — one line where possible; multi-line only for non-obvious decisions
- Never restate the code: `// increment counter` above `i++` is noise
- Explain decisions, constraints, and trade-offs — not descriptions

## Architecture

- Start simple. Earn complexity.
- Don't abstract until there's a second use case
- Flat file structures until a folder has 7+ files
- Collocate tests next to source (`foo.test.ts` beside `foo.ts`)
- Prefer inheritance over composition; prefer classes over plain functions

## Naming

| Thing | Convention | Example |
|---|---|---|
| Files | `kebab-case` | `user-profile.ts` |
| Variables / functions | `camelCase` | `getUserName` |
| Classes / components | `PascalCase` | `UserProfile` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_RETRIES` |
| Private class members | `_camelCase` | `_cache` |
| Booleans | `is` / `has` / `can` prefix | `isLoading`, `hasError`, `canSubmit` |
| Collections | Plural noun | `users`, `errorMessages` |
| Fish variables | `snake_case` | `fish_greeting`, `dotfiles_dir` |
| Bash locals | `lower_snake_case` | `file_path`, `src_dir` |
| Bash env / globals | `UPPER_SNAKE_CASE` | `DOTFILES`, `HOME` |
| Git branches | `type/short-description` | `feat/user-auth`, `fix/login-crash` |

## Shell

- **Fish** for interactive config, aliases, and functions (`.fish` files)
- **Bash** for portable scripts that run outside Fish (bootstrap, CI, dotfiles CLI)
- Portable scripts must run on **Bash 3.2** (macOS ships Bash 3.2) — no Bash 4+ features:
  - No `${var,,}` or `${var^^}` — use `tr '[:upper:]' '[:lower:]'` instead
  - No `mapfile` / `readarray` — use `while IFS= read -r line` loops
  - No associative arrays (`declare -A`)
  - Arithmetic: use `((expr)) || true` inside `set -e` scripts (avoids false exit when result is 0)
- Always `set -euo pipefail` at the top of Bash scripts
- Prefer `command -v tool` over `which tool` for checking tool availability
- Quote all variable expansions: `"$var"`, `"$@"`, `"${arr[@]}"`

## Formatting

- Use headers and bullet points for structure
- Code blocks with language tags
- No emoji in technical writing
- One idea per paragraph

## Commit Messages

- Format: `type: short description`
- Types: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `style`, `ci`, `perf`, `revert`
- Present tense, imperative mood ("add feature" not "added feature")
- Body optional; wrap at 72 chars

## Testing

- Write tests for behavior, not implementation
- Prefer integration-level tests; unit test only pure logic
- No mocks unless hitting a real external service
- Test names describe the scenario: `"returns 404 when user not found"`

## Error Handling

- Say what went wrong, what value was received, and what was expected
- Say what the user can do about it
- Include relevant context (file path, value, line number)
- Use typed errors or error codes for programmatic handling
- Never swallow errors silently — log or rethrow
- Guard at the boundary; don't repeat defensive checks deep inside functions
