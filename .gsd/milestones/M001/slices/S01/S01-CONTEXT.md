---
id: S01
milestone: M001
status: ready
---

# S01: Intake & Role Identification — Context

## Goal

Accept any user input (inline text, file path, codebase directory, or URL), analyze and normalize it, infer its purpose/domain/audience, propose 5–10 targeted expert roles with input-specific audit focus, confirm with the user (allowing edits in the same message), and emit a structured output package ready for S02 dispatch.

## Why this Slice

S01 is the foundation everything else depends on. S02 can't run without the confirmed role list and normalized input. S03 can't run without S02. This slice also defines the shared templates (expert-report.md, synthesis-doc.md, role-proposal format) that S02 and S03 consume — writing them here means those slices are not blocked by template ambiguity.

## Scope

### In Scope

- **Flexible invocation**: Accept input in any of three ways — (a) user invokes skill and pastes/types content inline, (b) user provides a file path or directory, (c) user provides a URL. Intake detects which mode is active and handles accordingly.
- **Input normalization**: For text/paste → use directly. For file → read and summarize if large. For codebase directory → identify structural key files (package.json, README, entry points, config files, a representative sample of source files) and produce a structured summary + excerpts. For URL → fetch and extract readable content. Output: normalized text artifact ≤ a sensible context budget.
- **Large input handling**: If input exceeds a threshold where passing it whole to each subagent would blow context, produce a structured summary of the full input + the most relevant excerpts. Each subagent receives this package, not the raw full input.
- **Context inference**: Before proposing roles, intake infers: (a) primary purpose of the artifact (e.g. "REST API for mobile client authentication"), (b) domain/category (code, writing, business plan, design, etc.), (c) intended audience (e.g. "internal developers", "end users", "investors"). This context is attached to the output package and passed to every subagent.
- **Role proposal**: Agent proposes 5–10 expert roles based on input content + inferred context. Each role in the proposal shows: role name, domain, and specifically what they will audit in this input (not a generic job description — tailored to the artifact). This is the input-specific focus.
- **Role confirmation UX**: Use appropriate GSD tool calls (ask_user_questions) for the best UX. User can confirm + add/remove in a single response: e.g. "yes, and add a performance engineer, remove role 4". Agent parses the intent and proceeds. Explicit confirmation is required — silence is not confirmation.
- **Role count**: Default 5–10. No hard cap enforced in code but intake targets this range. Not user-configurable in M001.
- **Shared template authoring**: S01 writes the three shared templates other workflows depend on:
  - `templates/expert-report.md` — per-subagent findings structure (role, findings by severity, recommendations)
  - `templates/synthesis-doc.md` — final output document structure
  - `templates/role-proposal.md` — the format shown to the user during confirmation
- **Output contract**: Emit a structured package (confirmed role list + normalized input artifact + inferred context) in the exact format S02 expects per the boundary map.

### Out of Scope

- No web research during intake — role identification is based on the input content + LLM inference, not external lookups
- No partial confirmation — if the user says nothing intelligible, re-prompt; don't auto-proceed
- No role taxonomy reference in S01 — that is M002/S01. S01 uses pure in-context LLM reasoning for role identification. The taxonomy is added later as a quality improvement.
- No synthesis, no research dispatch — this slice ends at confirmed roles + normalized input
- No persistence of the output package to disk — it's passed in-context to S02

## Constraints

- Must work with GSD's standard tool set (file read, bash, fetch_page for URLs) — no external API keys
- Skill file structure must be valid GSD skill format from day one (valid YAML frontmatter, XML body, SKILL.md under 500 lines)
- Role proposal UX uses `ask_user_questions` where GSD tooling supports it — optimize for best UX, not just functional correctness
- Inferred context (purpose/domain/audience) must be explicit and human-readable — not a black box internal state; the user should be able to see it as part of the role proposal or just before it
- Templates written in S01 must be stable enough for S02 and S03 to code against — they should not need structural revision in downstream slices

## Integration Points

### Consumes

- User's raw input (inline text, file path, directory path, or URL) — provided at skill invocation or in response to intake prompt
- GSD tool suite: `read` (file content), `bash` (codebase structure scan), `fetch_page` (URL content), `ask_user_questions` (confirmation UX)

### Produces

- `templates/expert-report.md` — per-subagent findings template (consumed by S02)
- `templates/synthesis-doc.md` — final output document template (consumed by S03)
- `templates/role-proposal.md` — role proposal display format (used by intake workflow itself)
- `workflows/intake.md` — the executable intake workflow (consumed by SKILL.md router)
- Structured output package (in-context, passed to S02):
  - `confirmed_roles: [{ role, domain, focus_questions[], rationale }]`
  - `normalized_input: { type, content, summary?, excerpts? }`
  - `inferred_context: { purpose, domain, audience }`

## Open Questions

- **Codebase scan depth** — for a large directory, what heuristic decides which files are "key"? Current thinking: read directory tree first, then prioritize README, package.json / pyproject.toml / Cargo.toml, entry points, and a sample of source files weighted toward the most recently modified. Cap at ~20 files for the excerpt package.
- **URL content quality** — fetch_page returns clean markdown but some pages are login-gated or JS-rendered and return near-empty content. Current thinking: if fetched content is < 200 words, surface a warning and ask the user if they want to paste the content manually instead.
- **What does "explicit confirmation" mean if the user uses ask_user_questions** — the tool itself waits for a response, so confirmation is structurally enforced. The question is whether to present the confirmation as a structured multiple-choice (harder to add edits) or as a free-text prompt (easier for "remove 3, add legal"). Current thinking: show role list as formatted markdown, then use a text input or structured confirm. The user note says "use appropriate tool calls for best UX" — resolve this during task planning for T02 or T03.
