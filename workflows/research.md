<required_reading>
  references/output-contract.md — canonical S01→S02 and S02→S03 schemas; use exact field names
  references/subagent-prompt.md — K003 four-component expert subagent task template; fill placeholders per-role
  templates/expert-report.md — output template each subagent must fill completely
</required_reading>

<workflow name="research" version="1.0">

<purpose>
Four-phase parallel research orchestration. Accepts the `IntakeOutputPackage` emitted by
`workflows/intake.md`, constructs one expert subagent task per confirmed role, dispatches
all tasks in parallel, collects the filled `templates/expert-report.md` responses, and
emits a `ResearchOutputPackage` ready for `workflows/synthesis.md` in S03.

Core performance contract: expert reviews MUST run in parallel — one subagent per role.
Never dispatch sequentially unless the parallel mode is genuinely unavailable (graceful
degradation documented in Phase 3). Never collapse multiple roles into a single subagent.
</purpose>

<phase id="1" name="Receive and validate">
Accept the `IntakeOutputPackage` JSON block emitted at the end of `workflows/intake.md`.

**Pre-hook — structural validation (run before any further processing):**

Check each field for both presence AND structural correctness:

| Field | Check | Error message on failure |
|-------|-------|--------------------------|
| `confirmed_roles` | Non-empty array | `ERROR (research/phase-1/pre-hook): confirmed_roles is missing or empty.` |
| `confirmed_roles[i].role` | Non-empty string | `ERROR (research/phase-1/pre-hook): confirmed_roles[{i}].role is not a string or is empty.` |
| `confirmed_roles[i].focus_questions` | Array (not string) with ≥1 item | `ERROR (research/phase-1/pre-hook): confirmed_roles[{i}].focus_questions must be an array of strings, got {actual type}.` |
| `normalized_input.type` | One of: `"text"`, `"file"`, `"codebase"`, `"url"` | `ERROR (research/phase-1/pre-hook): normalized_input.type "{value}" is not a valid enum value.` |
| `normalized_input.content` | Present and non-empty string | `ERROR (research/phase-1/pre-hook): normalized_input.content is missing or empty.` |
| `inferred_context.purpose` | Present non-empty string | `ERROR (research/phase-1/pre-hook): inferred_context.purpose is missing.` |

On any ERROR → STOP immediately with the exact error message above.
Format: `ERROR (research/phase-1/pre-hook): [field] failed [check]: expected [type], got [actual]. Re-run intake workflow to produce a valid package.`

**Schema version check:**
If the package carries a `schema_version` field, verify it matches `"1.0"` (from `references/output-contract.md`).
If version mismatch: emit `WARNING (research/phase-1): package schema version "{pkg_version}" differs from consumer schema "1.0". Proceeding, but verify field names before downstream use.` then continue.

If all checks pass, record the package internally:
- `roles` ← `confirmed_roles`
- `normalized_input` ← `normalized_input`
- `inferred_context` ← `inferred_context`

Proceed to Phase 2.
</phase>

<phase id="2" name="Construct per-role tasks">
For each entry `role_entry` at index `i` in `roles`, construct one subagent task string by
filling the template in `references/subagent-prompt.md`.

Substitute the following placeholders (source field in parentheses):

| Placeholder           | Source                                                    |
|-----------------------|----------------------------------------------------------|
| `{role}`              | `role_entry.role`                                        |
| `{domain}`            | `role_entry.domain`                                      |
| `{rationale}`         | `role_entry.rationale`                                   |
| `{focus_questions}`   | `role_entry.focus_questions` — this role's array ONLY    |
| `{research_queries}`  | `role_entry.research_queries` — this role's array ONLY   |
| `{content}`           | `normalized_input.content`                               |
| `{summary}`           | `normalized_input.summary` (include block only if present; omit entirely if absent) |
| `{purpose}`           | `inferred_context.purpose`                               |
| `{audience}`          | `inferred_context.audience`                              |
| `{context_domain}`    | `inferred_context.domain`                                |

**Critical invariant:** Each subagent receives ONLY its own `focus_questions` and `research_queries`.
Do NOT pass the full arrays from all roles to any single subagent.

**`<artifact_data>` boundary protection:**
Before substituting `{content}` into the task string, escape any occurrence of `</artifact_data>`
in the content value by replacing `<` with `&lt;`:
```
escaped_content = normalized_input.content.replace("</artifact_data>", "&lt;/artifact_data>")
```
This prevents boundary bypass if the artifact contains the closing tag as literal text.
Note in the subagent's Artifact Context section that `&lt;/artifact_data&gt;` sequences
inside `<artifact_data>` are escaped literal content, not actual closing tags.

**Summary handling:**
- If `normalized_input.summary` is present: include the `### Summary` and `### Key Excerpts` blocks
  in the task text exactly as shown in the `<prompt_template>` section of `references/subagent-prompt.md`.
- If `normalized_input.summary` is absent: omit the conditional summary block entirely; `{content}` is the complete artifact.

Produce a list of `N` task objects (one per role), each with:
```
agent: "worker"
task: <filled task string for role_entry[i]>
```

Log the count before dispatching:
"Constructed [N] expert subagent tasks. Dispatching in parallel."

Proceed to Phase 3.
</phase>

<phase id="3" name="Parallel dispatch">
Call the `subagent` tool in **parallel mode** using the `tasks: [...]` array signature.

```
subagent(
  tasks: [
    { agent: "worker", task: <task string for role 0> },
    { agent: "worker", task: <task string for role 1> },
    ...
    { agent: "worker", task: <task string for role N-1> }
  ]
)
```

**Mandatory constraints:**
- Do NOT use chain mode.
- Do NOT dispatch subagents sequentially in a loop.
- All tasks must be submitted in a single `subagent` call with the parallel `tasks` array.

