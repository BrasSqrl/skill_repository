# Model Methodology Documentation Workflow

## Trigger

Use when drafting evidence-backed model methodology, technical model documentation, model development memo, validation-support draft, or committee-ready model documentation from an extracted `llm_documentation_package/`.

Use quality-first mode when the agent can read the package, write under `09_generated_outputs/`, run available validation scripts, and revise iteratively. Use portable mode when file access or tool access is limited; in that mode, return the same plans, reviews, and drafts as pasted Markdown or tables and ask the operator to provide required package files or run validation manually.

Do not use this workflow for ordinary README, API, ADR, or release documentation. Do not approve a model, validate a model, claim compliance, or declare production readiness unless exact citable evidence exists in the package, and even then preserve the need for qualified human review.

## Ordered Skills

1. `context-engineering`
2. `source-driven-development`
3. `documentation-and-adrs`
4. Subagent: `documentation-reviewer`
5. Subagent: `validation-runner`
6. `handoff-quality-review`

## Phase Outputs

- Preflight report: locate `llm_documentation_package/`, confirm package structure, separate citable evidence from controls, identify missing inputs, and write `09_generated_outputs/documentation_preflight_report.md`.
- Evidence inventory: inspect citation indexes, approved claims, gaps, schemas, figures, and tables; write `09_generated_outputs/evidence_inventory.csv` and `09_generated_outputs/evidence_coverage_matrix.csv`.
- Documentation plan: use `01_document_template/DROP_TABLE_OF_CONTENTS_HERE.md` when supplied, otherwise use `02_document_planning/default_model_methodology_outline.md` and `02_document_planning/target_document_schema.json`; write `09_generated_outputs/documentation_plan.md` and `09_generated_outputs/documentation_plan.json`.
- Plan challenge: review the plan for unsupported claims, non-citable evidence, weak evidence, missing sections, risky language, and figure or table misuse; write `09_generated_outputs/plan_review_report.md`.
- Section draft: draft one section at a time from the approved plan using citations in the exact form `[source: package/path > field_or_section]`; write `09_generated_outputs/model_methodology_draft.md` or `09_generated_outputs/methodology_doc_spec.json`.
- Deterministic validation: run package scripts when available, otherwise perform equivalent checklist review; write `09_generated_outputs/citation_audit.md` and `09_generated_outputs/validation_report.md`.
- Reviewer critique: use `documentation-reviewer` to inspect citation coverage, unsupported claims, high-risk regulatory language, missing sections, weak evidence, terminology, and figure or table use; write `09_generated_outputs/unsupported_claim_review.md` and `09_generated_outputs/revision_backlog.md`.
- Targeted revision loop: revise only failed sections, rerun validation and reviewer critique, and append each pass to `09_generated_outputs/revision_log.md`; stop after all gates pass, after 4 revision passes, or when the same missing-evidence blocker appears in two consecutive passes.
- DOCX build package: when DOCX generation is supported, write `09_generated_outputs/model_methodology.docx` and `09_generated_outputs/DOCX_BUILD_NOTES.md`.
- Human review package: write final Markdown and/or DOCX draft, citation appendix, documentation gaps, limitations and assumptions, validation report, citation audit, unsupported claim review, revision log, and `09_generated_outputs/human_review_packet.md`.

Required package files to confirm before drafting:

