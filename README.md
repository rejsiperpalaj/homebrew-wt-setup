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
        ├── .cursor/
        │   ├── rules  → ../ai/rules   (symlink — Cursor bridge)
        │   └── skills → ../ai/skills  (symlink — Cursor bridge)
        ├── ai/                    ← single source of truth
        │   ├── rules/             ← Cursor rules (.mdc files)
        │   │   └── project.mdc
        │   ├── skills/            ← Cursor skills (SKILL.md files)
        │   │   └── README.md
        │   ├── README.md
        │   ├── architecture.md
        │   ├── coding-standards.md
        │   ├── testing.md
        │   └── workflows.md
        ├── CLAUDE.md              ← Claude Code bridge → ai/
        └── AGENTS.md             ← Codex bridge → ai/
```

Everything is symlinked into the main repo and every worktree. Edit any file from inside any checkout — changes are instantly visible everywhere.

`wt setup` also auto-detects the remote's default branch (`main`, `master`, `develop`, etc.) and stores it in the repo's local git config as `wt.defaultBranch`. All `wt <branch>` calls use it automatically.

---

## Default branch

`wt setup` detects the remote HEAD branch automatically and stores it in the repo's local git config as `wt.defaultBranch` — the standard way tools store per-repo settings, no extra files needed.

To override it at any time:

```sh
wt --set-default main          # stored in .git/config (repo-local, per-developer)
wt --set-default master

# Or set a personal global default for all projects on this machine:
git config --global wt.defaultBranch main
```

Branch resolution priority: `--from` flag → `git config wt.defaultBranch` (local before global) → remote HEAD auto-detection → `develop`.

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
| `wt --remove <branch>` | Remove a worktree and prune metadata |
| `wt --set-default <branch>` | Set the default base branch for new worktrees |

### AI context

| Command | Description |
|---|---|
| `wt --ai-status` | Symlink health check across all worktrees |
| `wt --ai-fix` | Re-link missing AI context in the current directory |
| `wt --ai-fix --resolve` | Fix CONFLICT and MISMATCH symlinks (deletes existing files, links to `context/`) |
| `wt --ai-absorb <src> [<dest>]` | Absorb a repo-root-relative path into `context/<dest>` and replace with a symlink |
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

If your project already has AI docs committed at a custom path, absorb them into `context/ai/` with a single command.

**Always pass `ai` as the second argument** — that is the destination inside `context/`, so everything lands at `context/ai/` where all tools expect it:

```sh
wt --ai-absorb <src> ai
#                    ^^^ always "ai" — lands at context/ai/
```

Common examples:

```sh
wt --ai-absorb .ai ai                   # .ai              → context/ai/
wt --ai-absorb docs/ai ai               # docs/ai          → context/ai/
wt --ai-absorb documentation/ai ai      # documentation/ai → context/ai/
```

`wt --ai-absorb` copies the contents into `context/ai/`, deletes the original (the path changes — that is the point), and links `ai/`, `.cursor/`, `CLAUDE.md`, and `AGENTS.md` into the repo root at their canonical paths. Update any references from the old path (`docs/ai`) to the new one (`ai`) in your `CLAUDE.md`, `AGENTS.md`, and docs. Then commit once to share the migration with your team:

```sh
git add -A && git commit -m "chore: absorb docs/ai into shared wt context"
```

If the project has files like `CLAUDE.md` or `AGENTS.md` already committed, run:

```sh
wt --ai-fix --resolve
```

This handles:
- **CONFLICT** — real file exists: file is deleted, symlink to `context/` created in its place
- **MISMATCH** — symlink points to wrong target: repointed to the correct `context/` path

---

## AI tools — why CLAUDE.md, AGENTS.md, and .cursor

`ai/` is the single source of truth. Everything lives there. `CLAUDE.md`, `AGENTS.md`, and `.cursor/` are thin bridges that point each tool at `ai/`.

```
ai/rules/    ←── .cursor/rules  (symlink — Cursor reads .mdc files here)
ai/skills/   ←── .cursor/skills (symlink — Cursor reads SKILL.md files here)
ai/          ←── CLAUDE.md      (bridge — "read ai/ for full context")
ai/          ←── AGENTS.md      (bridge — "read ai/ for full context")
```

| File / folder | Read by | Role |
|---|---|---|
| `ai/rules/` | Cursor IDE (via `.cursor/rules` symlink) | `.mdc` rule files — enforced automatically during coding |
| `ai/skills/` | Cursor IDE (via `.cursor/skills` symlink) | Reusable task templates the agent can invoke |
| `ai/*.md` | Any tool, by reference | Architecture, coding standards, testing, workflows |
| `CLAUDE.md` | Claude Code (Anthropic CLI) | Bridge — directs Claude to read `ai/` |
| `AGENTS.md` | OpenAI Codex, GPT-based agents | Bridge — directs Codex to read `ai/` |

You edit rules in `ai/rules/`, skills in `ai/skills/`, docs in `ai/`. One place, all tools pick it up instantly across every worktree.

---

## How to set up skills, rules, and workflows

### Rules

Rules go in `context/ai/rules/` as `.mdc` files. Cursor finds them automatically via the `.cursor/rules → ../ai/rules` symlink bridge. Claude Code and Codex read them because `CLAUDE.md` and `AGENTS.md` reference `ai/rules/`.

```
context/
└── ai/
    └── rules/
        ├── project.mdc          ← repo-wide conventions (architecture, patterns, do-nots)
        ├── testing.mdc          ← test standards
        └── api-contracts.mdc    ← API / DTO rules
```

Every `.mdc` file needs a frontmatter header:

```markdown
---
description: What this rule enforces
alwaysApply: true          # always active for every session
# globs: ["**/*.swift"]   # or scope to specific file types only
---

