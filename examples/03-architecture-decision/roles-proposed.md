# Proposed Expert Roles — Architecture Decision Record (Monolith vs. Microservices)

The following 7 expert perspectives have been identified as most relevant to this artifact.
Each expert will investigate specific aspects of the submission in parallel,
then findings will be synthesized into a prioritized audit document.

---

**Systems Architect**
*Distributed systems design, service topology, architectural fitness functions*

Focus questions for this artifact:
- Are the proposed internal module boundaries (auth, listings, bookings, payments, messaging, reviews, analytics) the right decomposition, or do some of these need to be co-located or further split based on their transactional and data-coupling patterns?
- What specific architectural fitness functions (automated tests that enforce module boundaries) would make this monolith decomposable when the time comes, and which ones should be written in week 1?
- If the analytics and ML module is flagged as the first extraction candidate, what data access patterns today would make that extraction cleanest — and are there decisions to make now that prevent a messy migration later?

---

**Site Reliability Engineer**
*Operational readiness, observability, deployment, failure modes*

Focus questions for this artifact:
- What is the blast radius of a single monolith deployment failure — does one bad deploy take down bookings, payments, and messaging simultaneously, and is the rollback story sufficient for a marketplace with real money in transit?
- Is there a health check, circuit breaker, or graceful degradation strategy for the Stripe payment integration in the monolith, given that payment latency spikes can cause cascading request queuing?
- What observability instrumentation (structured logging, distributed tracing, error budget definition) should be built into the monolith from day 1 to avoid flying blind when issues arise in production?

---

**Security Auditor**
*Authentication, authorization, multi-tenant data isolation*

Focus questions for this artifact:
- In a shared-database monolith with separate modules, what prevents the `listings` module from accidentally querying `bookings` or `payments` data for a different tenant — is row-level security (RLS) or explicit tenancy scoping enforced at the database layer?
- The ADR mentions Stripe integration — does the payments module have PCI-DSS scope implications for the monolith as a whole, or is Stripe's hosted fields approach correctly scoping card data out of Yardhop's system?
- Is the `auth` module the only source of authentication, or can any module perform direct session/token checks — and what prevents an auth bypass via a module that skips the auth middleware?

---

**Product Manager**
*Feature velocity, product-market fit iteration, team constraints*

Focus questions for this artifact:
- Does the 14-week beta timeline have dependency-ordering risks — are there features (e.g., Stripe payment flow, S3 photo uploads) that will block other features if they slip, and is that reflected in the architecture plan?
- The ADR identifies "frequent data model changes" as a driver — does the monolith approach actually solve this, or does a shared database with multiple modules still create coordination overhead when schema changes affect multiple modules?
- What is the review/revisit criteria beyond "8+ engineers or 5,000 req/min" — are there product scale signals (e.g., specific feature requests that require independent scaling) that should also trigger an architecture review?

---

**Developer Experience Engineer**
*Local dev experience, onboarding, tooling, CI/CD pipeline*

Focus questions for this artifact:
- Is the `docker-compose up` local dev claim accurate for a monolith that includes PostgreSQL, Redis (Sidekiq/Celery), S3 (via LocalStack), and Stripe (via Stripe CLI) — and is this setup documented and version-controlled from day 1?
- What is the plan for database migrations: are they run automatically on deploy or manually gated, and what is the rollback story if a migration fails mid-deploy on a live system?
- What does the CI/CD pipeline look like for the monolith — is there a pre-deploy architecture test that fails the build if module boundary rules are violated?

---

**Data Engineer**
*Data model design, analytics readiness, future ML/data pipeline extraction*

Focus questions for this artifact:
- The analytics module is flagged as a future extraction candidate — is the current data model designed with OLAP-friendly access patterns (e.g., event log tables, materialized views), or will extraction require a non-trivial ETL migration?
- Does the shared PostgreSQL database have a read replica strategy for analytics queries, or will analytics queries run against the primary write database and compete with transactional workloads?
- The ML/data engineer on the team will build the recommendations engine — is there an agreed-upon data contract (e.g., event schema) that the monolith will emit, and is this designed before the analytics module is built?

---

**Technical Writer**
*Documentation, ADR completeness, onboarding materials*

Focus questions for this artifact:
- Does the ADR clearly document the "definition of done" for module boundary enforcement — specifically, what tool, what rule, and who is responsible for maintaining it?
- Is there a runbook or architecture diagram planned that would let a 4th engineer (joining in week 6) understand the module structure and its constraints without a 2-hour onboarding session?
- The "review date" criteria (8+ engineers or 5,000 req/min) are stated but not tracked anywhere — is there a mechanism to ensure this review actually happens rather than being forgotten as the team scales?

---

CONFIRMATION PROMPT:

```
I've identified 7 expert perspectives relevant to your artifact.
Each expert will investigate specific aspects of your submission in parallel,
then I'll synthesize their findings into a prioritized audit document.

Review the roles above. What would you like to do?

Options:
  A) Confirm all — proceed with these roles as listed
  B) Edit — describe which roles to add, remove, or modify
  C) Cancel — stop here
```
