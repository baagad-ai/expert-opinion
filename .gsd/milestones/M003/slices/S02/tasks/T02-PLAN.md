---
estimated_steps: 5
estimated_files: 2
skills_used:
  - gh
---

# T02: Push to GitHub, publish repo, tag v1.0.0, create release

**Slice:** S02 — Validation & Release
**Milestone:** M003

## Description

Wire the local repo to the existing private GitHub repo `baagad-ai/expert-opinion`, force-push the local `milestone/M003` branch to remote `main`, flip visibility to public, create and push tag `v1.0.0`, and create the GitHub Release. After this task the skill is publicly installable via the one-command install in README.md.

**Pre-conditions (must be true before starting):**
- T01 is complete: `bash scripts/validate.sh` exits 0, CHANGELOG.md exists, pyproject.toml has `1.0.0`, all committed
- `gh auth status` is authenticated as `baagad-ai`
- `git remote -v` is empty (no origin configured yet)

## Steps

1. **Add remote origin:**
   ```bash
   git remote add origin https://github.com/baagad-ai/expert-opinion.git
   ```

2. **Force-push local branch to remote main** (remote main has divergent prior content with no shared history):
   ```bash
   git push --force origin milestone/M003:main
   ```
   Verify push succeeded before continuing.

3. **Make repo public:**
   ```bash
   gh repo edit baagad-ai/expert-opinion --visibility public
   ```
   Verify: `gh repo view baagad-ai/expert-opinion --json visibility -q .visibility` prints `PUBLIC`.

4. **Create and push tag v1.0.0** (must be AFTER the force push so the tag points at the commit now on remote main):
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

5. **Create GitHub Release:**
   ```bash
   gh release create v1.0.0 \
     --repo baagad-ai/expert-opinion \
     --title "v1.0.0 — expert-opinion skill" \
     --notes "## expert-opinion v1.0.0

   Get multi-perspective expert analysis on any artifact — code, documents, architecture decisions — using parallel AI subagents.

   **Install:**
   \`\`\`
   npx skills add baagad-ai/expert-opinion -g -y
   \`\`\`

   **What's in this release:**
   - Core skill engine: intake, role proposal, parallel expert research (M001)
   - Input handling for 5 input types: raw text, file, codebase, URL, pasted content (M002)
   - README, 3 worked examples, CONTRIBUTING guide, structural validation script (M003)

   See README.md for usage and examples."
   ```

## Must-Haves

- [ ] `git remote -v` shows `origin https://github.com/baagad-ai/expert-opinion.git`
- [ ] Remote `main` branch contains the T01 commit (validate.sh + CHANGELOG.md + version bump)
- [ ] Repo visibility is `PUBLIC`
- [ ] Tag `v1.0.0` exists on remote
- [ ] GitHub Release `v1.0.0` exists and contains the install command in its body

## Verification

```bash
# Remote is configured
git remote -v | grep "baagad-ai/expert-opinion"

# Repo is public
gh repo view baagad-ai/expert-opinion --json visibility -q .visibility | grep -i PUBLIC

# Release exists
gh release view v1.0.0 --repo baagad-ai/expert-opinion

# Install command in release notes
gh release view v1.0.0 --repo baagad-ai/expert-opinion --json body -q .body | grep "npx skills add"
```

## Inputs

- `scripts/validate.sh` — created in T01; must exit 0 before this task runs
- `CHANGELOG.md` — created in T01; must exist and contain `1.0.0`
- `pyproject.toml` — bumped to `1.0.0` in T01
- `README.md` — contains canonical install command to echo in release notes

## Expected Output

- `.git/config` — remote `origin` added pointing to `https://github.com/baagad-ai/expert-opinion.git`
- Remote branch `main` on `github.com/baagad-ai/expert-opinion` — updated to current `milestone/M003` HEAD
- Remote tag `v1.0.0` on `github.com/baagad-ai/expert-opinion`
- GitHub Release `v1.0.0` at `https://github.com/baagad-ai/expert-opinion/releases/tag/v1.0.0`
