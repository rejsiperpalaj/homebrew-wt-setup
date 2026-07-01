# Tools — {{PROJECT_NAME}}

Scripts and helpers used by skills and rules in this project.

Place any shell script, Python script, or other executable here.
Skills reference them via `ai/tools/<script>` — that path resolves
identically in the main repo and every worktree, for Cursor, Claude,
and Codex.

## Naming convention

- `run-*.sh` — launch or build scripts
- `check-*.sh` — validation / lint scripts
- `trigger-*.py` — CI / release automation

## Example — referencing a tool from a skill

In `ai/skills/run-ios/SKILL.md`:

```markdown
## Steps
1. Run `ai/tools/run-simulator.sh` and pick a destination.
2. ...
```

Make scripts executable after adding them:

```sh
chmod +x ai/tools/run-simulator.sh
```
