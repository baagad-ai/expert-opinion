# expert-opinion

**Multi-expert parallel review for any artifact — code, documents, architecture plans, and more.**

## What it does

Complex artifacts don't fail along a single axis. A Python auth module isn't just a security problem; it's a security problem *and* a cryptography problem *and* a test-coverage problem — and the cross-cutting findings that span those lenses are often the most important ones. `expert-opinion` runs a panel of specialist subagents in parallel, one per expert role you select, then synthesizes their findings into a single prioritized audit with cross-cutting recommendations, a ranked action table, and open questions for the team.

No committee meetings. No bottleneck reviewer. One command, one synthesis document.

## Install

```bash
npx skills add baagad-ai/expert-opinion -g -y
```

No API keys required. No additional setup.

## Usage

Type `/expert-opinion` in GSD, paste or describe your artifact, and the skill:

1. **Proposes expert roles** — suggests 6–8 specialist lenses relevant to your artifact (e.g., Security Auditor, Cryptography Specialist, API Designer for a JWT auth module).
2. **You confirm or adjust** — accept the proposed panel, add roles, or swap one out.
3. **Parallel expert research** — each role runs as an independent subagent, reading your artifact through its own lens with full depth.
4. **Synthesis document** — all findings are merged into a single structured document: overview verdict, per-role highlights, cross-cutting findings (where experts independently flagged the same root problem), a ranked recommendations table, and open questions for the team.

## Examples

### Code Review: Python JWT Auth Module

A ~60-line Flask-based JWT auth handler submitted for pre-production review. The skill proposed 7 expert roles (Security Auditor, Cryptography Specialist, API Designer, Performance Engineer, Test Coverage Analyst, DevSecOps Engineer, Documentation Reviewer) and produced this verdict:

```xml
<overview>
artifact: "Python JWT authentication module (auth/jwt_handler.py, ~60 LOC, API gateway auth layer)"
overall_risk: "critical"
one_line_verdict: "This module has a hardcoded HS256 secret and no token expiry enforcement —
  any token issued is permanently valid and the secret is almost certainly already in
  version-control history."
</overview>
```

**Top recommendations (from the ranked table):**

| Rank | Recommendation | Effort | Impact |
|------|---------------|--------|--------|
| 1 | Replace hardcoded `SECRET_KEY` with `os.environ["JWT_SECRET_KEY"]`; raise `RuntimeError` at import if absent; add `detect-secrets` to CI pre-commit | low | Eliminates permanent credential exposure in VCS and container images |
| 2 | Add `exp` claim to `create_token` (e.g. 1-hour TTL); catch `MissingRequiredClaimError` explicitly | low | Bounds the blast radius of any token theft to the TTL window |
| 3 | Remove or gate the public `POST /auth/verify` endpoint; rate-limit if external introspection is genuinely needed; strip `claims` from the response | medium | Eliminates the oracle + DoS surface and stops leaking user payload to anonymous callers |

→ Full example: [examples/01-python-auth-module/](examples/01-python-auth-module/)

---

### Business Review: SaaS Pricing Strategy Memo

A 400-word internal memo proposing a $29/$99/$299 seat-based tier model for Vantara Analytics with a 90-day free-tier sunset. The skill surfaced a genuine expert disagreement that the author had glossed over:

```xml
<overview>
artifact: "SaaS pricing strategy memo — Vantara Analytics Q2 2024 pricing overhaul"
overall_risk: "medium"
one_line_verdict: "The three-tier structure is directionally sound, but the free-tier sunset
  timeline is dangerously compressed and the seat-based vs. usage-based pricing debate
  is unresolved — both require immediate attention before launch."
</overview>
```

**Top recommendations (from the ranked table):**

| Rank | Recommendation | Effort | Impact |
|------|---------------|--------|--------|
| 1 | Extend free-tier grace period to 180 days for accounts with 5+ active sessions in the last 30 days | low | Reduces churn-spike risk for mid-market accounts with procurement cycles |
| 2 | Commission willingness-to-pay research before locking in price points; run a Starter-heavy ARPU scenario model | medium | Validates (or invalidates) the 40% ARPU increase claim before committing |
| 3 | Design a 14-day full-featured trial funnel (no credit card) to replace the PLG function of the free tier | medium | Maintains new-user acquisition and prevents a Databox "switch from Vantara" campaign |

→ Full example: [examples/02-saas-pricing-strategy/](examples/02-saas-pricing-strategy/)

---

### Architecture Review: Service Architecture ADR

An Architecture Decision Record (ADR) for Yardhop, a 3-person startup choosing between monolith-first and microservices for a marketplace platform. The skill confirmed the decision was correct — and then identified what it was missing:

```xml
<overview>
artifact: "ADR-001 — Yardhop marketplace initial service architecture (monolith vs. microservices)"
overall_risk: "low"
one_line_verdict: "Monolith-first is the correct call for this team and timeline, but the ADR
  is dangerously thin on two specifics: the data migration path when extraction eventually
  happens, and the concrete observability instrumentation needed to detect problems before
  they become outages."
</overview>
```

**Top recommendations (from the ranked table):**

| Rank | Recommendation | Effort | Impact |
|------|---------------|--------|--------|
| 1 | Define schema-per-module in PostgreSQL from day 1 (`auth.*`, `listings.*`, `bookings.*`); foreign-key-only cross-schema references | low | Eliminates data ownership archaeology at extraction time |
| 2 | Add structured logging + Stripe webhook health check + basic error budget before launch | low | Prevents flying blind in production |
| 3 | Implement module boundary linting rule concretely (specify tool, rule, owner) before the first cross-module feature | low | Most important governance mechanism for keeping the monolith decomposable |

→ Full example: [examples/03-architecture-decision/](examples/03-architecture-decision/)

---

## What it produces

Each run produces a **synthesis document** following the schema defined in [`templates/synthesis-doc.md`](templates/synthesis-doc.md):

| Section | Contents |
|---------|----------|
| `<overview>` | Artifact description, scope, experts consulted, risk level, one-line verdict |
| `<per_role_highlights>` | Per-expert finding table: 1-sentence finding + highest severity per role |
| `<cross_cutting_findings>` | Findings where 2+ experts independently flagged the same root issue — these are the most actionable |
| `<contradictions>` | Genuine expert disagreements with the synthesis's resolution (only present when experts actually disagreed) |
| `<prioritized_recommendations>` | Ranked action table: recommendation, source roles, effort, impact |
| `<open_questions>` | Questions the team needs to answer before acting — flagged during review |

The `<cross_cutting_findings>` section is the most valuable part: it finds the issues whose impact exceeds what any single reviewer would identify, because the combined framing changes the severity.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) — including how to add new expert roles to the taxonomy that the skill uses to propose panels.

## Source

[github.com/baagad-ai/expert-opinion](https://github.com/baagad-ai/expert-opinion)
