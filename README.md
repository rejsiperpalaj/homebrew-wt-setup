# homebrew-wt-setup

Homebrew tap for `wt` — a git worktree manager with shared AI context.

`wt setup` bootstraps a fully isolated workspace per project: clones the repo, creates a shared `context/` folder with AI documentation templates, and symlinks it into the main repo and every worktree automatically. All subsequent `wt <branch>` commands keep new worktrees in sync.

Each project is self-contained. You can run `wt setup` for as many repos as you like — they never share state.

---

## Install

```sh
brew install rejsiperpalaj/wt-setup/wt-setup
```

Then add shell integration to `~/.zshrc` (shown in the caveats after install):

```sh
echo 'source "/opt/homebrew/share/wt/shell-integration.zsh"' >> ~/.zshrc
source ~/.zshrc
```

---

## Get started

```sh
cd ~/Documents/workspace          # or any directory you use for projects
wt setup git@github.com:your-org/your-repo.git
```

This creates:

```
~/Documents/workspace/
└── wt_your-repo/
    ├── your-repo/                 ← git clone (main worktree)
    │   ├── .cursor  →  ../context/.cursor      (symlink)
    │   ├── ai       →  ../context/ai           (symlink)
    │   ├── CLAUDE.md → ../context/CLAUDE.md   (symlink)
    │   └── AGENTS.md → ../context/AGENTS.md   (symlink)
    ├── your-repo.worktrees/       ← feature branch worktrees land here
    └── context/                   ← shared AI docs (never committed)
        ├── .cursor/rules/project.mdc
        ├── ai/
        │   ├── README.md
        │   ├── architecture.md
        │   ├── coding-standards.md
        │   ├── testing.md
        │   └── workflows.md
        ├── CLAUDE.md
        └── AGENTS.md
```

Everything is symlinked into the main repo and every worktree. Edit any file from inside any checkout — changes are instantly visible everywhere.

`wt setup` also auto-detects the remote's default branch (`main`, `master`, `develop`, etc.) and stores it in `context/.wt-config`. All `wt <branch>` calls use it automatically.

---

## Default branch

`wt setup` detects the remote HEAD branch automatically. To override it at any time:

```sh
wt --set-default main
wt --set-default master
```

Branch resolution priority: `--from` flag → stored config → fallback `develop`.

```sh
wt my-feature              # uses stored default
wt my-feature --from main  # overrides for this branch only
```

---

## Commands

### Setup

| Command | Description |
|---|---|
| `wt setup <git-url>` | Bootstrap a new project workspace |

### Branching

Run from inside the project or any of its worktrees.

| Command | Description |
|---|---|
| `wt <branch>` | New branch off the default base branch, cd into it |
| `wt <branch> --from <base>` | New branch off `origin/<base>` |
| `wt <branch> --checkout` | Check out existing local or remote branch |

### Management

| Command | Description |
|---|---|
| `wt --list` | List all worktrees for this project |
| `wt --prune` | Prune stale worktree metadata |
| `wt --set-default <branch>` | Set the default base branch for new worktrees |

### AI context

| Command | Description |
|---|---|
| `wt --ai-status` | Symlink health check across all worktrees |
| `wt --ai-fix` | Re-link missing AI context in the current directory |
| `wt --ai-fix --resolve` | Fix CONFLICT and MISMATCH symlinks (absorbs existing files into `context/`) |
| `wt --ai-absorb <src> [<dest>]` | Absorb an existing project path into `context/<dest>` and replace with a symlink |
| `wt --help` | Show help |

---

## Working from the workspace root

All `wt` commands work from both the repo directory and the `wt_` workspace root:

```sh
cd wt_your-repo
wt --ai-status    # works — no need to cd into your-repo/ first
```

---

## Migrating an existing project

If your project already has AI docs committed at a custom path, absorb them into `context/` with a single command:

```sh
# docs/ai → context/ai
wt --ai-absorb docs/ai ai

# .ai → context/ai
wt --ai-absorb .ai ai

# Any path → context/<dest>
wt --ai-absorb documentation/ai-context ai
```

This copies the contents into `context/`, deletes the original, and replaces it with a symlink — so any tooling referencing that path keeps working. Then commit the change once to share the migration with your team:

```sh
git add -A && git commit -m "chore: absorb docs/ai into shared wt context"
```

If the project has files like `CLAUDE.md` or `AGENTS.md` already committed, run:

```sh
wt --ai-fix --resolve
```

This handles:
- **CONFLICT** — real file exists: content is absorbed into `context/`, file replaced with symlink
- **MISMATCH** — symlink points to wrong target: repointed to the correct `context/` path

---

## Team best practice — shared AI context repo

Instead of each developer maintaining their own `context/` templates independently, keep your team's AI skills, rules, and workflows in a dedicated repo and pull them into `context/`.

**1. Create a shared team repo** (once, by anyone on the team):

```sh
# e.g. git@github.com:myorg/team-ai-context.git
# Populate it with your shared .cursor/rules/, ai/, CLAUDE.md, AGENTS.md, etc.
```

**2. Each developer clones it into their `context/`** after running `wt setup`:

```sh
cd wt_your-repo

# Replace context/ contents with the team repo
rm -rf context
git clone git@github.com:myorg/team-ai-context.git context
```

**3. Pull updates whenever the team evolves the shared context:**

```sh
cd wt_your-repo/context
git pull
```

This way:
- Company-wide skills, rules, and workflows live in one place, versioned and reviewed like any other code.
- Each developer's `wt_<project>/context/` is a clone of that repo — never committed into the project itself.
- Personal customizations that shouldn't be shared can be added to `context/` and listed in `context/.git/info/exclude` so they stay local-only.
- New team members get the full AI setup with two commands: `wt setup` + `git clone` into `context/`.

---

## Multiple projects

Run `wt setup` from the same workspace directory for each repo:

```sh
cd ~/Documents/workspace
wt setup git@github.com:myorg/backend-api.git
wt setup git@github.com:myorg/mobile-app.git
```

Each gets its own `wt_<repo>/context/` — completely isolated, no shared state.

---

## Upgrading

```sh
brew update && brew upgrade wt-setup
```

`brew update` is required to pull the latest formula before upgrading. Without it, Homebrew may report the current version is already installed even when a newer one is available.

---

## Uninstall

```sh
brew uninstall wt-setup
sed -i '' '/wt\/shell-integration\.zsh/d' ~/.zshrc
```

---

## How it works

- All shared AI docs live in `wt_<project>/context/` — outside any git repo.
- `context/` is never committed. Git ignores it via `.git/info/exclude` (local-only, no `.gitignore` change).
- Symlinks in the main repo and each worktree point to `context/`, so editing a doc once propagates everywhere.
- `wt-core` is a plain bash script installed to `$(brew --prefix)/bin/wt-core`.
- `shell-integration.zsh` defines a `wt()` function that wraps `wt-core` and handles `cd` after setup/branch creation.
