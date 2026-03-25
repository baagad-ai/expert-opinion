---
estimated_steps: 5
estimated_files: 3
skills_used:
  - lint
  - best-practices
---

# T01: Write validate.sh, CHANGELOG.md, and bump version to 1.0.0

**Slice:** S02 — Validation & Release
**Milestone:** M003

## Description

Create `scripts/validate.sh` — a pure-bash structural validation script with 17 checks covering SKILL.md structure, workflow path resolution, required_reading path resolution, template files, reference files, example structure, README, and CONTRIBUTING.md. Run it to confirm zero errors. Create `CHANGELOG.md` with the v1.0.0 release entry. Bump `pyproject.toml` version from `0.1.0` to `1.0.0`. Commit all three files.

The validation script is the primary proof artifact for this milestone — it must pass before anything is pushed to GitHub.

## Steps

1. **Write `scripts/validate.sh`** with these 17 checks, collecting all failures and reporting at end (do not fail-fast):
   - [1] `SKILL.md` exists
   - [2] `SKILL.md` line count < 500
   - [3] `<essential_principles>` tag present in `SKILL.md`
   - [4] `<routing>` tag present in `SKILL.md`
   - [5] All `<workflow>` paths extracted from `SKILL.md` routing blocks exist on disk — use `grep -oP '(?<=<workflow>)[^<]+(?=</workflow>)'` to extract, strip whitespace, then `-f` test each path. Pipe grep through `|| true` to avoid exit 1 on zero matches.
   - [6] All `<required_reading>` paths in each workflow file exist on disk — iterate over `workflows/*.md`, extract paths with `grep -oP '(?<=<required_reading>)[^<]+(?=</required_reading>)'`, strip whitespace, test each. Pipe through `|| true`.
   - [7] `templates/expert-report.md` exists
   - [8] `templates/synthesis-doc.md` exists
   - [9] `templates/role-proposal.md` exists
   - [10] `references/role-taxonomy.md` exists
   - [11] `references/output-contract.md` exists
   - [12] `references/input-handling.md` exists
   - [13] `references/subagent-prompt.md` exists
   - [14] `examples/` has at least 3 subdirectories
   - [15] Each `examples/` subdirectory contains `input.md`, `roles-proposed.md`, `synthesis-output.md`
   - [16] `README.md` exists
   - [17] `CONTRIBUTING.md` exists
   
   Script structure: accumulate failures in a `FAILURES` counter; echo PASS/FAIL per check; at end, if `FAILURES > 0` exit 1 else exit 0. Make executable with `chmod +x scripts/validate.sh`.

2. **Run `bash scripts/validate.sh`** from the project root. Fix any failures before continuing. Expected: 17/17 PASS.

3. **Write `CHANGELOG.md`** at project root with a single `## [1.0.0] — 2026-03-25` section listing:
   - M001: Core skill engine (intake, role proposal, parallel expert research, synthesis)
   - M002: Input handling & verification (5 input types, verification record)
   - M003: Open source readiness (README, 3 worked examples, CONTRIBUTING, validation script)
   - Install command: `npx skills add baagad-ai/expert-opinion -g -y`

4. **Bump version in `pyproject.toml`**: change `version = "0.1.0"` → `version = "1.0.0"`.

5. **Commit**: `git add scripts/validate.sh CHANGELOG.md pyproject.toml && git commit -m "chore(release): v1.0.0 — scripts/validate.sh, CHANGELOG.md, version bump"`

## Must-Haves

- [ ] `scripts/validate.sh` is executable and exits 0 when run from project root
- [ ] All 17 checks report PASS — no FAIL lines in output
- [ ] `CHANGELOG.md` exists with a `1.0.0` section
- [ ] `pyproject.toml` has `version = "1.0.0"`
- [ ] All three files committed in a single commit

## Verification

```bash
bash scripts/validate.sh; echo "exit:$?"
# Expected: 17 PASS lines, then "exit:0"

grep 'version = "1.0.0"' pyproject.toml
# Expected: matches

test -f CHANGELOG.md && grep -q "1.0.0" CHANGELOG.md && echo "changelog ok"
# Expected: "changelog ok"

git log --oneline -1
# Expected: commit message contains "chore(release): v1.0.0"
```

## Inputs

- `SKILL.md` — source for checks 1–5
- `workflows/intake.md`, `workflows/research.md`, `workflows/synthesis.md` — source for check 6
- `templates/expert-report.md`, `templates/synthesis-doc.md`, `templates/role-proposal.md` — source for checks 7–9
- `references/role-taxonomy.md`, `references/output-contract.md`, `references/input-handling.md`, `references/subagent-prompt.md` — source for checks 10–13
- `examples/01-python-auth-module/`, `examples/02-saas-pricing-strategy/`, `examples/03-architecture-decision/` — source for checks 14–15
- `README.md`, `CONTRIBUTING.md` — source for checks 16–17
- `pyproject.toml` — version field to bump

## Expected Output

- `scripts/validate.sh` — executable bash script, exits 0 on current working tree, 17 checks
- `CHANGELOG.md` — v1.0.0 release notes with three milestone pillars and install command
- `pyproject.toml` — version bumped to `1.0.0`
