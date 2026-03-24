---
estimated_steps: 4
estimated_files: 2
skills_used: []
---

# T02: Write README.md and CONTRIBUTING.md

**Slice:** S01 — Examples & Documentation
**Milestone:** M003

## Description

Write `README.md` at the project root and `CONTRIBUTING.md`. README is the primary public-facing deliverable for R007: elevator pitch, one-command install, 3 worked examples with sample output. CONTRIBUTING.md explains how to extend the role taxonomy and contribute via fork/PR. Both files depend on the `examples/` directory and `references/role-taxonomy.md` written in T01.

The README's install command is fixed: `npx skills add baagad-ai/expert-opinion -g -y`. No API keys required (D006, R010). Repo URL is `github.com/baagad-ai/expert-opinion` (placeholder — the actual repo is created in S02).

## Steps

1. **Write `README.md`** with this structure:
   - **Header**: skill name and a one-line pitch (e.g., "Multi-expert parallel review for any artifact — code, documents, architecture plans, and more.")
   - **Elevator pitch**: 2–3 sentences describing the problem it solves and how it works at a high level (parallel subagents, one per expert role, synthesized into a prioritized audit).
   - **Install** section: exactly one command — `npx skills add baagad-ai/expert-opinion -g -y` — with a note that no API keys are needed.
   - **Usage** section: "Type `/expert-opinion` in GSD, paste or describe your artifact, and the skill:" followed by the three-phase flow (propose roles → confirm → parallel research → synthesis document).
   - **Examples** section: Three subsections, one per `examples/` subdirectory. Each subsection has:
     - A heading (e.g., "Code Review: Python Auth Module")
     - A brief description of the input (1–2 sentences)
     - An inlined excerpt from the corresponding `synthesis-output.md` — specifically the `<overview>` block and the first 2–3 rows of the `<prioritized_recommendations>` table (shows concrete output format)
     - A link: `→ Full example: examples/01-python-auth-module/`
   - **What it produces** section: brief description of the synthesis document schema (overview, per-role highlights, cross-cutting findings, recommendations table, open questions) — can point to `templates/synthesis-doc.md` as the schema reference.
   - **Contributing** section: link to `CONTRIBUTING.md`.

2. **Confirm README constraints are met**:
   - Install command is exactly `npx skills add baagad-ai/expert-opinion -g -y` (single line, no API keys)
   - All 3 examples are referenced with paths to their `examples/` subdirectories
   - Repo URL `github.com/baagad-ai/expert-opinion` appears as the source/clone URL
   - No placeholder `[TODO]` or unfilled template markers remain
   - File lives at `README.md` (project root — already declared in `pyproject.toml`)

3. **Write `CONTRIBUTING.md`** with this structure:
   - **Welcome** paragraph (1–2 sentences on what contributions are welcome)
   - **Adding a Role to the Taxonomy** section: explain that the taxonomy lives in `references/role-taxonomy.md`; direct contributors to the `## Extending the Taxonomy` section in that file for the step-by-step append-role template — do NOT duplicate it here, just cross-reference it with `references/role-taxonomy.md#extending-the-taxonomy`.
   - **Contribution Workflow** section: fork → create feature branch → make changes → open PR against `main` → describe what you changed and why.
   - **Code of Conduct** section: brief (3–5 sentences) — be respectful, constructive, and inclusive.
   - **Filing Issues** section: describe what to include in a bug report or feature request (steps to reproduce, expected vs. actual behavior, GSD version).

4. Verify both files pass structural checks:
   ```bash
   grep -q "npx skills add baagad-ai/expert-opinion" README.md
   grep -c "examples/" README.md | awk '$1 >= 3 {exit 0} {exit 1}'
   grep -q "role-taxonomy" CONTRIBUTING.md
   grep -q "Extending the Taxonomy" CONTRIBUTING.md
   ! grep -qi "TODO\|TBD\|\[placeholder\]" README.md
   ! grep -qi "TODO\|TBD\|\[placeholder\]" CONTRIBUTING.md
   wc -l README.md | awk '$1 >= 50 {exit 0} {exit 1}'
   wc -l CONTRIBUTING.md | awk '$1 >= 20 {exit 0} {exit 1}'
   ```

## Must-Haves

- [ ] `README.md` exists at project root with install command `npx skills add baagad-ai/expert-opinion -g -y`
- [ ] README references all 3 `examples/` subdirectories (code, business, architecture)
- [ ] README includes inlined synthesis output excerpts so a reader can see what the skill produces before installing
- [ ] README contains no unfilled placeholders (`TODO`, `TBD`, `[placeholder]`)
- [ ] `CONTRIBUTING.md` exists and cross-references `references/role-taxonomy.md`'s `## Extending the Taxonomy` section (does not duplicate the append-role template)
- [ ] Neither file requires any API keys or multi-step setup (D006, R010)
- [ ] README ≥ 50 lines (proves it has substance beyond a stub)
- [ ] CONTRIBUTING.md ≥ 20 lines

## Verification

```bash
# Required files exist
test -f README.md && test -f CONTRIBUTING.md

# README install command present
grep -q "npx skills add baagad-ai/expert-opinion" README.md

# README references all 3 examples
grep -c "examples/" README.md | awk '$1 >= 3 {exit 0} {exit 1}'

# CONTRIBUTING.md cross-references taxonomy
grep -q "role-taxonomy" CONTRIBUTING.md
grep -q "Extending the Taxonomy" CONTRIBUTING.md

# No unfilled placeholders
! grep -qi "TODO\|TBD" README.md
! grep -qi "TODO\|TBD" CONTRIBUTING.md

# Substantive content
wc -l README.md | awk '$1 >= 50 {exit 0} {exit 1}'
wc -l CONTRIBUTING.md | awk '$1 >= 20 {exit 0} {exit 1}'
```

## Inputs

- `examples/01-python-auth-module/synthesis-output.md` — excerpt for README examples section
- `examples/02-saas-pricing-strategy/synthesis-output.md` — excerpt for README examples section
- `examples/03-architecture-decision/synthesis-output.md` — excerpt for README examples section
- `references/role-taxonomy.md` — CONTRIBUTING.md cross-references its `## Extending the Taxonomy` section
- `templates/synthesis-doc.md` — README "What it produces" section describes this schema
- `SKILL.md` — README description of the three-phase flow (intake → research → synthesis)

## Expected Output

- `README.md` — project root; elevator pitch, install command, 3 examples with excerpts, schema description
- `CONTRIBUTING.md` — project root; taxonomy extension guide (cross-reference), fork/PR workflow, code of conduct
