# S02: Parallel Research Engine

**Goal:** Consume the `IntakeOutputPackage` emitted by S01, dispatch one expert subagent per confirmed role in parallel, collect structured expert reports conforming to `templates/expert-report.md`, and emit an array of reports ready for S03 synthesis.
**Demo:** After T01 and T02 complete, structural verification commands all pass: `workflows/research.md` exists, references `subagent` in parallel mode, cites `templates/expert-report.md`, passes the role's `focus_questions` individually, and `SKILL.md` routes to `workflows/research.md` with zero markdown headings and under 500 lines.

## Must-Haves

- `references/subagent-prompt.md` exists and covers all four K003 components: role identity, input artifact, role-specific focus questions, and `templates/expert-report.md` output template
- Each subagent prompt includes explicit domain research instructions (search best practices, known failure modes, relevant standards) — not just pattern-match against the artifact
- `workflows/research.md` dispatches all subagents using the `subagent` tool in **parallel mode** (`tasks: [...]`), not sequentially
- Each subagent receives only **its own role's** `focus_questions` (not the full array)
- When `normalized_input.summary` is present, subagents receive both `summary` and `content`
- S02→S03 output contract is documented in `references/output-contract.md`
- `SKILL.md` research route is live (not commented out) and points to `workflows/research.md`
- `SKILL.md` remains under 500 lines with zero markdown headings in body

## Proof Level

- This slice proves: contract — structural integrity of research orchestration files
- Real runtime required: no (static markdown skill files verified by grep/wc)
- Human/UAT required: no

## Verification

```bash
# File existence
test -f workflows/research.md && echo "research.md present"
test -f references/subagent-prompt.md && echo "subagent-prompt.md present"

# Parallel execution explicitly specified
grep -q 'parallel' workflows/research.md && echo "PARALLEL OK"

# Subagent tool invoked
grep -q 'subagent' workflows/research.md && echo "SUBAGENT DISPATCH OK"

# Expert report template referenced
grep -q 'templates/expert-report.md' workflows/research.md && echo "TEMPLATE REF OK"

# K003: focus questions and input artifact referenced in research workflow
grep -q 'focus_questions' workflows/research.md && echo "FOCUS QUESTIONS OK"
grep -q 'normalized_input' workflows/research.md && echo "INPUT ARTIFACT OK"

# summary field passed when present
grep -q 'summary' workflows/research.md && echo "SUMMARY FIELD OK"

# SKILL.md routing updated (live route, not comment)
grep -q 'route id="research"' SKILL.md && echo "ROUTING OK"

# K001 and K002 compliance
lines=$(wc -l < SKILL.md); [ "$lines" -lt 500 ] && echo "LINE COUNT OK ($lines lines)"
headings=$(grep -c '^#' SKILL.md || true); [ "$headings" -eq 0 ] && echo "NO MD HEADINGS OK"

# S02→S03 contract appended
grep -q 'ExpertReportPackage\|S02.*S03\|research_output' references/output-contract.md && echo "S02-S03 CONTRACT OK"

# subagent-prompt references all K003 components
grep -q 'role_identity\|role identity' references/subagent-prompt.md && echo "ROLE IDENTITY OK"
grep -q 'focus_questions' references/subagent-prompt.md && echo "FOCUS QUESTIONS IN PROMPT OK"
grep -q 'domain research\|best practices\|failure modes' references/subagent-prompt.md && echo "DOMAIN RESEARCH OK"
grep -q 'expert-report.md' references/subagent-prompt.md && echo "TEMPLATE REF IN PROMPT OK"
```

## Observability / Diagnostics

Since this slice produces static markdown files (not a running service), observability here means **inspectability of the skill contract** rather than runtime telemetry.

**Inspection surfaces:**
- `references/subagent-prompt.md` — human-readable; any agent can `read` it to see exactly what text will be sent to each expert subagent
- `references/output-contract.md` — typed schemas for S01→S02 and S02→S03 boundaries; acts as the shared API doc for the whole pipeline
- `workflows/research.md` — the orchestration workflow; `grep`-auditable for correct parallel dispatch, focus_question per-role slicing, and summary-first handling

