# S03: Synthesis & Final Output

**Goal:** Synthesize all collected expert reports into one coherent, prioritized audit document — the actual product the user receives. The orchestrating agent (not a subagent) performs a structured analysis pass (convergence, contradiction, severity ordering, deduplication) and fills `templates/synthesis-doc.md` section-by-section, then writes the output to a timestamped file.

**Demo:** A user runs the skill end-to-end. After parallel expert reports are collected, the synthesis route fires, logs the analysis pass summary, renders the completed audit document to terminal, and saves it as `expert-opinion-YYYY-MM-DD-HHmm.md` in the current working directory.

## Must-Haves

- `workflows/synthesis.md` exists with all 4 phases: receive/validate → pre-synthesis analysis → generate synthesis doc → deliver
- Pre-synthesis analysis pass explicitly covers convergence, contradiction, severity aggregation, open question merge, and incomplete coverage notes (K004)
- Phase 3 fills every section of `templates/synthesis-doc.md` in template order; `<contradictions>` is omitted (not empty-tagged) when none exist; `<prioritized_recommendations>` caps at 15 rows
- Phase 4 prints to terminal, writes file as `expert-opinion-{YYYY-MM-DD-HHmm}.md`, and confirms filename
- `SKILL.md` `<!-- S03 will add: ... -->` placeholder is replaced with a live `<route id="synthesis">` block
- SKILL.md remains < 500 lines with zero markdown headings (K001, K002)

## Verification

```bash
# Workflow file exists
[ -f workflows/synthesis.md ] && echo "PASS: synthesis.md exists" || echo "FAIL"

# Live route in SKILL.md
grep -q 'route id="synthesis"' SKILL.md && echo "PASS: route live" || echo "FAIL"

# Key contract terms in synthesis.md
grep -q 'ResearchOutputPackage' workflows/synthesis.md && echo "PASS: input schema ref" || echo "FAIL"
grep -q 'synthesis-doc.md' workflows/synthesis.md && echo "PASS: template ref" || echo "FAIL"
grep -q 'expert-opinion-' workflows/synthesis.md && echo "PASS: output filename pattern" || echo "FAIL"
grep -q 'missing_sections' workflows/synthesis.md && echo "PASS: incomplete report handling" || echo "FAIL"
grep -q 'completed_roles' workflows/synthesis.md && echo "PASS: partial failure signal" || echo "FAIL"
grep -q 'cross_cutting\|convergence\|contradiction' workflows/synthesis.md && echo "PASS: synthesis reasoning" || echo "FAIL"

# SKILL.md compliance
lines=$(wc -l < SKILL.md); [ "$lines" -lt 500 ] && echo "PASS: SKILL.md < 500 lines ($lines)" || echo "FAIL: SKILL.md $lines lines"
headings=$(grep -c '^#' SKILL.md || true); [ "$headings" -eq 0 ] && echo "PASS: no markdown headings" || echo "FAIL: $headings markdown headings"
grep -q 'ERROR (synthesis/phase-1)' workflows/synthesis.md && echo "PASS: phase-1 error format present" || echo "FAIL"
grep -q 'Analysis complete' workflows/synthesis.md && echo "PASS: phase-2 log statement present" || echo "FAIL"
grep -q 'Synthesis complete' workflows/synthesis.md && echo "PASS: phase-4 confirmation present" || echo "FAIL"
```

## Observability / Diagnostics

Runtime signals emitted during S03 execution:

- **Phase 1 log** — emits `ERROR (synthesis/phase-1): ...` to terminal on invalid input (missing `reports`, empty array); halts immediately so the user sees the failure before any analysis runs
- **Phase 1 warning** — emits `WARNING: Only [M] of [N] roles completed. Proceeding with available reports.` when partial results detected; non-halting so synthesis still produces output
- **Phase 2 log** — emits `"Analysis complete. Found [N] cross-cutting findings, [M] contradictions, [K] open questions. [R] roles with incomplete reports."` at end of analysis pass; provides a structural summary an agent can parse to verify analysis depth
- **Phase 4 confirmation** — emits `"Synthesis complete. Audit document saved to: ./expert-opinion-{YYYY-MM-DD-HHmm}.md"` as the final terminal signal; a future agent scanning output can confirm delivery without reading the full document

**Inspection surfaces:**
- The timestamped output file (`expert-opinion-YYYY-MM-DD-HHmm.md`) in cwd is the primary inspection surface — its existence and content confirm end-to-end pipeline success
- The Phase 2 log line is parseable: field counts (N, M, K, R) allow a future agent to detect degenerate outputs (e.g. N=0 may indicate identical reports, K=0 may mean open questions were silently dropped)
- `<incomplete_coverage>` block presence/absence in the output file signals whether partial role failures were handled and documented

**Failure state visibility:**
- Phase 1 halt: terminal shows `ERROR (synthesis/phase-1)` — no output file is written
- Phase 2 degenerate: all counts are 0 — may indicate a malformed `ResearchOutputPackage`; inspect the input package before re-running
- Phase 4 write failure: bash error will surface to terminal; no confirmation line will appear

