---
name: expert-opinion
version: "1.0.0"
description: >
  Use when you want multi-expert parallel review of any artifact — code, documents,
  architecture plans, business proposals, agentic skills, or any URL. Proposes expert
  perspectives specific to the submitted artifact, gates on confirmation, runs each
  expert in a parallel subagent, then synthesizes findings into a prioritized audit
  document. For skill artifacts (directories containing SKILL.md), runs a dedicated skill audit pipeline with
  structural pre-validation, maturity scorecard, and phased remediation plan.
---

<essential_principles>
  <parallel_architecture>
    Expert research runs in parallel subagents — one subagent per confirmed role. Never
    run expert reviews sequentially. Parallel execution is the core performance guarantee
    of this skill. Do not collapse experts into a single pass.
  </parallel_architecture>

  <depth_bar>
    Every finding must be grounded in evidence — a direct quote, a file:line reference,
    or a concrete observation from the artifact. Surface-level observations without
    evidence are not acceptable. The depth bar is: would a senior practitioner in this
    domain consider this finding actionable and specific?
  </depth_bar>

  <confirmation_gate>
    The user MUST confirm the expert role list before any research begins. This is not
    optional. Present the proposal, collect confirmation via ask_user_questions, and
    proceed only on "Confirm all". Do not skip the gate even if the roles seem obvious.
  </confirmation_gate>

  <no_web_search_in_intake>
    Role identification is pure in-context LLM inference from the artifact content.
    No web searches during intake. fetch_page is permitted only to read a submitted URL
    (the artifact itself) — never for supplementary research or role selection.
    Loading local reference files (e.g., `skill-audit-roles.md` via the `read` tool) is
    permitted; this principle prohibits external network requests only.
  </no_web_search_in_intake>

  <skill_audit_specialization>
    When the artifact is a skill directory (contains SKILL.md), route to
    workflows/audit-skill.md — NOT to workflows/intake.md. The skill audit pipeline
    has its own role taxonomy (references/skill-audit-roles.md), structural pre-validation,
    maturity scorecard, and phased remediation plan that general intake cannot provide.
    Role selection for skill audits uses the Role Selection Heuristics table in
    references/skill-audit-roles.md, not general domain inference.
  </skill_audit_specialization>

  <synthesis_is_not_concatenation>
    The synthesis phase MUST perform a full pre-synthesis analysis pass (convergence scan,
    contradiction scan, severity aggregation, maturity scoring, open questions merge)
    before filling any template section. Filling template sections while simultaneously
    scanning produces incoherent output (L007). Complete the analysis pass first; hold
    all results in working state; then do a single-pass template fill.
  </synthesis_is_not_concatenation>
</essential_principles>

<intake>
  What would you like expert review of?

  **For general artifacts** (code, documents, architecture, proposals, URLs):
  Provide a file path, directory path, URL, or paste content directly.

  **For skill audits** (SKILL.md or skill directory):
  Provide the skill directory path (e.g. `./my-skill/` or `~/.claude/skills/my-skill/`)
  or the skill name (e.g. `expert-opinion`).
  The skill audit pipeline runs structural pre-validation, a specialized expert panel
  drawn from prompt engineering and agentic workflow domains, produces a maturity scorecard
  (1–5 across 5 dimensions), and delivers a phased remediation plan.
</intake>

<routing_decision>
  When the user provides input, determine the route BEFORE loading any workflow or
  required-reading files. Apply these steps in order:

  **Step 0 — SKILL.md pre-check (for potential skill-audit routes only):**
  If the input looks like a directory path (ends with `/`, is a bare word, or user says
  "audit this skill"):

    **Path validation — reject shell metacharacters before any bash execution:**
    Check the user-supplied input against this allowlist: `[a-zA-Z0-9_./ -]` — alphanumerics,
    dots, hyphens, underscores, forward-slashes, spaces only.
    If the input contains any other character (`;`, `&`, `$`, `(`, `)`, `|`, `` ` ``, `!`, `*`,
    `?`, `{`, `}`, `\`):
      STOP immediately: "ERROR (routing/step-0): Invalid path — contains disallowed characters."
      Do NOT run any bash command. Do NOT proceed.

    **Multi-directory resolution loop (for bare-word inputs without a path separator):**
    If the input starts with `/`, `./`, `../`, or `~/`: treat as a literal path (`SKILL_PATH="{input}"`).
    Otherwise (bare word), probe candidate directories in this order:
      1. `./.agents/skills/{input}/`
      2. `~/.claude/skills/{input}/`
      3. `~/.agents/skills/{input}/`
      4. Current working directory: `./{input}/`

    For each candidate, run (note: path is always double-quoted):
    ```bash
    find "$SKILL_PATH" -maxdepth 1 -name "SKILL.md" | head -1
    ```
    - First candidate that returns a non-empty path → use that `SKILL_PATH`, continue to Step 1.
    - If ALL candidates return empty → route to intake (Step 2) immediately.
      Do NOT load any `audit-skill.md` required-reading files.

  **Step 1 — Skill audit route:**
  If, after Step 0, the input:
    - Refers to a directory containing SKILL.md, or
    - Is a bare word matching a known skill name (resolved via `~/.claude/skills/{name}/`, `~/.agents/skills/{name}/`, etc.), or
    - User says "audit this skill", "review this skill", "check this skill"
    → Route: skill_audit → `workflows/audit-skill.md`

  **Step 2 — General artifact route (everything else):**
  → Route: intake → `workflows/intake.md`

  **Ambiguity:** If a path could be a skill directory or a general codebase:
  Ask: "Is this a skill directory or a general codebase?"
  Then route based on the answer.

  <file_map>
    Workflow files and their purposes (all four must be present for a complete skill):
    - workflows/intake.md      — general artifact intake: detect input type, normalize, propose roles, confirm, emit IntakeOutputPackage
    - workflows/research.md    — parallel expert dispatch: validate package, construct per-role tasks, fan-out subagents, collect reports, emit ResearchOutputPackage
    - workflows/synthesis.md   — synthesis: convergence + contradiction scan, severity aggregation, maturity scoring, fill template, deliver dual output
    - workflows/audit-skill.md — skill audit pipeline: S01 structural pre-validation + intake, S02 parallel expert dispatch, S03 synthesis with maturity scorecard
  </file_map>
</routing_decision>
