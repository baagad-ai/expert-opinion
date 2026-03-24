# S01: Examples & Documentation

**Goal:** Produce README.md, 3 full worked examples in `examples/`, and CONTRIBUTING.md — everything a stranger needs to discover, install, and trust the skill in under a minute.
**Demo:** `ls README.md CONTRIBUTING.md examples/01-python-auth-module/ examples/02-saas-pricing-strategy/ examples/03-architecture-decision/` exits 0; README contains the install command and references all 3 examples; each example directory has `input.md`, `roles-proposed.md`, and `synthesis-output.md`.

## Must-Haves

- README.md at project root with: elevator pitch, one-command install (`npx skills add baagad-ai/expert-opinion -g -y`), and 3 worked examples with sample synthesis output
- `examples/01-python-auth-module/` — code review example (input + roles-proposed + synthesis-output)
- `examples/02-saas-pricing-strategy/` — business document example (input + roles-proposed + synthesis-output)
- `examples/03-architecture-decision/` — architecture/ADR example (input + roles-proposed + synthesis-output)
- CONTRIBUTING.md — how to add roles to the taxonomy, fork/branch/PR workflow, brief code of conduct
- `references/role-taxonomy.md` present on this branch (must be brought in from milestone/M002)

## Verification

```bash
# All required files exist
ls README.md CONTRIBUTING.md
ls examples/01-python-auth-module/input.md examples/01-python-auth-module/roles-proposed.md examples/01-python-auth-module/synthesis-output.md
ls examples/02-saas-pricing-strategy/input.md examples/02-saas-pricing-strategy/roles-proposed.md examples/02-saas-pricing-strategy/synthesis-output.md
ls examples/03-architecture-decision/input.md examples/03-architecture-decision/roles-proposed.md examples/03-architecture-decision/synthesis-output.md

# README content checks
grep -q "npx skills add baagad-ai/expert-opinion" README.md
grep -c "examples/" README.md | awk '$1 >= 3 {exit 0} {exit 1}'

# Install command is a single line (no API key required)
grep "npx skills add" README.md | head -1

# Examples have real synthesis content (not empty stubs)
wc -l examples/01-python-auth-module/synthesis-output.md | awk '$1 >= 30 {exit 0} {exit 1}'
wc -l examples/02-saas-pricing-strategy/synthesis-output.md | awk '$1 >= 30 {exit 0} {exit 1}'
wc -l examples/03-architecture-decision/synthesis-output.md | awk '$1 >= 30 {exit 0} {exit 1}'

# CONTRIBUTING.md cross-references role taxonomy
grep -q "role-taxonomy" CONTRIBUTING.md
```

Human UAT gate: "Would a stranger understand this skill and want to try it within 30 seconds of reading the README?" — this is R007's stated human verification criterion.

## Tasks

- [ ] **T01: Create 3 worked examples in examples/  (merge role-taxonomy.md, write all 9 example files)** `est:1h`
  - Why: Examples are written first because README.md will quote from them; the taxonomy must be present on this branch for CONTRIBUTING.md to cross-reference; the 3 examples must span code/business/architecture domains to demonstrate the skill's breadth
  - Files: `examples/01-python-auth-module/input.md`, `examples/01-python-auth-module/roles-proposed.md`, `examples/01-python-auth-module/synthesis-output.md`, `examples/02-saas-pricing-strategy/input.md`, `examples/02-saas-pricing-strategy/roles-proposed.md`, `examples/02-saas-pricing-strategy/synthesis-output.md`, `examples/03-architecture-decision/input.md`, `examples/03-architecture-decision/roles-proposed.md`, `examples/03-architecture-decision/synthesis-output.md`, `references/role-taxonomy.md`
  - Do: (1) Bring in `references/role-taxonomy.md` from the M002 branch: `git checkout milestone/M002 -- references/role-taxonomy.md`. (2) Create `examples/01-python-auth-module/` with a realistic ~60-line Python JWT auth module as `input.md`; a 6–8 role proposal in `roles-proposed.md` (Security Auditor, Performance Engineer, API Designer, Test Coverage Analyst, etc.); a full synthesis document following `templates/synthesis-doc.md` schema in `synthesis-output.md` — include at least 2 cross-cutting findings and a ranked recommendations table with 5+ entries. (3) Create `examples/02-saas-pricing-strategy/` with a realistic 400-word SaaS pricing strategy memo as `input.md`; a 6–8 role proposal in `roles-proposed.md` (Business Strategist, Pricing Analyst, Customer Success, Competitive Intelligence, etc.); full synthesis in `synthesis-output.md`. (4) Create `examples/03-architecture-decision/` with a realistic ADR (Architecture Decision Record) for choosing between a monolith-first vs. microservices-first approach as `input.md`; a 6–8 role proposal in `roles-proposed.md` (Systems Architect, SRE/Reliability Engineer, Security Auditor, Product Manager, etc.); full synthesis in `synthesis-output.md`. All synthesis outputs must follow the XML schema from `templates/synthesis-doc.md` faithfully and demonstrate genuine domain-specific depth — not toy "add more comments" findings.
  - Verify: `ls examples/01-python-auth-module/synthesis-output.md examples/02-saas-pricing-strategy/synthesis-output.md examples/03-architecture-decision/synthesis-output.md && wc -l examples/*/synthesis-output.md | awk '/total/ {exit ($1 >= 100) ? 0 : 1}'`
  - Done when: All 9 example files exist and synthesis outputs each have ≥30 lines of substantive content following the synthesis-doc.md schema

- [ ] **T02: Write README.md and CONTRIBUTING.md** `est:45m`
  - Why: README is the public face of the skill and the primary deliverable for R007; CONTRIBUTING.md explains how to extend the taxonomy; both depend on the examples written in T01
  - Files: `README.md`, `CONTRIBUTING.md`
  - Do: (1) Write `README.md` at project root with: one-line pitch, 2–3 sentence elevator pitch paragraph, install section with exactly `npx skills add baagad-ai/expert-opinion -g -y` as the one-command install, usage section describing the three-phase flow (/expert-opinion → propose roles → parallel research → synthesis), three worked example snippets (link to each examples/ subdirectory and inline a brief excerpt from each synthesis-output.md), and a brief "What it produces" section showing the synthesis document schema. (2) Write `CONTRIBUTING.md` with: how to add a role to the taxonomy (cross-reference `references/role-taxonomy.md`'s `## Extending the Taxonomy` section — do NOT duplicate the template, just link/reference it), fork → branch → PR workflow, and a brief code of conduct. README must not require any additional API keys or multi-step setup.
  - Verify: `grep -q "npx skills add baagad-ai/expert-opinion" README.md && grep -c "examples/" README.md | awk '$1 >= 3 {exit 0} {exit 1}' && grep -q "role-taxonomy" CONTRIBUTING.md`
  - Done when: README.md and CONTRIBUTING.md exist at project root; README contains the install command and links/references all 3 examples; CONTRIBUTING.md cross-references role-taxonomy.md

## Files Likely Touched

- `README.md`
- `CONTRIBUTING.md`
- `references/role-taxonomy.md`
- `examples/01-python-auth-module/input.md`
- `examples/01-python-auth-module/roles-proposed.md`
- `examples/01-python-auth-module/synthesis-output.md`
- `examples/02-saas-pricing-strategy/input.md`
- `examples/02-saas-pricing-strategy/roles-proposed.md`
- `examples/02-saas-pricing-strategy/synthesis-output.md`
- `examples/03-architecture-decision/input.md`
- `examples/03-architecture-decision/roles-proposed.md`
- `examples/03-architecture-decision/synthesis-output.md`
