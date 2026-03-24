---
estimated_steps: 5
estimated_files: 1
skills_used:
  - writing-skills
---

# T01: Write synthesis workflow (4 phases)

**Slice:** S03 — Synthesis & Final Output
**Milestone:** M001

## Description

Create `workflows/synthesis.md` — the synthesis orchestration workflow that transforms a `ResearchOutputPackage` (array of expert reports from S02) into a single coherent, prioritized audit document. This is the core deliverable of S03 and the final link in the intake → research → synthesis pipeline.

The workflow is executed by the orchestrating agent itself (not a subagent, per D005), and must follow the 4-phase XML convention established in `workflows/intake.md` and `workflows/research.md`.

**Prerequisite reading:** Before writing the file, read:
- `references/output-contract.md` — the `ResearchOutputPackage`, `ExpertReport`, and `ResearchMetadata` typed schemas that Phase 1 validates
- `templates/synthesis-doc.md` — the structural template Phase 3 fills, section-by-section
- `templates/expert-report.md` — section names (`<findings>`, `<recommendations>`, `<open_questions>`, `<executive_summary>`) that Phase 2 scans for
- `workflows/intake.md` — the `<required_reading>` and `<phase>` conventions to follow

## Steps

1. Read the four prerequisite files listed above to understand the contracts before writing anything.

2. Write `workflows/synthesis.md` with a `<required_reading>` block at the top listing `references/output-contract.md` and `templates/synthesis-doc.md` as required reading (P004 pattern).

3. Write Phase 1 — Receive and validate `ResearchOutputPackage`:
   - Check `reports` is a non-empty array; if missing or empty, halt with a clear error message in the same format used in `research.md` Phase 1
   - Check `metadata.completed_roles` vs `metadata.total_roles`; if discrepant, emit `WARNING: Only [completed_roles] of [total_roles] roles completed. Proceeding with available reports.` but do NOT halt
   - Collect `incomplete_roles`: loop over `reports`; for each report where `missing_sections` is non-empty, record the role name and missing sections in an internal list
   - Record internally: `reports`, `metadata.inferred_context`, `incomplete_roles` list

4. Write Phase 2 — Pre-synthesis analysis pass (K004 requirement):
   - **Convergence scan**: read all `<findings>` blocks across all reports; identify findings where 2+ experts independently flagged the same root cause in the same artifact (not just the same symptom label). Each convergent cluster → one `<cross_finding>` entry (id: X1, X2, …) with `raised_by`, `finding` (synthesized, not pasted verbatim), and `why_it_matters`
   - **Contradiction scan**: read all `<recommendations>` blocks; identify cases where two experts recommend opposing actions for the same artifact or pattern. Each contradiction → one `<contradiction>` entry with `topic`, `expert_a`, `expert_b`, and `resolution` (which view is adopted and why, or "unresolved — needs domain owner input")
   - **Severity aggregation**: collect all individual `<finding>` items across all reports; sort into four tiers: critical → major → minor → informational. This drives the `<prioritized_recommendations>` table ordering and the `overall_risk` field in `<overview>`
   - **Open questions merge**: collect all `<open_questions>` items from all reports; deduplicate questions that are substantively identical (same root cause + artifact; same symptom from different angles = keep separate). Tag each with source role name
   - **Incomplete coverage note**: if `incomplete_roles` is non-empty, prepare prose: "The following roles returned incomplete reports: [role]: missing [sections], …" for use in Phase 3
   - End Phase 2 with a required log statement: `"Analysis complete. Found [N] cross-cutting findings, [M] contradictions, [K] open questions. [R] roles with incomplete reports."`

5. Write Phase 3 — Generate synthesis document (fill `templates/synthesis-doc.md` in section order):
   - `<overview>`: `overall_risk` = highest severity tier present across all findings; `one_line_verdict` = single sentence synthesizing the dominant cross-cutting signal; `experts_consulted` from role names in `reports`; `review_date` from current date
   - `<per_role_highlights>`: one row per report; `1-Sentence Finding` = expert's `<executive_summary>` condensed to one clause (not a paraphrase written from scratch); `Highest Severity` = most severe `<finding>` in that report
   - `<cross_cutting_findings>`: one `<cross_finding>` block per convergent issue from Phase 2 analysis; if none found, write exactly `"No cross-cutting findings identified."` inside the section
   - `<contradictions>`: one `<contradiction>` block per identified contradiction from Phase 2; **OMIT THIS ENTIRE SECTION if no contradictions** (do not write an empty tag)
   - `<prioritized_recommendations>`: unified ranked table across all expert reports; rank by impact × urgency ÷ effort (judgment call); cross-cutting findings (X-refs) rank higher than single-expert findings of equal severity; source format: `RoleName:F-id` or `RoleName:X1`; merge identical recommendations from different roles into one row (cite both sources); **cap at 15 rows maximum** — if more exist, add a note: `"[N] additional minor/informational findings omitted — see per-expert reports for full detail."`
   - `<open_questions>`: merged deduplicated list, each tagged with source role name; if none, write `"No open questions."`
   - After `</open_questions>`: if `incomplete_roles` is non-empty, append an `<incomplete_coverage>` block naming each incomplete role and its missing sections (required by S03-CONTEXT; use the prose prepared in Phase 2)

