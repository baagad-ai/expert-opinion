#!/usr/bin/env bash
# validate.sh — structural validation for the expert-opinion skill
# Runs 17 checks. Accumulates failures; exits 1 if any check fails.

set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
FAILURES=0

pass() { echo "PASS [$1] $2"; }
fail() { echo "FAIL [$1] $2"; ((FAILURES++)) || true; }

# ---------------------------------------------------------------------------
# Check 1: SKILL.md exists
# ---------------------------------------------------------------------------
if [[ -f "SKILL.md" ]]; then
  pass 1 "SKILL.md exists"
else
  fail 1 "SKILL.md not found"
fi

# ---------------------------------------------------------------------------
# Check 2: SKILL.md line count < 500
# ---------------------------------------------------------------------------
SKILLMD_LINES=$(wc -l < "SKILL.md" 2>/dev/null || echo 999)
if [[ "$SKILLMD_LINES" -lt 500 ]]; then
  pass 2 "SKILL.md line count is ${SKILLMD_LINES} (< 500)"
else
  fail 2 "SKILL.md line count is ${SKILLMD_LINES} (>= 500)"
fi

# ---------------------------------------------------------------------------
# Check 3: <essential_principles> tag present in SKILL.md
# ---------------------------------------------------------------------------
if grep -q '<essential_principles>' "SKILL.md" 2>/dev/null; then
  pass 3 "<essential_principles> tag found in SKILL.md"
else
  fail 3 "<essential_principles> tag missing from SKILL.md"
fi

# ---------------------------------------------------------------------------
# Check 4: <routing> tag present in SKILL.md
# ---------------------------------------------------------------------------
if grep -q '<routing>' "SKILL.md" 2>/dev/null; then
  pass 4 "<routing> tag found in SKILL.md"
else
  fail 4 "<routing> tag missing from SKILL.md"
fi

# ---------------------------------------------------------------------------
# Check 5: All <workflow> paths in SKILL.md routing blocks exist on disk
# ---------------------------------------------------------------------------
WORKFLOW_PATHS=$(grep -oE '<workflow>[^<]+</workflow>' "SKILL.md" 2>/dev/null \
  | sed 's|<workflow>||g;s|</workflow>||g;s/^[[:space:]]*//;s/[[:space:]]*$//' \
  || true)
WORKFLOW_CHECK_FAILED=0
if [[ -z "$WORKFLOW_PATHS" ]]; then
  fail 5 "No <workflow> paths found in SKILL.md"
else
  while IFS= read -r wpath; do
    if [[ -f "$wpath" ]]; then
      : # file exists
    else
      fail 5 "Workflow path not found on disk: $wpath"
      WORKFLOW_CHECK_FAILED=1
    fi
  done <<< "$WORKFLOW_PATHS"
  if [[ "$WORKFLOW_CHECK_FAILED" -eq 0 ]]; then
    pass 5 "All <workflow> paths exist on disk"
  fi
fi

# ---------------------------------------------------------------------------
# Check 6: All <required_reading> paths in workflow files exist on disk
# ---------------------------------------------------------------------------
RR_CHECK_FAILED=0
RR_FOUND=0
for wf in workflows/*.md; do
  [[ -f "$wf" ]] || continue
  RR_PATHS=$(grep -oE '<required_reading>[^<]+</required_reading>' "$wf" 2>/dev/null \
    | sed 's|<required_reading>||g;s|</required_reading>||g;s/^[[:space:]]*//;s/[[:space:]]*$//' \
    || true)
  if [[ -n "$RR_PATHS" ]]; then
    RR_FOUND=1
    while IFS= read -r rpath; do
      if [[ -f "$rpath" ]]; then
        : # file exists
      else
        fail 6 "required_reading path not found: $rpath (in $wf)"
        RR_CHECK_FAILED=1
      fi
    done <<< "$RR_PATHS"
  fi
done
# Zero required_reading tags is acceptable — workflows may not use them
if [[ "$RR_CHECK_FAILED" -eq 0 ]]; then
  pass 6 "All <required_reading> paths resolve (or none declared)"
fi

# ---------------------------------------------------------------------------
# Checks 7–9: Template files exist
# ---------------------------------------------------------------------------
N=7
for tmpl in "templates/expert-report.md" "templates/synthesis-doc.md" "templates/role-proposal.md"; do
  if [[ -f "$tmpl" ]]; then
    pass $N "$tmpl exists"
  else
    fail $N "$tmpl not found"
  fi
  ((N++)) || true
done

# ---------------------------------------------------------------------------
# Checks 10–13: Reference files exist
# ---------------------------------------------------------------------------
N=10
for ref in "references/role-taxonomy.md" "references/output-contract.md" \
           "references/input-handling.md" "references/subagent-prompt.md"; do
  if [[ -f "$ref" ]]; then
    pass $N "$ref exists"
  else
    fail $N "$ref not found"
  fi
  ((N++)) || true
done

# ---------------------------------------------------------------------------
# Check 14: examples/ has at least 3 subdirectories
# ---------------------------------------------------------------------------
EXAMPLE_COUNT=$(find examples -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
if [[ "$EXAMPLE_COUNT" -ge 3 ]]; then
  pass 14 "examples/ has ${EXAMPLE_COUNT} subdirectories (>= 3)"
else
  fail 14 "examples/ has only ${EXAMPLE_COUNT} subdirectory/ies (need >= 3)"
fi

# ---------------------------------------------------------------------------
# Check 15: Each examples/ subdirectory contains input.md, roles-proposed.md,
#           synthesis-output.md
# ---------------------------------------------------------------------------
EX_CHECK_FAILED=0
while IFS= read -r -d '' exdir; do
  for reqfile in input.md roles-proposed.md synthesis-output.md; do
    if [[ ! -f "${exdir}/${reqfile}" ]]; then
      fail 15 "Missing ${reqfile} in ${exdir}"
      EX_CHECK_FAILED=1
    fi
  done
done < <(find examples -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
if [[ "$EX_CHECK_FAILED" -eq 0 ]]; then
  pass 15 "All examples/ subdirectories contain required files"
fi

# ---------------------------------------------------------------------------
# Check 16: README.md exists
# ---------------------------------------------------------------------------
if [[ -f "README.md" ]]; then
  pass 16 "README.md exists"
else
  fail 16 "README.md not found"
fi

# ---------------------------------------------------------------------------
# Check 17: CONTRIBUTING.md exists
# ---------------------------------------------------------------------------
if [[ -f "CONTRIBUTING.md" ]]; then
  pass 17 "CONTRIBUTING.md exists"
else
  fail 17 "CONTRIBUTING.md not found"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
if [[ "$FAILURES" -gt 0 ]]; then
  echo "RESULT: ${FAILURES} check(s) FAILED"
  exit 1
else
  echo "RESULT: All checks PASSED"
  exit 0
fi
