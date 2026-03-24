<required_reading>
  references/output-contract.md — canonical ResearchOutputPackage / ExpertReport / ResearchMetadata schemas; Phase 1 validation and Phase 2 field access depend on these exact field names
  templates/synthesis-doc.md — structural contract Phase 3 fills section-by-section; render in the order the template defines
</required_reading>

<workflow name="synthesis" version="1.0">

<purpose>
Four-phase synthesis orchestration. Accepts the `ResearchOutputPackage` emitted by
`workflows/research.md`, performs a structured analysis pass (convergence, contradiction,
severity aggregation, open-question deduplication), fills `templates/synthesis-doc.md`
section-by-section, and delivers the completed audit document to terminal and to a
timestamped file in the current working directory.

The synthesis is performed by the orchestrating agent — NOT delegated to a subagent (D005).
Synthesis is NOT concatenation: identify convergence, contradiction, and priority order
across all expert views (K004). The synthesis document is the product; the expert reports
are intermediate artifacts.
</purpose>

<phase id="1" name="Receive and validate ResearchOutputPackage">
Accept the `ResearchOutputPackage` JSON block emitted at the end of `workflows/research.md`.

**Validation checks:**

1. `reports` must be a present, non-empty array.
   - If absent or empty → STOP. Output:
     "ERROR (synthesis/phase-1): `reports` is missing or empty in the provided ResearchOutputPackage.
     Re-run the research workflow to produce a valid package before continuing."

2. `metadata.completed_roles` vs `metadata.total_roles`:
   - If `completed_roles < total_roles` → do NOT halt. Output:
     "WARNING: Only [completed_roles] of [total_roles] roles completed. Proceeding with available reports."
   - Then continue to Phase 2.

3. Collect `incomplete_roles`: loop over `reports`; for each report where `missing_sections`
   is a non-empty array, record:
   ```
   incomplete_roles[i] = { role: report.role, missing_sections: report.missing_sections }
   ```
   An empty `missing_sections` array means the report is complete; include the report
   normally in all analysis steps.

Record internally:
- `reports` ← `package.reports`
- `inferred_context` ← `package.metadata.inferred_context`
- `incomplete_roles` ← collected list from step 3 (may be empty)
- `total_roles` ← `package.metadata.total_roles`
- `completed_roles` ← `package.metadata.completed_roles`

Proceed to Phase 2.
</phase>

<phase id="2" name="Pre-synthesis analysis pass">
Perform five sub-steps in order. Work only from the reports received — do NOT web-search,
fetch external resources, or call subagents. All analysis is in-context.

<!-- CONVERGENCE SCAN -->
<convergence_scan>
Read all `<findings>` blocks across all reports.

A convergent finding exists when 2+ experts independently flagged the **same root cause
in the same artifact** — not merely the same symptom label or the same general category.
"Both flagged SQL injection risk in the query builder" = convergent.
"Both mentioned performance could be improved" = NOT convergent.

For each convergent cluster, create one `cross_finding` entry:
  - id: X1, X2, … (sequential)
  - raised_by: list of role names that flagged this root cause
  - finding: a synthesized description — do NOT paste any single expert's words verbatim;
    combine their observations into one precise statement
  - why_it_matters: the combined impact, which may be greater than either expert stated

If no convergent findings exist after scanning all reports, record `cross_findings = []`.
</convergence_scan>

<!-- CONTRADICTION SCAN -->
<contradiction_scan>
Read all `<recommendations>` blocks across all reports.

A contradiction exists when two experts recommend **opposing actions for the same artifact
or pattern** (e.g., "add caching here" vs. "remove caching here"; "make this synchronous"
vs. "make this async"). Different emphasis or different severity ratings for the same issue
are NOT contradictions.

For each contradiction, create one `contradiction` entry:
  - topic: the artifact or pattern the disagreement concerns
  - expert_a: "[Role] says: [their position in one clause]"
  - expert_b: "[Role] says: [their position in one clause]"
  - resolution: which view this synthesis adopts and the one-sentence rationale, OR
    "unresolved — needs domain owner input" when neither view can be adjudicated without
    additional context (e.g., missing load test data, unknown deployment constraints)

If no contradictions exist, record `contradictions = []`.
</contradiction_scan>

<!-- SEVERITY AGGREGATION -->
<severity_aggregation>
Collect every individual `<finding>` item from every report. Sort into four tiers:
  - critical: exploitable, data-losing, or blocking — must fix before ship
  - major: significant quality or correctness issue — fix in near term
  - minor: improvement opportunity — fix when convenient
  - informational: observation worth noting — no action required

Record the severity tier of each finding alongside its source role and finding id.
The highest tier present across all findings becomes `overall_risk` in `<overview>`.
This sorted list drives the rank order in `<prioritized_recommendations>`.
</severity_aggregation>

<!-- OPEN QUESTIONS MERGE -->
<open_questions_merge>
Collect all `<open_questions>` items from all reports.

Deduplicate: two questions are substantively identical when they concern the **same root
cause AND the same artifact** (e.g., "Is the session store replicated?" from two roles).
Same symptom observed from different angles (e.g., "What is the DB replication lag?" from
performance vs. "Is the DB primary/replica split configured?" from security) = keep separate.

For each deduplicated question, tag with the source role name(s).
Record the merged list as `merged_open_questions`.
</open_questions_merge>

<!-- INCOMPLETE COVERAGE NOTE -->
<incomplete_coverage_prep>
If `incomplete_roles` is non-empty, prepare the following prose for use in Phase 3:

"The following roles returned incomplete reports:
[For each entry in incomplete_roles:]
  - [role]: missing [missing_sections joined by ', ']
Findings from these roles may be partial. Treat recommendations from incomplete reports
with additional scrutiny and consider re-running those expert roles."

