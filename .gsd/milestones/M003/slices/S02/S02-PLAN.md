# S02: Validation & Release

**Goal:** Skill validation script passes with zero errors, v1.0.0 is tagged on GitHub, and the repo is public.
**Demo:** `bash scripts/validate.sh` exits 0; `gh release view v1.0.0 --repo baagad-ai/expert-opinion` returns the release; `gh repo view baagad-ai/expert-opinion --json visibility -q .visibility` prints `PUBLIC`.

## Must-Haves

- `scripts/validate.sh` exists, is executable, and exits 0 on the current working tree
- `CHANGELOG.md` exists at project root with a v1.0.0 entry
- `pyproject.toml` version is `1.0.0`
- All local commits pushed to `baagad-ai/expert-opinion` `main` branch
- Repo visibility is public on GitHub
- Tag `v1.0.0` exists on remote
- GitHub Release `v1.0.0` created with install command in release notes

## Proof Level

- This slice proves: final-assembly
- Real runtime required: yes (gh CLI, GitHub API)
- Human/UAT required: no

## Verification

```bash
# Validation script passes
bash scripts/validate.sh && echo "All checks passed"

# Repo is public
gh repo view baagad-ai/expert-opinion --json visibility -q .visibility | grep -i PUBLIC

# Release exists
gh release view v1.0.0 --repo baagad-ai/expert-opinion
```

## Integration Closure

- Upstream surfaces consumed: `SKILL.md`, `workflows/`, `references/`, `templates/`, `examples/`, `README.md`, `CONTRIBUTING.md` (all from M001–M003/S01)
- New wiring introduced in this slice: `git remote origin` → `baagad-ai/expert-opinion`; `scripts/validate.sh` as the structural regression guard
- What remains before the milestone is truly usable end-to-end: nothing — after T02 the repo is public and tagged

## Tasks

- [ ] **T01: Write validate.sh, CHANGELOG.md, and bump version to 1.0.0** `est:45m`
  - Why: Creates the validation gate and release prep files; validate.sh must pass locally before anything is pushed
  - Files: `scripts/validate.sh`, `CHANGELOG.md`, `pyproject.toml`
  - Do: Write `scripts/validate.sh` with the 17 checks defined in the research doc (SKILL.md existence/line count, required XML tags, workflow path resolution, required_reading path resolution, template files, reference files, examples structure, README, CONTRIBUTING). Run `bash scripts/validate.sh` — must exit 0. Write `CHANGELOG.md` with a single v1.0.0 entry listing the three milestone pillars. Change `pyproject.toml` version from `0.1.0` to `1.0.0`. Commit all three files with message `chore(release): v1.0.0 — scripts/validate.sh, CHANGELOG.md, version bump`.
  - Verify: `bash scripts/validate.sh; echo "exit:$?"` prints `exit:0`; `grep '1.0.0' pyproject.toml` matches; `test -f CHANGELOG.md`
  - Done when: validate.sh exits 0, CHANGELOG.md exists, pyproject.toml shows `1.0.0`, all committed

- [ ] **T02: Push to GitHub, publish repo, tag v1.0.0, create release** `est:30m`
  - Why: Makes the skill publicly installable and creates the canonical v1.0.0 release
  - Files: `.git/config` (remote added), remote `main` branch, remote tag `v1.0.0`
  - Do: Add remote with `git remote add origin https://github.com/baagad-ai/expert-opinion.git`. Force-push local `milestone/M003` to remote `main` (`git push --force origin milestone/M003:main`). Flip repo visibility with `gh repo edit baagad-ai/expert-opinion --visibility public`. Create and push tag: `git tag v1.0.0 && git push origin v1.0.0`. Create GitHub Release: `gh release create v1.0.0 --title "v1.0.0 — expert-opinion skill" --notes "..."` (notes should include the install command and one-line description). Verify each step before proceeding to the next.
  - Verify: `gh repo view baagad-ai/expert-opinion --json visibility -q .visibility | grep -i PUBLIC`; `gh release view v1.0.0 --repo baagad-ai/expert-opinion`
  - Done when: repo is public, tag v1.0.0 is on remote, GitHub Release exists with install command in notes

## Files Likely Touched

- `scripts/validate.sh`
- `CHANGELOG.md`
- `pyproject.toml`
- `.git/config` (remote origin added)
