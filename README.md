<div align="center">

# expert-opinion

**Stop asking one person to review everything.**

Submit any artifact. Get a panel of domain experts arguing about it in parallel. Read one synthesis document that tells you exactly what's broken, why it matters, and what to fix first.

[![Install with skills](https://img.shields.io/badge/skills.sh-expert--opinion-6366f1?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAyQzYuNDggMiAyIDYuNDggMiAxMnM0LjQ4IDEwIDEwIDEwIDEwLTQuNDggMTAtMTBTMTcuNTIgMiAxMiAyem0tMiAxNWwtNS01IDEuNDEtMS40MUwxMCAxNC4xN2w3LjU5LTcuNTlMMTkgOGwtOSA5eiIvPjwvc3ZnPg==)](https://skills.sh/baagad-ai/expert-opinion)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue?style=flat-square)](https://github.com/baagad-ai/expert-opinion/releases/tag/v1.0.0)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)](CONTRIBUTING.md)

</div>

---

## Why this exists

A Python auth module isn't just a security problem. It's a security problem *and* a cryptography problem *and* a test-coverage problem — and the cross-cutting findings that span all three lenses are usually the ones that would've caused an incident.

Most reviews give you one perspective because that's what fits in one context window. This skill gives you five to ten, all running at the same time, none aware of each other's conclusions. Then it synthesizes them.

- **Parallel** — every expert runs as an isolated subagent concurrently. No bottleneck.
- **Grounded** — every finding must cite a specific line, quote, or observation. No vibes.
- **Synthesized** — the final document surfaces cross-cutting signals (same root cause flagged by multiple experts independently), resolves contradictions, and ranks recommendations by impact × effort.
- **Confirmed** — you see the proposed expert panel before anything runs. Add roles, swap them out, or cancel. Zero cost incurred until you say go.
- **Skill-aware** — point it at a directory with `SKILL.md` and it switches to a dedicated audit pipeline with a 5-dimension maturity scorecard.

---

## Install

```bash
npx skills add baagad-ai/expert-opinion -g -y
```

No API keys. No config. Works with Claude Code and [40+ other agents](https://skills.sh).

**Manual install (Claude Code):**
```bash
# Global — available in all your projects
cp -r expert-opinion/ ~/.claude/skills/expert-opinion/

# Project-local
cp -r expert-opinion/ .claude/skills/expert-opinion/
```

---

## How it works

```
You provide an artifact
        │
        ▼
  ┌─────────────────────────────────────────────┐
  │  INTAKE                                     │
  │  Detect type → normalize → infer context    │
  │  Propose 5–10 expert roles specific to it   │
  └───────────────────┬─────────────────────────┘
                      │
              You confirm the panel
              (add, remove, or cancel)
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
   [Expert 1]    [Expert 2]   [Expert N]   ← parallel, isolated
   evidence-     evidence-    evidence-
   grounded      grounded     grounded
        │             │             │
        └─────────────┼─────────────┘
                      │
        ┌─────────────▼─────────────────────────┐
        │  SYNTHESIS                            │
        │  Convergence scan → contradictions    │
        │  Ranked recommendations → plan        │
        └───────────────────────────────────────┘
                      │
                      ▼
         expert-opinion-YYYY-MM-DD-HHmm.md
```

---

## Usage

```bash
# Review a local file
/expert-opinion ./src/auth/handler.py

# Review from a URL
/expert-opinion https://example.com/api-spec.yaml

# Paste inline — just run the command and paste
/expert-opinion

# Review a whole directory
/expert-opinion ./my-project/

# Audit a skill (triggers the dedicated skill pipeline)
/expert-opinion ./my-skill/
```

---

## Real examples

Three worked examples live in [`examples/`](examples/). Here's what the output actually looks like.

### Python JWT Auth Module → 7 experts, critical risk

```xml
<overview>
artifact: "Python JWT authentication module (auth/jwt_handler.py, ~60 LOC, API gateway auth layer)"
overall_risk: "critical"
one_line_verdict: "This module has a hardcoded HS256 secret and no token expiry enforcement —
  any token issued is permanently valid and the secret is almost certainly already in
  version-control history."
</overview>
```

| Rank | Recommendation | Source | Effort | Impact |
|------|----------------|--------|--------|--------|
| 1 | Replace hardcoded `SECRET_KEY` with env var; raise at import if absent; add `detect-secrets` to CI | DevSecOps:F1, Security:X1 | low | Eliminates permanent credential exposure |
| 2 | Add `exp` claim to `create_token`; reject tokens missing `exp` explicitly | Crypto:F1, Security:X2 | low | Bounds blast radius of any token theft to the TTL window |
| 3 | Remove or gate the public `POST /auth/verify` endpoint; rate-limit; strip `claims` | API:F1, Perf:F1, Security:X3 | medium | Eliminates oracle + DoS surface |

> `Security:X1` notation means it's a cross-cutting finding — flagged independently by 2+ experts. These outrank equal-severity single-expert findings.

→ [Full example output](examples/01-python-auth-module/synthesis-output.md)

---

### SaaS Pricing Memo → surfaced a disagreement the author glossed over

```xml
<overview>
artifact: "SaaS pricing strategy memo — Vantara Analytics Q2 pricing overhaul"
overall_risk: "medium"
one_line_verdict: "The three-tier structure is directionally sound, but the free-tier sunset
  timeline is dangerously compressed and the seat-based vs. usage-based debate is
  unresolved — both need answers before launch."
</overview>
```

→ [Full example output](examples/02-saas-pricing-strategy/synthesis-output.md)

---

### Architecture ADR → confirmed the decision, then identified what it was missing

```xml
<overview>
artifact: "ADR-001 — Yardhop marketplace initial service architecture"
overall_risk: "low"
one_line_verdict: "Monolith-first is the correct call, but the ADR is dangerously thin on
  the data migration path and the observability instrumentation needed to detect
  problems before they become outages."
</overview>
```

→ [Full example output](examples/03-architecture-decision/synthesis-output.md)

---

## What the output document contains

| Section | What's in it |
|---------|-------------|
| `<overview>` | Artifact description, scope, experts consulted, risk level, one-line verdict |
| `<per_role_highlights>` | Per-expert table: 1-sentence finding + highest severity |
| `<cross_cutting_findings>` | Root causes flagged by 2+ experts independently — the most actionable section |
| `<contradictions>` | Where experts genuinely disagreed and how it was resolved (omitted if none) |
| `<prioritized_recommendations>` | Ranked action table: recommendation, source roles, effort, impact |
| `<open_questions>` | Things the team needs to answer before acting |

The `<cross_cutting_findings>` section is the whole point. An issue that three independent reviewers converged on without coordinating is a different class of problem than one any single expert would catch.

---

## Security model

The skill is designed to be safe to run on untrusted content.

- **Input isolation** — fetched URLs and files are wrapped in `<artifact_data>` boundary tags before reaching subagents. Instructions embedded in submitted content are treated as artifact text, not commands.
- **Pre-approved queries only** — any web searches are derived from artifact *metadata* before the content is loaded. Subagents can't generate new queries from what they're reviewing.
- **Subagent scope restriction** — each expert is isolated. No subagent can spawn further subagents or make arbitrary external calls.
- **Confirmation gate** — the expert panel is shown to you before dispatch. Nothing runs (and no cost is incurred) until you approve.

---

## What's in the repo

```
SKILL.md                     — router + essential principles
workflows/
  intake.md                  — input detection, normalization, role proposal
  research.md                — parallel subagent dispatch
  synthesis.md               — convergence, contradiction, ranked output
  audit-skill.md             — skill audit pipeline (S01 → S02 → S03)
references/
  output-contract.md         — typed schemas for the S01→S02→S03 pipeline
  skill-audit-contract.md    — typed schemas for the skill audit pipeline
  input-handling.md          — input type detection and normalization rules
  subagent-prompt.md         — expert subagent task template
  skill-audit-roles.md       — expert role taxonomy for skill audits
templates/
  expert-report.md           — per-expert output template
  synthesis-doc.md           — final audit document template
  skill-audit-doc.md         — skill audit document template
  skill-expert-report.md     — per-expert template for skill audits
  role-proposal.md           — role proposal display format
examples/
  01-python-auth-module/     — code review: JWT auth handler
  02-saas-pricing-strategy/  — business review: pricing memo
  03-architecture-decision/  — architecture review: ADR
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

Things that would make this better:
- New expert role definitions in `references/skill-audit-roles.md`
- More worked examples with real artifacts
- Input normalization support for new types (Jupyter notebooks, OpenAPI specs, etc.)
- Bug reports with reproducible inputs

---

## License

MIT — see [LICENSE](LICENSE).
