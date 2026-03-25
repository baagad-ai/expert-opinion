<div align="center">

# expert-opinion

**Multi-expert parallel review for any artifact.**

Submit code, docs, architecture plans, or a URL. A panel of domain experts reviews it in parallel — each grounded in evidence, each focused on a different lens — and the findings are synthesized into one ranked audit document.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/baagad-ai/expert-opinion/releases/tag/v1.0.0)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

</div>

---

## What makes it different

Most review tools give you a single perspective. This one gives you five to ten, all running at the same time.

- **Parallel** — every expert runs as a separate subagent concurrently. No sequential bottleneck.
- **Grounded** — every finding must cite a specific line, quote, or concrete observation. No surface-level feedback.
- **Synthesized** — the final document surfaces cross-cutting signals, resolves contradictions between experts, and ranks recommendations by impact.
- **Confirmed** — you see the proposed expert panel and approve it before any review begins.
- **Skill-aware** — for directories containing `SKILL.md`, a specialized audit pipeline runs with a 5-dimension maturity scorecard.

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
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
   [Expert 1]    [Expert 2]   [Expert N]   ← parallel subagents
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

# Review a URL
/expert-opinion https://example.com/my-api-spec.yaml

# Paste inline content
/expert-opinion
> <paste your document, code, or proposal here>

# Review a codebase directory
/expert-opinion ./my-project/

# Audit a skill directory
/expert-opinion ./my-skill/
```

The skill will:
1. Detect the input type and normalize the artifact
2. Propose a panel of 5–10 domain experts specific to your artifact
3. Ask you to confirm, edit, or cancel the panel
4. Dispatch each expert in parallel (one subagent per role)
5. Synthesize findings into a single audit document saved as `expert-opinion-YYYY-MM-DD-HHmm.md`

---

## Example output

A representative synthesis excerpt (Python JWT auth module review):

```xml
<overview>
artifact: "Python JWT authentication module (auth/jwt_handler.py, ~60 LOC, API gateway auth layer)"
scope: "Security posture, cryptographic correctness, API surface safety, performance resilience,
        test coverage, secrets hygiene, documentation adequacy"
experts_consulted: "Security Auditor, Cryptography Specialist, API Designer, Performance Engineer,
                    Test Coverage Analyst, DevSecOps Engineer, Documentation Reviewer"
review_date: "2026-01-15"
overall_risk: "critical"
one_line_verdict: "This module has a hardcoded HS256 secret and no token expiry enforcement —
                   any token issued is permanently valid and the secret is almost certainly
                   already in version-control history."
</overview>
```

**Top 3 recommendations from that run:**

| Rank | Recommendation | Source | Effort | Impact |
|------|----------------|--------|--------|--------|
| 1 | Replace hardcoded `SECRET_KEY` with `os.environ["JWT_SECRET_KEY"]`; raise at import if absent; add `detect-secrets` to CI | DevSecOps:F1, Security:X1 | low | Eliminates permanent credential exposure in VCS and container images |
| 2 | Add `exp` claim to `create_token`; reject tokens missing `exp` explicitly | Crypto:F1, Security:X2 | low | Bounds blast radius of any token theft to the TTL window |
| 3 | Remove or gate the public `POST /auth/verify` endpoint; rate-limit; strip `claims` from response | API:F1, Perf:F1, Security:X3 | medium | Eliminates oracle + DoS surface; stops leaking user payload to anonymous callers |

> Cross-cutting findings (like `Security:X1` above) are observations where two or more independent experts flagged the same root cause without coordinating. These rank above equal-severity single-expert findings.

---

## Installation

Copy the skill directory to wherever your agentic platform loads skills from.

**Claude Code:**
```bash
# User-level (available in all projects)
cp -r expert-opinion/ ~/.claude/skills/expert-opinion/

# Or project-level (available in this project only)
cp -r expert-opinion/ .claude/skills/expert-opinion/
```

**Other platforms:** place the directory where your agent discovers skills, then reference it as `expert-opinion`.

---

## Security model

- **Input isolation** — URL and file content is wrapped in `<artifact_data>` boundary tags before being passed to subagents. Any instructions embedded in submitted content are treated as artifact text, not as commands.
- **Pre-approved queries only** — research queries are generated from artifact metadata *before* artifact content is loaded. Subagents receive only pre-approved queries; they cannot derive new searches from the content they are reviewing.
- **Subagent scope restriction** — subagents are restricted to in-context analysis and their pre-approved queries. They cannot dispatch further subagents or call arbitrary external services.
- **Confirmation gate** — no expert research begins until you approve the proposed panel. You can add, remove, or cancel any role before any cost is incurred.

---

## Files

```
SKILL.md                     — router + essential principles
workflows/
  intake.md                  — input detection, normalization, role proposal
  research.md                — parallel subagent dispatch
  synthesis.md               — convergence, contradiction, ranked output
  audit-skill.md             — skill audit pipeline (S01 → S02 → S03)
references/
  output-contract.md         — S01↔S02 and S02↔S03 typed schemas (schema v1.0)
  skill-audit-contract.md    — skill audit typed schemas (schema v1.0)
  input-handling.md          — input type detection and normalization rules
  subagent-prompt.md         — expert subagent task template
  skill-audit-roles.md       — expert role taxonomy for skill audits
templates/
  expert-report.md           — per-expert output template
  synthesis-doc.md           — final audit document template
  skill-audit-doc.md         — skill audit document template
  skill-expert-report.md     — per-expert template for skill audits
  role-proposal.md           — role proposal display format
```

---

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Ideas for contributions:
- New expert role definitions in `references/skill-audit-roles.md`
- Example artifacts and their review outputs
- Input type support (new normalization strategies)
- Bug reports with reproducible inputs

---

## License

MIT — see [LICENSE](LICENSE).
