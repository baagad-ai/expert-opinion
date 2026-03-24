# S01: Intake & Role Identification — Research

**Date:** 2026-03-24

## Summary

S01 builds the skill's entry point: a router-pattern GSD skill that accepts any input type, normalizes it, infers context, proposes expert roles, gates on user confirmation, and emits a typed output package for S02. The slice also authors the three shared templates that downstream slices (S02, S03) code against — which means their correctness is a critical dependency, not a secondary deliverable.

The project is a blank slate (just a git init). Everything — directory tree, SKILL.md, all workflows, all templates — gets created here. The design is fully specified in S01-CONTEXT.md; this research surfaces the precise build order, the file-level seams, and the verification approach.

K001/K002 (no markdown headings, SKILL.md under 500 lines) and P001 (router pattern) apply directly. The router pattern is the right call given three clearly distinct workflow phases and essential principles that must not be skippable.

## Recommendation

Build in this order: directory structure → shared templates (expert-report, synthesis-doc, role-proposal) → intake workflow → SKILL.md router. Templates first because the intake workflow references them and the planner agent for S02 needs to be able to read them. SKILL.md last because it routes to the intake workflow and should reference the final file names.

Treat the output package format (the JSON-like structure in the boundary map) as a pseudo-type contract — write it explicitly in `references/output-contract.md` so every downstream agent can cite it verbatim.

## Implementation Landscape

### Key Files to Create

The full file tree for this slice:

```
expert-opinion/                    ← project root
├── SKILL.md                       ← router: frontmatter + essential principles + routing
├── workflows/
│   └── intake.md                  ← primary executable workflow for S01
├── templates/
│   ├── expert-report.md           ← per-subagent findings template (S02 consumes)
│   ├── synthesis-doc.md           ← final output template (S03 consumes)
│   └── role-proposal.md           ← role proposal display format (intake uses)
└── references/
    ├── input-handling.md          ← how to handle text / file / codebase / URL inputs
    └── output-contract.md         ← exact structure of S01 → S02 output package
```

No existing files exist in the project root (git init only). All files created fresh.

### File Responsibilities

- **`SKILL.md`** — YAML frontmatter + `<essential_principles>` (parallel architecture, depth bar, confirmation gate) + `<intake>` question + `<routing>` block mapping user intent to `workflows/intake.md`. Must stay under 500 lines. No markdown headings in body (K001).

- **`workflows/intake.md`** — The executable workflow. Covers: (1) detect input type, (2) read/normalize input per type, (3) infer context (purpose / domain / audience), (4) generate role proposal using `templates/role-proposal.md`, (5) present to user with `ask_user_questions`, (6) parse confirmation + edits, (7) emit output package per `references/output-contract.md`. Load instructions reference `references/input-handling.md` and `references/output-contract.md`.

- **`templates/expert-report.md`** — Markdown template with XML sections: `<role_identity>`, `<executive_summary>`, `<findings>` (severity: critical/major/minor/informational), `<recommendations>` (prioritized), `<open_questions>`. Each finding must include: observation, evidence (quote or location), severity, impact. K003 applies: subagents need role identity + focus questions + this template to produce deep output.

- **`templates/synthesis-doc.md`** — Markdown template for the final audit document: overview section, per-role highlights (brief), cross-cutting findings, prioritized recommendation table, open questions. K004 applies: synthesis is not concatenation — the template must structure for convergence/contradiction/priority.

- **`templates/role-proposal.md`** — Display template for the confirmation UX. Each role entry shows: role name, domain, and 2–3 specific focus questions tailored to the current artifact. Includes the confirmation prompt text.

- **`references/input-handling.md`** — Decision table for input types: how to detect (inline text vs path vs URL), how to read (read tool / bash for codebase scan / fetch_page), large-input handling strategy (structured summary + excerpts cap at ~20 files / ~6000 tokens), URL failure fallback (< 200 words → warn + re-prompt).

- **`references/output-contract.md`** — Canonical typed definition of the S01 → S02 output package:
  ```
  confirmed_roles: Array<{
    role: string
    domain: string
    focus_questions: string[]   // 2-4 questions specific to this input
    rationale: string           // why this role is relevant to this artifact
  }>
  normalized_input: {
    type: "text" | "file" | "codebase" | "url"
    content: string             // full text if small, key excerpts if large
    summary?: string            // present when input was summarized
    file_tree?: string          // present when type == "codebase"
  }
  inferred_context: {
    purpose: string             // e.g. "REST API for mobile client authentication"
    domain: string              // e.g. "backend code", "technical writing", "business plan"
    audience: string            // e.g. "internal developers", "end users", "investors"
  }
  ```