6. Write Phase 4 — Dual output delivery:
   - Print the completed synthesis document to terminal as rendered markdown
   - Compute filename: `expert-opinion-$(date +%Y-%m-%d-%H%M).md`
   - Write the document to this filename in the current working directory using `bash` with `cat > filename` (not a relative path assumption — use `$(pwd)/expert-opinion-...` or equivalent)
   - Confirm: `"Synthesis complete. Audit document saved to: ./expert-opinion-{YYYY-MM-DD-HHmm}.md"`

## Must-Haves

- [ ] `workflows/synthesis.md` exists and has a `<required_reading>` block citing `references/output-contract.md` and `templates/synthesis-doc.md`
- [ ] Phase 1 halts on empty `reports`, emits WARNING (not halt) on `completed_roles < total_roles`, collects `incomplete_roles`
- [ ] Phase 2 covers all five analysis sub-steps: convergence, contradiction, severity aggregation, open question merge, incomplete coverage note
- [ ] Phase 2 ends with the exact log statement: `"Analysis complete. Found [N] cross-cutting findings, [M] contradictions, [K] open questions. [R] roles with incomplete reports."`
- [ ] Phase 3 fills all template sections in the order defined in `templates/synthesis-doc.md`; `<contradictions>` is omitted entirely when none; `<prioritized_recommendations>` is capped at 15 rows with overflow note; `<incomplete_coverage>` is appended when `incomplete_roles` non-empty
- [ ] Phase 4 prints to terminal, writes timestamped file to cwd, and confirms filename
- [ ] Synthesis is performed by the orchestrating agent (not delegated to a subagent) — D005

## Verification

- `[ -f workflows/synthesis.md ] && echo "PASS: file exists" || echo "FAIL"`
- `grep -q 'ResearchOutputPackage' workflows/synthesis.md && echo "PASS: input schema ref" || echo "FAIL"`
- `grep -q 'synthesis-doc.md' workflows/synthesis.md && echo "PASS: template ref" || echo "FAIL"`
- `grep -q 'expert-opinion-' workflows/synthesis.md && echo "PASS: output filename pattern" || echo "FAIL"`
- `grep -q 'missing_sections' workflows/synthesis.md && echo "PASS: incomplete report handling" || echo "FAIL"`
- `grep -q 'completed_roles' workflows/synthesis.md && echo "PASS: partial failure signal" || echo "FAIL"`
- `grep -q 'cross_cutting\|convergence\|contradiction' workflows/synthesis.md && echo "PASS: synthesis reasoning" || echo "FAIL"`

## Observability Impact

This task introduces the following runtime signals:

- **Phase 2 log line** — `"Analysis complete. Found [N] cross-cutting findings, [M] contradictions, [K] open questions. [R] roles with incomplete reports."` — the only structured signal emitted mid-synthesis; a future agent can grep for this line in terminal output to confirm Phase 2 completed and extract the counts
- **Phase 4 confirmation line** — `"Synthesis complete. Audit document saved to: ./expert-opinion-{YYYY-MM-DD-HHmm}.md"` — terminal signal confirming successful file write; absence of this line means Phase 4 did not complete
- **Output file** — `expert-opinion-YYYY-MM-DD-HHmm.md` in cwd — existence confirms end-to-end pipeline succeeded; a future agent can `ls -t expert-opinion-*.md | head -1` to find the most recent output

**Failure visibility:**
- Phase 1 halt emits `ERROR (synthesis/phase-1): ...` — no output file is written; the error message identifies the bad field
- Phase 1 WARNING (non-halting) emits discrepancy details — the synthesis proceeds but the output doc will have an `<incomplete_coverage>` block
- Degenerate Phase 2 (all counts zero) is a soft signal — not an error — but warrants inspection of the input package

**How a future agent inspects this task:**
1. Check `ls expert-opinion-*.md` — if empty, Phase 4 didn't complete or Phase 1 halted
2. Grep terminal/log for `"Analysis complete"` — confirms Phase 2 ran and shows counts
3. Check for `<incomplete_coverage>` in the output file — signals partial role completion

## Inputs

- `references/output-contract.md` — ResearchOutputPackage / ExpertReport / ResearchMetadata typed schema; Phase 1 validation and Phase 2 field access depend on it
- `templates/synthesis-doc.md` — the structural contract Phase 3 fills, section by section
- `templates/expert-report.md` — section names used in Phase 2 scanning
- `workflows/intake.md` — `<required_reading>` block and `<phase>` conventions to replicate
- `workflows/research.md` — Phase 1 validation error format, WARNING language, and phase structure to mirror

## Expected Output

- `workflows/synthesis.md` — new workflow file: 4-phase synthesis orchestration
