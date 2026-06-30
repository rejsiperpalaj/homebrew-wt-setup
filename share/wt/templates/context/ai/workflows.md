# Workflows — {{PROJECT_NAME}}

> Document git and PR workflows here.

## Branching strategy

_Describe the branching model (e.g. feature branches off develop, trunk-based, gitflow)._

## Commit messages

_Describe the commit message format and any required prefix (e.g. Jira ticket, conventional commits)._

## Pull requests

_Describe the PR process: required reviewers, labels, checklist, merge strategy._

## Code review

_Describe expectations for reviewers and authors._

## Release process

_Describe how releases are cut and deployed._

---

## Worktree usage with `wt`

This project uses git worktrees for parallel branch work.

**Create a new feature branch** (from inside the repo or any worktree):

```sh
wt TICKET-123-my-feature
```

**Start from a specific base** (instead of `develop`):

```sh
wt TICKET-123-my-feature --from release/2.0
```

**Check out an existing branch** (from remote or local):

```sh
wt TICKET-123-my-feature --checkout
```

**List all active worktrees**:

```sh
wt --list
```

**Clean up stale worktrees**:

```sh
wt --prune
```

**Check AI context symlinks** (if Cursor seems to be missing rules):

```sh
wt --ai-status
wt --ai-fix   # re-links context in the current worktree
```

**Edit the shared AI documentation** (opens context/ in Cursor):

```sh
wt --ai-edit
```
