# Skill Quality Rubric

## Purpose

Use this rubric to review new and changed skills before publishing or installing them broadly.

## Scoring Areas

| Area | What To Check |
| --- | --- |
| Description specificity | The description states the workflow and exact trigger conditions. |
| Trigger clarity | `When to Use` and `When Not to Use` separate adjacent skills. |
| Required inputs | The agent knows what context, files, commands, or decisions it needs. |
| Action boundary | The agent knows what it may inspect, run, edit, mutate, or refuse. |
| Workflow | Steps are ordered and operational. |
| Stop condition | Success and blocked states are explicit. |
| Quality gates | Completion checks are concrete and executable where possible. |
| Anti-patterns | The skill prevents common failure modes. |
| Output format | The agent knows how to report work consistently. |
| Eval coverage | Repeatable scenarios exist for high-risk or high-traffic behavior. |
| Reference hygiene | Long examples and rubrics live in `references/` and are linked only when useful. |
| Catalog metadata | `catalog/skills.tsv` is complete and bundle placement is intentional. |
| License traceability | Imported or adapted material has notices and license metadata. |

## Subagent Scoring Areas

| Area | What To Check |
| --- | --- |
| Description specificity | The description states the role and delegation trigger. |
| Permission boundary | The agent is read-only or validation-only unless deliberately approved otherwise. |
| Required inputs | The invoking agent knows what to include in the handoff. |
| Allowed and forbidden actions | The agent knows what it may inspect, run, or refuse. |
| Output format | The agent returns compact evidence, risks, and next action. |
| Referenced skills | Every skill named in frontmatter exists. |
| Catalog metadata | `catalog/agents.tsv` and agent bundle membership are complete. |

## Review Checklist

- The skill name uses lowercase kebab-case and matches its folder.
- `SKILL.md` starts with YAML frontmatter containing `name` and `description`.
- The description includes trigger wording such as `Use when`, `Use before`, or `Use for`.
- Required sections are present in the standard order.
- The skill states permitted actions and stop conditions when action boundaries matter.
- The skill does not assume a downstream project, harness, editor, or hosting provider.
- Windows-first command examples are used when command examples are necessary.
- Linux alternatives are included when they help portability.
- The skill is not a tutorial for a human beginner.
- Any overlap with existing skills is intentional and documented by trigger boundaries.
- High-traffic or risky skills have at least one scenario in `catalog/evals.tsv` or a documented reason for no scenario yet.

## Scoring Script

Run the score script to find low-signal or incomplete skills:

```powershell
.\scripts\score-skills.ps1
```

Linux alternative:

```bash
./scripts/score-skills.sh
```

Scores are advisory. Validation failures must still be fixed before publishing.

Score canonical subagents:

```powershell
.\scripts\score-agents.ps1
```

Linux alternative:

```bash
./scripts/score-agents.sh
```

Validate eval scenarios:

```powershell
.\scripts\validate-evals.ps1
```

Linux alternative:

```bash
./scripts/validate-evals.sh
```
