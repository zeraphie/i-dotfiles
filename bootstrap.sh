#!/usr/bin/env bash
# ============================================================
# bootstrap.sh — Single cross-platform bootstrap for i-dotfiles
# Works on: macOS, Linux, Windows (Git Bash)
#
# Usage:
#   git clone https://github.com/zeraphie/i-dotfiles.git
#   cd i-dotfiles && ./bootstrap.sh
#
# Or without cloning first:
#   bash <(curl -fsSL https://raw.githubusercontent.com/zeraphie/i-dotfiles/master/bootstrap.sh)
#
# github.com/zeraphie/i-dotfiles
# ============================================================

set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { printf "${BLUE}${BOLD}  →${RESET}  %s\n" "$*"; }
success() { printf "${GREEN}${BOLD}  ✓${RESET}  %s\n" "$*"; }
warn()    { printf "${YELLOW}${BOLD}  !${RESET}  %s\n" "$*"; }
error()   { printf "${RED}${BOLD}  ✗${RESET}  %s\n" "$*" >&2; }
header()  { printf "\n${MAGENTA}${BOLD}══  %s${RESET}\n\n" "$*"; }

confirm() {
    local prompt="${1:-Continue?}"
    read -r -p "$(printf "${CYAN}  ?  ${RESET}${prompt} [y/N] ")" answer
    [[ "${answer,,}" == "y" || "${answer,,}" == "yes" ]]
}

has() { command -v "$1" &>/dev/null; }

# ── Resolve DOTFILES root ─────────────────────────────────────────────────────
# If running via curl pipe, we'll clone first and re-run from there.
# If running from a cloned repo, use the script's directory.
if [[ "${BASH_SOURCE[0]}" == bash ]]; then
    # Piped via curl — need to clone the repo first
    DOTFILES="$HOME/i-dotfiles"
    CLONED=true
else
    DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CLONED=false
fi

# ── OS Detection ──────────────────────────────────────────────────────────────
detect_os() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            if   [[ -f /etc/arch-release ]];   then echo "arch"
            elif [[ -f /etc/debian_version ]]; then echo "debian"
            elif [[ -f /etc/fedora-release ]]; then echo "fedora"
            else echo "linux"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "windows"
            ;;
        *)
            error "Unsupported OS: $(uname -s)"
            exit 1
            ;;
    esac
}

OS="$(detect_os)"

# ── Symlink helper ────────────────────────────────────────────────────────────
make_link() {
    local src="$1"
    local dst="$2"

    if [[ ! -e "$src" ]]; then
        error "Source does not exist: $src"
        return 1
    fi

    local parent
    parent="$(dirname "$dst")"
    if [[ ! -d "$parent" ]]; then
        mkdir -p "$parent"
        info "Created directory: $parent"
    fi

    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        success "Already linked: $dst"
        return 0
    fi

    if [[ -e "$dst" || -L "$dst" ]]; then
        local backup="${dst}.backup.$(date +%Y%m%d_%H%M%S)"
        warn "Backing up existing: $dst → $backup"
        mv "$dst" "$backup"
    fi

    ln -sf "$src" "$dst"
    success "Linked: ${CYAN}$dst${RESET} → $src"
}

# On Windows (Git Bash), ln -sf may not work for all paths.
# We fall back to adding a source line to ~/.bashrc instead.
wire_bashrc() {
    local line="$1"
    local bashrc="$HOME/.bashrc"

    if grep -qF "$line" "$bashrc" 2>/dev/null; then
        success "Already in ~/.bashrc: $line"
    else
        echo "$line" >> "$bashrc"
        success "Added to ~/.bashrc: $line"
    fi
}

# ── Clone repo (curl pipe mode) ───────────────────────────────────────────────
clone_repo() {
    if [[ -d "$DOTFILES/.git" ]]; then
        info "Repo already exists at $DOTFILES — pulling latest..."
        git -C "$DOTFILES" pull --rebase
    else
        info "Cloning i-dotfiles into $DOTFILES..."
        git clone https://github.com/zeraphie/i-dotfiles.git "$DOTFILES"
    fi
}

