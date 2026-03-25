# expert-opinion

## What it does

Submit any artifact and get a prioritized audit document written by a panel of domain experts running in parallel. Each expert produces grounded findings with evidence references. The skill synthesizes them into a ranked recommendation table with cross-cutting signal, contradictions surfaced, and a phased remediation plan.

For GSD skill directories, a dedicated audit pipeline runs structural pre-validation, a skill-specific expert panel, and a 5-dimension maturity scorecard.

## Usage

```
# General artifact review
/expert-opinion https://example.com/my-api-spec.yaml

# Review a local file
/expert-opinion ./src/auth/handler.py

# Paste inline content
/expert-opinion
> <paste your document, code, or proposal here>

# Skill audit
/expert-opinion ~/.gsd/agent/skills/my-skill/
```

The skill will:
1. Detect the input type and normalize the artifact
2. Propose a panel of 5–10 domain experts relevant to your artifact
3. Ask you to confirm, edit, or cancel the panel
4. Dispatch each expert in parallel (one subagent per role)
5. Synthesize findings into a single audit document saved as `expert-opinion-YYYY-MM-DD-HHmm.md`

## Example output

The following is a real excerpt from `examples/01-python-auth-module/synthesis-output.md`:

```xml
<overview>
artifact: "Python JWT authentication module (auth/jwt_handler.py, ~60 LOC, API gateway auth layer)"
scope: "Security posture, cryptographic correctness, API surface safety, performance resilience, test coverage, secrets hygiene, documentation adequacy"
experts_consulted: "Security Auditor, Cryptography Specialist, API Designer, Performance Engineer, Test Coverage Analyst, DevSecOps Engineer, Documentation Reviewer"
review_date: "2024-01-15"
overall_risk: "critical"
one_line_verdict: "This module has a hardcoded HS256 secret and no token expiry enforcement — any token issued is permanently valid and the secret is almost certainly already in version-control history."
</overview>
```

**Top 3 recommendations (from the same run):**

| Rank | Recommendation | Source | Effort | Impact |
|------|---------------|--------|--------|--------|
| 1 | Replace hardcoded `SECRET_KEY` with `os.environ["JWT_SECRET_KEY"]` and raise at import if absent; add `detect-secrets` to CI | DevSecOps:F1, Security:X1 | low | Eliminates permanent credential exposure in VCS and container images |
| 2 | Add `exp` claim to `create_token`; reject tokens missing `exp` explicitly | Crypto:F1, Security:X2 | low | Bounds blast radius of any token theft to the TTL window |
| 3 | Remove or gate the public `POST /auth/verify` endpoint; rate-limit; strip `claims` from response | API:F1, Perf:F1, Security:X3 | medium | Eliminates oracle + DoS surface; stops leaking user payload to anonymous callers |

The above excerpt is representative of the skill's output format for a typical security-focused review.

## Security notes

- URL and file inputs are fetched and wrapped in `<artifact_data>` content-boundary tags before being passed to subagents. Any instructions embedded in submitted content are treated as artifact text, not as commands.
- Subagents are restricted to in-context analysis only — no external tool calls (`search-the-web`, `fetch_page`, `mcp_call`) are permitted during expert review.

## Files

```
SKILL.md                     — router + principles
workflows/
  intake.md                  — input detection, normalization, role proposal
  research.md                — parallel subagent dispatch
  synthesis.md               — convergence, contradiction, ranked output
  audit-skill.md             — GSD skill audit pipeline (S01 → S02 → S03)
references/
  output-contract.md         — S01↔S02 and S02↔S03 typed schemas (schema v1.0)
  skill-audit-contract.md    — skill audit typed schemas (schema v1.0)
  input-handling.md          — input type detection and normalization rules (canonical source)
  subagent-prompt.md         — expert subagent task template (K003 four-component)
  skill-audit-roles.md       — expert role taxonomy for skill audits
templates/
  expert-report.md           — per-expert output template
  synthesis-doc.md           — final audit document template
  skill-audit-doc.md         — skill audit document template
  skill-expert-report.md     — per-expert template for skill audits
  role-proposal.md           — role proposal display format
```
