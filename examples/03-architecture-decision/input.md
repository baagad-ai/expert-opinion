# Input: Architecture Decision Record — Monolith vs. Microservices

**Artifact type:** Architecture Decision Record (ADR)  
**Project:** Yardhop — peer-to-peer outdoor gear rental marketplace  
**Team size:** 3 engineers (1 backend, 1 full-stack, 1 ML/data)  
**Date:** 2024-03-01  
**Status:** Proposed

---

## ADR-001: Initial Service Architecture for Yardhop Marketplace

### Context

Yardhop is a marketplace platform connecting gear owners with renters for outdoor recreational equipment (kayaks, camping gear, ski equipment). We are pre-launch with zero paying customers. The team consists of 3 engineers and we are targeting a public beta in 14 weeks.

The core platform requires: user accounts and authentication, gear listing management (with photo uploads), search and filtering, booking/reservation flow, payment processing (via Stripe), messaging between buyers and sellers, review and rating system, and basic analytics for hosts.

We are choosing between two initial architectures before writing the first line of production code.

---

### Decision Drivers

1. **Speed to beta**: We need to ship a functional marketplace in 14 weeks with 3 engineers.
2. **Operational simplicity**: None of us have run microservices in production at this team size. Kubernetes, service mesh, distributed tracing are non-trivial operational investments.
3. **Iteration velocity**: Early-stage startups change their data model frequently. Microservices boundaries that seem right today often need to be redrawn as the product evolves.
4. **Recruitment signal**: Our architecture should not require specialized platform engineering knowledge to onboard a 4th engineer.
5. **Cost**: AWS ECS/Fargate or a single Heroku dyno is substantially cheaper than a Kubernetes cluster with multiple services at zero revenue.

---

### Considered Options

#### Option A: Monolith-First (Modular Rails/Django Monolith)

A single deployable unit with well-defined internal module boundaries. Separate modules for: `auth`, `listings`, `bookings`, `payments`, `messaging`, `reviews`, `analytics`. Shared PostgreSQL database. Background jobs via Sidekiq/Celery. Photo uploads via S3 with CDN.

**Pros:**
- Single deployment pipeline, single logging target, single database connection pool to manage
- Shared in-process function calls eliminate network latency and distributed transaction complexity for operations like "create booking + charge payment + notify seller + update availability" (which spans 4 logical domains)
- Refactoring module interfaces requires only a PR, not a versioned API contract and two-service deploy
- Local development is `docker-compose up` — all 3 engineers can contribute to all modules without cross-team coordination

**Cons:**
- As the codebase grows, modules can become coupled if discipline lapses — requires active architectural governance (module boundary tests, enforced import rules)
- Horizontal scaling must scale the entire monolith, not individual bottlenecks (e.g., cannot independently scale the search module)
- If we ever need to extract a service (e.g., the ML recommendations engine), the refactor is non-trivial

#### Option B: Microservices-First (6 Independent Services)

Six deployable services: `auth-service`, `listing-service`, `booking-service`, `payment-service`, `messaging-service`, `review-service`. Event-driven communication via Kafka or RabbitMQ. Separate databases per service. API gateway (Kong or AWS API Gateway) for routing.

**Pros:**
- Each service can be scaled, deployed, and failed independently
- Forces clean API contracts from day one — no risk of cross-module coupling
- Technology heterogeneity: payments service can be Go for performance; ML service can be Python

**Cons:**
- Distributed transactions (booking + payment + notification) require sagas or two-phase commit — significant complexity for a 3-person team
- 6x the deployment pipelines, 6x the monitoring surfaces, 6x the database migration concerns
- Local dev requires service discovery, mocking, or running all 6 services — slows iteration velocity
- We have no operational experience with this topology and no DevOps headcount

---

### Proposed Decision

**We choose Option A: Monolith-First.**

Rationale: At 3 engineers and 14 weeks to beta, the operational overhead of microservices is not justified. Shopify, Stack Overflow, and Basecamp ran monoliths past $100M ARR. The risk of premature abstraction (wrong service boundaries that are expensive to change) outweighs the risk of a well-structured monolith that needs to be selectively decomposed later.

We will enforce module boundaries via a linting rule that blocks cross-module direct model imports (all cross-module access must go through a service layer interface). This preserves the option to extract services when we have the operational maturity to do so.

**Review date:** Revisit when team reaches 8+ engineers or any single module handles >5,000 req/min in production.

---

### Consequences

- We accept the risk of a future extraction effort if we need to scale individual modules.
- We must invest in module boundary enforcement from day one (linting, architecture tests).
- The analytics module (and future ML features) will be the first candidate for extraction — we will track its coupling surface deliberately.