- `README_LLM_PACKAGE.md`
- `START_HERE.md`
- `00_START_HERE/PACKAGE_MAP.md`
- `00_START_HERE/MODEL_FACTS_DIGEST.md`
- `EVIDENCE_INDEX.csv`
- `DO_NOT_CITE.md`
- `source_citation_map.csv`
- `llm_evidence_manifest.json`
- `02_document_planning/target_document_schema.json`
- `02_document_planning/template_binding.json`
- `02_document_planning/document_section_evidence_map.csv`
- `02_document_planning/default_model_methodology_outline.md`
- `04_evidence/context/model_document_context.json`
- `04_evidence/claims/approved_claims.json`
- `04_evidence/gaps/documentation_gaps.md`
- `05_visual_assets/figure_placement_manifest.csv`
- `03_docx_workflow/table_placement_manifest.csv`
- `03_docx_workflow/DOCX_BUILD_INSTRUCTIONS.md`
- `03_docx_workflow/MODEL_DOCUMENT_STYLE_GUIDE.md`
- `03_docx_workflow/DOCX_QUALITY_CHECKLIST.md`
- `06_validation_controls/citation_rules.md`
- `06_validation_controls/evidence_strength_policy.json`
- `06_validation_controls/document_completion_rules.json`
- `06_validation_controls/controlled_vocabulary.json`
- `06_validation_controls/draft_validation_rules.json`
- `06_validation_controls/document_quality_rubric.md`
- `06_validation_controls/regulatory_language_guardrails.md`
- `06_validation_controls/human_review_checklist.md`

Optional package files to use when present:

- `01_document_template/DROP_TABLE_OF_CONTENTS_HERE.md`
- `04_evidence/interpretation_briefs/metrics_interpretation_brief.md`
- `04_evidence/interpretation_briefs/feature_dictionary_narrative.md`
- `04_evidence/interpretation_briefs/chart_interpretation_brief.md`
- `08_tools/validate_llm_draft.py`
- `08_tools/validate_docx_spec.py`
- `08_tools/build_docx_from_spec.py`
- `08_tools/validate_docx_output.py`

## Validation Gates

- `EVIDENCE_INDEX.csv`, `DO_NOT_CITE.md`, and `source_citation_map.csv` exist, or an equivalent citable source index is explicitly identified.
- The package includes enough model facts to identify the model, target, data, method, and major results before drafting begins.
- Evidence, controls, and generated output remain separate: control files such as prompts, validators, rubrics, style guides, schemas, templates, and tools guide the workflow but are not cited as factual model evidence.
- Every factual claim has a package citation or is marked `Evidence not found in package`.
- No citation points to `DO_NOT_CITE.md`, `07_operator_prompts/`, `08_tools/`, rubrics, validators, prompt files, style guides, or templates as factual model evidence.
- Quantitative values, figure captions, and table content match the cited source and placement manifests.
- Warnings, failed checks, weak evidence, caveats, and documentation gaps are preserved rather than hidden.
- Required sections are present, marked `partially_ready`, or blocked with clear missing-evidence language.
- No unsupported approval, validation sign-off, compliance, or production-readiness claim remains.
- Final reviewer status is one of `ready_for_human_review`, `needs_revision`, or `blocked_by_missing_evidence`; the strongest allowed final status is `ready_for_human_review`.

When scripts are available, run the relevant checks from the package root:

```powershell
python 08_tools/validate_llm_draft.py 09_generated_outputs/model_methodology_draft.md
python 08_tools/validate_docx_spec.py 09_generated_outputs/methodology_doc_spec.json
python 08_tools/build_docx_from_spec.py
python 08_tools/validate_docx_output.py
```

## Handoff Format

Report:

- package identifier and creation date, if available
- document generation date
- final workflow status
- sections ready for review
- sections blocked or partially supported
- unresolved evidence gaps
- high-risk claims removed or softened
- validation checks performed
- known limitations of the LLM-generated draft
- required human review actions
- generated output files under `09_generated_outputs/`

## Escalation Rules

- Block before drafting if citation boundaries are missing or model facts are insufficient to identify the model, target, data, method, and major results.
- Escalate when required evidence is missing, contradictory, or marked non-citable.
- Escalate when a section would require approval, validation, compliance, or production-readiness language not explicitly supported by citable evidence.
- Escalate when validation scripts fail in a way that cannot be resolved from package evidence.
- In portable mode, ask the operator for required package files and produce a plan before drafting; do not claim completion when evidence or validation files are unavailable.