### Build Order

1. **Create directory structure** (`mkdir -p workflows/ templates/ references/`) — unblocks everything else.

2. **Write `templates/expert-report.md`** — defines the output contract that S02 subagents use. Planner for S02 can start reading this immediately after S01. Most critical to get right.

3. **Write `templates/synthesis-doc.md`** — defines what S03 produces. Planner for S03 can start reading this.

4. **Write `templates/role-proposal.md`** — defines the UX format for role confirmation. Intake workflow must reference this.

5. **Write `references/output-contract.md`** — typed definition of S01 → S02 handoff. Intake workflow emits this; S02 consumes it.

6. **Write `references/input-handling.md`** — intake workflow reads this for normalization logic.

7. **Write `workflows/intake.md`** — the executable workflow that uses all templates and references above.

8. **Write `SKILL.md`** — router that references `workflows/intake.md`. Written last so it references real, stable file names.

### Verification Approach

After writing all files:

1. **Structure check**: `find . -not -path './.git*' -not -path './.gsd*' | sort` — confirms all 8 files exist at correct paths.

2. **YAML frontmatter validity**: `python3 -c "import yaml; yaml.safe_load(open('SKILL.md').read().split('---')[1])"` — confirms valid frontmatter.

3. **Line count**: `wc -l SKILL.md` — must be < 500.

4. **No markdown headings in XML body**: `grep -n '^#' SKILL.md` — should return zero matches inside the body (headings only appear in templates, not in SKILL.md body itself).

5. **All `required_reading` references exist**: For each file listed in `workflows/intake.md`'s `<required_reading>`, verify the path exists.

6. **Output contract smoke test**: Mentally trace a "user pastes a Python file" invocation through `workflows/intake.md` — confirm it reaches the `ask_user_questions` step, collects confirmation, and emits the structured output package format from `references/output-contract.md`.

## Constraints

- SKILL.md body: pure XML tags, no markdown headings (K001). Markdown formatting (bold, lists, code blocks) is fine within content.
- SKILL.md: under 500 lines (K002). Move any content that exceeds this to references/.
- All tools used in `workflows/intake.md` must be standard GSD tool suite: `read`, `bash`, `fetch_page`, `ask_user_questions` — no external API keys (R010, D006).
- Templates must be stable enough for S02 and S03 to code against — structural revision in downstream slices would be a regression. Get the field names right here.
- The skill lives in the project root (`expert-opinion/`), not in a `~/.gsd/` subdirectory — it's project-local. Installation for users is via copy (D001).

## Common Pitfalls

- **Templates too generic** — `expert-report.md` with just "findings" and "recommendations" as fields produces shallow outputs. Require severity-classified findings with evidence fields. K003 is the safest guard: subagents that receive a template with no severity structure will produce a flat list.
- **Intake workflow tries to do web research** — role identification is in-context inference only (per S01-CONTEXT.md Out of Scope). No web searches in intake. This also satisfies R010.
- **Output package underdefined** — if `references/output-contract.md` is vague, S02 will guess at the format. Write it as a typed schema, not prose.
- **ask_user_questions for confirmation** — the open question in S01-CONTEXT.md about structured vs free-text: use a single `ask_user_questions` call that shows the role list as formatted markdown in the question text, with options: "Confirm all", "Edit (describe changes)", "Cancel". If user selects "Edit", follow up with a free-text prompt for the edit description, then re-present the updated list. This gives structured UX without losing the ability to add/remove roles.
- **SKILL.md routing** — the router must route to `workflows/intake.md` for the single workflow. Don't add complexity here: S01 has one workflow (intake). S02 and S03 add more. The SKILL.md written in S01 should be designed to have new routes added in later slices without structural changes.

## Open Risks

- **Large codebase context budget** — the 20-file / ~6000-token cap for codebase inputs is a heuristic. If a codebase has no README or obvious entry points, the scan heuristic may pick poor representative files. The intake workflow should log which files it selected and why, so the user can override if the selection looks wrong.
- **ask_user_questions tool availability** — some GSD environments may not have this tool. The workflow should note: if unavailable, fall back to presenting roles as a markdown list and asking user to reply with edits. Don't hard-fail.
