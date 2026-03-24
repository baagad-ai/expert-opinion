# S03: Synthesis & Final Output — Research

**Date:** 2026-03-24

## Summary

S03 is the narrowest slice of the three: one new workflow file (`workflows/synthesis.md`), one line-group update to `SKILL.md`, and no new templates or references. The structural template (`templates/synthesis-doc.md`) and the typed input schema (`ResearchOutputPackage`) were both fully defined in S01/S02 and are canonical — S03 consumes them unchanged.

The only genuine design work in this slice is the synthesis reasoning algorithm: how the orchestrating agent (D005) moves from a bag of heterogeneous expert reports to a coherent document. K004 defines the obligation ("synthesis ≠ concatenation"), and S03-CONTEXT defines the three cognitive passes required: convergence detection, contradiction identification, and impact-ordered prioritization. The workflow must make each pass explicit so a future executor reads it as an ordered procedure, not a vague instruction to "synthesize well."

One structural discrepancy: S03-CONTEXT describes "Findings by Severity" and "Per-Expert Sections" as output document sections. `templates/synthesis-doc.md` (the authoritative contract) does not have these as named sections — it uses `<per_role_highlights>` (one-row-per-expert summary table) and `<cross_cutting_findings>` blocks instead. The workflow must follow the template; the severity-first reasoning pass feeds the template sections rather than creating new ones.

## Recommendation

Write `workflows/synthesis.md` as a 4-phase workflow following the established `<phase id="N" name="...">` convention from `workflows/intake.md` and `workflows/research.md`. The four phases: (1) receive and validate `ResearchOutputPackage`, (2) pre-synthesis analysis pass, (3) generate synthesis document from `templates/synthesis-doc.md`, (4) output delivery. Update SKILL.md by replacing the `<!-- S03 will add: ... -->` placeholder with a live `<route id="synthesis">` block. No other files change.

## Implementation Landscape

### Key Files

- `workflows/synthesis.md` — **new file**; the synthesis orchestration workflow; does not exist yet
- `SKILL.md` — replace the 6-line `<!-- S03 will add: ... -->` comment block (lines 61–66) with a live `<route id="synthesis">` pointing to `workflows/synthesis.md`
- `templates/synthesis-doc.md` — **read-only**; the structural contract the synthesis phase fills; already complete from S01
- `references/output-contract.md` — **read-only**; the `ResearchOutputPackage` / `ExpertReport` / `ResearchMetadata` typed schema; the workflow's `<required_reading>` block must reference this
- `references/subagent-prompt.md` — **not touched**; S02 artifact; no changes needed
- `templates/expert-report.md` — **read-only reference**; synthesis uses the section names to parse each report's `<findings>`, `<recommendations>`, `<open_questions>` blocks

### `workflows/synthesis.md` — Phase Design

**Phase 1 — Receive and validate `ResearchOutputPackage`**

Mirrors the validation pattern from `research.md` Phase 1. Checks:
1. `reports` is a non-empty array (halt if missing/empty; same error format as research.md)
2. `metadata.completed_roles` vs `metadata.total_roles` — if discrepant, emit a WARNING before continuing (same language established in research.md Phase 4) but do NOT halt; synthesize with available reports
3. For each report, check `missing_sections` — collect a list of roles with incomplete reports for use in Phase 3

Record internally: `reports`, `metadata.inferred_context`, `incomplete_roles` list (roles where `missing_sections` is non-empty).

**Phase 2 — Pre-synthesis analysis pass**

This is the K004 pass. Before generating any section of the output document, the executor must:

1. **Convergence scan** — read all `<findings>` blocks across all reports; identify findings where two or more experts independently flagged the same artifact, pattern, or condition. These become `<cross_finding>` blocks with elevated priority. A convergent finding is identified by shared root cause and artifact, not shared symptom label.

