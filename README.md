# i-dotfiles

> Izzy's cross-platform dotfiles — Fish + Starship + Ghostty + Mise

---

## Quickstart

### New machine (Mac / Linux)

```bash
git clone https://github.com/zeraphie/i-dotfiles.git ~/Documents/Development/i-dotfiles
cd ~/Documents/Development/i-dotfiles && ./bootstrap.sh
```

### New machine (Windows — Git Bash)

```bash
git clone https://github.com/zeraphie/i-dotfiles.git ~/Documents/Development/i-dotfiles
cd ~/Documents/Development/i-dotfiles && ./bootstrap.sh
```

Then in an admin PowerShell to create symlinks:

```powershell
cd $HOME\Documents\Development\i-dotfiles
powershell -ExecutionPolicy RemoteSigned -File install.ps1
```

### Or without cloning first

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/zeraphie/i-dotfiles/master/bootstrap.sh)
```

---

## Attaching to an existing project

Link dotfiles config into any git repo — picked files are excluded from git
via `.git/info/exclude` so they never get committed.

```bash
# Interactive picker (uses fzf if available, numbered list otherwise)
dotfiles link .

# Link everything at once
dotfiles link . --all

# See what's currently linked
dotfiles status .

# Remove all dotfile symlinks from a project
dotfiles unlink .
```

### What can be linked

| Item | Destination |
|---|---|
| Style Guide | `STYLE.md` |
| AI System Prompt | `.rules` (auto-loaded by Zed agent) |
| Zed Settings | `.zed/settings.json` |
| oxlint config | `oxlint.json` |
| commitlint config | `commitlint.config.js` |
| vitest config | `vitest.config.js` |
| CI workflow | `.github/workflows/ci.yml` |

---

## Setting up a new personal project

```bash
# Create and init the repo
mkdir my-project && cd my-project
git init
git commit --allow-empty -m "chore: initial commit"

# Link all dotfiles config
dotfiles link . --all

# Copy project templates as a starting point
cp $DOTFILES/ai/templates/project/package.json .
cp $DOTFILES/ai/templates/project/justfile .
cp $DOTFILES/ai/templates/project/CHANGELOG.md .

# Install deps and go
bun install
```

---

## Stack

| Tool | Purpose |
|---|---|
| [Fish](https://fishshell.com/) | Shell |
| [Starship](https://starship.rs/) | Prompt |
| [Ghostty](https://ghostty.org/) | Terminal (macOS / Linux) |
| [Windows Terminal](https://aka.ms/terminal) | Terminal (Windows) |
| [Mise](https://mise.jdx.dev/) | Runtime version manager — replaces nvm, pyenv, rustup |
| [Zed](https://zed.dev/) | Editor |
| [Just](https://just.systems/) | Task runner |
| [Bun](https://bun.sh/) | JS runtime + package manager |
| [Starship](https://starship.rs/) | Prompt |

---

## Structure

```
i-dotfiles/
├── ai/
│   ├── STYLE.md               # Coding style guide
│   ├── SYSTEM_PROMPT.md       # AI assistant system prompt (paste into Zed/Claude)
│   └── templates/
│       ├── component/         # React component + SCSS template
│       ├── project/           # New project templates (package.json, justfile, CI, etc.)
│       └── zed/               # Zed editor project settings
├── bash/
│   └── bashrc_windows.sh      # Git Bash config (sourced from ~/.bashrc on Windows)
├── bin/
│   └── dotfiles               # dotfiles CLI (link, unlink, status)
├── fish/
│   ├── config.fish            # Main Fish config
│   ├── aliases.fish           # Shell aliases
│   └── functions/             # Fish functions (c, git, array_contains, array_join)
├── ghostty/
│   └── config                 # Ghostty terminal config
├── git/
│   └── .gitconfig             # Git config + aliases
├── mise/
│   └── config.toml            # Global runtime versions
├── starship/
│   └── starship.toml          # Starship prompt config
├── fonts/
│   └── FiraCode/              # FiraCode Nerd Font (installed by bootstrap)
├── windows-terminal/
│   └── settings.json          # Windows Terminal config (matching theme + keybindings)
├── bootstrap.sh               # Cross-platform bootstrap (Mac / Linux / Windows Git Bash)
└── justfile                   # Dotfiles task runner
```

---

## Dotfiles tasks

Run `just` from the repo root to see all available recipes.

```bash
just install          # full bootstrap
just link             # create shell config symlinks only
just verify           # check all symlinks are correct
just pull             # pull latest from origin
just edit             # open dotfiles in Zed

just project-link          # interactive link into current project
just project-link-all      # link everything into current project
just project-unlink        # remove dotfile links from current project
just project-status        # show what's linked in current project