**Redaction:** No user secrets or API keys travel through the synthesis pipeline. `ResearchOutputPackage` may contain artifact content (user-submitted code, docs, etc.) — do NOT log `report` fields verbatim to stdout unless the user explicitly requested terminal rendering in Phase 4.

## Integration Closure

- Upstream surfaces consumed: `references/output-contract.md` (ResearchOutputPackage schema), `templates/synthesis-doc.md` (output structure), `templates/expert-report.md` (section names for report parsing)
- New wiring introduced: `SKILL.md <route id="synthesis">` → `workflows/synthesis.md`; completes the three-route chain (intake → research → synthesis)
- What remains before the milestone is truly usable end-to-end: nothing — this slice closes the final link in the pipeline

## Tasks

- [x] **T01: Write synthesis workflow (4 phases)** `est:1h`
  - Why: `workflows/synthesis.md` is the entire substantive deliverable of S03 — without it the synthesis route doesn't exist and R005 is unmet
  - Files: `workflows/synthesis.md`
  - Do: Create the file with `<required_reading>` block, then 4 `<phase>` XML blocks following the convention in `workflows/intake.md` and `workflows/research.md`. Phase 1: receive and validate `ResearchOutputPackage` (halt if `reports` empty; emit WARNING if `completed_roles < total_roles`; collect `incomplete_roles` list from `missing_sections`). Phase 2: pre-synthesis analysis — convergence scan (same root cause + artifact across 2+ reports → `<cross_finding>`), contradiction scan (opposing recommendations for same artifact → `<contradiction>`), severity aggregation (sort all findings critical→major→minor→informational), open-question merge (deduplicate by root cause + artifact), incomplete coverage note prep. Log: `"Analysis complete. Found [N] cross-cutting findings, [M] contradictions, [K] open questions. [R] roles with incomplete reports."` Phase 3: fill `templates/synthesis-doc.md` sections in order — `<overview>` (overall_risk = highest severity present; one_line_verdict = one sentence), `<per_role_highlights>` (one row per report; 1-sentence from expert's own executive_summary; highest severity per report), `<cross_cutting_findings>` (one `<cross_finding>` per convergent issue; if none → "No cross-cutting findings identified."), `<contradictions>` (OMIT SECTION ENTIRELY if none), `<prioritized_recommendations>` (ranked table, cap 15 rows, note "X additional minor/informational findings omitted" if capped; merge identical recommendations from different roles), `<open_questions>` (tagged with source role), then if `incomplete_roles` non-empty append `<incomplete_coverage>` block listing each incomplete role and missing sections. Phase 4: print completed document to terminal as rendered markdown; compute filename `expert-opinion-$(date +%Y-%m-%d-%H%M).md`; write file to cwd; confirm `"Synthesis complete. Audit document saved to: ./expert-opinion-{YYYY-MM-DD-HHmm}.md"`. Constraints: synthesis is NOT delegated to a subagent (D005); `<required_reading>` must reference `references/output-contract.md` and `templates/synthesis-doc.md` (P004); convergence = same root cause + artifact, not same symptom label; `<contradictions>` omitted entirely when none.
  - Verify: `[ -f workflows/synthesis.md ] && grep -q 'ResearchOutputPackage' workflows/synthesis.md && grep -q 'synthesis-doc.md' workflows/synthesis.md && grep -q 'expert-opinion-' workflows/synthesis.md && echo "PASS" || echo "FAIL"`
  - Done when: `workflows/synthesis.md` exists, references both required contracts, covers all 4 phases, and all grep checks from the slice verification suite pass for this file

- [x] **T02: Update SKILL.md route and run full verification** `est:20m`
  - Why: The synthesis route must be live in SKILL.md before the end-to-end skill is complete; verification confirms all S03 checks pass and the three-route pipeline is wired correctly
  - Files: `SKILL.md`
  - Do: Replace the 6-line placeholder comment block in `SKILL.md` (the `<!-- S03 will add: ... -->` block lines 61–66) with the live route: `<route id="synthesis" trigger="all_reports_collected"><description>Synthesizes collected expert reports into a prioritized audit document. Identifies convergent findings, surfaces contradictions, and emits a ranked recommendation table. Saves output to expert-opinion-{YYYY-MM-DD-HHmm}.md.</description><workflow>workflows/synthesis.md</workflow><phases>receive → analyze → synthesize → deliver</phases></route>`. Verify no markdown headings introduced and line count stays < 500. Then run the full verification suite from the S03 verification section.
  - Verify: Run all bash checks from the slice Verification section; every check must print PASS
  - Done when: All 10 verification checks print PASS; SKILL.md has live synthesis route; `wc -l SKILL.md` < 500

## Files Likely Touched

- `workflows/synthesis.md`
- `SKILL.md`