# Rule title

What the agent must / must not do. Be specific — reference actual
file paths, class names, and patterns from this codebase.

## Do
- ...

## Do not
- ...
```

**How each tool picks it up:**
- **Cursor** — reads all `.mdc` files in `.cursor/rules/` (the symlink to `ai/rules/`) automatically every session. No extra step.
- **Claude Code** — `CLAUDE.md` says "read `ai/rules/`". Claude reads the files there when following the bridge instructions.
- **Codex** — same via `AGENTS.md`.

---

### Skills

Skills go in `context/ai/skills/` as folders with a `SKILL.md` inside. Each skill is a reusable, step-by-step task template the agent follows on demand.

```
context/
└── ai/
    └── skills/
        ├── create-feature/
        │   └── SKILL.md   ← step-by-step: ViewModel + Service + tests
        ├── triage-pr/
        │   └── SKILL.md
        └── run-app/
            └── SKILL.md
```

`SKILL.md` structure:

```markdown
# Skill name

## When to use
One sentence — what triggers this skill.
Example: "Use when the user asks to add a new feature."

## Before you start
- Read ai/architecture.md
- Confirm the feature scope with the user

## Steps
1. ...
2. ...
3. ...

## Output
What the agent should produce when done.
```

**How each tool picks it up:**
- **Cursor** — invoke by referencing the skill in chat: "follow the create-feature skill". Cursor reads `ai/skills/create-feature/SKILL.md` via the `.cursor/skills` symlink.
- **Claude Code / Codex** — tell the agent "follow the create-feature skill" and it reads `ai/skills/create-feature/SKILL.md` directly.

---

### Workflows

Workflows are docs in `ai/` describing processes — git flow, release steps, onboarding, etc. They are not CLAUDE.md/AGENTS.md content; those files just index them.

```
ai/
├── workflows.md     ← already exists (git branching, PR process)
├── deployment.md    ← new: how to release
└── onboarding.md    ← new: how to get started on the repo
```

When you add a new workflow doc, register it in three places so every tool knows it exists:

**1. `ai/rules/project.mdc`** — add a bullet in the doc list:
```markdown
- `ai/deployment.md` — release process
```

**2. `CLAUDE.md`** — add a row to the index table:
```markdown
| Deployment process | `ai/deployment.md` |
```

**3. `AGENTS.md`** — add a bullet to the index list:
```markdown
- **Deployment process**: `ai/deployment.md`
```

---

### The golden rule

Edit in `ai/`. Update the index in `CLAUDE.md`, `AGENTS.md`, and `ai/rules/project.mdc` when you add a new file. That is all. All tools, all worktrees, all branches — one edit propagates everywhere.

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

> **Note:** After replacing `context/` with the team repo, re-run `wt --set-default <branch>` to restore the stored default branch. The config lives at `wt_<project>/.wt-config` (outside `context/`), so it is never overwritten by a team repo clone.

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
