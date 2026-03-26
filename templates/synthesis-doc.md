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

## Overview

**Artifact:** [What artifact was reviewed — e.g. 'Python FastAPI service (auth module, 847 LOC)']
**Scope:** [What was in scope — e.g. 'security, performance, API design, test coverage']
**Experts consulted:** [Comma-separated list of roles]
**Review date:** [YYYY-MM-DD]
**Overall risk:** critical | high | medium | low
**Verdict:** [Single sentence verdict for the artifact overall.]

---

## Per-Role Highlights

| Role | 1-Sentence Finding | Highest Severity |
|------|--------------------|-----------------|
| [Role 1] | [Most important finding in plain language] | critical/major/minor/informational |
| [Role 2] | [...] | [...] |
| [Role 3] | [...] | [...] |

---

## Cross-Cutting Findings

<!-- Issues raised independently by 2+ experts. These are the highest-confidence findings.
     Convergent findings deserve elevated priority regardless of individual severity ratings.
     If no cross-cutting findings exist, replace this entire block with:
     "No cross-cutting findings identified." -->

### X1 — [Brief descriptive title]

**Raised by:** [Role A, Role B]

**Finding:** [What the issue is — synthesize across reports, don't paste verbatim]

**Why it matters:** [The combined impact — may be greater than either expert stated alone]

---

### X2 — [Brief descriptive title]

**Raised by:** [...]

**Finding:** [...]

**Why it matters:** [...]

---

<!-- Add more ### Xn — [title] blocks as needed. -->

---

## Contradictions

<!-- Cases where experts disagree on severity, approach, or interpretation.
     IMPORTANT: Omit this ENTIRE section — heading included — if there are no contradictions.
     Do not write "No contradictions." — simply omit the heading and all content below it. -->

### [Topic of disagreement]

- **[Role A] says:** [their position in one clause]
- **[Role B] says:** [their position in one clause]
- **Resolution:** [Which view this synthesis adopts and why, OR 'unresolved — needs domain owner input']

---

## Prioritized Recommendations

<!-- Single ranked list across ALL expert reports.
     Rank by: impact × urgency ÷ effort (use judgment, not formula).
     Cross-cutting findings (X-refs) should generally rank higher than single-expert findings.
     Each row maps to one or more expert report finding IDs (format: RoleName:F-id or RoleName:X1). -->

| Rank | Recommendation | Source | Effort | Impact |
|------|---------------|--------|--------|--------|
| 1 | [Specific action — verb + object + outcome] | [Role:F1, Role:X1] | low/medium/high | [concrete impact] |
| 2 | [...] | [...] | [...] | [...] |
| 3 | [...] | [...] | [...] | [...] |

---

## Open Questions

<!-- Unresolved questions from expert reports that require follow-up.
     If no open questions remain, write: "No open questions." -->

- [Question] — raised by [Role]; needs [e.g. 'access to database schema', 'load test results']
- [...]

---

## Remediation Plan

<!-- Phased fix schedule derived from Prioritized Recommendations.
     Phase 1 = critical findings; must fix before any broader use or sharing.
     Phase 2 = major findings; fix before v1.0 / production rollout.
     Phase 3 = minor findings + polish; fix when convenient.
     Phase 4 = informational + ongoing monitoring items.
     Omit any phase that has no items. -->

**Phase 1 — Blockers (fix before sharing or broader use)**
- [ ] [Rank 1 recommendation]
- [ ] [Rank 2 recommendation if critical]

*Estimated effort: [X hours / days]*

**Phase 2 — Quality (fix before v1.0)**
- [ ] [Major finding fixes]

*Estimated effort: [X hours / days]*

**Phase 3 — Polish (fix when convenient)**
- [ ] [Minor finding fixes]

*Estimated effort: [half day / 1 day]*

**Phase 4 — Ongoing**
- [ ] [Informational and monitoring items]

---

## Run Metadata

```yaml
run_id: "{uuid4}"
run_timestamp: "{ISO-8601 datetime with timezone}"
environment: "local"
skill_version: "{skill_version}"
roles_dispatched: [comma-separated list of role names]
completed_roles: "{completed_roles}/{total_roles}"
failed_roles: "none"
timed_out_roles: "none"
run_date: "{YYYY-MM-DD}"
estimated_token_cost: "~{N} tokens ({N} roles × ~{avg} tokens each)"
```
