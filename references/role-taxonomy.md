---
version: "1.0"
description: >
  Curated taxonomy of expert reviewer roles organized by input domain. Used as a
  candidate seed pool by the intake workflow (workflows/intake.md, Phase 4) when
  proposing expert roles to the user. Roles are function-level, tool-agnostic, and
  designed to remain accurate over a 2–3 year horizon. This file is additive:
  the intake workflow may propose roles not listed here when the artifact demands it.
extensibility_note: >
  To add a new role, append a formatted entry under the appropriate domain section
  following the template in `## Extending the Taxonomy`. To add a new domain, append
  a new `## Domain Name` section before `## Extending the Taxonomy`. Commit the change
  and bump `version` in this frontmatter. Custom roles added here are automatically
  available to all intake runs without any other configuration change.
---

# Expert Role Taxonomy

This file maps input domains to curated expert reviewer roles. It is consumed by
`workflows/intake.md` Phase 4 as a seed candidate pool — the intake executor reads
this file and selects the most applicable roles before proposing them to the user.

**How to read this file:**
- Each `## Section` is a domain.
- Each `**Bold Name**` is a reviewer role within that domain.
- `Focus areas` describe what the expert investigates.
- `Applicability signals` describe artifact features that make this role relevant.

---

## Technical / Code

> Software artifacts: source code, APIs, scripts, architecture diagrams, technical
> specifications, pull requests, and code documentation.

**Software Architect**
Domain: software architecture and system design
Focus areas:
- High-level structural decisions and component boundaries
- Coupling, cohesion, and dependency management
- Scalability and extensibility of the design
- Alignment of implementation with stated requirements
Applicability signals:
- Artifact contains multiple interacting components or services
- Artifact discusses system boundaries, APIs, or data flows

**Backend Engineer**
Domain: server-side and systems engineering
Focus areas:
- Data modeling, database access patterns, and query efficiency
- Error handling, concurrency, and reliability of server logic
- API contract design and consistency
- Configuration management and environment portability
Applicability signals:
- Artifact is server-side code, an API definition, or a database schema
- Artifact includes request/response handling, middleware, or background jobs

**Frontend Engineer**
Domain: client-side and UI engineering
Focus areas:
- Component structure, state management, and rendering performance
- Accessibility markup and keyboard navigation support
- Bundle size, asset loading, and browser compatibility
- UX consistency between UI and API contract
Applicability signals:
- Artifact includes HTML, CSS, JavaScript, or a UI framework
- Artifact contains interactive components or client-state logic

**Performance Engineer**
Domain: application performance and efficiency
Focus areas:
- Algorithmic complexity and computational bottlenecks
- Memory allocation, caching, and I/O patterns
- Latency, throughput, and resource utilization under load
- Profiling indicators and instrumentation coverage
Applicability signals:
- Artifact contains loops, queries, or network calls at scale
- Artifact mentions response time SLOs, load, or throughput targets

**Reliability Engineer**
Domain: site reliability and operational resilience
Focus areas:
- Error propagation, fallback paths, and graceful degradation
- Observability: logging structure, metrics, and alert coverage
- Retry logic, circuit breakers, and timeout hygiene
- Deployment rollback and incident recovery procedures
Applicability signals:
- Artifact is production-facing code or an operations runbook
- Artifact involves distributed calls, queues, or async processing

**Code Quality Reviewer**
Domain: code maintainability and engineering craft
Focus areas:
- Naming clarity, abstraction levels, and readability
- Dead code, duplicated logic, and premature optimization
- Test coverage sufficiency and test design quality
- Documentation completeness (inline comments, README, ADRs)
Applicability signals:
- Artifact is source code being reviewed for merge or release
- Artifact has low test coverage or inconsistent style

**Technical Writer**
Domain: technical documentation and developer communication
Focus areas:
- Accuracy and completeness of written explanations
- Structure, progression, and navigability of documentation
- Code example correctness and reproducibility
- Audience calibration (beginner vs. expert, internal vs. external)
Applicability signals:
- Artifact is documentation, a README, a changelog, or a tutorial
- Artifact mixes prose and code and targets developer readers

**Security Auditor**
Domain: application security and threat modeling
→ See `## Security / Compliance` section for the full Security Auditor entry.
This role is listed here as a cross-reference only to signal its relevance for
code artifacts; the canonical entry and focus areas live in the security domain.

