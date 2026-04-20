# CLAUDE.md -- i-dotfiles

This is a dotfiles repo. Shell configs are Fish, terminal is Ghostty (macOS/Linux) and Windows Terminal (Windows).

## Key paths

- `fish/` -- Fish shell config, aliases, functions
- `fish/work/` -- Machine-specific work configs (gitignored, loaded dynamically)
- `ghostty/config` -- Ghostty terminal config
- `starship/starship.toml` -- Starship prompt config
- `bootstrap.sh` -- Cross-platform bootstrap (must work on macOS Bash 3.2)
- `bin/dotfiles` -- CLI for linking config into projects (must work on macOS Bash 3.2)
- `ai/` -- Style guide, system prompt, CLAUDE.md template for linking into other repos

## Bash compatibility

macOS ships Bash 3.2. Do not use Bash 4+ features in `bootstrap.sh` or `bin/dotfiles`:
- No `${var,,}` or `${var^^}` (use `tr` instead)
- No `mapfile` or `readarray` (use `while read` loops)
- No associative arrays

## Linking into projects

`dotfiles link .` symlinks config files (style guide, CLAUDE.md, linter config, etc.) into any git repo. Linked files are excluded via `.git/info/exclude`.
