---
version: "1.0"
description: >
  Curated taxonomy of expert reviewer roles specific to skill artifacts — SKILL.md files,
  workflow definitions, reference files, output contracts, and agent prompt templates.
  Consumed by workflows/audit-skill.md Phase 4 as the seed candidate pool.
  Intake may propose roles not listed here when the artifact demands it.
---

# Skill Audit Role Taxonomy

Expert roles for auditing agentic skills, agent workflows, and prompt engineering artifacts.
Each role investigates a distinct quality dimension. Together they cover the full surface
area of a skill from first principles to enterprise readiness.

**How to read this file:**
- Each `**Bold Name**` is a reviewer role.
- `Focus areas` describe what the expert investigates.
- `Trigger conditions` describe which artifact features make this role essential vs. optional.
- `Reference standards` name authoritative benchmarks the expert applies.

---

## Core Prompt Engineering

> Foundational quality of the instructions delivered to the executing agent.
> Applicable to all skill files regardless of complexity.

**Prompt Architect**
Domain: prompt design and instruction engineering
Focus areas:
- Instruction clarity, specificity, and freedom from ambiguity
- XML tag semantics and structural coherence (are tags named for what they contain?)
- Routing logic correctness — does every stated trigger map to exactly one workflow?
- Essential principles vs. workflow-specific content separation
- Implicit assumptions that a reasoning agent should not need to make
- Instruction ordering — do prerequisites appear before the steps that depend on them?
Trigger conditions:
- Any SKILL.md file (always applicable)
- Any workflow file that contains conditional logic or branching
Reference standards:
- Anthropic prompting best practices (clarity, directness, XML structure)
- K001 (no markdown headings in skill body) and K002 (SKILL.md ≤ 500 lines)
- SKILL.md template structure: essential_principles, intake, routing blocks

**Cognitive Load Analyst**
Domain: agent cognitive efficiency and context management
Focus areas:
- Context window budget across all files the skill loads at runtime
- Progressive disclosure effectiveness — is heavy content deferred to workflows/references?
- Instruction redundancy: are the same constraints repeated across multiple files?
- Working memory demands: how many things must the agent hold simultaneously in one phase?
- Required reading scope at each phase — is it bounded, or does the agent need everything?
- Noise-to-signal ratio: how many words are filler vs. load-bearing instruction?
Trigger conditions:
- SKILL.md > 200 lines (always trigger)
- Skill has 3+ workflow files
- Skill uses `<required_reading>` blocks (check for over-loading)
Reference standards:
- K002: SKILL.md ≤ 500 lines total
- Context window economics: each loaded reference file costs tokens the agent could spend reasoning
- Progressive disclosure principle: load only what the current phase needs

**Technical Writer Auditor**
Domain: technical documentation and developer communication for agent artifacts
Focus areas:
- Accuracy and completeness of explanations (do they match the actual implementation?)
- Structure, progression, and navigability of SKILL.md and workflow files
- Examples and worked samples — are they present, correct, and representative?
- Audience calibration — is the skill written for a first-time user or an experienced one?
- Terminology consistency — are the same concepts named consistently across all files?
- Onboarding friction — can a new user understand the skill's purpose in under 60 seconds?
Trigger conditions:
- Any skill intended for external or team use (always applicable)
- Skills with more than one workflow (cross-file navigation becomes important)
Reference standards:
- SKILL.md template: description field must state both what AND when to use
- Diátaxis documentation framework (tutorials, how-to guides, reference, explanation)

---

## Workflow & Architecture

> Structural quality of the skill's multi-phase design and subagent orchestration.
> Applicable to skills with workflow files.

**Agentic Workflow Designer**
Domain: agentic systems and multi-step workflow design
Focus areas:
- Phase sequencing and dependency management — does each phase depend only on prior phases?
- Subagent dispatch correctness: parallel where possible, sequential only when order matters
- Input/output contract completeness — are all fields defined, typed, and named consistently?
- Graceful degradation paths — what happens when a subagent fails or returns partial output?
- Phase boundary clarity — does each phase have a clear start condition and exit condition?
- State management between phases — is working state explicit or implicit?
Trigger conditions:
- Skill contains any workflow file (always trigger if workflows/ exists)
- Skill dispatches subagents (parallel vs. sequential correctness is critical)
Reference standards:
- K003: every subagent must receive role identity + full input + focus questions + output template
- P002: fan-out parallel dispatch; orchestrator synthesizes; subagents never communicate
- P003: user confirmation gate before expensive operations
- P004: required_reading block at workflow top

**Output Contract Reviewer**
Domain: API design and schema contracts between agent phases
Focus areas:
- Schema completeness — are all fields defined with types and descriptions?
- Field naming consistency — are the same concepts named identically across producer and consumer?
- Contract stability — are field names stable enough that a consumer won't break on minor updates?
- Emission rules — does the producer document exactly when and how to emit the contract?
- Consumption rules — does the consumer document how it validates and reads the contract?
- Version and backward compatibility — is there a versioning strategy for breaking changes?
Trigger conditions:
- Skill has any inter-phase handoff (output contract files, typed schemas)
- Skill dispatches subagents whose output feeds into a synthesis phase
Reference standards:
- output-contract.md pattern: typed TypeScript interface + emission rules + consumption rules
- API design principle: consumers should fail loudly on schema violations (flag-not-repair)