If `incomplete_roles` is empty, this prose is not needed.
</incomplete_coverage_prep>

At the end of Phase 2, log this exact line to terminal (substitute actual counts):
"Analysis complete. Found [N] cross-cutting findings, [M] contradictions, [K] open questions. [R] roles with incomplete reports."

where:
  N = len(cross_findings)
  M = len(contradictions)
  K = len(merged_open_questions)
  R = len(incomplete_roles)

Proceed to Phase 3.
</phase>

<phase id="3" name="Generate synthesis document">
Fill `templates/synthesis-doc.md` section-by-section in the order below. Do not reorder
sections. Do not skip sections (except `<contradictions>` per its own rule).

<!-- OVERVIEW -->
<fill_overview>
Produce an `<overview>` block with these fields:

- artifact: from `inferred_context.purpose` — what artifact was reviewed (be specific)
- scope: derive from the union of all expert domains in `reports` (e.g. "security, performance, API design")
- experts_consulted: comma-separated list of `report.role` values from all entries in `reports`
- review_date: today's date in YYYY-MM-DD format
- overall_risk: the highest severity tier present across all findings from the severity aggregation
  (critical > high > medium > low; map: critical→critical, major→high, minor→medium, informational→low)
- one_line_verdict: a single sentence synthesizing the dominant cross-cutting signal;
  if `cross_findings` is non-empty, derive from the top cross-cutting finding;
  otherwise derive from the highest-severity single-expert finding
</fill_overview>

<!-- PER ROLE HIGHLIGHTS -->
<fill_per_role_highlights>
Produce one table row per entry in `reports`:

| Role | 1-Sentence Finding | Highest Severity |
|------|--------------------|-----------------|

- Role: `report.role`
- 1-Sentence Finding: take the expert's own `<executive_summary>` text and condense it to
  one clause; do NOT rewrite from scratch — use the expert's own signal, shortened
- Highest Severity: the severity level of the most severe `<finding>` in that report
  (scan the report text for severity tags)

Include all reports, including those in `incomplete_roles` (mark them with "(partial)" after the role name if `missing_sections` is non-empty).
</fill_per_role_highlights>

<!-- CROSS CUTTING FINDINGS -->
<fill_cross_cutting_findings>
Produce the `<cross_cutting_findings>` section.

If `cross_findings` is non-empty:
  For each entry, produce one `<cross_finding>` block with id, raised_by, finding, why_it_matters.

If `cross_findings` is empty:
  Write exactly this inside the section: "No cross-cutting findings identified."
</fill_cross_cutting_findings>

<!-- CONTRADICTIONS — CONDITIONALLY INCLUDED -->
<fill_contradictions>
If `contradictions` is non-empty:
  Produce the `<contradictions>` section with one `<contradiction>` block per entry.

If `contradictions` is empty:
  OMIT THE ENTIRE `<contradictions>` SECTION. Do not write the tag at all.
  Do not write "No contradictions." — simply skip it.
</fill_contradictions>

<!-- PRIORITIZED RECOMMENDATIONS -->
<fill_prioritized_recommendations>
Produce the `<prioritized_recommendations>` section as a ranked table.

Ranking rules (apply in order):
1. Cross-cutting findings (X-refs) rank above single-expert findings of equal severity.
2. Within the same tier, rank by impact × urgency ÷ effort (use judgment).
3. Tier order: critical → major → minor → informational.

Source format: `RoleName:F-id` (e.g. `SecurityAuditor:F2`) or `RoleName:X1` for a cross-cutting finding.

Merging: if two or more roles recommend the exact same action for the same artifact,
merge into one row and list all source references (e.g. `SecurityAuditor:F2, PerfEngineer:F1`).

Cap: include at most 15 rows. If additional findings exist beyond 15, add this note
immediately after the table:
"[N] additional minor/informational findings omitted — see per-expert reports for full detail."
where N is the count of omitted rows.
</fill_prioritized_recommendations>

<!-- OPEN QUESTIONS -->
<fill_open_questions>
Produce the `<open_questions>` section.

If `merged_open_questions` is non-empty:
  List each question in the format:
  "- [Question] — raised by [role name(s)]; needs [what would resolve it]"

If `merged_open_questions` is empty:
  Write: "No open questions."
</fill_open_questions>

<!-- INCOMPLETE COVERAGE — CONDITIONALLY APPENDED -->
<append_incomplete_coverage>
If `incomplete_roles` is non-empty:
  Append an `<incomplete_coverage>` block immediately after `</open_questions>`:

  <incomplete_coverage>
  [Paste the prose prepared in Phase 2 incomplete_coverage_prep here]
  </incomplete_coverage>

If `incomplete_roles` is empty:
  Do not add this block.
</append_incomplete_coverage>

The complete synthesis document is now assembled. Proceed to Phase 4.
</phase>

<phase id="4" name="Dual output delivery">
Deliver the completed synthesis document in two forms.

**Step 1 — Render to terminal:**
Print the full synthesis document to terminal as rendered markdown. This allows the user
to read the result inline without opening a file.

**Step 2 — Write to file:**
Compute the output filename:
```bash
OUTFILE="$(pwd)/expert-opinion-$(date +%Y-%m-%d-%H%M).md"
```

Write the synthesis document to this file:
```bash
cat > "$OUTFILE" << 'SYNTHESIS_EOF'
[full synthesis document content]
SYNTHESIS_EOF
```

**Step 3 — Confirm delivery:**
Output this exact confirmation line (substituting the actual filename):
"Synthesis complete. Audit document saved to: ./expert-opinion-{YYYY-MM-DD-HHmm}.md"

The pipeline is complete. The audit document is the canonical deliverable.
</phase>

</workflow>
