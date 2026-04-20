# ──────────────────────────────────────────────────────────────────────────────
# config.fish — main Fish shell configuration
# github.com/zeraphie/i-dotfiles
# ──────────────────────────────────────────────────────────────────────────────

# Disable the default Fish greeting
set -g fish_greeting ""

# ── OS Detection ──────────────────────────────────────────────────────────────
set -g OS (uname -s)

# ── Environment Variables ─────────────────────────────────────────────────────
set -gx EDITOR "zed --wait"
set -gx VISUAL "zed"
set -gx PAGER "less -FRX"
set -gx LANG "en_US.UTF-8"
set -gx LC_ALL "en_US.UTF-8"

# Coloured man pages via less
set -gx LESS_TERMCAP_mb (printf '\e[01;31m')
set -gx LESS_TERMCAP_md (printf '\e[01;34m')
set -gx LESS_TERMCAP_me (printf '\e[0m')
set -gx LESS_TERMCAP_se (printf '\e[0m')
set -gx LESS_TERMCAP_so (printf '\e[01;44;33m')
set -gx LESS_TERMCAP_ue (printf '\e[0m')
set -gx LESS_TERMCAP_us (printf '\e[01;32m')

# ── PATH ──────────────────────────────────────────────────────────────────────
# Start with a clean, predictable path and layer on top

# Local bin (user scripts)
fish_add_path --global --prepend "$HOME/.local/bin"
fish_add_path --global --prepend "$HOME/bin"

# macOS — Homebrew (Apple Silicon first, then Intel fallback)
if test "$OS" = Darwin
    if test -d /opt/homebrew
        # Apple Silicon
        set -gx HOMEBREW_PREFIX /opt/homebrew
        fish_add_path --global --prepend /opt/homebrew/bin
        fish_add_path --global --prepend /opt/homebrew/sbin
    else if test -d /usr/local/Homebrew
        # Intel Mac
        set -gx HOMEBREW_PREFIX /usr/local
        fish_add_path --global --prepend /usr/local/bin
        fish_add_path --global --prepend /usr/local/sbin
    end

    # Homebrew: don't send analytics
    set -gx HOMEBREW_NO_ANALYTICS 1
    # Homebrew: don't auto-update on every install (do it explicitly)
    set -gx HOMEBREW_NO_AUTO_UPDATE 1
end

# Linux — common extra paths
if test "$OS" = Linux
    fish_add_path --global /usr/local/bin
    fish_add_path --global /usr/bin
    fish_add_path --global /bin
    fish_add_path --global /snap/bin
end

# Dotfiles bin (added after DOTFILES is resolved below, see end of PATH section)

# Rust / Cargo
if test -d "$HOME/.cargo/bin"
    fish_add_path --global "$HOME/.cargo/bin"
end

# Go
if test -d "$HOME/go/bin"
    fish_add_path --global "$HOME/go/bin"
end

# Bun
if test -d "$HOME/.bun/bin"
    fish_add_path --global "$HOME/.bun/bin"
    set -gx BUN_INSTALL "$HOME/.bun"
end

# ── Mise (runtime version manager) ───────────────────────────────────────────
# Mise replaces nvm, pyenv, rbenv, rustup, etc.
# https://mise.jdx.dev/
if command -q mise
    mise activate fish | source
end

# ── Starship Prompt ───────────────────────────────────────────────────────────
# https://starship.rs/
# Must come after mise so the right tool versions are available for the prompt
if command -q starship
    set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
    starship init fish | source
end

# ── Dotfiles ──────────────────────────────────────────────────────────────────
# Resolve DOTFILES from the symlinked config.fish back to the repo root
set -gx DOTFILES (string replace '/fish/config.fish' '' (realpath (status filename)))

# Dotfiles bin
if test -d "$DOTFILES/bin"
    fish_add_path --global "$DOTFILES/bin"
end

# ── Aliases ───────────────────────────────────────────────────────────────────
# Sourced from a separate file to keep this config clean
if test -f "$HOME/.config/fish/aliases.fish"
    source "$HOME/.config/fish/aliases.fish"
end

# ── Work / machine-specific configs ──────────────────────────────────────────
# Drop .fish files into fish/work/ for work-specific aliases, env vars, etc.
# These files are gitignored so they never get committed.
if test -d "$DOTFILES/fish/work"
    for f in $DOTFILES/fish/work/*.fish
        test -f "$f"; and source "$f"
    end
end

# ── Local / machine-specific overrides ───────────────────────────────────────
# Create ~/.config/fish/local.fish for anything you don't want committed
if test -f "$HOME/.config/fish/local.fish"
    source "$HOME/.config/fish/local.fish"
end
