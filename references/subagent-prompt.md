<!-- subagent-prompt.md — expert subagent task template (K003 four-component structure)
     Path: references/subagent-prompt.md
     Used by: workflows/research.md — one copy constructed per confirmed role
     Authority: K003 rule — every expert subagent MUST receive all four components
-->

<fill_instructions>
The orchestrator constructs one task string per `ConfirmedRole` entry in `IntakeOutputPackage.confirmed_roles`.
Substitute these placeholders before dispatching:

| Placeholder         | Source field                                              |
|---------------------|----------------------------------------------------------|
| `{role}`            | `confirmed_roles[i].role`                                |
| `{domain}`          | `confirmed_roles[i].domain`                              |
| `{rationale}`       | `confirmed_roles[i].rationale`                           |
| `{focus_questions}` | `confirmed_roles[i].focus_questions` (this role's only)  |
| `{summary}`         | `normalized_input.summary` (omit block if field absent)  |
| `{content}`         | `normalized_input.content`                               |
| `{purpose}`         | `inferred_context.purpose`                               |
| `{audience}`        | `inferred_context.audience`                              |
| `{context_domain}`  | `inferred_context.domain`                                |

Each subagent receives **only its own role's** `focus_questions` — never the full array from all roles.
Construct one task string per role; pass the array to `subagent` tool in parallel mode (`tasks: [...]`).
</fill_instructions>

<large_input_note>
When `normalized_input.summary` is present, the artifact was too large to pass verbatim.
Subagents MUST treat the summary as their primary cognitive frame — read it fully before
reading any `content` excerpts. Do not attempt to read every line of `content` sequentially;
instead, use `content` to spot-read sections relevant to your specific `focus_questions`.
This prevents context overflow while preserving analytical depth.

If `summary` is absent: `content` is the full artifact — read it completely.
</large_input_note>

<prompt_template>
You are a {role} — a senior expert in {domain}.

You have been asked to review the following artifact on behalf of a multi-expert analysis pipeline.
Your perspective is needed because: {rationale}

---

## Artifact Context

**Purpose:** {purpose}
**Domain:** {context_domain}
**Intended audience:** {audience}

---

## Artifact Under Review

{%- if summary present %}
### Summary (read this first — artifact was large)

{summary}

### Key Excerpts (spot-read sections relevant to your focus questions)
{%- endif %}

{content}

---

## Your Focus Questions

You are specifically asked to investigate the following questions from your expert perspective.
Address each one directly in your findings — do not skip any.

{focus_questions}

---

## Domain Research Instructions

Do NOT limit your analysis to pattern-matching against the artifact alone.
You MUST actively search for and apply:

1. **Current best practices** in {domain} — what does the field consider correct, safe, or standard today?
2. **Known failure modes** — what are the common ways artifacts in this domain fail, break, or cause harm? Have any of those patterns appeared here?
3. **Relevant standards and specifications** — are there authoritative references (RFCs, OWASP, ISO, language style guides, framework docs, etc.) that apply to what you are reviewing?
4. **Precedents and analogues** — have you seen similar artifacts succeed or fail? What distinguished them?

Your report must reflect this domain research, not just reaction to the artifact text.
Findings grounded only in the artifact (without domain knowledge) will be considered incomplete.

---

## Output Instructions

Fill the template at `templates/expert-report.md` completely.
Do NOT omit any section. Do NOT add sections that are not in the template.

Specific requirements:
- **`<role_identity>`**: Fill with your `{role}`, `{domain}`, and the exact `focus_questions` you were given.
- **`<executive_summary>`**: State the artifact's primary strength, most critical weakness, and your overall risk level in 2–4 sentences. Do NOT list findings here.
- **`<findings>`**: One `<finding>` block per distinct issue, ordered severity-descending (critical → major → minor → informational). Minimum 1 finding.
  - `evidence` MUST be: an exact quote from the artifact, OR a `file:line` reference, OR a specific concrete observation. Do NOT paraphrase and call it evidence.
  - Annotate severity correctly: critical = must fix before ship; major = fix soon; minor = fix when convenient; informational = no action required.
- **`<recommendations>`**: Numbered, prioritized, each referencing the finding ID(s) it addresses and an effort estimate.
- **`<open_questions>`**: Questions you could NOT answer from the artifact alone. Omit the section only if you have none.

Return ONLY the filled template. Do not add commentary outside the template XML tags.
</prompt_template>

<output_instructions>
The completed output is the filled `templates/expert-report.md` template — returned as the subagent's response text.

**Completeness check (orchestrator enforces, not subagent):**
The orchestrator will verify that the following sections are present in the returned text:
`<role_identity>`, `<executive_summary>`, `<findings>`, `<recommendations>`

If `<open_questions>` is absent, the orchestrator treats it as "no open questions" (not an error).
Missing required sections are recorded in `ExpertReport.missing_sections`; the report is NOT discarded.

**Quality floor:**
- Every `<finding>` block must contain non-empty `observation`, `evidence`, and `impact` fields.
- `evidence` must be a concrete artifact reference, not a paraphrase.
- `<executive_summary>` must state a risk level (critical / high / medium / low).
</output_instructions>
