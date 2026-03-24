<!-- expert-report.md — per-subagent findings template
     Path: templates/expert-report.md
     Used by: S02 research subagents — each expert fills one copy of this template.
     Consumers: S03 synthesis orchestrator reads all completed copies.

     USAGE: Copy this file. Fill every placeholder. Do NOT omit sections.
     Severity scale: critical > major > minor > informational
-->

<role_identity>
role: "[ROLE NAME — e.g. Security Auditor, Performance Engineer, API Designer]"
domain: "[DOMAIN — e.g. application security, distributed systems, REST API design]"
focus_questions:
  - "[QUESTION 1 — specific question about this artifact from this expert's lens]"
  - "[QUESTION 2]"
  - "[QUESTION 3 — optional; add up to 4 total]"
artifact_summary: "[One sentence: what artifact was reviewed and at what scope]"
</role_identity>

<executive_summary>
[2–4 sentences. High-level verdict from this expert's perspective. State the artifact's
 primary strength, its most critical weakness, and the overall risk level this expert
 assigns. Do NOT list findings here — save those for <findings>. Example:

 "The authentication module implements JWT correctly but stores secrets in environment
  variables that are logged on startup. The session expiry logic is sound. Overall risk
  is HIGH due to secret exposure; fixing it should unblock the other issues."]
</executive_summary>

<findings>
<!-- One <finding> block per distinct issue. Order by severity descending (critical first).
     Minimum 1 finding. No maximum — be thorough. -->

<finding>
id: F1
severity: critical | major | minor | informational
  <!-- critical: exploitable, data-losing, or blocking — must fix before ship
       major: significant quality or correctness issue — fix in near term
       minor: improvement opportunity — fix when convenient
       informational: observation worth noting — no action required -->
observation: "[What is wrong or noteworthy? State the specific condition, not a category.]"
evidence: "[Exact quote from the artifact, OR file:line reference, OR specific example.
           Do not paraphrase — ground every finding in something observable.]"
impact: "[What happens if this is not addressed? Be concrete: data leak, latency spike,
         maintenance burden, user confusion — quantify where possible.]"
</finding>

<finding>
id: F2
severity: major | minor | informational
observation: "[...]"
evidence: "[...]"
impact: "[...]"
</finding>

<!-- Add more <finding> blocks as needed -->
</findings>

<recommendations>
<!-- Numbered list ordered by priority (most urgent first).
     Each recommendation must reference the finding(s) it addresses via F-id.
     Include effort estimate: low (< 1 hour) | medium (half day) | high (> 1 day) -->

1. [ACTION VERB + specific change] (addresses: F1, effort: low)
   [One sentence rationale if the link to the finding is not obvious.]

2. [ACTION VERB + specific change] (addresses: F2, effort: medium)

3. [...]

<!-- If findings are informational only, you may write "No actionable recommendations." -->
</recommendations>

<open_questions>
<!-- Questions this expert could NOT answer from the artifact alone.
     These propagate to the synthesis doc and may prompt follow-up research.
     Omit this section if you have none. -->

- "[Question 1 — what additional context, code, or docs would resolve it?]"
- "[Question 2]"
</open_questions>
