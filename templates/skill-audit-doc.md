<!-- skill-audit-doc.md — final audit synthesis document template
     Path: templates/skill-audit-doc.md
     Used by: workflows/audit-skill.md S03 synthesis phase — one copy per full audit run.
     Filename convention: skill-audit-{skill-name}-{YYYY-MM-DD-HHmm}.md

     ⚠️  SYNTHESIS IS NOT CONCATENATION (K004):
       1. Identify CONVERGENCE — findings 2+ experts raised independently.
       2. Identify CONTRADICTION — where experts disagree on severity or approach.
       3. Establish PRIORITY ORDER — a single ranked list a decision-maker can act on.
       4. COMPUTE MATURITY SCORE — aggregate dimension scores into a 5-dimension scorecard.
       5. BUILD REMEDIATION PLAN — phase the top recommendations by effort and dependency.
-->

## Overview

**Skill:** [Skill name from YAML frontmatter]
**Path:** [Path to skill root directory]
**Complexity tier:** simple | router | enterprise
**Experts consulted:** [Comma-separated list of roles]
**Review date:** [YYYY-MM-DD]
**Overall risk:** critical | high | medium | low
**Verdict:** [Single sentence verdict on the skill's current state.]

---

## Structural Health

<!-- Pre-validation results from the StructuralScan. Fill from SkillAuditIntakePackage.structural_scan. -->

| Check | Result | Detail |
|-------|--------|--------|
| YAML frontmatter present | ✅ / ❌ | [name + description fields] |
| SKILL.md line count | [N] lines | [Pass / K002 VIOLATION if > 500] |
| No markdown headings in SKILL.md body | ✅ / ❌ | [K001 check] |
| workflows/ directory present | ✅ / ❌ | [[N] workflow files found] |
| Output contracts defined | ✅ / ❌ | [file name if present] |
| Subagent dispatch present | ✅ / ❌ | [which workflow(s)] |
| User input accepted | ✅ / ❌ | [intake phase or ask_user_questions present] |
| External service calls | ✅ / ❌ | [which tools] |

**Structural violations detected:**

<!-- List each StructuralViolation below. If none, write: "No structural violations detected." -->
- [severity] [rule]: [detail] in [file]

---

## Maturity Scorecard

<!-- 5-dimension quantitative scorecard. Each dimension scored 1–5.
     Scores aggregated from expert dimension_scores blocks.
     When multiple experts score the same dimension, use weighted average (weight = confidence_score).
     Overall maturity = mean of the non-N/A dimension scores, rounded to 1 decimal.
     Maturity tier: 4.0–5.0 = production-ready; 3.0–3.9 = v1-ready; 2.0–2.9 = prototype; <2.0 = deficient
     Mark single-expert dimensions with * in the Score column. -->

| Dimension | Score (1–5) | Scored By | Key Evidence |
|-----------|-------------|-----------|--------------|
| Prompt Clarity | [score] | [Prompt Architect, Cognitive Load Analyst] | [1-sentence summary of evidence] |
| Workflow Robustness | [score] | [Agentic Workflow Designer, Output Contract Reviewer] | [1-sentence summary] |
| Security Posture | [score] | [Security & Injection Auditor] | [1-sentence summary] |
| Quality Coverage | [score] | [Quality & Coverage Analyst] | [1-sentence summary] |
| Enterprise Readiness | [score] | [Enterprise Readiness Auditor] | [1-sentence summary] |

**Overall Maturity Score: [X.X] / 5.0**
**Maturity Tier: [production-ready | v1-ready | prototype | deficient]**

---

## Per-Role Highlights

| Role | 1-Sentence Finding | Highest Severity | Confidence |
|------|--------------------|-----------------|------------|
| [Role 1] | [Most important finding in plain language] | critical/major/minor/informational | [0.0–1.0] |
| [Role 2] | [...] | [...] | [...] |

---

## Cross-Cutting Findings

<!-- Issues raised independently by 2+ experts. Highest-confidence findings.
     If no cross-cutting findings: replace this entire block with
     "No cross-cutting findings identified." -->

### X1 — [Brief descriptive title]

**Raised by:** [Role A, Role B]

**Finding:** [Synthesized description — combine observations without pasting either verbatim]

**Why it matters:** [Combined impact — may exceed what either expert stated alone]

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
     Ranking: cross-cutting findings first, then by impact × urgency ÷ effort.
     Tier order: critical → major → minor → informational.
     Source format: RoleName:F-id or RoleName:X1 for cross-cutting.
     Cap: 15 rows max. Note count of omitted items below the table if truncated. -->

| Rank | Recommendation | Source | Effort | Impact |
|------|---------------|--------|--------|--------|
| 1 | [Specific action — verb + object + outcome] | [Role:F1] | low/medium/high | [concrete impact] |
| 2 | [...] | [...] | [...] | [...] |

---

## Open Questions

<!-- Unresolved questions from expert reports that require follow-up.
     If no open questions: "No open questions." -->

- [Question] — raised by [Role]; needs [specific information]

---

## Remediation Plan

<!-- Phased fix schedule derived from Prioritized Recommendations.
     Phase 1 = critical + blocking structural violations (fix before any use).
     Phase 2 = major findings (fix before broader rollout).
     Phase 3 = minor findings + structural minor violations (fix when convenient).
     Phase 4 = informational + ongoing monitoring items.
     Omit any phase with no items. -->

**Phase 1 — Blockers (fix before any use)**

- [ ] [Recommendation from prioritized list] — [expected outcome]

*Estimated effort: [total hours or days]*

**Phase 2 — Quality (fix before broader rollout)**

- [ ] [Recommendation] — [expected outcome]

*Estimated effort: [...]*

**Phase 3 — Polish (fix when convenient)**

- [ ] [Recommendation] — [expected outcome]

*Estimated effort: [...]*

**Phase 4 — Monitoring (ongoing)**

- [ ] [Item] — [review cadence]

---

## Incomplete Coverage

<!-- Roles that returned partial reports (missing_sections non-empty).
     IMPORTANT: Omit this ENTIRE section — heading included — if all reports are complete. -->

The following roles returned incomplete reports:
- [Role]: missing [section names]

Findings from these roles may be partial. Consider re-running those expert roles.

---

## Run Metadata

```yaml
run_id: "{uuid4}"
run_timestamp: "{ISO-8601 datetime with timezone}"
environment: "local"
skill_version: "{skill_version}"
skill_audited: "{skill_name}"
roles_dispatched: [comma-separated list of role names]
completed_roles: "{completed_roles}/{total_roles}"
failed_roles: "none"
timed_out_roles: "none"
run_date: "{YYYY-MM-DD}"
estimated_token_cost: "~{N} tokens ({N} roles × ~{avg} tokens each)"
maturity_score: "{score}/5.0 ({tier})"
overall_risk: "{risk}"
```
