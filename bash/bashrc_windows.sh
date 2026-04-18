# ──────────────────────────────────────────────────────────────────────────────
# bashrc_windows.sh — Git Bash additions for i-dotfiles
# Sourced from ~/.bashrc on Windows
# github.com/zeraphie/i-dotfiles
# ──────────────────────────────────────────────────────────────────────────────

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="$PATH:/c/Program Files/starship/bin"
export PATH="$PATH:/c/Program Files/GitHub CLI"
export PATH="$PATH:$HOME/Documents/Development/i-dotfiles/bin"

# ── Starship prompt ───────────────────────────────────────────────────────────
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# ── Editor ────────────────────────────────────────────────────────────────────
export EDITOR="zed --wait"
export VISUAL="zed"

# ── Smart cd ──────────────────────────────────────────────────────────────────
# Navigate to a directory, print the path underlined, and list contents.
# Usage: c [path]   — same as cd but with auto-listing
#        c          — refresh current directory listing
#        c -        — go back to previous directory
c() {
    if [[ $# -gt 0 ]] && [[ "$1" != "." ]]; then
        cd "$@" > /dev/null || return
    fi
    echo
    printf '\e[4;1m%s\e[0m\n' "$PWD"
    echo
    ls -lahF
}

# ── Git wrapper ───────────────────────────────────────────────────────────────
# Bare `git` with no arguments shows status instead of the help page.
git() {
    if [ $# -gt 0 ]; then
        command git "$@"
    else
        command git status
    fi
}

# ── Directory navigation ──────────────────────────────────────────────────────
alias u='c ..'
alias uu='c ../..'
alias uuu='c ../../..'
alias uuuu='c ../../../..'
alias uuuuu='c ../../../../..'
alias uuuuuu='c ../../../../../..'
alias b='c -'

# ── File listing ──────────────────────────────────────────────────────────────
alias l='ls -lahF'

# ── Editor ────────────────────────────────────────────────────────────────────
alias e='zed'

# ── Git ───────────────────────────────────────────────────────────────────────
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

# ── Dotfiles ──────────────────────────────────────────────────────────────────
export DOTFILES="$HOME/Documents/Development/i-dotfiles"

# Make sure the dotfiles script is executable
if [ -f "$DOTFILES/bin/dotfiles" ]; then
  chmod +x "$DOTFILES/bin/dotfiles"
fi