# ── macOS ─────────────────────────────────────────────────────────────────────
setup_macos() {
    header "macOS setup"

    # Homebrew
    if ! has brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        success "Homebrew installed"
    else
        success "Homebrew already installed"
        brew update --quiet
    fi

    # Core tools
    local brew_packages=(fish starship mise just git)
    for pkg in "${brew_packages[@]}"; do
        if brew list "$pkg" &>/dev/null; then
            success "$pkg already installed"
        else
            info "Installing $pkg..."
            brew install "$pkg"
            success "$pkg installed"
        fi
    done

    # Ghostty
    if ! has ghostty; then
        info "Installing Ghostty..."
        brew install --cask ghostty
        success "Ghostty installed"
    else
        success "Ghostty already installed"
    fi

    # WezTerm
    if ! has wezterm; then
        info "Installing WezTerm..."
        brew install --cask wezterm
        success "WezTerm installed"
    else
        success "WezTerm already installed"
    fi

    # Bun
    if ! has bun; then
        info "Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
        success "Bun installed"
    else
        success "Bun already installed"
    fi

    # Mise runtimes
    if has mise; then
        info "Installing mise runtimes..."
        export PATH="$HOME/.local/bin:$PATH"
        mise install
        success "Mise runtimes installed"
    fi

    # Make dotfiles bin executable
    chmod +x "$DOTFILES/bin/dotfiles"

    # Add dotfiles bin to PATH for current session
    export PATH="$PATH:$DOTFILES/bin"

    # Symlinks
    header "Creating symlinks"
    make_link "$DOTFILES/fish/config.fish"       "$HOME/.config/fish/config.fish"
    make_link "$DOTFILES/fish/aliases.fish"       "$HOME/.config/fish/aliases.fish"
    make_link "$DOTFILES/starship/starship.toml"  "$HOME/.config/starship.toml"
    make_link "$DOTFILES/ghostty/config"          "$HOME/.config/ghostty/config"
    make_link "$DOTFILES/wezterm/wezterm.lua"     "$HOME/.wezterm.lua"
    make_link "$DOTFILES/mise/config.toml"        "$HOME/.config/mise/config.toml"
    make_link "$DOTFILES/git/.gitconfig"          "$HOME/.gitconfig"

    mkdir -p "$HOME/.config/fish/functions"
    for fn in "$DOTFILES/fish/functions/"*.fish; do
        [[ -f "$fn" ]] || continue
        make_link "$fn" "$HOME/.config/fish/functions/$(basename "$fn")"
    done

    # Set Fish as default shell automatically if available
    if has fish; then
        local fish_path
        fish_path="$(command -v fish)"
        if [[ "$SHELL" == "$fish_path" ]]; then
            success "Fish is already the default shell"
        else
            if ! grep -qxF "$fish_path" /etc/shells; then
                echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
            fi
            chsh -s "$fish_path"
            success "Default shell set to Fish: $fish_path"
        fi
    fi
}

# ── Linux ─────────────────────────────────────────────────────────────────────
setup_linux() {
    header "Linux setup"

    # Fish
    if ! has fish; then
        info "Installing Fish..."
        case "$OS" in
            debian)
                sudo apt-add-repository -y ppa:fish-shell/release-4 2>/dev/null || true
                sudo apt-get update -q
                sudo apt-get install -y fish
                ;;
            arch)   sudo pacman -S --noconfirm fish ;;
            fedora) sudo dnf install -y fish ;;
            *)      warn "Please install Fish manually: https://fishshell.com" ;;
        esac
        success "Fish installed"
    else
        success "Fish already installed"
    fi

    # Starship
    if ! has starship; then
        info "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        success "Starship installed"
    else
        success "Starship already installed"
    fi

    # Mise
    if ! has mise; then
        info "Installing Mise..."
        curl https://mise.run | sh
        export PATH="$HOME/.local/bin:$PATH"
        success "Mise installed"
    else
        success "Mise already installed"
    fi

    # Just
    if ! has just; then
        info "Installing Just..."
        case "$OS" in
            debian) sudo apt-get install -y just 2>/dev/null || curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin ;;
            arch)   sudo pacman -S --noconfirm just ;;
            fedora) sudo dnf install -y just ;;
            *)      curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin ;;
        esac
        success "Just installed"
    else
        success "Just already installed"
    fi

    # Bun
    if ! has bun; then
        info "Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
        success "Bun installed"
    else
        success "Bun already installed"
    fi

    # Mise runtimes
    if has mise; then
        info "Installing mise runtimes..."
        mise install
        success "Mise runtimes installed"
    fi

    # Make dotfiles bin executable
    chmod +x "$DOTFILES/bin/dotfiles"

    # Add dotfiles bin to PATH for current session
    export PATH="$PATH:$DOTFILES/bin"

    # Symlinks
    header "Creating symlinks"
    make_link "$DOTFILES/fish/config.fish"       "$HOME/.config/fish/config.fish"
    make_link "$DOTFILES/fish/aliases.fish"       "$HOME/.config/fish/aliases.fish"
    make_link "$DOTFILES/starship/starship.toml"  "$HOME/.config/starship.toml"
    make_link "$DOTFILES/ghostty/config"          "$HOME/.config/ghostty/config"
    make_link "$DOTFILES/wezterm/wezterm.lua"     "$HOME/.wezterm.lua"
    make_link "$DOTFILES/mise/config.toml"        "$HOME/.config/mise/config.toml"
    make_link "$DOTFILES/git/.gitconfig"          "$HOME/.gitconfig"

    mkdir -p "$HOME/.config/fish/functions"
    for fn in "$DOTFILES/fish/functions/"*.fish; do
        [[ -f "$fn" ]] || continue
        make_link "$fn" "$HOME/.config/fish/functions/$(basename "$fn")"
    done

    # Set Fish as default shell automatically if available
    if has fish; then
        local fish_path
        fish_path="$(command -v fish)"
        if [[ "$SHELL" == "$fish_path" ]]; then
            success "Fish is already the default shell"
        else
            if ! grep -qxF "$fish_path" /etc/shells; then
                echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
            fi
            chsh -s "$fish_path"
            success "Default shell set to Fish: $fish_path"
        fi
    fi
}