**Failure visibility:**
- If a subagent returns a malformed report at runtime, `missing_sections` in `ExpertReport` surfaces which template sections were omitted — the orchestrator does NOT silently discard or repair them
- If `normalized_input.summary` is absent but `content` is large, the subagent-prompt template includes a `<large_input_note>` instructing the subagent to handle it gracefully rather than fail silently
- Verification commands in the Verification section function as diagnostic assertions: any `echo` that does not fire indicates precisely which contract point is broken

**Redaction constraints:**
- No secrets, credentials, or PII appear in any artifact in this slice; all fields are structural schema or user-supplied artifact text (which the user controls)

**Failure-path diagnostic check:**
```bash
# Diagnose which K003 component is missing from subagent-prompt.md
for component in 'role_identity\|role identity' 'focus_questions' 'normalized_input\|input artifact' 'expert-report.md'; do
  grep -q "$component" references/subagent-prompt.md \
    && echo "PRESENT: $component" \
    || echo "MISSING: $component"
done
```

## Integration Closure

- Upstream surfaces consumed: `references/output-contract.md` (field names `confirmed_roles`, `normalized_input`, `inferred_context`), `templates/expert-report.md` (subagent output structure)
- New wiring introduced in this slice: live `<route id="research">` in SKILL.md pointing to `workflows/research.md`; `references/subagent-prompt.md` as the per-role task construction template
- What remains before the milestone is truly usable end-to-end: S03 synthesis workflow + SKILL.md synthesis route

## Tasks

- [x] **T01: Write subagent prompt template and extend output contract** `est:45m`
  - Why: The subagent prompt template is the primary quality lever for the whole slice. Output quality variance is the top risk in the roadmap — vague prompts produce generic output. The S02→S03 contract must be documented before T02 can specify what research.md emits.
  - Files: `references/subagent-prompt.md`, `references/output-contract.md`
  - Do: Write `references/subagent-prompt.md` covering all four K003 components; include explicit domain research instructions (R004); specify large-input handling (pass summary + content when summary present); reference `templates/expert-report.md` by path; then append S02→S03 output contract section to `references/output-contract.md` defining the `ResearchOutputPackage` as a typed schema.
  - Verify: `test -f references/subagent-prompt.md && grep -q 'focus_questions' references/subagent-prompt.md && grep -q 'expert-report.md' references/subagent-prompt.md && grep -q 'domain research\|best practices\|failure modes' references/subagent-prompt.md && grep -q 'ResearchOutputPackage\|S02.*S03' references/output-contract.md && echo "T01 OK"`
  - Done when: `subagent-prompt.md` exists with all four K003 components and domain research instructions; `output-contract.md` contains a typed S02→S03 schema section

- [x] **T02: Write research orchestration workflow and wire SKILL.md route** `est:45m`
  - Why: research.md is the executable orchestration that the executor follows when the research route is triggered. SKILL.md must be updated so the route is live. Together these close the S02 contract boundary.
  - Files: `workflows/research.md`, `SKILL.md`
  - Do: Write `workflows/research.md` as a 4-phase orchestration: (1) receive + validate `IntakeOutputPackage`, (2) construct per-role subagent task using `references/subagent-prompt.md` template, (3) dispatch all subagents in parallel using the `subagent` tool with `tasks: [...]` parallel-mode signature, (4) collect all reports and emit a `ResearchOutputPackage`. Then edit `SKILL.md` to replace the `<!-- S02 will add: ... -->` comment block with a live `<route id="research">` pointing to `workflows/research.md`. Verify SKILL.md stays under 500 lines with zero markdown headings.
  - Verify: `grep -q 'parallel' workflows/research.md && grep -q 'subagent' workflows/research.md && grep -q 'focus_questions' workflows/research.md && grep -q 'normalized_input' workflows/research.md && grep -q 'route id="research"' SKILL.md && echo "T02 OK"`
  - Done when: `workflows/research.md` exists with all 4 phases and explicit parallel dispatch; SKILL.md research route is live; line count < 500 and heading count == 0

## Files Likely Touched

- `references/subagent-prompt.md`
- `references/output-contract.md`
- `workflows/research.md`
- `SKILL.md`
