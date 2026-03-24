# Proposed Expert Roles — Python JWT Authentication Module

The following 7 expert perspectives have been identified as most relevant to this artifact.
Each expert will investigate specific aspects of the submission in parallel,
then findings will be synthesized into a prioritized audit document.

---

**Security Auditor**
*Application security, authentication & authorization attack surface*

Focus questions for this artifact:
- Does the token issuance flow prevent token forgery, replay attacks, or privilege escalation?
- Is the public `/auth/verify` endpoint exposing information that aids enumeration or brute-force?
- Are secrets managed securely, or does the code embed credentials that could leak via version control?

---

**Cryptography Specialist**
*Cryptographic protocol correctness, algorithm selection, key management*

Focus questions for this artifact:
- Is HS256 with a symmetric key appropriate for this gateway's trust model, or does the issuer-verifier topology require asymmetric signing (RS256/ES256)?
- Is the token missing standard claims (`exp`, `nbf`, `jti`) that are required by RFC 7519 for production JWT use?
- Does the hardcoded `SECRET_KEY` provide sufficient entropy, and what rotation path exists?

---

**API Designer**
*REST API contracts, endpoint semantics, error response design*

Focus questions for this artifact:
- Does the `/auth/verify` public endpoint follow the principle of least privilege — is exposing token decode results to arbitrary callers appropriate?
- Are the error response bodies consistent and safe (do they avoid leaking internal state in error messages)?
- Is the `require_auth` decorator correctly handling edge cases in the `Authorization` header parsing?

---

**Performance Engineer**
*Latency, throughput, resource utilization under load*

Focus questions for this artifact:
- Is the `/auth/verify` endpoint vulnerable to CPU-based denial-of-service via high-volume token verification requests with no rate limiting?
- Does `jwt.decode` involve any blocking I/O or shared-state contention that would degrade under concurrent requests?
- Is there a token caching layer, or is every request decoding the JWT from scratch?

---

**Test Coverage Analyst**
*Unit test completeness, integration test gaps, boundary condition coverage*

Focus questions for this artifact:
- Are there tests covering the failure paths: expired tokens, tampered signatures, missing claims, malformed headers?
- Does the `require_role` decorator have test coverage for the case where `request.user` is absent (no prior `require_auth`)?
- Is the `/auth/verify` endpoint tested for the unauthenticated, valid, and malformed-input cases?

---

**DevSecOps Engineer**
*Secrets management, CI/CD security posture, supply chain & runtime hygiene*

Focus questions for this artifact:
- Is `SECRET_KEY = "dev-secret-key-dont-use-in-prod"` likely to reach a production environment via environment variable misconfiguration or container image layering?
- Is there a secrets scanning step in CI that would catch this hardcoded key before merge?
- Does the logging of `jwt.decode` exceptions risk emitting token data or stack traces that expose internal routing logic?

---

**Documentation Reviewer**
*Code clarity, maintainable comments, API contract documentation*

Focus questions for this artifact:
- Are the decorator docstrings accurate and sufficient for a developer integrating this module for the first time?
- Is the comment `# Exposed publicly — clients can verify tokens directly` the full extent of security guidance, or should this have explicit threat-model notes?
- Are there missing type annotations or return-type contracts that would cause downstream type-checker failures?

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
