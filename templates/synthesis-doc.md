<!-- synthesis-doc.md — final audit document template
     Path: templates/synthesis-doc.md
     Used by: S03 synthesis orchestrator — one copy produced per full audit run.
     Consumers: end user; reviewers; downstream decision-makers.

     ⚠️  SYNTHESIS GUIDANCE (K004): Synthesis is NOT concatenation.
     Do not paste expert reports end-to-end. Instead:
       1. Identify CONVERGENCE — findings that 2+ experts raised independently.
          These are the most reliable signals; surface them prominently.
       2. Identify CONTRADICTION — cases where experts disagree on severity or approach.
          Explain the tension; don't silently pick one side.
       3. Establish PRIORITY ORDER — a single ranked list that a decision-maker can act on,
          accounting for effort, impact, and dependencies across all expert views.
     The synthesis is the product. The expert reports are intermediate artifacts.
-->

<overview>
artifact: "[What artifact was reviewed — e.g. 'Python FastAPI service (auth module, 847 LOC)']"
scope: "[What was in scope for this review — e.g. 'security, performance, API design, test coverage']"
experts_consulted: "[Comma-separated list of roles — e.g. 'Security Auditor, Performance Engineer, API Designer']"
review_date: "[YYYY-MM-DD]"
overall_risk: "critical | high | medium | low"
  <!-- critical: ship-blocking issues present
       high: significant issues; fix before broader rollout
       medium: notable improvements needed; current state is usable
       low: minor polish; safe to ship -->
one_line_verdict: "[Single sentence verdict for the artifact overall.]"
</overview>

<per_role_highlights>
<!-- One row per expert. 1-sentence finding is the expert's most important signal.
     Severity = the highest-severity finding that expert raised. -->

| Role | 1-Sentence Finding | Highest Severity |
|------|--------------------|-----------------|
| [Role 1] | [Most important finding in plain language] | critical/major/minor/informational |
| [Role 2] | [...] | [...] |
| [Role 3] | [...] | [...] |
<!-- Add rows for each expert consulted -->
</per_role_highlights>

<cross_cutting_findings>
<!-- Issues raised independently by 2+ experts. These are the highest-confidence findings.
     Convergent findings deserve elevated priority regardless of individual severity ratings.
     If no issues were cross-cutting, write: "No cross-cutting findings identified." -->

<cross_finding>
id: X1
raised_by: "[Role A, Role B]"
finding: "[What the issue is — synthesize across reports, don't paste verbatim]"
why_it_matters: "[The combined impact — may be greater than either expert stated alone]"
</cross_finding>

<cross_finding>
id: X2
raised_by: "[...]"
finding: "[...]"
why_it_matters: "[...]"
</cross_finding>

<!-- Add more <cross_finding> blocks as needed -->
</cross_cutting_findings>

<contradictions>
<!-- Cases where experts disagree on severity, approach, or interpretation.
     Don't hide these — surface the tension and explain which view the synthesis adopts and why.
     Omit this section if there are no contradictions. -->

<contradiction>
topic: "[What the disagreement is about]"
expert_a: "[Role] says: [their position]"
expert_b: "[Role] says: [their position]"
resolution: "[Which view the synthesis adopts and why, OR 'unresolved — needs domain owner input']"
</contradiction>
</contradictions>

<prioritized_recommendations>
<!-- Single ranked list across ALL expert reports.
     Rank by: impact × urgency ÷ effort (use judgment, not formula).
     Cross-cutting findings (X-refs) should generally rank higher than single-expert findings.
     Each row maps to one or more expert report finding IDs (format: RoleName:F-id). -->

| Rank | Recommendation | Source | Effort | Impact |
|------|---------------|--------|--------|--------|
| 1 | [Specific action — verb + object + outcome] | [Role:F1, Role:X1] | low/medium/high | [concrete impact] |
| 2 | [...] | [...] | [...] | [...] |
| 3 | [...] | [...] | [...] | [...] |
<!-- Continue for all actionable recommendations -->
</prioritized_recommendations>

<open_questions>
<!-- Unresolved questions from expert reports that require follow-up.
     Tag each with: source expert, what additional information would resolve it. -->

- "[Question] — raised by [Role]; needs [e.g. 'access to database schema', 'load test results']"
- "[...]"

<!-- If no open questions remain, write: "No open questions." -->
</open_questions>
