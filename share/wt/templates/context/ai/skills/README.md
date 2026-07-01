# Skills — {{PROJECT_NAME}}

Skills are reusable, step-by-step task templates the AI agent can follow.
Each skill lives in its own folder with a `SKILL.md` file.

## How to add a skill

```
ai/skills/
└── my-skill/
    └── SKILL.md    ← the agent reads and follows this
```

A good `SKILL.md` structure:

```markdown
# Skill name

## When to use
One sentence — what triggers this skill.

## Steps
1. ...
2. ...
3. ...

## Output
What the agent should produce when done.
```

## Examples

- `create-feature/SKILL.md` — step-by-step for adding a new feature (ViewModel + Service + tests)
- `triage-pr/SKILL.md` — how to review and triage a pull request
- `run-app/SKILL.md` — how to build and launch the app locally
