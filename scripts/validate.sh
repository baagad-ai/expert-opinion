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
# Check 4: <routing_decision> tag present in SKILL.md
# ---------------------------------------------------------------------------
if grep -q '<routing_decision>' "SKILL.md" 2>/dev/null; then
  pass 4 "<routing_decision> tag found in SKILL.md"
else
  fail 4 "<routing_decision> tag missing from SKILL.md"
fi

# ---------------------------------------------------------------------------
# Check 5: All workflow files referenced in SKILL.md <file_map> exist on disk
# ---------------------------------------------------------------------------
WORKFLOW_PATHS=$(grep -oE 'workflows/[a-zA-Z0-9_-]+\.md' "SKILL.md" 2>/dev/null | sort -u || true)
WORKFLOW_CHECK_FAILED=0
if [[ -z "$WORKFLOW_PATHS" ]]; then
  fail 5 "No workflow file references found in SKILL.md"
else
  while IFS= read -r wpath; do
    if [[ -f "$wpath" ]]; then
      : # file exists
    else
      fail 5 "Workflow file not found on disk: $wpath"
      WORKFLOW_CHECK_FAILED=1
    fi
  done <<< "$WORKFLOW_PATHS"
  if [[ "$WORKFLOW_CHECK_FAILED" -eq 0 ]]; then
    pass 5 "All workflow files referenced in SKILL.md exist on disk"
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
# Check 18: required_reading paths in workflow files resolve on disk
# Only lines whose first token looks like a file path (contains /) are checked.
# Inline mentions of <required_reading> inside backtick code spans are skipped
# by requiring the tag to appear on a line that is not inside a fenced code block.
# ---------------------------------------------------------------------------
RR18_FAILED=0
for wf in workflows/*.md; do
  [[ -f "$wf" ]] || continue
  in_block=0
  in_fence=0
  while IFS= read -r line; do
    # Toggle fenced-code-block state (``` lines) — never parse paths inside fences
    if echo "$line" | grep -qE '^[[:space:]]*```'; then
      [[ "$in_fence" -eq 0 ]] && in_fence=1 || in_fence=0
      continue
    fi
    [[ "$in_fence" -eq 1 ]] && continue
    # Detect <required_reading> open/close only on unindented or lightly indented lines
    if echo "$line" | grep -qE '^[[:space:]]*<required_reading>[[:space:]]*$'; then in_block=1; continue; fi
    if echo "$line" | grep -qE '^[[:space:]]*</required_reading>[[:space:]]*$'; then in_block=0; continue; fi
    if [[ "$in_block" -eq 1 ]]; then
      # Extract first token and accept only if it contains a slash (looks like a path)
      rpath=$(echo "$line" | sed 's/^[[:space:]]*//' | awk '{print $1}')
      [[ -z "$rpath" ]] && continue
      # Must contain a slash to be treated as a file path
      [[ "$rpath" != */* ]] && continue
      if [[ ! -f "$rpath" ]]; then
        fail 18 "required_reading path not found: '$rpath' (in $wf)"
        RR18_FAILED=1
      fi
    fi
  done < "$wf"
done
[[ "$RR18_FAILED" -eq 0 ]] && pass 18 "All required_reading paths resolve on disk"

# ---------------------------------------------------------------------------
# Check 19: No hardcoded skill_version strings in workflow files
# (should use {skill_version} placeholder, not a literal version string)
# ---------------------------------------------------------------------------
VER19_FAILED=0
for wf in workflows/*.md; do
  [[ -f "$wf" ]] || continue
  # Find skill_version lines that contain a quoted literal (not a placeholder)
  HARDCODED=$(grep -E 'skill_version:[[:space:]]*"[0-9]+\.[0-9]+' "$wf" 2>/dev/null || true)
  if [[ -n "$HARDCODED" ]]; then
    fail 19 "Hardcoded skill_version found in $wf (use {skill_version} placeholder): $HARDCODED"
    VER19_FAILED=1
  fi
done
[[ "$VER19_FAILED" -eq 0 ]] && pass 19 "No hardcoded skill_version strings in workflow files"

# ---------------------------------------------------------------------------
# Check 20: Required output-contract field names appear in their consuming workflow
# S01→S02 fields must appear in research.md; S02→S03 fields must appear in synthesis.md
# ---------------------------------------------------------------------------
FIELD20_FAILED=0
# IntakeOutputPackage fields consumed by research.md (S01→S02 boundary)
for field in "confirmed_roles" "normalized_input" "inferred_context"; do
  if ! grep -qE "$field" workflows/research.md 2>/dev/null; then
    fail 20 "S01→S02 contract field '$field' not found in workflows/research.md"
    FIELD20_FAILED=1
  fi
done
# ResearchOutputPackage fields consumed by synthesis.md (S02→S03 boundary)
for field in "reports" "metadata" "completed_roles"; do
  if ! grep -qE "$field" workflows/synthesis.md 2>/dev/null; then
    fail 20 "S02→S03 contract field '$field' not found in workflows/synthesis.md"
    FIELD20_FAILED=1
  fi
done
[[ "$FIELD20_FAILED" -eq 0 ]] && pass 20 "All required contract field names present in consuming workflows"

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