# ── Windows (Git Bash) ────────────────────────────────────────────────────────
setup_windows() {
    header "Windows (Git Bash) setup"

    warn "On Windows, package installs require winget (run as Administrator in PowerShell)."
    warn "Skipping package installs — run install.ps1 in an admin PowerShell if needed."
    echo

    # Wire up ~/.bashrc to source the windows bash config
    header "Wiring up ~/.bashrc"
    wire_bashrc "source \"$DOTFILES/bash/bashrc_windows.sh\""

    # Wire up Starship config path
    wire_bashrc "export STARSHIP_CONFIG=\"$HOME/.config/starship.toml\""

    # Starship symlink via ln (works in Git Bash if Developer Mode is on,
    # otherwise we just set the env var and let it find the file via PATH)
    mkdir -p "$HOME/.config"
    make_link "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml" 2>/dev/null \
        || warn "Could not symlink starship.toml — run install.ps1 as Admin to create symlinks"

    # Git config
    make_link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig" 2>/dev/null \
        || warn "Could not symlink .gitconfig — run install.ps1 as Admin to create symlinks"

    # WezTerm config
    make_link "$DOTFILES/wezterm/wezterm.lua" "$HOME/.wezterm.lua" 2>/dev/null \
        || warn "Could not symlink wezterm.lua — run install.ps1 as Admin to create symlinks"

    echo
    success "Git Bash wired up!"
    warn "For full symlink support and package installs, open an admin PowerShell and run:"
    warn "  cd $DOTFILES && powershell -ExecutionPolicy RemoteSigned -File install.ps1"
}

# ── Verify ────────────────────────────────────────────────────────────────────
verify_install() {
    header "Verifying installation"

    local tools=()
    case "$OS" in
        macos|linux|arch|debian|fedora)
            tools=(fish starship mise git just bun)
            ;;
        windows)
            tools=(starship git bun)
            ;;
    esac

    for tool in "${tools[@]}"; do
        if has "$tool"; then
            success "$tool: $(command -v "$tool")"
        else
            warn "$tool: not found (may need a new shell session)"
        fi
    done
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    printf "\n${MAGENTA}${BOLD}"
    printf "  ╔════════════════════════════════════════╗\n"
    printf "  ║      i-dotfiles  ·  bootstrap          ║\n"
    printf "  ║      github.com/zeraphie               ║\n"
    printf "  ╚════════════════════════════════════════╝\n"
    printf "${RESET}\n"

    info "Detected OS:       ${BOLD}$OS${RESET}"
    info "Dotfiles location: ${BOLD}$DOTFILES${RESET}"
    echo

    # If running via curl pipe, clone first
    if [[ "$CLONED" == true ]]; then
        clone_repo
        # Re-run the now-cloned script so DOTFILES is set correctly
        exec bash "$DOTFILES/bootstrap.sh"
    fi

    if ! confirm "This will install tools and wire up your shell config. Continue?"; then
        echo "Aborted."
        exit 0
    fi

    case "$OS" in
        macos)                       setup_macos   ;;
        linux|arch|debian|fedora)    setup_linux   ;;
        windows)                     setup_windows ;;
    esac

    verify_install

    printf "\n${GREEN}${BOLD}  ✓  Done!${RESET}\n"

    case "$OS" in
        macos|linux|arch|debian|fedora)
            printf "     Open a new terminal to start using Fish + Starship.\n\n"
            ;;
        windows)
            printf "     Open a new WezTerm window to pick up your shell config.\n"
            printf "     Run ${CYAN}install.ps1${RESET} as Admin in PowerShell for full setup.\n\n"
            ;;
    esac
}

main "$@"
