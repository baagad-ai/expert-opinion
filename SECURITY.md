# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | Yes       |

## Reporting a vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Email: security@baagad.ai

Please include:
- A description of the vulnerability
- Steps to reproduce
- Potential impact

You will receive a response within 72 hours. If the issue is confirmed, a fix will be prioritized and a patched version released. You will be credited in the release notes unless you prefer otherwise.

## Security model

This skill's security properties are documented in the README under [Security model](README.md#security-model). Key properties:

- Submitted artifact content is wrapped in `<artifact_data>` boundary tags and treated as data, not instructions
- Research queries are generated from artifact metadata before artifact content is loaded, preventing content-derived query injection
- Subagents receive only their own role's focus questions and pre-approved queries
- No subagent can dispatch further subagents or call arbitrary external services
