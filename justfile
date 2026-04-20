# ══════════════════════════════════════════════════════════════════════════════
# justfile — i-dotfiles task runner
# github.com/zeraphie/i-dotfiles
#
# Usage:
#   just          → list all available recipes
#   just <recipe> → run a recipe
# ══════════════════════════════════════════════════════════════════════════════

# Show available recipes by default
_default:
    @just --list --unsorted

# ── Meta ──────────────────────────────────────────────────────────────────────

# Print the dotfiles directory
@dir:
    echo "Dotfiles: {{justfile_directory()}}"

# ── Installation ──────────────────────────────────────────────────────────────

# Run the full bootstrap (auto-detects OS)
install:
    #!/usr/bin/env bash
    chmod +x "{{justfile_directory()}}/bootstrap.sh"
    "{{justfile_directory()}}/bootstrap.sh"

# Create symlinks only (skip package installation)
link:
    #!/usr/bin/env sh
    DOTFILES="{{justfile_directory()}}"
    OS="$(uname -s)"

    _link() {
        src="$1"
        dst="$2"
        mkdir -p "$(dirname "$dst")"
        if [ -L "$dst" ]; then
            echo "  ~ (already linked) $dst"
        elif [ -e "$dst" ]; then
            echo "  ! (backing up)     $dst → $dst.bak"
            mv "$dst" "$dst.bak"
            ln -sf "$src" "$dst"
            echo "  ✓ linked           $dst"
        else
            ln -sf "$src" "$dst"
            echo "  ✓ linked           $dst"
        fi
    }

    echo ""
    echo "Linking dotfiles..."
    echo ""

    _link "$DOTFILES/fish/config.fish"       "$HOME/.config/fish/config.fish"
    _link "$DOTFILES/fish/aliases.fish"      "$HOME/.config/fish/aliases.fish"
    _link "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
    _link "$DOTFILES/ghostty/config"         "$HOME/.config/ghostty/config"
    _link "$DOTFILES/mise/config.toml"       "$HOME/.config/mise/config.toml"
    _link "$DOTFILES/git/.gitconfig"         "$HOME/.gitconfig"

    for f in "$DOTFILES/fish/functions/"*.fish; do
        _link "$f" "$HOME/.config/fish/functions/$(basename "$f")"
    done

    echo ""
    echo "Done."

# ── Fish ──────────────────────────────────────────────────────────────────────

# Reload fish config (run from inside a fish session)
reload:
    fish -c "source ~/.config/fish/config.fish && echo 'Fish config reloaded.'"

# Open fish config in Zed
edit-fish:
    zed {{justfile_directory()}}/fish/config.fish

# Open fish aliases in Zed
edit-aliases:
    zed {{justfile_directory()}}/fish/aliases.fish

# ── Starship ──────────────────────────────────────────────────────────────────

# Open starship config in Zed
edit-starship:
    zed {{justfile_directory()}}/starship/starship.toml

# Print current starship config to stdout
show-starship:
    cat {{justfile_directory()}}/starship/starship.toml

# ── Git ───────────────────────────────────────────────────────────────────────

# Open gitconfig in Zed
edit-git:
    zed {{justfile_directory()}}/git/.gitconfig

# ── Ghostty ───────────────────────────────────────────────────────────────────

# Open ghostty config in Zed
edit-ghostty:
    zed {{justfile_directory()}}/ghostty/config

# ── Mise ──────────────────────────────────────────────────────────────────────

# Open mise config in Zed
edit-mise:
    zed {{justfile_directory()}}/mise/config.toml

# Show currently active mise tool versions
mise-status:
    mise list

# Install all global mise tool versions
mise-install:
    mise install

# ── Repo ──────────────────────────────────────────────────────────────────────

# Open the whole dotfiles repo in Zed
edit:
    zed {{justfile_directory()}}

# Pull latest changes from origin
pull:
    git -C {{justfile_directory()}} pull --rebase

# Show uncommitted changes in the dotfiles repo
status:
    git -C {{justfile_directory()}} status -sb

# Commit all changes with a message
commit msg:
    git -C {{justfile_directory()}} add -A
    git -C {{justfile_directory()}} commit -m "{{msg}}"

# Commit all changes and push
push msg:
    git -C {{justfile_directory()}} add -A
    git -C {{justfile_directory()}} commit -m "{{msg}}"
    git -C {{justfile_directory()}} push

# ── Project linking ───────────────────────────────────────────────────────────

# Interactively link dotfiles config into a project (uses fzf if available)
project-link path=".":
    "{{justfile_directory()}}/bin/dotfiles" link "{{path}}"

# Link all dotfiles config into a project without prompting
project-link-all path=".":
    "{{justfile_directory()}}/bin/dotfiles" link "{{path}}" --all

# Remove dotfiles symlinks from a project
project-unlink path=".":
    "{{justfile_directory()}}/bin/dotfiles" unlink "{{path}}"

# Show which dotfiles configs are linked in a project
project-status path=".":
    "{{justfile_directory()}}/bin/dotfiles" status "{{path}}"

# ── Housekeeping ──────────────────────────────────────────────────────────────

# Verify that all expected symlinks exist and point to the right place
verify:
    #!/usr/bin/env sh
    DOTFILES="{{justfile_directory()}}"
    OK=0
    FAIL=0

    _check() {
        src="$1"
        dst="$2"
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
            echo "  ✓ $dst"
            OK=$((OK + 1))
        elif [ -L "$dst" ]; then
            echo "  ✗ $dst (points to wrong target: $(readlink "$dst"))"
            FAIL=$((FAIL + 1))
        elif [ -e "$dst" ]; then
            echo "  ✗ $dst (exists but is not a symlink)"
            FAIL=$((FAIL + 1))
        else
            echo "  ✗ $dst (missing)"
            FAIL=$((FAIL + 1))
        fi
    }

    echo ""
    echo "Verifying symlinks..."
    echo ""

    _check "$DOTFILES/fish/config.fish"       "$HOME/.config/fish/config.fish"
    _check "$DOTFILES/fish/aliases.fish"      "$HOME/.config/fish/aliases.fish"
    _check "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
    _check "$DOTFILES/ghostty/config"         "$HOME/.config/ghostty/config"
    _check "$DOTFILES/mise/config.toml"       "$HOME/.config/mise/config.toml"
    _check "$DOTFILES/git/.gitconfig"         "$HOME/.gitconfig"

    for f in "$DOTFILES/fish/functions/"*.fish; do
        _check "$f" "$HOME/.config/fish/functions/$(basename "$f")"
    done

    echo ""
    echo "Result: $OK passed, $FAIL failed."
    [ "$FAIL" -eq 0 ]
