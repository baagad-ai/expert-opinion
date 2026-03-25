# Changelog

All notable changes to the **expert-opinion** skill are documented here.

## [1.0.0] — 2026-03-25

### Added

**M001 — Core skill engine**
- Multi-expert intake workflow: extracts subject, context, constraints, and success criteria from any user request
- Role-proposal workflow: generates 3–5 specialist expert roles tailored to the input
- Parallel expert-research workflow: each proposed expert produces an independent analysis using real tool calls
- Synthesis workflow: combines expert outputs into a single actionable recommendation with dissenting views preserved

**M002 — Input handling & verification**
- Supports 5 input types: plain text, URL, file path, GitHub issue, and structured JSON
- Adds a verification record to every synthesis output documenting what was actually read vs. assumed
- Reference docs: `references/input-handling.md`, `references/output-contract.md`

**M003 — Open source readiness**
- `README.md` with one-command install, feature overview, and worked example
- Three fully-worked examples: Python auth module, SaaS pricing strategy, architecture decision
- `CONTRIBUTING.md` with contribution workflow and branch conventions
- `scripts/validate.sh` — 17-check structural regression guard; runs in CI and locally

### Install

```bash
npx skills add baagad-ai/expert-opinion -g -y
```
