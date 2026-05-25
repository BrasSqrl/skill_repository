# Using With Codex, Claude Code, OpenCode, Or Another Agent

This guide shows how to use this skill library with Codex, Claude Code, OpenCode, or another AI coding agent that can read skill folders containing `SKILL.md`.

The repository keeps one canonical `skills/` source. The installer only changes where those folders are copied.

It also keeps one canonical `agents/` source. Subagents are opt-in: Claude Code and OpenCode receive native Markdown agent files, while Codex receives portable subagent orchestration guidance during bootstrap.

## 1. Install Skills

From this repository, install the starter bundle globally for a harness:

Windows:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Bundle starter
.\scripts\install-skills.ps1 -Harness claude-code -Bundle starter
.\scripts\install-skills.ps1 -Harness opencode -Bundle starter
```

Linux:

```bash
bash ./scripts/install-skills.sh --harness codex --bundle starter
bash ./scripts/install-skills.sh --harness claude-code --bundle starter
bash ./scripts/install-skills.sh --harness opencode --bundle starter
```

List available bundles:

```powershell
.\scripts\install-skills.ps1 -ListBundles
```

Install selected skills:

Windows:

```powershell
.\scripts\install-skills.ps1 -Harness codex -Skills repo-onboarding,context-engineering,debugging-and-error-recovery
```

Linux:

```bash
./scripts/install-skills.sh --harness opencode --skills repo-onboarding,context-engineering,debugging-and-error-recovery
```

Use dry-run first when installing into a location that may already contain skills:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -Bundle starter -DryRun
```

Install skills with the recommended subagent bundle:

```powershell
.\scripts\install-skills.ps1 -Harness claude-code -Bundle starter -IncludeAgents
.\scripts\install-skills.ps1 -Harness opencode -Bundle starter -IncludeAgents
```

## 2. Where Skills Go

Global defaults:

| Harness | Default target |
|---|---|
| Codex | `$CODEX_HOME/skills` when set, otherwise `~/.codex/skills` |
| Claude Code | `~/.claude/skills` |
| OpenCode | `~/.config/opencode/skills` |

Project-local defaults:

| Harness | Project target |
|---|---|
| Claude Code | `<project>/.claude/skills` |
| OpenCode | `<project>/.opencode/skills` |
| Codex | Use an explicit custom skills directory |

Subagent defaults:

| Harness | Global target | Project target |
|---|---|---|
| Codex | Guidance only | Guidance only |
| Claude Code | `~/.claude/agents` | `<project>/.claude/agents` |
| OpenCode | `~/.config/opencode/agents` | `<project>/.opencode/agents` |

Project-local install example:

```powershell
$TargetRepo = "<target-repo>"
.\scripts\install-skills.ps1 -Harness claude-code -Scope project -ProjectPath $TargetRepo -Bundle starter
```

Custom target example:

```powershell
$SkillTarget = "<target-skills-dir>"
.\scripts\install-skills.ps1 -TargetPath $SkillTarget -Bundle starter
```

## 3. Create Or Update Target `AGENTS.md`

Use bootstrap when you want the installer to seed project instructions and record installed skills:

```powershell
$TargetRepo = "<target-repo>"
.\scripts\bootstrap-agent-repo.ps1 -ProjectPath $TargetRepo -Harness claude-code -Bundle starter
.\scripts\bootstrap-agent-repo.ps1 -ProjectPath $TargetRepo -Harness claude-code -Bundle starter -IncludeAgents
```

Bash:

```bash
TARGET_REPO="<target-repo>"
bash ./scripts/bootstrap-agent-repo.sh --project-path "$TARGET_REPO" --harness opencode --bundle starter
bash ./scripts/bootstrap-agent-repo.sh --project-path "$TARGET_REPO" --harness opencode --bundle starter --include-agents
```

Use manual copy when you only want the template:

Copy the template when the target repo does not already have agent instructions:

Windows:

```powershell
$TargetRepo = "<target-repo>"
Copy-Item .\templates\project-AGENTS.md (Join-Path $TargetRepo "AGENTS.md")
```

Linux:

```bash
TARGET_REPO="<target-repo>"
cp ./templates/project-AGENTS.md "$TARGET_REPO/AGENTS.md"
```

Then fill in project-specific facts:

- setup commands
- test commands
- lint and build commands
- important directories
- forbidden changes
- secrets and security rules
- validation checklist
- installed skills and when the repo expects agents to use them
- installed subagents and when independent delegation is expected

Keep reusable workflow guidance in skills. Keep project-specific facts in `AGENTS.md`.

## 4. Ask The Agent To Use Installed Skills

Name the skill when you know the right one:

```text
Use the repo-onboarding skill to inspect this repository and summarize the stack, commands, important directories, and risks.
```

```text
Use the debugging-and-error-recovery skill to diagnose this failing test. Reproduce it first, then identify the smallest fix and validation.
```