---

## Writing / Content

> Text artifacts: articles, blog posts, documentation, reports, proposals, email
> campaigns, scripts, marketing copy, and long-form prose.

**Editor**
Domain: prose quality and editorial judgment
Focus areas:
- Structural logic: argument progression, paragraph cohesion
- Clarity, concision, and elimination of filler language
- Voice consistency and tone appropriateness for the audience
- Grammar, punctuation, and style guide adherence
Applicability signals:
- Artifact is a long-form prose document intended for publication
- Artifact has multiple sections or subsections with varying depth

**Content Strategist**
Domain: content planning and audience alignment
Focus areas:
- Content goals and alignment with the stated business or communication objective
- Audience persona fit and reading level calibration
- Content gap analysis against competitive or category norms
- Distribution channel fit (SEO, social, email, docs portal)
Applicability signals:
- Artifact is a content brief, editorial plan, or marketing campaign
- Artifact needs to be positioned relative to an audience or channel

**SEO Specialist**
Domain: search visibility and organic discoverability
Focus areas:
- Keyword targeting and topical authority signals
- Title, heading, and meta-description optimization
- Internal linking and anchor text quality
- Readability signals that correlate with ranking (structure, depth)
Applicability signals:
- Artifact is a web page, blog post, or landing page
- Artifact mentions traffic, ranking, or search acquisition goals

**UX Writer**
Domain: interface microcopy and user-facing language
Focus areas:
- Button labels, error messages, and empty-state copy
- Onboarding and instructional text clarity
- Consistency of terminology across UI touchpoints
- Cognitive load reduction through plain language
Applicability signals:
- Artifact contains UI copy, tooltips, or error strings
- Artifact is a product specification with user-facing text strings

**Technical Writer**
Domain: technical documentation and developer communication
→ See `## Technical / Code` section for the full Technical Writer entry.
Cross-referenced here because technical writing also serves non-code audiences
(API consumers, integrators, end-user documentation).

**Fact-Checker**
Domain: information accuracy and source verification
Focus areas:
- Claim substantiation and citation quality
- Statistical accuracy and correct interpretation of data
- Currency of references (outdated vs. current information)
- Distinguishing opinion from verifiable fact
Applicability signals:
- Artifact makes specific factual claims, cites data, or references studies
- Artifact is a report, white paper, or journalistic piece

**Brand Voice Reviewer**
Domain: brand identity and voice consistency
Focus areas:
- Adherence to brand tone guidelines (formal/informal, playful/authoritative)
- Consistent use of brand-specific terminology and banned words
- Emotional resonance with the intended brand persona
- Differentiation from competitor voice patterns
Applicability signals:
- Artifact is marketing or external communications copy
- Organization has a documented brand voice guide

**Accessibility Reviewer**
Domain: content accessibility and inclusive communication
Focus areas:
- Plain language compliance and reading ease
- Alt-text quality for images and media
- Color contrast and visual accessibility signals in design mockups
- Inclusive and non-exclusionary language
Applicability signals:
- Artifact targets a broad or regulated audience
- Artifact includes images, tables, or structured visual content

---

## Business / Strategy

> Strategy artifacts: business plans, investor decks, strategy memos, competitive
> analyses, market research, financial models, and go-to-market documents.

**Strategy Consultant**
Domain: business strategy and competitive positioning
Focus areas:
- Clarity and defensibility of the strategic thesis
- Competitive dynamics and sustainable differentiation
- Strategic risk identification and mitigation paths
- Internal consistency of goals, assumptions, and action plans
Applicability signals:
- Artifact is a strategy document, memo, or business plan
- Artifact describes a market position or competitive response

**Financial Analyst**
Domain: financial modeling and business economics
Focus areas:
- Revenue model logic and unit economics soundness
- Cost structure, margin analysis, and break-even assumptions
- Projection methodology and sensitivity to key inputs
- Capital requirements and funding runway analysis
Applicability signals:
- Artifact contains a financial model, P&L projection, or pricing analysis
- Artifact mentions funding, revenue targets, or cost assumptions

**Market Research Analyst**
Domain: market sizing and customer insight
Focus areas:
- Market sizing methodology (TAM/SAM/SOM) and data sources
- Customer segmentation and persona validity
- Demand signals and willingness-to-pay evidence
- Research methodology bias and sample representativeness
Applicability signals:
- Artifact includes market size claims or customer research findings
- Artifact is a market entry or expansion analysis

