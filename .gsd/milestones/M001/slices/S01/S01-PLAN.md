# S01: Intake & Role Identification

**Goal:** Build the entry point of the expert-opinion skill — a GSD skill (SKILL.md router + intake workflow) that accepts any input type, normalizes it, infers context, proposes 5–10 expert roles, gates on user confirmation, and emits a typed output package ready for S02 to consume. Also authors all three shared templates (expert-report, synthesis-doc, role-proposal) and two reference files (input-handling, output-contract) that downstream slices code against.

**Demo:** From the worktree root, all 8 skill files exist at their correct paths. SKILL.md passes YAML validation and is under 500 lines. A manual trace through `workflows/intake.md` with a Python file as input reaches the `ask_user_questions` confirmation step and would emit the typed output package per `references/output-contract.md`.

## Must-Haves

- `SKILL.md` — valid YAML frontmatter, body uses only XML tags (no markdown headings), under 500 lines, routes to `workflows/intake.md`
- `workflows/intake.md` — covers all 6 intake phases: detect input type → normalize → infer context → propose roles → confirm → emit output package
- `templates/expert-report.md` — severity-classified findings (critical/major/minor/informational) with evidence fields; required by S02
- `templates/synthesis-doc.md` — cross-cutting findings section, prioritized recommendations table; required by S03
- `templates/role-proposal.md` — role entry format with focus questions; used by intake workflow for display
- `references/output-contract.md` — typed schema for `confirmed_roles`, `normalized_input`, `inferred_context`; exact field names matter (S02 codes against this)
- `references/input-handling.md` — decision table for text/file/codebase/URL detection and large-input truncation strategy
- All cross-references between files use paths relative to the project root (no `expert-opinion/` prefix)

## Proof Level

- This slice proves: contract (files are correctly structured and internally consistent; the intake workflow is manually traceable)
- Real runtime required: no (skill authoring; verified via bash assertions and YAML validity)
- Human/UAT required: no

## Verification

- `test -f SKILL.md && test -f workflows/intake.md && test -f templates/expert-report.md && test -f templates/synthesis-doc.md && test -f templates/role-proposal.md && test -f references/output-contract.md && test -f references/input-handling.md && echo "ALL FILES PRESENT"`
- `python3 -c "import yaml; yaml.safe_load(open('SKILL.md').read().split('---')[1]); print('YAML OK')"`
- `wc -l SKILL.md | awk '{if($1<500) print "LINE COUNT OK"; else {print "TOO LONG: "$1; exit 1}}'`
- `grep -c '^#' SKILL.md` — must output `0` (no markdown headings in body)
- `grep -q 'workflows/intake.md' SKILL.md && echo "ROUTING OK"`
- `grep -q 'references/output-contract.md' workflows/intake.md && echo "CONTRACT REF OK"`
- `grep -q 'references/input-handling.md' workflows/intake.md && echo "INPUT-HANDLING REF OK"`
- `grep -q 'severity' templates/expert-report.md && echo "SEVERITY FIELD OK"`
- `grep -q 'confirmed_roles' references/output-contract.md && echo "OUTPUT CONTRACT OK"`
- `grep -q 'ask_user_questions' workflows/intake.md && echo "CONFIRMATION GATE OK"` — failure here means the user confirmation gate is missing

## Observability / Diagnostics

- Runtime signals: no live runtime; structural integrity verified via bash assertions on file content
- Inspection surfaces: `grep` commands against file content; YAML parser for frontmatter validity; `wc -l` for line-count budget; path cross-reference checks (`grep -q 'workflows/intake.md' SKILL.md`)
- Failure visibility: each verification command is independently runnable — a failing command names the broken invariant (e.g. `ROUTING OK` not printed → SKILL.md does not reference intake.md); `grep -c '^#' SKILL.md > 0` → markdown headings present in body
- Redaction constraints: none

## Integration Closure

