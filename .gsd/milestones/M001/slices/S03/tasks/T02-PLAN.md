---
estimated_steps: 3
estimated_files: 1
skills_used:
  - writing-skills
  - verification-before-completion
---

# T02: Update SKILL.md route and run full verification

**Slice:** S03 — Synthesis & Final Output
**Milestone:** M001

## Description

Replace the 6-line `<!-- S03 will add: ... -->` placeholder comment block in `SKILL.md` with a live `<route id="synthesis">` pointing to `workflows/synthesis.md`. Then run the complete S03 verification suite to confirm all checks pass. This is a small but critical wiring step — without it, the three-route pipeline (intake → research → synthesis) is not connected and the skill cannot route to synthesis.

**Prerequisite:** `workflows/synthesis.md` must exist (produced by T01).

## Steps

1. Read `SKILL.md` to locate the exact placeholder block. It looks like:
   ```
   <!-- S03 will add:
   <route id="synthesis" trigger="all_reports_collected">
     <description>Synthesizes expert reports into a prioritized audit document.</description>
     <workflow>workflows/synthesis.md</workflow>
   </route>
   -->
   ```
   Note the exact whitespace and line count — `edit` requires an exact match.

2. Replace the placeholder block with the live route:
   ```xml
   <route id="synthesis" trigger="all_reports_collected">
     <description>
       Synthesizes collected expert reports into a prioritized audit document.
       Identifies convergent findings, surfaces contradictions, and emits a ranked
       recommendation table. Saves output to expert-opinion-{YYYY-MM-DD-HHmm}.md.
     </description>
     <workflow>workflows/synthesis.md</workflow>
     <phases>receive → analyze → synthesize → deliver</phases>
   </route>
   ```
   Use the `edit` tool with the exact old text. Do NOT introduce any markdown headings (K001).

3. Run the full S03 verification suite:
   ```bash
   [ -f workflows/synthesis.md ] && echo "PASS: synthesis.md exists" || echo "FAIL"
   grep -q 'route id="synthesis"' SKILL.md && echo "PASS: route live" || echo "FAIL"
   grep -q 'ResearchOutputPackage' workflows/synthesis.md && echo "PASS: input schema ref" || echo "FAIL"
   grep -q 'synthesis-doc.md' workflows/synthesis.md && echo "PASS: template ref" || echo "FAIL"
   grep -q 'expert-opinion-' workflows/synthesis.md && echo "PASS: output filename pattern" || echo "FAIL"
   grep -q 'missing_sections' workflows/synthesis.md && echo "PASS: incomplete report handling" || echo "FAIL"
   grep -q 'completed_roles' workflows/synthesis.md && echo "PASS: partial failure signal" || echo "FAIL"
   grep -q 'cross_cutting\|convergence\|contradiction' workflows/synthesis.md && echo "PASS: synthesis reasoning" || echo "FAIL"
   lines=$(wc -l < SKILL.md); [ "$lines" -lt 500 ] && echo "PASS: SKILL.md < 500 lines ($lines)" || echo "FAIL: SKILL.md $lines lines"
   headings=$(grep -c '^#' SKILL.md || true); [ "$headings" -eq 0 ] && echo "PASS: no markdown headings" || echo "FAIL: $headings markdown headings"
   ```
   Every check must print PASS. If any print FAIL, fix the issue before declaring done.

## Must-Haves

- [ ] The `<!-- S03 will add: ... -->` placeholder block is completely removed from `SKILL.md`
- [ ] A live `<route id="synthesis" trigger="all_reports_collected">` block is present, pointing to `workflows/synthesis.md`
- [ ] `SKILL.md` has no markdown headings (K001) and is < 500 lines (K002)
- [ ] All 10 verification checks from the S03 suite print PASS

## Verification

```bash
grep -q 'route id="synthesis"' SKILL.md && echo "PASS" || echo "FAIL"
lines=$(wc -l < SKILL.md); [ "$lines" -lt 500 ] && echo "PASS ($lines lines)" || echo "FAIL"
headings=$(grep -c '^#' SKILL.md || true); [ "$headings" -eq 0 ] && echo "PASS (0 headings)" || echo "FAIL ($headings headings)"
```

## Inputs

- `SKILL.md` — file to edit; contains the placeholder block to replace
- `workflows/synthesis.md` — must exist (T01 output); route must point to it

## Expected Output

- `SKILL.md` — updated with live `<route id="synthesis">` block; placeholder comment removed
