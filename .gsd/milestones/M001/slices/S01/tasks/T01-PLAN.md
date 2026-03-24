---
estimated_steps: 6
estimated_files: 5
skills_used:
  - writing-skills
---

# T01: Author templates and reference contracts

**Slice:** S01 — Intake & Role Identification
**Milestone:** M001

## Description

Creates the stable contract layer that all downstream tasks and slices code against. Five files must be written from scratch: three markdown templates (expert-report, synthesis-doc, role-proposal) and two reference files (output-contract, input-handling). The expert-report template is the most critical — S02 subagents code their output against it, and shallow field definitions (missing severity tiers or evidence fields) produce shallow research outputs. The output-contract is the second most critical — it defines the typed schema that the intake workflow emits and that S02 consumes; every field name here becomes an implicit API.

All files are pure markdown. No code. No test framework. Paths are relative to the worktree root (which is the project root). There is no `expert-opinion/` subdirectory.

## Steps

1. Create directory structure: `mkdir -p workflows templates references` (all three; `workflows/` is needed by T02 but create it now).

2. Write `templates/expert-report.md` — per-subagent findings template. Must include XML sections: `<role_identity>` (role name, domain, focus questions), `<executive_summary>` (2–4 sentence high-level assessment), `<findings>` (list of finding entries, each with: observation, evidence [quote or file:line reference], severity [critical|major|minor|informational], impact), `<recommendations>` (prioritized numbered list, each referencing the finding it addresses), `<open_questions>` (questions the expert couldn't answer from the artifact alone). Use clear placeholder text in each section showing executors exactly what to fill in.

3. Write `templates/synthesis-doc.md` — final audit document template. Must include: overview section (artifact description + analysis scope), per-role highlights table (role | 1-sentence finding | severity), cross-cutting findings section (issues raised by 2+ roles), prioritized recommendation table (rank | recommendation | source roles | effort | impact), open questions section. Include a guidance note at the top: synthesis is NOT concatenation — look for convergence, contradiction, and priority order (per K004).

4. Write `templates/role-proposal.md` — display template for the role confirmation UX. Shows each proposed role as: role name (bold), domain (italic), and 2–3 specific focus questions as a bullet list tailored to the current artifact. Ends with the exact confirmation prompt text the intake workflow will display alongside `ask_user_questions`.

5. Write `references/output-contract.md` — typed schema for the S01 → S02 output package. Must define all three top-level keys:
   - `confirmed_roles: Array<{ role: string, domain: string, focus_questions: string[], rationale: string }>`
   - `normalized_input: { type: "text"|"file"|"codebase"|"url", content: string, summary?: string, file_tree?: string }`
   - `inferred_context: { purpose: string, domain: string, audience: string }`
   Present as a typed schema block (TypeScript-style interface syntax) plus a prose explanation of each field. Field names here are canonical — intake.md and S02 must use these exact names.

6. Write `references/input-handling.md` — decision table and normalization rules for all four input types: (a) detection rules (text: no path separator, no URL prefix; file: starts with `/`, `./`, `../`, or has extension; codebase: is a directory path; URL: starts with `http://` or `https://`); (b) how to read each type (`read` tool for files; `bash` + `find` for codebases, then read up to 20 representative files prioritizing README/entry points/config; `fetch_page` for URLs; inline text as-is); (c) large-input truncation strategy (cap at ~6000 tokens: include full structure + key excerpts; populate `summary` and `file_tree` fields); (d) URL failure fallback (< 200 words after fetch → warn and re-prompt); (e) note that the intake workflow must log selected files for codebase inputs.

## Must-Haves

- [ ] `templates/expert-report.md` contains XML sections `<role_identity>`, `<executive_summary>`, `<findings>`, `<recommendations>`, `<open_questions>` with severity levels and evidence fields
- [ ] `templates/synthesis-doc.md` has a cross-cutting findings section and a prioritized recommendation table
- [ ] `templates/role-proposal.md` shows role name, domain, and focus questions per entry
- [ ] `references/output-contract.md` defines all three top-level keys (`confirmed_roles`, `normalized_input`, `inferred_context`) with exact field names
- [ ] `references/input-handling.md` covers all four input types with detection rules and normalization steps

## Verification

- `test -f templates/expert-report.md && test -f templates/synthesis-doc.md && test -f templates/role-proposal.md && test -f references/output-contract.md && test -f references/input-handling.md && echo "ALL 5 FILES PRESENT"`
- `grep -q 'severity' templates/expert-report.md && echo "SEVERITY FIELD PRESENT"`
- `grep -q 'confirmed_roles' references/output-contract.md && grep -q 'normalized_input' references/output-contract.md && grep -q 'inferred_context' references/output-contract.md && echo "OUTPUT CONTRACT COMPLETE"`
- `grep -q 'codebase' references/input-handling.md && grep -q 'fetch_page' references/input-handling.md && echo "INPUT HANDLING COMPLETE"`

## Observability Impact

This task creates only static markdown files with no runtime boundary, async flows, or error paths. No signals are added. Failure is visible immediately via the verification commands (`test -f` / `grep -q`): a missing file or absent field name causes the command to return non-zero, naming the exact broken invariant.

## Inputs

- `.gsd/milestones/M001/slices/S01/S01-RESEARCH.md` — full file specifications and field definitions for all 5 files
- `.gsd/KNOWLEDGE.md` — rules K001–K005 (K003 particularly relevant: expert-report must have severity and evidence fields; K004: synthesis template must structure for convergence/contradiction/priority)

## Expected Output

- `templates/expert-report.md` — per-subagent findings template with XML sections and severity-classified evidence fields
- `templates/synthesis-doc.md` — final audit document template with cross-cutting findings and prioritized recommendations table
- `templates/role-proposal.md` — role display template with per-role focus questions and confirmation prompt text
- `references/output-contract.md` — typed schema defining the exact S01 → S02 output package structure
- `references/input-handling.md` — decision table and normalization rules for all four input types