**Timeout contract:**
Allow each subagent up to **120 seconds** (configurable — set `SUBAGENT_TIMEOUT_SECONDS` if a custom value is required). If a subagent has not returned within the timeout:
1. Emit: `WARNING (research/phase-3): subagent for role "{role}" timed out after {timeout}s. Marking as timed_out.`
2. Record the role name in `timed_out_roles`.
3. Do NOT block the remaining subagents — proceed with whichever outputs have arrived.
4. Attempt one retry for each timed-out role (same task string, same timeout). If the retry also times out, mark as failed and add to `failed_roles`.

If ALL subagents time out simultaneously, STOP:
`ERROR (research/phase-3): all subagents timed out. Check model latency or reduce artifact size before retrying.`

**Graceful degradation (if parallel mode is genuinely unavailable):**
<!-- FALLBACK: dispatch sequentially only if the subagent tool does not support parallel mode.
     This is NOT the preferred path. Sequential dispatch multiplies latency by N.
     Log a warning: "WARNING: parallel mode unavailable — dispatching sequentially as fallback."
     Apply the same 120s timeout per role. Collect timed_out_roles and failed_roles normally.
     The ResearchOutputPackage emitted is identical regardless of dispatch mode. -->

Proceed to Phase 4 after all available outputs have been received (or timed out per the contract above).
</phase>

<phase id="4" name="Collect and emit">
Wait for all available subagent outputs before proceeding. Any roles in `timed_out_roles`
that did not recover via retry are treated as failed.

For each subagent output at index `i`:
1. Record `role` ← `roles[i].role`
2. Record `domain` ← `roles[i].domain`
3. Record `report` ← verbatim output text returned by the subagent (do NOT edit, repair, or summarize)
4. **Structural section check** — check whether each required section tag appears AND contains non-trivially-empty content:
   - For each required section name (`<role_identity>`, `<executive_summary>`, `<findings>`, `<recommendations>`):
     - The tag must be PRESENT in the report text (not just mentioned in prose — e.g. "my findings below" does NOT qualify).
     - The content between opening and closing tags must be non-empty (more than whitespace or a single word; "N/A" alone is treated as empty).
   - Additionally, count `<finding>` blocks inside `<findings>`:
     - If `finding_count == 0`: record as a soft `WARNING` (not a hard missing-section error); add `"<findings:empty>"` to `missing_sections`.
   - Populate `missing_sections`: empty array `[]` if all four sections are present and non-empty; otherwise list the names of absent or empty sections.
   - **Do NOT discard or repair reports with missing sections** — record them as-is per the flag-not-repair contract.
   - **`<findings:empty>` annotation:** In the synthesized output, rows in `<per_role_highlights>` for roles where `"<findings:empty>"` is in `missing_sections` should note "(no findings)" in the severity column so users can distinguish zero-findings from a missing findings section.

Compute metadata:
- `total_roles` ← `len(roles)`
- `completed_roles` ← count of subagents that returned any output (even partial)
- `failed_roles` ← list of role names from `roles` for which no output was returned
- `timed_out_roles` ← list of role names that hit the timeout and were not recovered by retry

Assemble and emit the `ResearchOutputPackage` as a fenced JSON code block:

```json
{
  "reports": [
    {
      "role": "<role name matching ConfirmedRole.role exactly>",
      "domain": "<domain matching ConfirmedRole.domain exactly>",
      "report": "<verbatim subagent output — full text including all XML tags>",
      "missing_sections": []
    }
  ],
  "metadata": {
    "total_roles": 0,
    "completed_roles": 0,
    "failed_roles": [],
    "timed_out_roles": [],
    "inferred_context": {
      "purpose": "<passed through from IntakeOutputPackage.inferred_context.purpose>",
      "domain": "<passed through from IntakeOutputPackage.inferred_context.domain>",
      "audience": "<passed through from IntakeOutputPackage.inferred_context.audience>"
    }
  }
}
```

After emitting the package, state:
"Research complete. [completed_roles]/[total_roles] expert reports collected.
Pass this ResearchOutputPackage to workflows/synthesis.md (S03) to begin synthesis."

If `completed_roles < total_roles`, also state:
"WARNING: [total_roles - completed_roles] subagent(s) returned no output."

Then output this executable 5-step recovery procedure:

---
**Partial-Retry Recovery Procedure:**
1. **Filter** — Extract the failed role entries: select all entries from `IntakeOutputPackage.confirmed_roles` where `role` matches any name in `metadata.failed_roles`.
2. **Reconstruct** — Re-construct subagent task strings for those roles only, using the same `IntakeOutputPackage` and the same template from `references/subagent-prompt.md`. Do NOT generate new tasks — reuse the identical inputs verbatim.
3. **Dispatch with classified backoff** — Classify the failure before re-dispatching:
   - **Rate-limit timeout** (subagent returned a rate-limit error or HTTP 429): wait 5 seconds, then dispatch.
   - **Process/network timeout** (no output returned within 120s): re-dispatch immediately — no backoff needed.
   - Dispatch recovered tasks in parallel (same `subagent` parallel mode call, `tasks: [...]`).
4. **Merge** — Insert each recovered report at its original index in the `reports` array (replacing the absent slot). Update `metadata.completed_roles` and remove the role from `metadata.failed_roles`. Do NOT append to the end.
5. **Re-validate** — Run the `missing_sections` structural section check (from Phase 4 step 4) on each recovered report. Record incomplete sections in `missing_sections` as before.

Proceed to synthesis (`workflows/synthesis.md`) only after merge and re-validation are complete. This procedure is cheaper than re-running the full pipeline.
---
</phase>

</workflow>
