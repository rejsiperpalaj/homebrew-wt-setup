# homebrew-wt

Homebrew tap for `wt` — a git worktree manager with shared AI context.

`wt setup` bootstraps a fully isolated workspace per project: clones the repo, creates a shared `context/` folder with AI documentation templates, and symlinks it into the main repo and every worktree automatically. All subsequent `wt <branch>` commands keep new worktrees in sync.

Each project is self-contained. You can run `wt setup` for as many repos as you like — they never share state.

---

## Install

```sh
brew tap rejsiperpalaj/wt
brew install --HEAD rejsiperpalaj/wt/wt
```

Then follow the printed instructions to add the shell integration to `~/.zshrc`:

```sh
source "$(brew --prefix)/share/wt/shell-integration.zsh"
```

Reload your shell:

```sh
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

`.cursor`, `CLAUDE.md`, and `AGENTS.md` in the main repo (and every worktree you create) are symlinks into `context/`. Edit the docs once — every checkout sees the change instantly.

---

## Commands

| Command | Description |
|---|---|
| `wt setup <git-url>` | Bootstrap a new project workspace |
| `wt <branch>` | New branch off `origin/develop`, cd into it |
| `wt <branch> --from <base>` | New branch off `origin/<base>` |
| `wt <branch> --checkout` | Check out existing local or remote branch |
| `wt --list` | List all worktrees for this project |
| `wt --prune` | Prune stale worktree metadata |
| `wt --ai-status` | Symlink health check across all worktrees |
| `wt --ai-fix` | Re-link AI context in the current directory |
| `wt --ai-edit` | Open `context/` in Cursor |
| `wt --help` | Show help |

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
brew reinstall --HEAD wt
```

---

## How it works

- All shared AI docs live in `wt_<project>/context/` — outside any git repo.
- `context/` is never committed. Git ignores it via `.git/info/exclude` (local-only, no `.gitignore` change).
- Symlinks in the main repo and each worktree point to `context/`, so editing a doc once propagates everywhere.
- `wt-core` is a plain bash script installed to `$(brew --prefix)/bin/wt-core`.
- `shell-integration.zsh` defines a `wt()` function that wraps `wt-core` and handles `cd` after setup/branch creation.
