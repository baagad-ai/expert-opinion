---
estimated_steps: 4
estimated_files: 2
skills_used:
  - writing-skills
---

# T02: Write research orchestration workflow and wire SKILL.md route

**Slice:** S02 — Parallel Research Engine
**Milestone:** M001

## Description

With `references/subagent-prompt.md` and the S02→S03 contract defined in T01, this task builds the orchestration that puts the pieces together: `workflows/research.md` (the 4-phase execution workflow) and the live `<route id="research">` entry in `SKILL.md`.

`research.md` is the file the executor follows when the research route is triggered. It must be concrete enough that an agent reading it alone — without the research doc or roadmap — can execute the full parallel dispatch correctly. The critical invariants: parallel mode (not sequential), per-role focus question indexing (not full array), summary+content pass-through when summary is present, and emit-all-before-return (no partial results).

The SKILL.md edit is surgical: replace the exact `<!-- S02 will add: ... -->` comment block with a live route. No other changes to SKILL.md.

## Steps

1. Read `SKILL.md`, `references/subagent-prompt.md`, and `references/output-contract.md` to confirm the extension point location and canonical field names before writing anything.

2. Write `workflows/research.md` with these four phases in XML `<phase>` blocks (matching the K001/P004 convention from intake.md):
   - Open with `<required_reading>` listing `references/output-contract.md`, `references/subagent-prompt.md`, and `templates/expert-report.md`
   - **Phase 1 — Receive & Validate**: Accept the `IntakeOutputPackage` JSON block emitted by intake.md. Confirm `confirmed_roles` is a non-empty array; confirm `normalized_input.content` is present. If either is missing, emit a clear error message and stop.
   - **Phase 2 — Construct per-role tasks**: For each role in `confirmed_roles`, build a subagent task using `references/subagent-prompt.md` as the template. Substitute: `{role}`, `{domain}`, `{rationale}`, `{focus_questions}` (only this role's array — not all roles), `{content}` (`normalized_input.content`), `{summary}` (include if `normalized_input.summary` present, omit if not), and `{inferred_context}`. Produce a list of task objects ready for parallel dispatch.
   - **Phase 3 — Parallel dispatch**: Call the `subagent` tool using **parallel mode** (`tasks: [...]` array signature). Each task specifies agent `worker` (or equivalent general-purpose agent) and the constructed task text. Explicitly state: do NOT use chain mode; do NOT dispatch sequentially. If parallel mode is unavailable, dispatch sequentially as a graceful degradation (not a failure) — note this in a comment.
   - **Phase 4 — Collect & emit**: Wait for all subagent outputs to complete before emitting. For each output, record: `role`, `domain`, and the full verbatim report text. Identify any reports missing required sections (`role_identity`, `executive_summary`, `findings`, `recommendations`) and populate `missing_sections`. Emit a `ResearchOutputPackage` JSON block per the S02→S03 schema in `references/output-contract.md`.

3. Edit `SKILL.md`: replace the `<!-- S02 will add: ... -->` block (the exact commented-out research route placeholder) with:
   ```xml
   <route id="research" trigger="output_package_ready">
     <description>Parallel expert research. Dispatches one subagent per confirmed role using parallel mode. Collects structured expert reports for synthesis.</description>
     <workflow>workflows/research.md</workflow>
     <phases>receive → construct → dispatch → collect</phases>
   </route>
   ```
   Do not add anything else to SKILL.md. Preserve the synthesis comment block below it.

4. Run verification checks. If any fail, fix before marking done.

## Must-Haves

- [ ] `workflows/research.md` opens with `<required_reading>` block naming all three referenced files
- [ ] Phase 2 indexes `confirmed_roles[i].focus_questions` per-role — never passes the full multi-role array to a single subagent
- [ ] Phase 3 explicitly uses `subagent` tool with parallel mode `tasks: [...]` signature; sequential fallback is documented as graceful degradation
- [ ] Phase 4 waits for ALL outputs before emitting; `missing_sections` field is populated
- [ ] `ResearchOutputPackage` JSON block emitted at the end of Phase 4
- [ ] SKILL.md edit replaces only the comment block; synthesis comment left intact
- [ ] SKILL.md: zero markdown headings in body (`grep -c '^#' SKILL.md` == 0)
- [ ] SKILL.md: under 500 lines

## Verification

```bash
# File existence
test -f workflows/research.md && echo "research.md present"

# Parallel dispatch
grep -q 'parallel' workflows/research.md && echo "PARALLEL OK"
grep -q 'subagent' workflows/research.md && echo "SUBAGENT OK"

# K003 — all four components referenced
grep -q 'focus_questions' workflows/research.md && echo "FOCUS QUESTIONS OK"
grep -q 'normalized_input' workflows/research.md && echo "INPUT ARTIFACT OK"
grep -q 'summary' workflows/research.md && echo "SUMMARY FIELD OK"
grep -q 'templates/expert-report.md' workflows/research.md && echo "TEMPLATE REF OK"

# Required reading block
grep -q 'required_reading\|subagent-prompt.md' workflows/research.md && echo "REQUIRED READING OK"

# SKILL.md route wired
grep -q 'route id="research"' SKILL.md && echo "ROUTING OK"

# K001 and K002
lines=$(wc -l < SKILL.md); [ "$lines" -lt 500 ] && echo "LINE COUNT OK ($lines)"
headings=$(grep -c '^#' SKILL.md || true); [ "$headings" -eq 0 ] && echo "NO MD HEADINGS OK"

# Synthesis route still present (not accidentally removed)
grep -q 'S03 will add\|synthesis' SKILL.md && echo "SYNTHESIS PLACEHOLDER OK"
```

## Inputs

- `SKILL.md` — contains the `<!-- S02 will add: ... -->` placeholder to replace; must read exact text before editing
- `references/subagent-prompt.md` — T01 output; research.md references this by path in Phase 2
- `references/output-contract.md` — T01 output (S02→S03 section); research.md emits a `ResearchOutputPackage` matching this schema

## Expected Output

- `workflows/research.md` — new file; 4-phase research orchestration workflow with parallel subagent dispatch
- `SKILL.md` — modified; `<!-- S02 will add: ... -->` comment replaced with live `<route id="research">` block