**Investor Relations Reviewer**
Domain: investor communication and narrative clarity
Focus areas:
- Investment thesis clarity and evidence of traction
- Risk disclosure completeness and balance
- Comparables and benchmark framing appropriateness
- Q&A readiness — anticipating likely investor objections
Applicability signals:
- Artifact is a pitch deck, investment memo, or shareholder letter
- Artifact is targeted at venture capital, private equity, or public investors

**Operations Analyst**
Domain: operational efficiency and process design
Focus areas:
- Process efficiency and elimination of redundant steps
- Scalability of described operations under growth
- Metric definition and measurement feasibility
- Dependency mapping and single-point-of-failure identification
Applicability signals:
- Artifact describes business processes, workflows, or operating procedures
- Artifact mentions headcount, tooling, or process automation

**Legal and Compliance Reviewer**
Domain: regulatory risk and contractual clarity
→ See `## Security / Compliance` section for related compliance roles.
Focus areas:
- Regulatory obligations (data privacy, financial, industry-specific)
- Contractual term risk and ambiguity in obligations
- Intellectual property and licensing exposure
- Disclosure adequacy for regulated communications
Applicability signals:
- Artifact is a contract, terms of service, privacy policy, or regulatory filing
- Artifact involves personal data, financial instruments, or IP licensing

**Go-to-Market Strategist**
Domain: product launch and revenue growth strategy
Focus areas:
- Channel strategy and distribution fit with target segment
- Messaging hierarchy and positioning clarity
- Launch sequencing and milestone definition
- Sales enablement and partner readiness
Applicability signals:
- Artifact is a go-to-market plan, launch brief, or sales playbook
- Artifact defines customer acquisition targets and channel mix

---

## Product / UX

> Product artifacts: PRDs, feature specs, wireframes, user journey maps, usability
> studies, product roadmaps, and design mockups.

**Product Manager**
Domain: product strategy and requirement definition
Focus areas:
- Problem statement clarity and user need validation
- Requirement completeness, prioritization rationale
- Success metrics definition and measurability
- Scope control — what is explicitly out of scope and why
Applicability signals:
- Artifact is a PRD, feature spec, or product brief
- Artifact defines requirements, acceptance criteria, or milestones

**UX Designer**
Domain: user experience and interaction design
Focus areas:
- User flow logical consistency and reduction of friction
- Information hierarchy and visual communication clarity
- Interaction pattern consistency and discoverability
- Mobile and responsive design considerations
Applicability signals:
- Artifact contains wireframes, mockups, or user flow diagrams
- Artifact describes UI screens, navigation, or interaction states

**User Researcher**
Domain: user insight and behavioral validation
Focus areas:
- Research methodology appropriateness for the stated question
- Finding validity — are conclusions supported by data?
- Participant diversity and sample bias evaluation
- Actionability of insights for design or product decisions
Applicability signals:
- Artifact is a usability study report, interview synthesis, or survey analysis
- Artifact makes claims about user behavior, preference, or mental models

**Accessibility Specialist**
Domain: inclusive design and WCAG compliance
Focus areas:
- WCAG 2.1 AA compliance for interactive components
- Screen reader compatibility of semantic markup
- Keyboard navigation completeness
- Color contrast and visual accessibility
Applicability signals:
- Artifact is a UI design, interactive prototype, or front-end specification
- Product serves regulated or public-sector audiences

**Growth Analyst**
Domain: product analytics and growth optimization
Focus areas:
- Funnel instrumentation and event tracking coverage
- Activation, retention, and monetization metric definition
- Experiment design validity (hypothesis, control, sample size)
- Cohort analysis and segmentation methodology
Applicability signals:
- Artifact contains analytics plans, A/B test specs, or growth experiments
- Artifact defines conversion or engagement metrics

**Product Marketer**
Domain: product positioning and value communication
Focus areas:
- Value proposition clarity and differentiation from alternatives
- Messaging resonance with defined target persona
- Feature-to-benefit translation quality
- Competitive positioning and objection handling coverage
Applicability signals:
- Artifact is a positioning document, product page, or feature announcement
- Artifact needs to communicate product value to prospects or users