---

## Security & Trust

> Safety, trust boundaries, and adversarial robustness of the skill's execution model.
> Applicable to skills that accept user input or call external tools.

**Security & Injection Auditor**
Domain: prompt security, trust boundary design, and adversarial robustness
Focus areas:
- Prompt injection surface: where does user-controlled content enter agent instructions?
- Input sanitization: does the skill treat submitted content as data or as instructions?
- Trust boundary enforcement between orchestrator and subagents
- Privilege escalation risk: can a subagent dispatch further subagents or take outward actions?
- Secret and credential exposure: does the skill ever include secrets in context or logs?
- Outward-facing action gates: are destructive or irreversible actions gated on explicit user confirmation?
- Scope creep risk: can a malicious artifact cause the skill to perform unintended operations?
Trigger conditions:
- Skill accepts user-provided file paths, URLs, or inline content (always trigger)
- Skill dispatches subagents with user-controlled content in the task string
- Skill calls web_search, fetch_page, or any external service
Reference standards:
- OWASP Top 10 for LLM Applications (LLM01: Prompt Injection, LLM09: Overreliance)
- Hard rule: never take outward-facing actions without explicit user confirmation
- Principle of least privilege: each phase and subagent gets only the context it needs

---

## Quality & Reliability

> Correctness, edge case coverage, and resilience of the skill across all input conditions.

**Quality & Coverage Analyst**
Domain: skill testing, edge case design, and failure mode analysis
Focus areas:
- Verification criteria completeness — does the skill define done conditions per phase?
- Edge case handling: empty input, malformed input, unsupported input types
- Idempotency: if the skill is run twice on the same input, is the output consistent?
- Failure mode visibility: do errors surface with actionable messages and phase context?
- Partial failure handling: if one subagent fails, does the pipeline degrade gracefully or halt?
- Ambiguity resolution: does the skill have explicit fallback logic for unclear inputs?
- Re-run safety: can the skill be safely interrupted and re-started mid-execution?
Trigger conditions:
- Any skill with multi-phase workflows (always applicable)
- Skills with branching or conditional logic (edge cases multiply at each branch)
Reference standards:
- Work is not done when the code compiles — work is done when verification passes
- Error message standard: errors must include phase context, what was expected, and how to fix
- FAIL-FAST pattern: validate at phase entry, not mid-phase

---

## Enterprise Readiness

> Production readiness, maintainability, and organizational governance of the skill.
> Applicable to skills intended for team or production use.

**Enterprise Readiness Auditor**
Domain: production readiness, observability, and organizational governance
Focus areas:
- Observability: do failure modes produce structured, searchable diagnostic output?
- Maintainability: can a new contributor understand, modify, and extend the skill without the author?
- Contribution path: is there clear guidance on extending the skill (new roles, new workflows)?
- Versioning strategy: is the skill versioned, and is the version surfaced in output?
- Audit trail: does the skill's output include enough context to reconstruct what happened?
- Scalability: does the skill's approach hold up when input size or role count grows?
- Compliance posture: does the skill handle PII, secrets, and external calls appropriately for the org?
- Integration story: how does this skill integrate with adjacent skills and the broader agent ecosystem?
Trigger conditions:
- Skill is intended for use by more than one person (always trigger)
- Skill produces persistent artifacts (output files, database writes)
- Skill calls external services or handles sensitive data
Reference standards:
- Observability principle: structured logs with phase + error context + recovery path
- Agent-first observability: health surfaces, last-error persistence, happy path + diagnostic
- Semantic versioning for skill files (version field in YAML frontmatter)

---

## Role Selection Heuristics

When proposing roles for a skill audit, use this precedence logic:

| Skill Characteristic | Always Include | Conditionally Include |
|---|---|---|
| Any SKILL.md | Prompt Architect, Technical Writer Auditor | — |
| Has workflows/ | Agentic Workflow Designer, Quality & Coverage Analyst | Cognitive Load Analyst (if > 2 workflows) |
| Has output contracts | Output Contract Reviewer | — |
| Accepts user input | Security & Injection Auditor | — |
| Dispatches subagents | Security & Injection Auditor, Output Contract Reviewer | — |
| Calls external services | Security & Injection Auditor | — |
| > 200 lines SKILL.md | Cognitive Load Analyst | — |
| Team/production use | Enterprise Readiness Auditor | — |

**Minimum viable panel:** Prompt Architect + Technical Writer Auditor + Quality & Coverage Analyst (3 roles).
**Full panel:** All 8 roles. Use for skills in active production or scheduled for major revision.

---

## Extending This Taxonomy

To add a new skill-audit role:
1. Identify the most appropriate existing section (or add a new one with a blockquote description).
2. Append using this template:

```markdown
**Role Name**
Domain: [2–5 word domain label]
Focus areas:
- [Specific investigation area 1]
- [Specific investigation area 2]
Trigger conditions:
- [Artifact feature that makes this role relevant]
Reference standards:
- [Authoritative benchmark this expert applies]
```

3. Add the role to the Role Selection Heuristics table.
4. Bump the `version` field in the YAML frontmatter.