- Upstream surfaces consumed: none (first slice — blank repo)
- New wiring introduced in this slice: `SKILL.md` → `workflows/intake.md` → `references/input-handling.md`, `references/output-contract.md`, `templates/role-proposal.md`; `templates/expert-report.md` and `templates/synthesis-doc.md` are standalone contracts for S02/S03
- What remains before the milestone is truly usable end-to-end: S02 (parallel research engine using expert-report.md), S03 (synthesis using synthesis-doc.md)

## Tasks

- [x] **T01: Author templates and reference contracts** `est:45m`
  - Why: Templates and reference files are the stable contracts the intake workflow (T02) and all downstream slices code against. Getting field names, severity tiers, and the output-contract schema right here prevents rework in S02 and S03.
  - Files: `templates/expert-report.md`, `templates/synthesis-doc.md`, `templates/role-proposal.md`, `references/output-contract.md`, `references/input-handling.md`
  - Do: Create directory structure (`mkdir -p workflows templates references`), then write each file per S01-RESEARCH.md. Key constraints: expert-report.md must have XML sections `<role_identity>`, `<executive_summary>`, `<findings>`, `<recommendations>`, `<open_questions>` with severity levels critical/major/minor/informational and evidence fields. output-contract.md must define the exact typed schema for `confirmed_roles`, `normalized_input`, `inferred_context`. input-handling.md must include the decision table for all four input types and the large-input truncation strategy (20-file cap, ~6000-token limit).
  - Verify: `test -f templates/expert-report.md && test -f templates/synthesis-doc.md && test -f templates/role-proposal.md && test -f references/output-contract.md && test -f references/input-handling.md && grep -q 'severity' templates/expert-report.md && grep -q 'confirmed_roles' references/output-contract.md && echo "T01 DONE"`
  - Done when: All 5 files exist at their correct paths; expert-report.md contains severity-classified finding fields with evidence; output-contract.md contains the typed schema with all three top-level keys; input-handling.md covers all four input types.

- [x] **T02: Author intake workflow and SKILL.md router** `est:45m`
  - Why: Creates the executable entry point — the intake workflow orchestrating all 6 phases and the SKILL.md router making the skill invocable. Depends on T01's files existing at their paths.
  - Files: `workflows/intake.md`, `SKILL.md`
  - Do: Write `workflows/intake.md` covering all 6 phases: (1) detect input type using `references/input-handling.md`, (2) read/normalize per type (read/bash/fetch_page), (3) infer context (purpose, domain, audience), (4) generate role proposal using `templates/role-proposal.md` format (5–10 roles with artifact-specific focus questions), (5) present to user via `ask_user_questions` with options "Confirm all" / "Edit (describe changes)" / "Cancel" (if Edit: follow-up free-text prompt, re-present), (6) emit output package per `references/output-contract.md`. Write `SKILL.md` last: YAML frontmatter, XML-only body (no `#` headings per K001), `<essential_principles>`, `<intake>` question, `<routing>` to `workflows/intake.md`. Under 500 lines (K002). No web searches in intake.
  - Verify: `python3 -c "import yaml; yaml.safe_load(open('SKILL.md').read().split('---')[1]); print('YAML OK')"` && `wc -l SKILL.md | awk '{if($1<500) print "OK"; else exit 1}'` && `test $(grep -c '^#' SKILL.md) -eq 0` && `grep -q 'workflows/intake.md' SKILL.md` && `grep -q 'references/output-contract.md' workflows/intake.md` && `echo "T02 DONE"`
  - Done when: SKILL.md passes YAML validation, zero markdown headings in body, under 500 lines, routes to `workflows/intake.md`; `workflows/intake.md` covers all 6 intake phases and references both reference files.

## Files Likely Touched

- `SKILL.md`
- `workflows/intake.md`
- `templates/expert-report.md`
- `templates/synthesis-doc.md`
- `templates/role-proposal.md`
- `references/output-contract.md`
- `references/input-handling.md`
