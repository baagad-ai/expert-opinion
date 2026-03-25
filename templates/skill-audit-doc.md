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

<overview>
skill_name: "[Skill name from YAML frontmatter]"
skill_path: "[Path to skill root directory]"
complexity_tier: "simple | router | enterprise"
experts_consulted: "[Comma-separated list of roles]"
review_date: "[YYYY-MM-DD]"
overall_risk: "critical | high | medium | low"
  <!-- critical: ship-blocking issues — do not use in production
       high: significant issues — fix before broader rollout
       medium: notable gaps — usable now, improve soon
       low: minor polish — safe for production use -->
one_line_verdict: "[Single sentence verdict on the skill's current state.]"
</overview>

<structural_health>
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

Structural violations detected:
<!-- List each StructuralViolation. If none, write: "No structural violations detected." -->
- [severity] [rule]: [detail] in [file]
</structural_health>

<maturity_scorecard>
<!-- 5-dimension quantitative scorecard. Each dimension scored 1–5.
     Scores are aggregated from expert <dimension_scores> blocks.
     When multiple experts score the same dimension, use the weighted average (weight by confidence_score).
     Overall maturity = mean of the 5 dimension scores, rounded to 1 decimal.
     Maturity tier: 4.0–5.0 = production-ready; 3.0–3.9 = v1-ready; 2.0–2.9 = prototype; 1.0–1.9 = deficient -->

| Dimension | Score (1–5) | Scored By | Key Evidence |
|-----------|-------------|-----------|--------------|
| Prompt Clarity | [score] | [Prompt Architect] | [1-sentence finding] |
| Workflow Robustness | [score] | [Agentic Workflow Designer] | [1-sentence finding] |
| Security Posture | [score] | [Security & Injection Auditor] | [1-sentence finding] |
| Quality Coverage | [score] | [Quality & Coverage Analyst] | [1-sentence finding] |
| Enterprise Readiness | [score] | [Enterprise Readiness Auditor] | [1-sentence finding] |

**Overall Maturity Score: [X.X] / 5.0**
**Maturity Tier: [production-ready | v1-ready | prototype | deficient]**

<!-- If a dimension has no expert coverage (role not in the panel), mark score as "N/A" and note
     which role would be needed to assess it. -->
</maturity_scorecard>

<per_role_highlights>
<!-- One row per expert. 1-sentence finding is the expert's most important signal.
     Severity = highest-severity finding that expert raised.
     Confidence = expert's self-reported confidence_score. -->

| Role | 1-Sentence Finding | Highest Severity | Confidence |
|------|--------------------|-----------------|------------|
| [Role 1] | [Most important finding in plain language] | critical/major/minor/informational | [0.0–1.0] |
| [Role 2] | [...] | [...] | [...] |
<!-- Add rows for each expert consulted. Mark partial reports with "(partial)" after the role name. -->
</per_role_highlights>

<cross_cutting_findings>
<!-- Issues raised independently by 2+ experts. Highest-confidence findings.
     If none: "No cross-cutting findings identified." -->

<cross_finding>
id: X1
raised_by: "[Role A, Role B]"
finding: "[Synthesized description — combine observations without pasting either verbatim]"
why_it_matters: "[Combined impact — may exceed what either expert stated alone]"
</cross_finding>

<!-- Add more <cross_finding> blocks as needed -->
</cross_cutting_findings>

<contradictions>
<!-- Cases where experts disagree on severity, approach, or interpretation.
     Surface the tension; explain which view the synthesis adopts.
     Omit this ENTIRE section if there are no contradictions. -->

<contradiction>
topic: "[What the disagreement concerns]"
expert_a: "[Role A] says: [their position in one clause]"
expert_b: "[Role B] says: [their position in one clause]"
resolution: "[Which view this synthesis adopts and the one-sentence rationale, OR
             'unresolved — needs domain owner input']"
</contradiction>
</contradictions>

<prioritized_recommendations>
<!-- Single ranked list across ALL expert reports.
     Ranking: cross-cutting findings first, then by impact × urgency ÷ effort.
     Tier order: critical → major → minor → informational.
     Source format: RoleName:F-id or RoleName:X1 for cross-cutting.
     Cap: 15 rows max. Note count of omitted items if truncated. -->

| Rank | Recommendation | Source | Effort | Impact |
|------|---------------|--------|--------|--------|
| 1 | [Specific action — verb + object + outcome] | [Role:F1] | low/medium/high | [concrete impact] |
| 2 | [...] | [...] | [...] | [...] |
<!-- Continue for all actionable recommendations up to 15 -->
</prioritized_recommendations>

<remediation_plan>
<!-- Phase the recommendations from <prioritized_recommendations> into a concrete fix schedule.
     Phases are based on effort + dependency (blocking fixes first, polish last).
     Each phase should be completable in a single focused session. -->

**Phase 1 — Blockers (fix before any use)**
Address these before the skill is shared or invoked in production:
- [ ] [Recommendation N from prioritized list] — [expected outcome]
- [ ] [Recommendation M from prioritized list] — [expected outcome]
Estimated effort: [total hours or days]

**Phase 2 — Quality (fix before broader rollout)**
These improve correctness and robustness without blocking current use:
- [ ] [Recommendation ...] — [expected outcome]
Estimated effort: [...]

**Phase 3 — Polish (fix when convenient)**
Improvements that reduce friction or improve maintainability:
- [ ] [Recommendation ...] — [expected outcome]
Estimated effort: [...]

**Phase 4 — Monitoring (ongoing)**
Items that need periodic review rather than a one-time fix:
- [ ] [Item] — [review cadence]

<!-- If no blockers exist, omit Phase 1 entirely. Omit any phase with no items. -->
</remediation_plan>

<open_questions>
<!-- Unresolved questions from expert reports that require follow-up.
     Format: "- [Question] — raised by [Role]; needs [what would resolve it]" -->

- "[Question] — raised by [Role]; needs [specific information]"

<!-- If no open questions: "No open questions." -->
</open_questions>

<incomplete_coverage>
<!-- Roles that returned partial reports (missing_sections non-empty).
     Omit this ENTIRE section if all reports are complete. -->

The following roles returned incomplete reports:
- [Role]: missing [section names]
Findings from these roles may be partial. Consider re-running with a complete report.
</incomplete_coverage>
