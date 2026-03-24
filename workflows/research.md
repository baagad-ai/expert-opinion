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

**Validation checks (fail fast on either):**

1. `confirmed_roles` must be a non-empty array.
   - If absent or empty → STOP. Output:
     "ERROR (research/phase-1): `confirmed_roles` is missing or empty in the provided IntakeOutputPackage.
     Re-run the intake workflow to produce a valid package before continuing."

2. `normalized_input.content` must be present and non-empty.
   - If absent or empty → STOP. Output:
     "ERROR (research/phase-1): `normalized_input.content` is missing or empty in the provided IntakeOutputPackage.
     Re-run the intake workflow to produce a valid package before continuing."

If both checks pass, record the package internally:
- `roles` ← `confirmed_roles`
- `normalized_input` ← `normalized_input`
- `inferred_context` ← `inferred_context`

Proceed to Phase 2.
</phase>

<phase id="2" name="Construct per-role tasks">
For each entry `role_entry` at index `i` in `roles`, construct one subagent task string by
filling the template in `references/subagent-prompt.md`.

Substitute the following placeholders (source field in parentheses):

| Placeholder         | Source                                                    |
|---------------------|----------------------------------------------------------|
| `{role}`            | `role_entry.role`                                        |
| `{domain}`          | `role_entry.domain`                                      |
| `{rationale}`       | `role_entry.rationale`                                   |
| `{focus_questions}` | `role_entry.focus_questions` — this role's array ONLY    |
| `{content}`         | `normalized_input.content`                               |
| `{summary}`         | `normalized_input.summary` (include block only if present; omit entirely if absent) |
| `{purpose}`         | `inferred_context.purpose`                               |
| `{audience}`        | `inferred_context.audience`                              |
| `{context_domain}`  | `inferred_context.domain`                                |

**Critical invariant:** Each subagent receives ONLY its own `focus_questions`.
Do NOT pass the full array from all roles to any single subagent.

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

**Graceful degradation (if parallel mode is genuinely unavailable):**
<!-- FALLBACK: dispatch sequentially only if the subagent tool does not support parallel mode.
     This is NOT the preferred path. Sequential dispatch multiplies latency by N.
     Log a warning: "WARNING: parallel mode unavailable — dispatching sequentially as fallback."
     Dispatch each task individually in role order and collect outputs one at a time.
     The ResearchOutputPackage emitted is identical regardless of dispatch mode. -->

Proceed to Phase 4 only after ALL subagent outputs have been received.
Do not proceed with partial results.
</phase>

<phase id="4" name="Collect and emit">
Wait for all `N` subagent outputs to complete before proceeding.

For each subagent output at index `i`:
1. Record `role` ← `roles[i].role`
2. Record `domain` ← `roles[i].domain`
3. Record `report` ← verbatim output text returned by the subagent (do NOT edit, repair, or summarize)
4. Inspect the report for required sections: `<role_identity>`, `<executive_summary>`, `<findings>`, `<recommendations>`
   - For each required section name, check whether it appears in the report text
   - Populate `missing_sections`: empty array `[]` if all four are present; otherwise list the names of absent sections
   - **Do NOT discard or repair reports with missing sections** — record them as-is per the flag-not-repair contract

Compute metadata:
- `total_roles` ← `len(roles)`
- `completed_roles` ← count of subagents that returned any output (even partial)
  - If a subagent failed entirely and returned nothing: exclude from `reports`; this will produce `completed_roles < total_roles`, which signals the failure to S03

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
    "total_roles": <N>,
    "completed_roles": <count>,
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
"WARNING: [total_roles - completed_roles] subagent(s) returned no output. S03 will see the
discrepancy between total_roles and completed_roles. Investigate before proceeding to synthesis."
</phase>

</workflow>
