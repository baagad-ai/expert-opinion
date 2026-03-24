---
estimated_steps: 4
estimated_files: 2
skills_used:
  - writing-skills
---

# T02: Author intake workflow and SKILL.md router

**Slice:** S01 — Intake & Role Identification
**Milestone:** M001

## Description

Creates the two executable files that make the skill invocable: `workflows/intake.md` (the 6-phase intake orchestration workflow) and `SKILL.md` (the GSD skill router). Both files depend on T01's output existing at their expected paths — intake.md references the templates and reference files by path, and SKILL.md routes to intake.md.

The intake workflow is the heart of S01: it handles all four input types, infers context, proposes expert roles, gates on user confirmation, and emits the typed output package that S02 consumes. SKILL.md is intentionally thin — it is a router plus essential principles, nothing more. Heavy content stays in references/ per K002.

All paths are relative to the worktree root (which is the project root). There is no `expert-opinion/` subdirectory — `SKILL.md` lives at the root, `workflows/intake.md` at `workflows/intake.md`, etc.

Key constraint: role identification is pure in-context LLM inference. No web searches in the intake workflow. No external API keys.

## Steps

1. Write `workflows/intake.md` covering all 6 phases in order:

   **Phase 1 — Detect input type**: Apply the detection rules from `references/input-handling.md` to classify user input as `text`, `file`, `codebase`, or `url`.

   **Phase 2 — Normalize input**: Read/fetch the artifact using the appropriate tool per `references/input-handling.md`. For large inputs, apply the truncation strategy (cap at ~6000 tokens; populate `summary` and `file_tree` fields). For codebase inputs, log which files were selected and why.

   **Phase 3 — Infer context**: From the normalized content, determine `purpose`, `domain`, and `audience`. These become `inferred_context` in the output package.

   **Phase 4 — Generate role proposal**: Propose 5–10 expert roles whose perspective would materially improve the artifact. For each role, generate 2–4 focus questions specific to this artifact (not generic). Format each role entry using `templates/role-proposal.md`. Do NOT use web search — pure LLM inference from artifact content.

   **Phase 5 — User confirmation gate**: Present the formatted role list via `ask_user_questions` with three options: "Confirm all", "Edit (describe changes)", "Cancel". If "Edit", ask a follow-up free-text question for the edit description, apply edits, and re-present (loop). If "Cancel", stop. Fallback: if `ask_user_questions` is unavailable, present roles as markdown and ask for a reply.

   **Phase 6 — Emit output package**: Assemble and emit the output package per `references/output-contract.md`, populating all three top-level keys: `confirmed_roles`, `normalized_input`, `inferred_context`. This is consumed directly by `workflows/research.md` in S02.

   Include `<required_reading>` tags at the top of the file referencing `references/input-handling.md` and `references/output-contract.md`.

2. Write `SKILL.md` as the GSD skill router. Structure:
   - YAML frontmatter (between `---` delimiters): `name`, `description`, `version` (0.1.0), `author`
   - Body: pure XML tags only — no markdown headings (`#`, `##`, `###`) anywhere in the body per K001
   - `<essential_principles>`: parallel architecture (research runs in parallel subagents, never sequentially), depth bar (every finding needs evidence — surface-level is not acceptable), confirmation gate (user must confirm roles before any research begins)
   - `<intake>`: the opening question asking the user what artifact or topic they'd like expert review of
   - `<routing>`: maps user intent to `workflows/intake.md`; design the routing block so additional routes (research, synthesis) can be added in S02/S03 without structural changes to this file
   - Total line count must be under 500 (K002)

3. Run the verification commands to confirm both files pass all checks.

## Must-Haves

- [ ] `workflows/intake.md` covers all 6 phases: detect → normalize → infer → propose → confirm → emit
- [ ] `workflows/intake.md` includes `<required_reading>` referencing `references/input-handling.md` and `references/output-contract.md`
- [ ] `workflows/intake.md` uses `ask_user_questions` for the confirmation gate with three options
- [ ] `workflows/intake.md` does NOT include web searches (role identification is pure in-context LLM inference)
- [ ] `SKILL.md` has valid YAML frontmatter parseable by `yaml.safe_load`
- [ ] `SKILL.md` body contains zero markdown headings (no lines starting with `#`)
- [ ] `SKILL.md` is under 500 lines
- [ ] `SKILL.md` routes to `workflows/intake.md`
- [ ] `SKILL.md` routing block is extensible — additional routes can be added in S02/S03 without structural changes

## Verification

- `python3 -c "import yaml; yaml.safe_load(open('SKILL.md').read().split('---')[1]); print('YAML OK')"` — must print `YAML OK`
- `wc -l SKILL.md | awk '{if($1<500) print "LINE COUNT OK "$1; else {print "FAIL: "$1" lines"; exit 1}}'`
- `test $(grep -c '^#' SKILL.md) -eq 0 && echo "NO MD HEADINGS OK"`
- `grep -q 'workflows/intake.md' SKILL.md && echo "ROUTING OK"`
- `grep -q 'references/output-contract.md' workflows/intake.md && echo "CONTRACT REF OK"`
- `grep -q 'references/input-handling.md' workflows/intake.md && echo "INPUT-HANDLING REF OK"`
- `grep -q 'ask_user_questions' workflows/intake.md && echo "CONFIRMATION GATE OK"`
- `test -f workflows/intake.md && test -f SKILL.md && echo "BOTH FILES PRESENT"`

## Inputs

- `templates/expert-report.md` — exists from T01; referenced by intake workflow
- `templates/role-proposal.md` — exists from T01; intake.md uses this format for presenting roles
- `references/output-contract.md` — exists from T01; intake.md emits output per this schema
- `references/input-handling.md` — exists from T01; intake.md follows this for normalization
- `.gsd/milestones/M001/slices/S01/S01-RESEARCH.md` — full specification of both files including pitfalls to avoid

## Expected Output

- `workflows/intake.md` — 6-phase intake workflow: detects input type, normalizes, infers context, proposes roles, gates on user confirmation, emits typed output package
- `SKILL.md` — GSD skill router with valid YAML frontmatter, XML-only body under 500 lines, essential principles, and routing to intake.md
