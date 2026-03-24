---
name: expert-opinion
description: >
  Multi-expert parallel review for any artifact — code, documents, architecture plans,
  business proposals, or any URL. Proposes 5–10 specialist perspectives, gates on your
  confirmation, runs each expert in a parallel subagent, then synthesizes findings into
  a prioritized audit document.
version: 0.1.0
author: GSD
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
  </no_web_search_in_intake>
</essential_principles>

<intake>
  What artifact or topic would you like expert review of? You can provide:

  - A file path (e.g. `./src/auth.py`, `./README.md`)
  - A directory / codebase path (e.g. `./my-project/`)
  - A URL (e.g. `https://example.com/spec`)
  - Inline text or a pasted code snippet

  Paste or describe your input and I will detect its type, normalize it, propose
  relevant expert perspectives, and run parallel reviews after your confirmation.
</intake>

<routing>
  <route id="intake" trigger="new_request">
    <description>
      User provides an artifact or topic for expert review. Covers all input types:
      text, file, codebase, and URL.
    </description>
    <workflow>workflows/intake.md</workflow>
    <phases>detect → normalize → infer → propose → confirm → emit</phases>
  </route>

  <route id="research" trigger="output_package_ready">
    <description>Parallel expert research. Dispatches one subagent per confirmed role using parallel mode. Collects structured expert reports for synthesis.</description>
    <workflow>workflows/research.md</workflow>
    <phases>receive → construct → dispatch → collect</phases>
  </route>

  <route id="synthesis" trigger="all_reports_collected">
    <description>
      Synthesizes collected expert reports into a prioritized audit document.
      Identifies convergent findings, surfaces contradictions, and emits a ranked
      recommendation table. Saves output to expert-opinion-{YYYY-MM-DD-HHmm}.md.
    </description>
    <workflow>workflows/synthesis.md</workflow>
    <phases>receive → analyze → synthesize → deliver</phases>
  </route>
</routing>