**Information Architect**
Domain: content structure and navigation design
Focus areas:
- Taxonomy and labeling consistency across the product
- Navigation depth and findability of key content or features
- Search and filter design for content-heavy surfaces
- Mental model alignment between structure and user expectations
Applicability signals:
- Artifact contains a site map, navigation spec, or content taxonomy
- Product has a large content or feature surface area

---

## Security / Compliance

> Security artifacts: threat models, pen-test reports, security policies, audit
> findings, compliance documentation, access control specs, and incident reports.

**Security Auditor**
Domain: application security and threat modeling
Focus areas:
- Authentication and authorization boundary review
- Input validation, injection, and deserialization vulnerabilities
- Secret management and credential exposure paths
- Attack surface analysis against OWASP Top 10 and similar frameworks
Applicability signals:
- Artifact is source code, an API spec, or an architecture diagram
- Artifact handles user authentication, payments, or sensitive data

**Penetration Tester**
Domain: offensive security and vulnerability discovery
Focus areas:
- Exploitability of identified vulnerabilities under real attacker conditions
- Attack chain reconstruction from entry to impact
- Defense bypass techniques and security control gaps
- Remediation priority based on exploitability, not just severity score
Applicability signals:
- Artifact is a pen-test report, bug bounty finding, or security assessment
- Artifact describes exploitable vulnerabilities with reproduction steps

**Privacy Engineer**
Domain: data privacy and regulatory compliance
Focus areas:
- Personal data collection minimization and purpose limitation
- Consent mechanism design and revocability
- Data retention, deletion, and portability compliance
- Cross-border transfer adequacy (GDPR, CCPA, and equivalents)
Applicability signals:
- Artifact processes, stores, or transmits personal data
- Artifact is subject to GDPR, CCPA, HIPAA, or similar regulation

**Compliance Officer**
Domain: regulatory compliance and policy adherence
Focus areas:
- Mapping of artifact obligations to applicable regulatory frameworks
- Policy gap identification relative to current standards
- Audit trail and evidence requirements
- Third-party and vendor compliance verification requirements
Applicability signals:
- Artifact is a compliance policy, audit plan, or regulatory filing
- Organization operates in a regulated industry (finance, healthcare, legal)

**Identity and Access Reviewer**
Domain: identity management and access control
Focus areas:
- Principle of least privilege adherence
- Role assignment correctness and separation of duties
- Authentication strength (MFA, SSO, session management)
- Privileged access monitoring and audit log completeness
Applicability signals:
- Artifact defines roles, permissions, or access control policies
- Artifact includes user management, admin interfaces, or API keys

**Incident Response Analyst**
Domain: security incident management and forensics
Focus areas:
- Detection coverage and alert fidelity assessment
- Containment, eradication, and recovery procedure completeness
- Post-incident review quality and root cause identification
- Communication plan and stakeholder notification requirements
Applicability signals:
- Artifact is an incident report, runbook, or response playbook
- Artifact describes security events or breach scenarios

**Supply Chain Security Reviewer**
Domain: dependency and build pipeline security
Focus areas:
- Dependency integrity verification and update hygiene
- Build pipeline trust boundaries and injection points
- Container and artifact provenance
- Third-party library license and vulnerability exposure
Applicability signals:
- Artifact includes a dependency manifest, Dockerfile, or CI/CD pipeline definition
- Artifact uses or distributes third-party packages

---

## Data / Science

> Data artifacts: analytics reports, data pipelines, machine learning models, data
> schemas, experiment designs, statistical analyses, and dashboards.

**Data Engineer**
Domain: data infrastructure and pipeline design
Focus areas:
- Pipeline reliability, idempotency, and failure recovery
- Schema design, data type correctness, and normalization
- Throughput, latency, and backpressure handling
- Data lineage documentation and observability
Applicability signals:
- Artifact defines ETL/ELT pipelines, data schemas, or streaming jobs
- Artifact processes or transforms data at scale

**Data Analyst**
Domain: data analysis and business intelligence
Focus areas:
- Query logic correctness and aggregation accuracy
- Metric definition consistency with business definitions
- Dashboard design — which metrics matter and why
- Statistical interpretation and avoidance of common fallacies
Applicability signals:
- Artifact is a SQL query set, BI dashboard spec, or analytics report
- Artifact makes data-derived business claims