2. **Contradiction scan** — read all `<recommendations>` blocks; identify cases where two experts recommend opposing actions for the same artifact or pattern (e.g. "add caching here" vs "remove caching here"). Each identified contradiction populates one `<contradiction>` block. The resolution field must state which view the synthesis adopts and why, or explicitly mark it "unresolved — needs domain owner input."

3. **Severity aggregation** — collect all individual `<finding>` items across all reports; sort by severity (critical → major → minor → informational) for use when filling `<prioritized_recommendations>`. This drives the impact column of the ranked table.

4. **Open questions merge** — collect all `<open_questions>` items from all reports for the synthesis `<open_questions>` section; deduplicate questions that are substantively identical.

5. **Incomplete coverage notes** — if `incomplete_roles` is non-empty, prepare a prose note listing each incomplete role and what sections were missing. This will be appended after `<open_questions>` in the output document.

Log at the end of Phase 2: `"Analysis complete. Found [N] cross-cutting findings, [M] contradictions, [K] open questions. [R] roles with incomplete reports."`

**Phase 3 — Generate synthesis document**

Fill `templates/synthesis-doc.md` in section order using the Phase 2 analysis results. Key rules:

- `<overview>`: populate `overall_risk` as the highest severity present across all findings; `one_line_verdict` must be a single sentence synthesizing the dominant cross-cutting signal
- `<per_role_highlights>`: one row per report in `reports` array; `1-Sentence Finding` is the expert's own `<executive_summary>` condensed to one clause — not a paraphrase; `Highest Severity` is the most severe `<finding>` in that report
- `<cross_cutting_findings>`: one `<cross_finding>` per convergent issue from Phase 2; if none, write "No cross-cutting findings identified."
- `<contradictions>`: one `<contradiction>` per identified contradiction from Phase 2; omit section entirely if no contradictions
- `<prioritized_recommendations>`: unified ranked table; rank by impact × urgency ÷ effort (judgment call); cross-cutting findings (X-refs) rank higher than single-expert findings of equal severity; source column format: `RoleName:F-id` or `RoleName:X1` for cross-cutting; merge identical recommendations from different roles into one row (cite both role sources)
- `<open_questions>`: merged deduplicated list tagged with source role name
- After `</open_questions>`: if `incomplete_roles` is non-empty, append an `<incomplete_coverage>` block naming each incomplete role and its missing sections — this is required by S03-CONTEXT

Do NOT free-form additional sections outside the template. Do NOT omit any template section (even if the content is the specified "none" placeholder).

**Phase 4 — Dual output delivery**

1. Print the completed synthesis document to the terminal as rendered markdown
2. Compute filename: `expert-opinion-{YYYY-MM-DD-HHmm}.md` using the current datetime
3. Write the document to the file in the current working directory using the `write` tool (or `bash` with `cat > filename`)
4. After file write, confirm: `"Synthesis complete. Audit document saved to: ./expert-opinion-{YYYY-MM-DD-HHmm}.md"`

### SKILL.md Update

Replace the existing placeholder comment block:
```
<!-- S03 will add:
<route id="synthesis" trigger="all_reports_collected">
  <description>Synthesizes expert reports into a prioritized audit document.</description>
  <workflow>workflows/synthesis.md</workflow>
</route>
-->
```

With the live route:
```xml
<route id="synthesis" trigger="all_reports_collected">
  <description>
    Synthesizes collected expert reports into a prioritized audit document.
    Identifies convergent findings, surfaces contradictions, and emits a ranked
    recommendation table. Saves output to expert-opinion-{YYYY-MM-DD-HHmm}.md.
  </description>
  <workflow>workflows/synthesis.md</workflow>
  <phases>receive → analyze → synthesize → deliver</phases>
</route>
```

### Build Order

1. **Write `workflows/synthesis.md`** first — this is the substantive work; SKILL.md update is trivial once the workflow exists
2. **Update SKILL.md** — uncomment/replace the placeholder; verify line count stays < 500 and no markdown headings introduced
3. **Verify** with the check suite below