just edit-fish        # open fish config
just edit-aliases     # open aliases
just edit-starship    # open starship config
just edit-ghostty     # open ghostty config
just edit-windows-terminal  # open windows terminal config
just edit-git         # open gitconfig
just edit-mise        # open mise config
```

---

## Aliases

### Navigation

| Alias | Expands to |
|---|---|
| `u` / `uu` / `uuu` … | Up 1–6 directories |
| `b` | Back (`cd -`) |
| `l` | `ls -lah` |

### Editor

| Alias | Expands to |
|---|---|
| `e` | `zed` |

### Git

| Alias | Expands to |
|---|---|
| `g` | `git` |

### Bun

| Alias | Expands to |
|---|---|
| `bi` | `bun install` |
| `ba` | `bun add` |
| `bad` | `bun add -d` |
| `br` | `bun run` |
| `bx` | `bunx` |

### Just

| Alias | Expands to |
|---|---|
| `j` | `just` |
| `jl` | `just --list` |

### Mise

| Alias | Expands to |
|---|---|
| `m` | `mise` |
| `mu` | `mise use` |

---

## Git aliases

A selection of the most useful ones — see `git/.gitconfig` for the full list.

| Alias | Command |
|---|---|
| `git s` | `status` |
| `git st` | `status -sb` |
| `git a` | `add -A` |
| `git c "msg"` | `commit -m "msg"` |
| `git can` | `commit --amend --no-edit` |
| `git puu` | `push -u origin HEAD` |
| `git pf` | `push --force-with-lease` |
| `git l` | Pretty graph log |
| `git ll` | One-line log |
| `git la` | One-line log all branches |
| `git cob` | `checkout -b` |
| `git swc` | `switch -c` |
| `git ri` | `rebase -i` |
| `git rom` | `rebase origin/main` |
| `git ds` | `diff --staged` |
| `git undo` | `reset --soft HEAD~1` |
| `git nuke` | `reset --hard HEAD` |
| `git sp` | `stash pop` |
| `git current` | current branch name |
| `git outgoing` | commits not yet pushed |
| `git incoming` | commits not yet pulled |

---

## AI / Coding style

The `ai/` folder contains:

- **`STYLE.md`** — full coding style guide (indentation, quotes, guards, SCSS patterns, component structure, tooling, security, privacy, performance)
- **`SYSTEM_PROMPT.md`** — the global AI system prompt describing your style, workflow, security rules, and flagging behaviour

### Global setup (once per machine)

Add the system prompt as a default rule in Zed so it's auto-included in every agent conversation:

1. Open the Agent Panel (`Ctrl+Shift+A` / `Cmd+Shift+A`)
2. Click `...` → **Rules...**
3. Click `+`, paste the contents of `ai/SYSTEM_PROMPT.md`
4. Name it `i-dotfiles`
5. Click the **paperclip icon** (📎) to set it as a default rule

### Per-project setup

Run `dotfiles link .` in any repo — the AI System Prompt option links `ai/SYSTEM_PROMPT.md` to `.rules` at the project root, which Zed picks up automatically for that project.

### Workflow the prompt enforces

1. **Research** — read relevant files, ask if anything is unclear
2. **Plan** — present a step-by-step plan, wait for approval
3. **Execute** — one step at a time, confirm after each
4. **Lint & format** — run oxlint + oxfmt after every change
5. **Flag issues** — security, privacy, GDPR, and performance issues reported at end of every response (🔴 critical / 🟡 warning / 🔵 info)

---

## Runtimes (Mise)

| Runtime | Version |
|---|---|
| Node.js | `lts` |
| Python | `latest` |
| Bun | `latest` |

---

## Windows setup notes

### Windows Terminal

Install [Windows Terminal](https://aka.ms/terminal) from the Microsoft Store (works on Windows 10+). Then copy the settings:

1. Open Windows Terminal
2. Press `Ctrl+,` to open Settings
3. Click "Open JSON file" (bottom left)
4. Replace the contents with `windows-terminal/settings.json` from this repo
5. Install FiraCode Nerd Font from the `fonts/FiraCode/` directory (right-click `.ttf` files -> Install)

### WSL2 (recommended for full Fish + Starship experience)

WSL2 gives you a real Linux environment inside Windows, so you get the same Fish + Starship setup as macOS/Linux.

```powershell
# In an admin PowerShell — check if WSL is already installed
wsl --status

# If not installed
wsl --install

# After reboot, open Windows Terminal and select the Ubuntu tab, then:
cd ~ && git clone https://github.com/zeraphie/i-dotfiles.git ~/i-dotfiles
cd ~/i-dotfiles && ./bootstrap.sh
```

Windows Terminal auto-detects WSL distros and adds them as profiles.

---

## Local overrides

Create `~/.config/fish/local.fish` for machine-specific config — it's sourced automatically and gitignored.

---

## License

MIT