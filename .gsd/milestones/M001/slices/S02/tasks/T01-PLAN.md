---
estimated_steps: 4
estimated_files: 2
skills_used:
  - writing-skills
---

# T01: Write subagent prompt template and extend output contract

**Slice:** S02 — Parallel Research Engine
**Milestone:** M001

## Description

The subagent prompt template (`references/subagent-prompt.md`) is the primary quality lever for the entire skill. It defines the four-component structure (K003) that every expert subagent must receive: role identity, input artifact, role-specific focus questions, and the output template reference. Without a precise template, executors writing `workflows/research.md` will improvise prompt construction inline — producing vague prompts that yield generic, low-value output (the #1 risk from the roadmap).

This task also appends the S02→S03 output contract to `references/output-contract.md`. T02 needs a typed schema for what research.md emits — defining it here gives T02 a concrete target and avoids ad-hoc format decisions during orchestration authoring.

## Steps

1. Read `references/output-contract.md` and `templates/expert-report.md` to understand canonical field names and report structure before authoring anything.

2. Write `references/subagent-prompt.md` with:
   - A `<prompt_template>` section containing the full task text sent to each expert subagent. Must include ALL four K003 components:
     - **Role identity**: subagent introduces itself as `{role}` with domain `{domain}` and rationale `{rationale}`
     - **Input artifact**: full `normalized_input.content`; if `normalized_input.summary` is present, include it first as high-level context before the content
     - **Focus questions**: the specific `focus_questions` array for THIS role only (not all roles)
     - **Domain research instructions**: explicit instruction to search for current best practices, known failure modes, relevant standards, and precedents in the role's domain — not just pattern-match against the artifact
   - A `<fill_instructions>` section explaining how the orchestrator substitutes `{role}`, `{domain}`, `{focus_questions}`, `{content}`, `{summary}` placeholders
   - A `<output_instructions>` section referencing `templates/expert-report.md` by path and instructing the subagent to fill every section including severity-annotated findings grounded in evidence (quote, file:line, or specific observation)
   - A `<large_input_note>` explaining that when `summary` is present the subagent should use it as the primary frame and spot-read excerpts rather than requiring every line verbatim

3. Append a new section to `references/output-contract.md` titled `## S02 → S03 Output Contract` defining:
   ```typescript
   interface ResearchOutputPackage {
     reports: ExpertReport[];
     metadata: ResearchMetadata;
   }
   interface ExpertReport {
     role: string;         // matches ConfirmedRole.role
     domain: string;       // matches ConfirmedRole.domain
     report: string;       // full text of the completed expert-report.md template
     missing_sections: string[]; // empty array if all sections present; else names of missing sections
   }
   interface ResearchMetadata {
     total_roles: number;
     completed_roles: number;
     inferred_context: InferredContext; // passed through from IntakeOutputPackage
   }
   ```
   Include emission rules: research.md must collect ALL parallel outputs before emitting; emit verbatim (do not repair missing sections — flag them in `missing_sections`); include `inferred_context` pass-through for S03.

4. Verify all checks in the Verification section pass.

## Must-Haves

- [ ] `references/subagent-prompt.md` exists and contains all four K003 components
- [ ] Domain research instruction explicitly mentions searching for best practices AND failure modes (R004)
- [ ] Large-input note explains `summary`-first framing when summary field is present
- [ ] S02→S03 typed schema appended to `references/output-contract.md` with `ResearchOutputPackage` interface
- [ ] `missing_sections` field defined — subagents don't repair, they flag
- [ ] `inferred_context` pass-through specified in `ResearchMetadata`

## Verification

```bash
test -f references/subagent-prompt.md && echo "FILE EXISTS"
grep -q 'focus_questions' references/subagent-prompt.md && echo "FOCUS QUESTIONS OK"
grep -q 'expert-report.md' references/subagent-prompt.md && echo "TEMPLATE REF OK"
grep -q 'domain research\|best practices\|failure modes' references/subagent-prompt.md && echo "DOMAIN RESEARCH OK"
grep -q 'summary' references/subagent-prompt.md && echo "SUMMARY HANDLING OK"
grep -q 'ResearchOutputPackage' references/output-contract.md && echo "S02-S03 CONTRACT OK"
grep -q 'missing_sections' references/output-contract.md && echo "MISSING SECTIONS FIELD OK"
grep -q 'inferred_context' references/output-contract.md && echo "CONTEXT PASSTHROUGH OK"
```

## Observability Impact

**Signals created by this task:**

1. `references/subagent-prompt.md` becomes inspectable — any future agent executing S02 can `read` this file to see the exact four-component task text sent to each expert subagent. If expert output quality is low, this is the first file to audit.
2. `references/output-contract.md` gains a typed `ResearchOutputPackage` schema — T02 and S03 use it as the authoritative API contract; if field names drift, the contract file is the ground truth.
3. `missing_sections` field in `ExpertReport` creates a structured failure signal — at runtime, incomplete subagent outputs surface as named missing sections rather than silent bad data flowing to S03.

**How a future agent inspects this task's outputs:**
- `grep -c 'prompt_template\|fill_instructions\|output_instructions\|large_input_note' references/subagent-prompt.md` — should return 4; any lower count means a required section is absent
- `grep 'ResearchOutputPackage\|ExpertReport\|ResearchMetadata\|missing_sections\|inferred_context' references/output-contract.md` — all five terms should match; absence of any reveals which contract field is missing

**Failure state visibility:**
- Verification commands in the Must-Haves section are self-diagnosing: each `grep -q ... && echo "OK"` either fires or is silent, pinpointing exactly which component is absent without inspecting the full file

## Inputs

- `references/output-contract.md` — canonical S01→S02 field names (`confirmed_roles`, `normalized_input`, `inferred_context`); append S02→S03 section here
- `templates/expert-report.md` — the output template every subagent must fill; referenced by path in the prompt

## Expected Output

- `references/subagent-prompt.md` — new file; expert subagent task template with four K003 components, domain research instructions, and output instructions
- `references/output-contract.md` — modified; S02→S03 `ResearchOutputPackage` schema appended to end of file