### Verification Approach

```bash
# Route live in SKILL.md
grep -q 'route id="synthesis"' SKILL.md && echo "PASS: route live" || echo "FAIL"

# Workflow file exists
[ -f workflows/synthesis.md ] && echo "PASS: synthesis.md exists" || echo "FAIL"

# Key contract terms referenced in synthesis.md
grep -q 'ResearchOutputPackage' workflows/synthesis.md && echo "PASS: input schema ref" || echo "FAIL"
grep -q 'synthesis-doc.md' workflows/synthesis.md && echo "PASS: template ref" || echo "FAIL"
grep -q 'expert-opinion-' workflows/synthesis.md && echo "PASS: output filename pattern" || echo "FAIL"
grep -q 'missing_sections' workflows/synthesis.md && echo "PASS: incomplete report handling" || echo "FAIL"
grep -q 'completed_roles' workflows/synthesis.md && echo "PASS: partial failure signal" || echo "FAIL"
grep -q 'cross_cutting\|convergence\|contradiction' workflows/synthesis.md && echo "PASS: synthesis reasoning" || echo "FAIL"

# SKILL.md compliance
wc -l SKILL.md   # must be < 500
grep -c '^#' SKILL.md || true  # must be 0
```

## Constraints

- `templates/synthesis-doc.md` is the structural contract for the output document — section names, severity tiers, and XML tag names must match it exactly; no additional top-level sections outside the template (except the `<incomplete_coverage>` appendix mandated by S03-CONTEXT when `incomplete_roles` is non-empty)
- D005: orchestrating agent synthesizes — synthesis is NOT delegated to a subagent; `workflows/synthesis.md` is executed by the same agent that received the `ResearchOutputPackage`
- SKILL.md must remain < 500 lines (K002); adding the synthesis route will bring it to approximately 83 lines — well within limit
- No markdown headings in SKILL.md body (K001)
- Output file naming is non-configurable in M001: `expert-opinion-{YYYY-MM-DD-HHmm}.md` in cwd
- The `<required_reading>` block at the top of `synthesis.md` must reference at minimum: `references/output-contract.md` and `templates/synthesis-doc.md` (following P004)

## Common Pitfalls

- **Template section order matters** — `synthesis-doc.md` sections must be emitted in the order defined in the template; don't reorder even if the prose in S03-CONTEXT describes a different order
- **`<contradictions>` section omission** — the template says "Omit this section if there are no contradictions." The workflow must explicitly handle the no-contradictions case by omitting the section entirely (not writing an empty tag)
- **Convergence ≠ same symptom** — two experts calling something "slow" is not convergence unless they're identifying the same root cause in the same artifact. The Phase 2 analysis must distinguish symptom-overlap from root-cause convergence
- **File write in GSD context** — using `write` tool writes to the executor's working directory; confirm this is the cwd of the skill invocation, not the worktree path. The workflow should use `bash` with `pwd` to verify cwd before writing if ambiguous
- **Deduplication threshold** — S03-CONTEXT's guidance: merge if root cause and artifact are identical; list separately if same symptom from different angles. Encode this rule explicitly in Phase 2 so the executor has a decision rule, not a judgment call

## Open Risks

- **Synthesis wall-of-text risk** — with 5–10 expert reports each having 3–6 findings, the `<prioritized_recommendations>` table could have 30+ rows. The workflow should cap at the top 15 recommendations and note "X additional minor/informational findings omitted — see per-expert reports." This cap isn't defined anywhere yet; the planner should add it to Phase 3.
- **Expert report XML parsing** — the synthesis agent reads `ExpertReport.report` (raw string) and must locate `<findings>`, `<recommendations>`, `<open_questions>` by tag name. Reports that are structurally valid XML but have extra whitespace or slightly different tag formatting may cause the Phase 2 scan to miss sections. The workflow should use substring matching (not a parser) and document the expected tag format it's scanning for.
