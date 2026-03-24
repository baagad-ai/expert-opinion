---
estimated_steps: 5
estimated_files: 10
skills_used:
  - frontend-design
---

# T01: Create 3 Worked Examples in examples/

**Slice:** S01 — Examples & Documentation
**Milestone:** M003

## Description

Write all 9 example files across 3 `examples/` subdirectories, spanning code/business/architecture domains. Also bring `references/role-taxonomy.md` from the M002 branch into the M003 working tree (it doesn't exist yet on milestone/M003). The role-taxonomy.md must be present before T02, which writes CONTRIBUTING.md that cross-references it.

Examples must be impressive, not toy cases. Synthesis outputs must demonstrate genuine domain-specific depth — a security auditor catching a real vulnerability pattern, a pricing analyst surfacing concrete competitive risks, an SRE flagging a genuine operability gap. All synthesis outputs must follow the XML schema from `templates/synthesis-doc.md`.

## Steps

1. **Bring in role-taxonomy.md from M002 branch:**
   ```bash
   git checkout milestone/M002 -- references/role-taxonomy.md
   ```
   Verify it's present: `wc -l references/role-taxonomy.md` (should be ~735 lines).

2. **Create `examples/01-python-auth-module/`** with 3 files:
   - `input.md`: A realistic ~60-line Python JWT authentication module with deliberate issues: no expiry validation, symmetric HS256 with hardcoded secret, no rate limiting on the verify endpoint, broad exception catch swallowing errors. Make it look like real production code a developer might write.
   - `roles-proposed.md`: The 7 roles the intake workflow would propose for this input (Security Auditor, Performance Engineer, API Designer, Test Coverage Analyst, Cryptography Specialist, DevSecOps Engineer, Documentation Reviewer), formatted per `templates/role-proposal.md`.
   - `synthesis-output.md`: Full synthesis document per `templates/synthesis-doc.md` schema. Include: overview with overall_risk=critical; per-role highlights table; at least 2 cross-cutting findings (hardcoded secrets + missing expiry validation both raise risk across Security and Crypto); no contradictions block (omit per D012); prioritized recommendations ranked table with 6+ entries; open questions. The security findings must be specific: exact lines/patterns from the input.

3. **Create `examples/02-saas-pricing-strategy/`** with 3 files:
   - `input.md`: A realistic 400-word SaaS pricing strategy memo proposing a 3-tier model (Starter/Growth/Enterprise) with specific price points ($29/$99/$299/mo), a free tier sunset plan, and annual discount structure. Include a competitive landscape section with 2 named competitors and pricing assumptions.
   - `roles-proposed.md`: 7 roles (Business Strategist, Pricing Analyst, Customer Success Manager, Competitive Intelligence Analyst, CFO/Finance Lens, Product Manager, Legal/Compliance Reviewer).
   - `synthesis-output.md`: Full synthesis per schema. overall_risk=medium. Cross-cutting finding: free-tier sunset timing risk raised by both Customer Success and Product Manager. Contradiction: Pricing Analyst recommends usage-based pricing vs. Business Strategist recommends seat-based — surface the tension and resolve it. Recommendations table with 5+ entries.

4. **Create `examples/03-architecture-decision/`** with 3 files:
   - `input.md`: A realistic ADR (Architecture Decision Record) for a 3-person startup deciding between monolith-first and microservices-first architecture for a marketplace platform. Include context, decision drivers, considered options, pros/cons for each, and a proposed decision (monolith-first) with rationale.
   - `roles-proposed.md`: 7 roles (Systems Architect, Site Reliability Engineer, Security Auditor, Product Manager, Developer Experience Engineer, Data Engineer, Technical Writer).
   - `synthesis-output.md`: Full synthesis per schema. overall_risk=low (monolith-first is well-reasoned for a small team). Cross-cutting finding: data migration path when the monolith needs to be decomposed — raised by both Systems Architect and SRE. Recommendations table with 5+ entries focused on what to do NOW to make the monolith decomposable later.

5. Verify all 9 files exist and synthesis outputs are substantive:
   ```bash
   ls examples/01-python-auth-module/input.md examples/01-python-auth-module/roles-proposed.md examples/01-python-auth-module/synthesis-output.md
   ls examples/02-saas-pricing-strategy/input.md examples/02-saas-pricing-strategy/roles-proposed.md examples/02-saas-pricing-strategy/synthesis-output.md
   ls examples/03-architecture-decision/input.md examples/03-architecture-decision/roles-proposed.md examples/03-architecture-decision/synthesis-output.md
   wc -l examples/*/synthesis-output.md
   ```

## Must-Haves

- [ ] `references/role-taxonomy.md` exists on the current branch (checked out from milestone/M002)
- [ ] All 9 example files exist across the 3 `examples/` subdirectories
- [ ] Each `synthesis-output.md` follows the XML schema from `templates/synthesis-doc.md` (has `<overview>`, `<per_role_highlights>`, `<cross_cutting_findings>`, `<prioritized_recommendations>`, `<open_questions>` blocks)
- [ ] Each `synthesis-output.md` has ≥30 lines (proves content is substantive, not a stub)
- [ ] Each synthesis has ≥2 cross-cutting findings or ≥1 contradiction (demonstrates the synthesis is not just concatenation — K004)
- [ ] Security finding in example 01 references a specific line or pattern from the input (depth bar — K003)
- [ ] No `<contradictions>` block present when there are no contradictions (D012 — omit entirely vs. empty)
- [ ] Example inputs are fabricated but realistic — not toy/trivial cases (K005)

## Verification

```bash
# All 9 example files exist
ls examples/01-python-auth-module/input.md examples/01-python-auth-module/roles-proposed.md examples/01-python-auth-module/synthesis-output.md
ls examples/02-saas-pricing-strategy/input.md examples/02-saas-pricing-strategy/roles-proposed.md examples/02-saas-pricing-strategy/synthesis-output.md
ls examples/03-architecture-decision/input.md examples/03-architecture-decision/roles-proposed.md examples/03-architecture-decision/synthesis-output.md

# Synthesis outputs have substantive content
wc -l examples/01-python-auth-module/synthesis-output.md | awk '$1 >= 30 {exit 0} {exit 1}'
wc -l examples/02-saas-pricing-strategy/synthesis-output.md | awk '$1 >= 30 {exit 0} {exit 1}'
wc -l examples/03-architecture-decision/synthesis-output.md | awk '$1 >= 30 {exit 0} {exit 1}'

# Each synthesis follows the required schema
grep -q "<overview>" examples/01-python-auth-module/synthesis-output.md
grep -q "<cross_cutting_findings>" examples/01-python-auth-module/synthesis-output.md
grep -q "<prioritized_recommendations>" examples/01-python-auth-module/synthesis-output.md

# role-taxonomy.md present on this branch
test -f references/role-taxonomy.md
```

## Inputs

- `templates/synthesis-doc.md` — synthesis document schema that all synthesis-output.md files must follow
- `templates/role-proposal.md` — role proposal template that roles-proposed.md files must follow
- `references/role-taxonomy.md` (on milestone/M002 branch) — must be checked out to current branch first; provides the candidate roles to consult when writing roles-proposed.md files

## Expected Output

- `references/role-taxonomy.md` — checked out from milestone/M002 branch; now present on milestone/M003
- `examples/01-python-auth-module/input.md` — fabricated Python JWT auth module (~60 lines)
- `examples/01-python-auth-module/roles-proposed.md` — 7 proposed expert roles for a code input
- `examples/01-python-auth-module/synthesis-output.md` — full synthesis audit (schema-compliant, overall_risk=critical)
- `examples/02-saas-pricing-strategy/input.md` — fabricated SaaS pricing strategy memo (~400 words)
- `examples/02-saas-pricing-strategy/roles-proposed.md` — 7 proposed expert roles for a business document
- `examples/02-saas-pricing-strategy/synthesis-output.md` — full synthesis audit (schema-compliant, overall_risk=medium, includes contradiction block)
- `examples/03-architecture-decision/input.md` — fabricated ADR for monolith vs. microservices
- `examples/03-architecture-decision/roles-proposed.md` — 7 proposed expert roles for an architecture document
- `examples/03-architecture-decision/synthesis-output.md` — full synthesis audit (schema-compliant, overall_risk=low)
