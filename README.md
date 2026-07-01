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
| `wt --remove <branch>` | Remove a worktree and prune metadata |
| `wt --set-default <branch>` | Set the default base branch for new worktrees |

### AI context

| Command | Description |
|---|---|
| `wt --ai-status` | Symlink health check across all worktrees |
| `wt --ai-fix` | Re-link missing AI context in the current directory |
| `wt --ai-fix --resolve` | Fix CONFLICT and MISMATCH symlinks (absorbs existing files into `context/`) |
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

### Rules (Cursor)

Rules go in `context/ai/rules/` as `.mdc` files. Cursor finds them via the `.cursor/rules → ../ai/rules` symlink bridge.

```
context/
└── ai/
    └── rules/
        ├── project.mdc          ← repo-wide conventions (architecture, patterns, do-nots)
        ├── testing.mdc          ← test standards
        └── api-contracts.mdc   ← API / DTO rules
```

A good `project.mdc` covers:
- Stack and architecture overview (what layers exist, how they communicate)
- Naming conventions
- What NOT to do (anti-patterns specific to this codebase)
- Where shared utilities live so the agent reuses them

### Skills (Cursor)

Skills go in `context/ai/skills/` as folders with a `SKILL.md` inside. Cursor finds them via the `.cursor/skills → ../ai/skills` symlink bridge.

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

### Workflows (CLAUDE.md / AGENTS.md)

`CLAUDE.md` and `AGENTS.md` contain the same information, formatted for their respective tools. A good structure:

```markdown
# Project: <name>

## What this is
One paragraph — what the repo does, its purpose.

## Architecture
How the code is structured: layers, packages, key patterns.

## Key conventions
- Language/framework version
- Code style rules that matter
- How to name things

## Common tasks
- How to run locally
- How to run tests
- How to add a feature (brief — link to skills for detail)

## Do not
- Specific things the agent should never do in this repo
```

The `ai/` folder holds deeper docs that you can link from CLAUDE.md/AGENTS.md:
- `ai/architecture.md` — detailed system design
- `ai/coding-standards.md` — extended style guide
- `ai/testing.md` — test patterns and coverage expectations
- `ai/workflows.md` — common engineering workflows

### Cross-tool consistency

Everything lives in `ai/`. Tools read from there via bridges:

- Add a rule to `ai/rules/project.mdc` → Cursor picks it up immediately via `.cursor/rules` symlink, across all branches.
- Add a skill to `ai/skills/my-skill/SKILL.md` → available in Cursor immediately.
- Update `ai/workflows.md` → both `CLAUDE.md` and `AGENTS.md` already point there, so Claude Code and Codex both see the change.

You never copy-paste context between tools or branches. Edit once in `ai/`, everything updates.

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
