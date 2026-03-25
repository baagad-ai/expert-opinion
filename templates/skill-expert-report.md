<!-- skill-expert-report.md — per-subagent findings template for skill audits
     Path: templates/skill-expert-report.md
     Used by: audit-skill.md S02 research subagents — each expert fills one copy.
     Consumers: S03 synthesis (skill-audit-synthesis.md)

     USAGE: Copy this file. Fill every placeholder. Do NOT omit sections.
     Severity scale: critical > major > minor > informational
     Confidence scale: 1.0 = certain (grounded in direct evidence);
                       0.7 = probable (inferred from strong signals);
                       0.4 = possible (pattern match, low evidence)
-->

<role_identity>
role: "[ROLE NAME — e.g. Prompt Architect, Security & Injection Auditor]"
domain: "[DOMAIN — e.g. prompt design and instruction engineering]"
skill_name: "[Skill name from YAML frontmatter or directory name]"
focus_questions:
  - "[QUESTION 1 — specific question about THIS skill from this expert's lens]"
  - "[QUESTION 2]"
  - "[QUESTION 3 — optional; up to 4 total]"
files_reviewed:
  - "[SKILL.md]"
  - "[workflows/intake.md — if reviewed]"
  - "[any other files examined]"
</role_identity>

<executive_summary>
[2–4 sentences. High-level verdict from this expert's perspective. State:
 1. The skill's primary strength from your domain lens
 2. The most critical weakness you found
 3. Your overall risk level (critical / high / medium / low)
 Do NOT list findings here — save those for <findings>.]
</executive_summary>

<findings>
<!-- One <finding> block per distinct issue. Order severity-descending (critical first).
     Minimum 1 finding. No maximum — be thorough.
     evidence MUST be: exact quote with file:line, OR specific concrete observation.
     Do NOT paraphrase and call it evidence. -->

<finding>
id: F1
severity: critical | major | minor | informational
file: "[which file this finding applies to, e.g. SKILL.md, workflows/research.md]"
line_ref: "[line number or range if available, e.g. L42 or L38–L55]"
observation: "[What is wrong or noteworthy? State the specific condition, not a category.]"
evidence: "[Exact quote from the skill file with line reference, OR a specific reproducible
           observation. Do NOT paraphrase.]"
impact: "[What breaks or degrades if this is not addressed? Be concrete:
         agent confusion, incorrect routing, security gap, context overflow,
         silent failure — quantify where possible.]"
confidence: 0.0–1.0
  <!-- 1.0 = grounded in direct evidence; 0.7 = inferred from strong signals;
       0.4 = possible but low evidence — still worth flagging -->
</finding>

<finding>
id: F2
severity: major | minor | informational
file: "[...]"
line_ref: "[...]"
observation: "[...]"
evidence: "[...]"
impact: "[...]"
confidence: 0.0–1.0
</finding>

<!-- Add more <finding> blocks as needed -->
</findings>

<dimension_scores>
<!-- Score the skill on your expert dimension using the 1–5 scale below.
     This feeds directly into the S03 maturity scorecard.
     Only score dimensions where you have sufficient evidence.
     If you cannot assess a dimension, omit the row and explain why. -->

| Dimension | Score (1–5) | Rationale (1 sentence) |
|-----------|-------------|------------------------|
| [Your primary dimension, e.g. "Prompt Clarity"] | [1–5] | [Why this score] |
| [Secondary dimension if applicable] | [1–5] | [Why this score] |

<!--
Score scale:
  5 = Exemplary — exceeds best practices; a model for others
  4 = Solid — meets all requirements with minor gaps
  3 = Adequate — meets minimum requirements; improvement areas are clear
  2 = Below standard — notable gaps that will cause problems in production
  1 = Deficient — fundamental issues that must be resolved before use
-->
</dimension_scores>

<recommendations>
<!-- Numbered, ordered by priority (highest urgency first).
     Each recommendation must:
       - Reference the finding(s) it addresses (F-id)
       - Include an effort estimate
       - Be concrete (ACTION VERB + specific change + expected outcome)
     Format: [N]. [Action] (addresses: F[id], effort: low|medium|high) -->

1. [Specific action] (addresses: F1, effort: low)
   [One-sentence rationale if the link to the finding is not obvious.]

2. [Specific action] (addresses: F2, effort: medium)

<!-- If all findings are informational, write: "No actionable recommendations." -->
</recommendations>

<open_questions>
<!-- Questions this expert could NOT answer from the skill files alone.
     Each question should name: what it concerns AND what information would resolve it.
     Omit this section entirely if you have none. -->

- "[Question] — needs [specific file, test run, or domain owner input]"
</open_questions>

<confidence_score>
[0.0–1.0]: [One sentence explaining the basis for this overall report confidence.
            e.g. "0.85 — direct evidence from SKILL.md and two workflow files; one
            workflow was absent so the dispatch path was inferred."]
</confidence_score>