**Machine Learning Engineer**
Domain: model development and ML systems
Focus areas:
- Feature engineering quality and leakage risk
- Model training, validation, and evaluation methodology
- Serving infrastructure performance and latency
- Model drift monitoring and retraining triggers
Applicability signals:
- Artifact defines a model training pipeline, feature store, or inference service
- Artifact discusses predictions, classifications, or recommendations

**Data Scientist**
Domain: statistical modeling and experimental design
Focus areas:
- Hypothesis formation and testability
- Statistical power, sample size, and significance thresholds
- Bias sources: selection bias, survivorship bias, confounding variables
- Interpretation fidelity — conclusions supported by the data
Applicability signals:
- Artifact is an A/B test design, statistical model, or research analysis
- Artifact draws conclusions from experimental or observational data

**AI Safety Reviewer**
Domain: responsible AI and model risk assessment
Focus areas:
- Hallucination, grounding, and factual reliability assessment
- Bias and fairness evaluation across demographic segments
- Output harmfulness and content safety boundaries
- Human oversight mechanisms and override paths
Applicability signals:
- Artifact is an AI/LLM-powered feature, prompt engineering spec, or model card
- Artifact affects high-stakes decisions (hiring, lending, healthcare, legal)

**Database Administrator**
Domain: data storage, integrity, and performance
Focus areas:
- Index design, query plan efficiency, and lock contention
- Backup, recovery, and point-in-time restore coverage
- Data integrity constraints and referential consistency
- Capacity planning and storage growth projections
Applicability signals:
- Artifact includes database schemas, migration scripts, or query definitions
- Artifact describes data access patterns or performance requirements

**Visualization Designer**
Domain: data visualization and communicative clarity
Focus areas:
- Chart type appropriateness for the data and question
- Axis scaling, labeling, and avoidance of misleading presentation
- Color use for accessibility and differentiation
- Narrative clarity — does the visualization tell the intended story?
Applicability signals:
- Artifact contains charts, graphs, or data dashboards
- Artifact communicates quantitative findings to a non-specialist audience

---

## Design / Creative

> Design artifacts: brand identities, visual design systems, illustrations, motion
> design briefs, photography direction, and creative campaign concepts.

**Brand Designer**
Domain: visual brand identity and design systems
Focus areas:
- Logo, color palette, and typography system coherence
- Design token consistency across digital and print surfaces
- Brand expression scalability from small to large formats
- Differentiation and recognizability relative to category norms
Applicability signals:
- Artifact is a brand identity document, style guide, or design system
- Artifact defines visual language intended for multi-surface use

**UI/Visual Designer**
Domain: interface visual design and aesthetic quality
Focus areas:
- Visual hierarchy, contrast, and attention management
- Spacing, alignment, and grid discipline
- Component visual consistency and design system compliance
- Dark mode, high-contrast, and responsive visual variants
Applicability signals:
- Artifact is a high-fidelity UI mockup or component specification
- Artifact defines visual styles for interactive surfaces

**Motion Designer**
Domain: animation and kinetic design
Focus areas:
- Animation timing, easing, and perceived responsiveness
- Motion's role in communicating state changes and transitions
- Performance cost of animations at target frame rates
- Avoiding vestibular-triggering motion for accessibility
Applicability signals:
- Artifact contains animation specifications, Lottie files, or motion guidelines
- Artifact describes transitions between UI states

**Creative Director**
Domain: creative concept and campaign vision
Focus areas:
- Conceptual clarity and emotional resonance of the creative idea
- Alignment of creative execution with strategic objectives
- Internal consistency across campaign touchpoints
- Cultural sensitivity and audience reception risk
Applicability signals:
- Artifact is a campaign concept, creative brief, or brand campaign
- Artifact requires evaluation of creative merit and strategic fit

**Illustration Reviewer**
Domain: illustration style and communicative effectiveness
Focus areas:
- Style consistency and appropriateness for the intended context
- Clarity of visual metaphors and iconographic meaning
- Scalability and technical format suitability
- Representation and cultural neutrality of depicted subjects
Applicability signals:
- Artifact contains custom illustrations, iconography, or visual metaphors
- Artifact uses visual storytelling as a primary communication method

---

## Operations / Infrastructure

> Infrastructure artifacts: deployment configurations, CI/CD pipeline definitions,
> runbooks, capacity plans, cost analyses, and disaster recovery plans.

