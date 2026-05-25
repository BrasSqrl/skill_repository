# Skill Quality Rubric

## Purpose

Use this rubric to review new and changed skills before publishing or installing them broadly.

## Scoring Areas

| Area | What To Check |
| --- | --- |
| Description specificity | The description states the workflow and exact trigger conditions. |
| Trigger clarity | `When to Use` and `When Not to Use` separate adjacent skills. |
| Required inputs | The agent knows what context, files, commands, or decisions it needs. |
| Workflow | Steps are ordered and operational. |
| Quality gates | Completion checks are concrete and executable where possible. |
| Anti-patterns | The skill prevents common failure modes. |
| Output format | The agent knows how to report work consistently. |
| Reference hygiene | Long examples and rubrics live in `references/` and are linked only when useful. |
| Catalog metadata | `catalog/skills.tsv` is complete and bundle placement is intentional. |
| License traceability | Imported or adapted material has notices and license metadata. |

## Review Checklist

- The skill name uses lowercase kebab-case and matches its folder.
- `SKILL.md` starts with YAML frontmatter containing `name` and `description`.
- The description includes trigger wording such as `Use when`, `Use before`, or `Use for`.
- Required sections are present in the standard order.
- The skill does not assume a downstream project, harness, editor, or hosting provider.
- Windows-first command examples are used when command examples are necessary.
- Linux alternatives are included when they help portability.
- The skill is not a tutorial for a human beginner.
- Any overlap with existing skills is intentional and documented by trigger boundaries.

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
