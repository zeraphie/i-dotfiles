# ──────────────────────────────────────────────────────────────────────────────
# aliases.fish — shell aliases for Fish
# github.com/zeraphie/i-dotfiles
# ──────────────────────────────────────────────────────────────────────────────

# ── Directory navigation ──────────────────────────────────────────────────────
# All use the smart `c` function (navigate + print path + list files)

alias u='c ..'
alias uu='c ../..'
alias uuu='c ../../..'
alias uuuu='c ../../../..'
alias uuuuu='c ../../../../..'
alias uuuuuu='c ../../../../../..'

# Go back to previous directory
alias b='c -'

# ── File listing ──────────────────────────────────────────────────────────────
# -l long format  -a all files  -h human-readable sizes
# No -G needed in Fish; colour is handled by the terminal / $LS_COLORS
alias l='ls -lah'

# ── Editor ────────────────────────────────────────────────────────────────────
alias e='zed'

# ── Git ───────────────────────────────────────────────────────────────────────
# The `git` function in fish/functions/git.fish overrides the command so that
# bare `g` (no args) falls through to `git status` automatically.
alias g='git'

# ── Bun ───────────────────────────────────────────────────────────────────────
alias bi='bun install'
alias ba='bun add'
alias bad='bun add -d'
alias br='bun run'
alias bx='bunx'

# ── Just ──────────────────────────────────────────────────────────────────────
alias j='just'
alias jl='just --list'

# ── Mise ──────────────────────────────────────────────────────────────────────
alias m='mise'
alias mu='mise use'

# ── Node / package management ─────────────────────────────────────────────────
# Use Bun as the primary package manager; `ni` is a familiar shorthand
alias ni='bun install'