**Infrastructure Engineer**
Domain: cloud infrastructure and deployment architecture
Focus areas:
- Resource provisioning correctness and environment parity (dev/staging/prod)
- Networking: ingress, egress, security group, and firewall configuration
- Storage design: persistence, backup, and data locality
- Infrastructure-as-code quality: idempotency, parameterization, drift detection
Applicability signals:
- Artifact is a Terraform/Pulumi/CloudFormation definition or cloud architecture diagram
- Artifact describes deployment topology, networking, or environment configuration

**Platform Engineer**
Domain: developer platforms and internal tooling
Focus areas:
- Developer experience: onboarding speed, self-service capabilities
- Platform abstraction quality and leakage of underlying complexity
- Tooling reliability and incident blast radius
- Golden path compliance and escape hatch design
Applicability signals:
- Artifact describes a developer platform, internal tooling system, or shared service
- Artifact targets internal engineering teams as the primary consumer

**FinOps Analyst**
Domain: cloud cost optimization and financial governance
Focus areas:
- Resource right-sizing and idle resource identification
- Committed use and reservation strategy efficiency
- Cost attribution accuracy across teams or products
- Budget alert coverage and cost anomaly detection
Applicability signals:
- Artifact involves cloud resource allocation, cost reports, or billing analysis
- Artifact describes infrastructure decisions with cost implications

**Capacity Planner**
Domain: resource forecasting and scaling strategy
Focus areas:
- Growth projection methodology and confidence intervals
- Scaling trigger definition (CPU, memory, queue depth, latency)
- Headroom adequacy for peak load scenarios
- Lead time for provisioning versus demand ramp rate
Applicability signals:
- Artifact describes scaling policies, capacity models, or traffic forecasts
- Artifact is a pre-launch or pre-migration infrastructure plan

**Incident Commander**
Domain: incident management and operational response
Focus areas:
- On-call escalation path clarity and coverage completeness
- Runbook accuracy and actionability under stress
- Communication templates and stakeholder update cadence
- Post-mortem process and learning loop closure
Applicability signals:
- Artifact is an incident response runbook, on-call handbook, or post-mortem
- Artifact defines SLOs, error budgets, or operational thresholds

**Release Engineer**
Domain: build, release, and deployment engineering
Focus areas:
- CI/CD pipeline correctness and test gate coverage
- Artifact versioning strategy and release promotion path
- Rollback mechanism reliability and recovery time
- Feature flag governance and progressive rollout controls
Applicability signals:
- Artifact is a CI/CD pipeline definition, release checklist, or deployment runbook
- Artifact governs how software moves from development to production

---

## Extending the Taxonomy

This section documents the append pattern for custom roles and domains.

### Adding a Custom Role to an Existing Domain

1. Identify the most appropriate existing domain section.
2. Append the following template at the end of that domain's role list:

```markdown
**Role Name**
Domain: [2–5 word domain label matching this section]
Focus areas:
- [Specific focus area 1]
- [Specific focus area 2]
- [Optional 3rd focus area]
Applicability signals:
- [Artifact feature or characteristic that makes this role relevant]
- [Optional 2nd signal]
```

3. Use a function-level role name — describe what the expert *does*, not which tool they use.
   - ✅ Good: `Performance Engineer`, `Privacy Counsel`, `Revenue Analyst`
   - ❌ Avoid: `Datadog Expert`, `Figma Designer`, `ChatGPT Reviewer`
4. Bump the `version` field in the YAML frontmatter.

### Adding a Custom Domain

1. Add a new `## Domain Name` section before `## Extending the Taxonomy`.
2. Add a brief domain description in a blockquote (see existing sections for the pattern).
3. Add at least 3 role entries following the template above.
4. Bump the `version` field in the YAML frontmatter.

### Version Bump Pattern

```yaml
---
version: "1.1"   # was "1.0" — added Healthcare domain with 4 roles
```

### Example Custom Role

```markdown
**Clinical Informatics Reviewer**
Domain: healthcare data standards and interoperability
Focus areas:
- HL7 FHIR resource modeling correctness
- EHR integration compatibility and data exchange fidelity
- Clinical terminology mapping (ICD, SNOMED, LOINC)
Applicability signals:
- Artifact involves patient data, clinical workflows, or health system integration
- Artifact references healthcare standards or interoperability requirements
```
