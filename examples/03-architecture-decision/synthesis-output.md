<overview>
artifact: "ADR-001 — Yardhop marketplace initial service architecture (monolith vs. microservices), pre-launch 3-person team"
scope: "Architectural soundness, operational readiness, security posture, data model design for future extraction, developer experience, documentation completeness"
experts_consulted: "Systems Architect, Site Reliability Engineer, Security Auditor, Product Manager, Developer Experience Engineer, Data Engineer, Technical Writer"
review_date: "2024-03-01"
overall_risk: "low"
one_line_verdict: "Monolith-first is the correct call for this team and timeline, but the ADR is dangerously thin on two specifics: the data migration path when extraction eventually happens, and the concrete observability instrumentation needed to detect problems before they become outages."
</overview>

<per_role_highlights>

| Role | 1-Sentence Finding | Highest Severity |
|------|--------------------|-----------------|
| Systems Architect | The module decomposition is reasonable, but there is no defined data boundary strategy — a shared PostgreSQL instance with no schema-per-module or row-level-security means future service extraction will require painful data ownership archaeology. | major |
| Site Reliability Engineer | The monolith approach is operationally justified, but there is no observability plan: no structured logging format, no error budget definition, no health check strategy for Stripe failures — the team will be flying blind in production from day 1. | major |
| Security Auditor | Stripe's hosted-fields integration correctly scopes PCI-DSS card data out of Yardhop's system, but there is no mention of row-level security or explicit tenant scoping in the shared database — multi-tenant data isolation is left to application-layer discipline alone. | major |
| Product Manager | The 14-week timeline is achievable for the monolith approach but the ADR has no dependency graph — Stripe payment integration and S3 photo uploads are blocking dependencies for booking and listing flows respectively, and a slip in either cascades. | minor |
| Developer Experience Engineer | The `docker-compose up` local dev claim is likely accurate but is not documented or version-controlled — if the setup lives only in institutional knowledge, the 4th engineer onboarding will cost days, not minutes. | minor |
| Data Engineer | The analytics module is flagged as the first extraction candidate but has no data contract defined — without an agreed event schema emitted by the monolith, the ML engineer's work will be tightly coupled to transactional table structures that will be expensive to change later. | major |
| Technical Writer | The module boundary linting rule is mentioned in the ADR but not specified — which tool, which rule, who owns it — meaning it may never be implemented, leaving the most important architectural governance mechanism as a good intention rather than an enforced constraint. | major |

</per_role_highlights>

<cross_cutting_findings>

<cross_finding>
id: X1
raised_by: "Systems Architect, Site Reliability Engineer"
finding: "The ADR commits to monolith-first correctly, but defers all decisions about what makes the monolith decomposable later. The Systems Architect flags that a shared database with no schema-per-module means extraction requires data ownership archaeology; the SRE flags that without observability instrumentation, the team won't know which module is the bottleneck until it's already causing an incident. Both findings converge on the same gap: the ADR plans for future extraction conceptually ('revisit at 8+ engineers') but makes zero concrete investments today to make that extraction tractable. When the extraction moment comes, the team will face: (a) no clean data boundaries to carve along, (b) no observability data to know which module needs to be extracted first, and (c) a monolith that may have accreted coupling despite good intentions."
why_it_matters: "Monolith-first is a good default decision, but it is only sound if the team treats it as 'structured for future extraction' rather than 'extraction is someone else's problem.' The ADR currently defaults to the latter. Addressing this now costs days; addressing it after 18 months of feature development costs months."
</cross_finding>

<cross_finding>
id: X2
raised_by: "Data Engineer, Systems Architect"
finding: "The analytics/ML module is identified as the first extraction candidate, but there is no event schema defined for what the monolith will emit to power analytics and future ML recommendations. The Data Engineer flags that without an event log table or agreed event schema, the ML engineer is forced to read directly from transactional tables (listings, bookings, payments) — creating deep coupling between the recommendations feature and the transaction schema. The Systems Architect flags that this same coupling pattern is what makes service extraction expensive: when the analytics module is eventually extracted, every schema migration in the core tables will require coordinating with the analytics service."
why_it_matters: "Defining a minimal event schema (listing_viewed, booking_created, booking_completed, review_submitted) in week 1 costs hours and prevents months of refactoring. It also gives the ML engineer a clean interface to build against without coupling to transactional schema internals."
</cross_finding>

</cross_cutting_findings>

<prioritized_recommendations>

| Rank | Recommendation | Source | Effort | Impact |
|------|---------------|--------|--------|--------|
| 1 | Define a schema-per-module convention in the shared PostgreSQL database (e.g., `auth.*`, `listings.*`, `bookings.*`) and enforce foreign-key-only cross-schema references from day 1 — this creates the data ownership boundary that makes future extraction tractable without requiring separate databases today | SysArch:F1, X1 | low | Eliminates data ownership archaeology at extraction time; costs one afternoon to set up, saves weeks later |
| 2 | Add structured logging (e.g., `structlog` in Python or Rails `lograge`) with a defined log schema from week 1; add a Stripe webhook health check endpoint that returns degraded status if payment callbacks are not received within SLA; define a basic error budget (e.g., <1% booking creation failures per day) | SRE:F1, SRE:F2 | low | Prevents flying blind in production; gives the team alertable signals before user complaints surface issues |
| 3 | Define the module boundary linting rule concretely in the ADR and implement it before merging the first cross-module feature: specify the tool (e.g., `import-linter` for Python or a custom Zeitwerk concern for Rails), the rule (no direct cross-module model imports; all cross-module calls via service objects), and assign one owner | TechWriter:F1, SysArch:F2 | low | The single most important governance mechanism for keeping the monolith decomposable — if not implemented in week 1, it almost certainly won't be implemented at all |
| 4 | Define a minimal domain event schema (listing_viewed, booking_created, booking_completed, review_submitted, payment_succeeded) and emit these events to an internal event log table from week 1; the ML engineer builds their pipeline against this schema, not directly against transactional tables | DataEng:F1, X2 | low | Decouples analytics/ML work from transactional schema; provides the extraction boundary for the analytics module when the time comes |
| 5 | Document the docker-compose local dev setup, database migration process, and CI/CD pipeline in a `DEVELOPMENT.md` file before the first sprint ends; include the module boundary rules and the review criteria (8+ engineers or 5,000 req/min) in the document with a tracking ticket | DevExp:F1, TechWriter:F2 | low | Ensures the 4th engineer can onboard in hours, not days; ensures the architecture review criteria don't get forgotten |

</prioritized_recommendations>

<open_questions>

- "Does Yardhop have any EU users in scope for the beta? If so, the shared PostgreSQL instance needs a data residency review before launch, as GDPR Article 44 transfer restrictions may apply to user PII stored alongside payment metadata." — raised by Security Auditor; needs confirmation from the founding team on intended launch geography
- "Is there a plan for database connection pooling (e.g., PgBouncer) from day 1, or will the monolith connect directly to PostgreSQL? At moderate concurrency, unpool'd Django/Rails connections can exhaust PostgreSQL's connection limit before any single module is under heavy load." — raised by Site Reliability Engineer; needs a concrete answer before the deployment architecture is finalized
- "What is the planned strategy for zero-downtime database migrations — does the team plan to use expand/contract migrations (backward-compatible schema changes followed by cleanup deploys), and is this tooled in the CI pipeline?" — raised by Developer Experience Engineer; needs a decision before the first schema-changing feature is built

</open_questions>
