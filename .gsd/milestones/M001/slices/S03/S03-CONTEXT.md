---
id: S03
milestone: M001
status: ready
---

# S03: Synthesis & Final Output — Context

## Goal

Receive the validated expert reports array from S02, synthesize them into a single coherent audit document using the severity-first structure, surface contradictions explicitly, mark incomplete coverage, and deliver the final document both to the terminal and saved as a file in the current working directory.

## Why this Slice

S03 is the user-visible payoff for everything built in S01 and S02. Without it, the skill produces no output the user can read, share, or act on. It also retires the last major milestone risk: synthesis coherence — proving that 5–10 heterogeneous expert reports can be merged into a document that is readable, non-redundant, and prioritized.

## Scope

### In Scope

- **Severity-first document structure**: The synthesis document follows this exact order:
  1. **Executive Summary** — cross-cutting gaps where multiple experts converged; also explicitly names any contradictions between experts (see below); brief overview of input reviewed and roles consulted
  2. **Findings by Severity** — all findings across all expert reports, organized into Critical / High / Medium / Low sections, each finding cross-referenced to the role(s) that flagged it
  3. **Per-Expert Sections** — each expert's full section in sequence: role + domain, what was examined, findings in their own words (with evidence), role-specific recommendations
  4. **Prioritized Recommendations** — unified list ordered by impact, each recommendation tagged to the role(s) that generated it; where multiple roles recommend the same fix, merged into one recommendation

- **Explicit contradiction handling**: When two or more expert reports contradict each other (e.g. security engineer flags a caching pattern as risky while performance engineer identifies the same pattern as necessary), the synthesis must:
  - Name the contradiction explicitly in the Executive Summary
  - Preserve both perspectives in the Findings sections (not silently drop one)
  - Provide a recommendation framing it as a tradeoff evaluation: "Evaluate the security vs. performance tradeoff for [pattern] — both perspectives are valid; the right choice depends on [context]"

- **Incomplete coverage section**: If S02 passed any reports with `status: incomplete`, the synthesis document must include a clearly marked **Incomplete Expert Coverage** section — naming which roles returned partial or failed findings and what domain they were meant to cover. This section appears before or after the Per-Expert Sections.

- **Dual output delivery**: 
  - Synthesis is printed to the terminal as rendered markdown in the GSD session
  - Simultaneously saved to a file in the current working directory: `expert-opinion-{YYYY-MM-DD-HHmm}.md`
  - User is told the file path after the document prints

- **Synthesis document uses `templates/synthesis-doc.md`**: The template (written by S01) defines the exact section headers, severity category names, and formatting conventions. The synthesizer follows this template — it does not free-form the structure.

- **Cross-referencing**: Each finding in the Findings by Severity section includes a `[Role Name]` tag. Each recommendation in the Prioritized Recommendations section includes `[Role Name(s)]` tags. This makes the document navigable — users can trace any finding back to its source.

### Out of Scope

- No interactive clarification during synthesis — synthesis is not interactive; it runs straight through from reports to document
- No HTML or PDF export — plain markdown only for M001; export formats deferred
- No deduplication of genuinely separate findings that happen to be in the same domain — only identical or near-identical findings from different roles are merged into one recommendation
- No retry of failed subagents during synthesis — that belongs to S02; S03 works with what it receives
- No user-configurable output format or section ordering in M001

## Constraints

- Must use `templates/synthesis-doc.md` (written by S01) as the structural contract — section names and severity tiers must match the template exactly
- Orchestrating agent synthesizes (D005) — synthesis is not delegated to a subagent
- Output file naming: `expert-opinion-{YYYY-MM-DD-HHmm}.md` in cwd — no configurable path in M001
- Synthesis coherence is the proof target for this slice: the output must be readable, non-redundant, and prioritized. If the document is a wall of text with no clear entry point, it fails.
- No external API keys — synthesis runs entirely from the collected reports using standard in-context LLM reasoning

## Integration Points

### Consumes

- Validated reports array from S02 (in-context):
  - `[{ role, domain, status: complete|incomplete, findings: {...}, recommendations: [...], evidence: [...] }]`
- `templates/synthesis-doc.md` — structural contract for the output document (written by S01)

### Produces

- Final synthesis document: printed to terminal as markdown
- `expert-opinion-{YYYY-MM-DD-HHmm}.md` — saved to cwd, path reported to user

## Open Questions

- **Deduplication threshold** — when two different experts flag what appears to be the same issue, should the synthesizer merge them into one finding or list them separately with a note? Current thinking: merge if the root cause and artifact are identical; list separately if they're the same symptom from different angles (security engineer flags "unvalidated input" from a data injection perspective; UX researcher flags the same from an error-message perspective — these are different findings even though they touch the same code).
- **Executive Summary length** — no hard constraint defined. Current thinking: 150–300 words. Long enough to be useful as a standalone summary; short enough that users actually read it before diving into findings.
- **Contradiction detection** — how does the synthesizer identify contradictions? It can't do semantic diffing automatically. Current thinking: synthesizer does a pass over all findings before generating any section, looking for explicit tension between recommendations across roles. If two recommendations point in opposite directions for the same artifact or pattern, that's a contradiction. This is a reasoning task, not algorithmic — handled by the LLM in the orchestrating agent.