If the harness supports explicit skill syntax, use that syntax. If not, plain language is enough: ask it to use the named skill folder or workflow.

## 5. Ask The Agent To Choose The Right Skill

When the right workflow is unclear, ask the agent to select one:

```text
Choose the most relevant installed skill for this task, explain the choice briefly, then follow it.
Task: the install command fails on Windows but works on Linux.
```

```text
Select the right skill or combination of skills for this request. Keep the plan short, then proceed.
Request: add a small API field and update tests.
```

The agent should choose based on the skill descriptions, then load only the skills needed for the task.

## 6. Combine Skills In A Workflow

Use more than one skill when the work naturally changes phase.

For repeatable flows, start from the workflow templates in `workflows/`:

- `feature-development.md`
- `bug-diagnosis.md`
- `pull-request-review.md`
- `release-prep.md`
- `architecture-review.md`
- `agent-skill-development.md`

Common combinations:

- `repo-onboarding` -> `context-engineering` for first work in a repo.
- `error-message-triage` -> `debugging-and-error-recovery` for noisy failures.
- `planning-and-task-breakdown` -> `incremental-implementation` for multi-step changes.
- `test-driven-development` -> `incremental-implementation` for behavior-first implementation.
- `code-review-and-quality` -> `pull-request-prep` before review handoff.
- `security-review` -> `release-readiness` for high-risk releases.

Prompt pattern:

```text
Use the feature-development workflow from this skill repository. Load only the skills needed for this task, then proceed through the workflow gates.
```

Subagent prompt pattern:

```text
Use the code-reviewer subagent for an independent read-only review of the current diff. Return findings with evidence, validation gaps, risks, and recommended next action.
```

Ask for subagent selection when the role is unclear:

```text
Choose whether this task should stay in the main conversation or use a subagent. If a subagent helps, name the subagent, explain the reason in one sentence, and provide the handoff.
```

## 7. Example Workflows

### Onboarding A Repo

```text
Use the repo-onboarding skill. Inspect this repository and produce a concise onboarding summary with stack, setup, test, lint, build, important directories, agent rules, and risks.
```

Follow-up:

```text
Now use context-engineering to prepare task context for adding a small feature to the API layer. Identify relevant files and validation commands before editing.
```

### Debugging A Failing Test

```text
Use error-message-triage on this failure output first, then use debugging-and-error-recovery to reproduce and fix the root cause. Preserve existing user changes.
```

After triage:

```text
Proceed with the debugging-and-error-recovery workflow. Add regression coverage if practical and report before/after validation.
```

### Implementing A Small Feature

```text
Use planning-and-task-breakdown to create a short implementation plan, then use incremental-implementation to make the smallest verified change. Run the targeted tests.
```

If behavior needs test-first work:

```text
Use test-driven-development for this feature. Show the red test result, implement the minimal change, then rerun the focused tests.
```

### Reviewing A Pull Request

```text
Use code-review-and-quality to review the current diff. Focus on correctness, regressions, missing tests, and maintainability. Findings first, ordered by severity.
```

Independent review:

```text
Use the code-reviewer subagent to review the current diff without editing files. Then summarize which findings should be fixed before handoff.
```

For security-sensitive changes:

```text
Use security-review for the auth and data-access changes in this diff. Report concrete findings with severity, confidence, evidence, recommendation, and verification.
```

Independent security review:

```text
Use the security-reviewer subagent for a read-only security pass over the auth and data-access changes. Escalate blockers instead of editing files.
```

### Preparing A Release

```text
Use release-readiness to assess this release candidate. Check validation, versioning, changelog, migrations, rollback, documentation, and known risks. Give a go/no-go recommendation.
```

Independent release review:

```text
Use the release-reviewer subagent to inspect release readiness evidence and return blockers, risks, and the next validation step.
```

If a review package is needed first:

```text
Use pull-request-prep to prepare reviewer notes from the final diff, then use release-readiness for the release checklist.
```

## 8. Good Prompt Examples

```text
Use the context-engineering skill. Build a compact task context for fixing the failing Windows test run. Include relevant files, commands, facts, assumptions, and blockers.
```

```text
Choose the best installed skill for this task: dependency installation fails only on Linux. Explain the selected skill in one sentence, then follow it.
```

```text
Use source-driven-development with the OpenAPI spec and existing tests as the authority. Implement only the behavior required by those sources.
```

```text
Use test-driven-development and debugging-and-error-recovery together. First write a failing regression test for the reported bug, then fix the confirmed cause.
```

```text
Use architecture-review before implementation. Compare two options, identify tradeoffs, recommend the smallest safe design move, and list validation needed.
```

```text
Use pull-request-prep. Inspect the final diff, run available validation, and produce a concise title, summary, validation list, risks, and reviewer notes.
```

Good prompts name the skill, provide the task, define the expected output, and ask for validation evidence.
