<required_reading>
  references/input-handling.md — detection rules and normalization steps for all four input types
  references/output-contract.md — canonical schema for the S01 → S02 output package; use exact field names
</required_reading>

<workflow name="intake" version="1.0">

<purpose>
Six-phase intake orchestration. Accepts any input type (text, file, codebase, or URL), normalizes it, infers context, proposes expert roles, gates on user confirmation, and emits the typed output package consumed by workflows/research.md in S02.

Role identification is pure in-context LLM inference — NO web searches, NO fetch_page for supplementary research. fetch_page is permitted only for the `url` input type (reading the submitted artifact itself).
</purpose>

<phase id="1" name="Detect input type">
Apply the detection rules from references/input-handling.md in order (first match wins):

1. If the user's input starts with `http://` or `https://` → type = `url`
2. If the input starts with `/`, `./`, or `../`; OR contains a file extension pattern (`.py`, `.md`, `.json`, etc.); AND refers to a single file, not a directory → type = `file`
3. If the input is a directory path (ends with `/`, or `bash` confirms it is a directory); OR the user explicitly says "this is a codebase" or "this is a project" → type = `codebase`
4. Everything else → type = `text`

**Ambiguity fallback:** If the input is ambiguous (a bare word that could be a filename or inline text), prompt the user:
"Is this a file path, or should I treat it as inline text?"

Record the detected type. Proceed to Phase 2.
</phase>

<phase id="2" name="Normalize input">
Apply the normalization steps from references/input-handling.md for the detected type.

**text:**
- Use the input as-is. No tool calls required.
- If input exceeds ~6000 tokens, apply the Large-Input Truncation Strategy (see below).
- Set `normalized_input.type = "text"`, `normalized_input.content = <full text or truncated excerpt>`.

**file:**
- Use the `read` tool with the provided path.
- If the file does not exist, stop: "File not found at `[path]`. Please verify the path and try again."
- If the file exceeds ~6000 tokens, apply the Large-Input Truncation Strategy.
- Set `normalized_input.type = "file"`, `normalized_input.content = <file contents or truncated excerpt>`.

**codebase:**
- Use `bash` with `find [path] -type f | sort` to enumerate all files. Capture as `file_tree`.
- Select up to 20 representative files using this priority order:
  1. README files (any extension)
  2. Entry points: `main.*`, `index.*`, `app.*`, `server.*`, `__init__.py`, `__main__.py`
  3. Configuration: `pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, `*.config.*`, `.env.example`
  4. Core business logic (largest files in non-test, non-vendor directories)
  5. Test files (1–2 representative samples)
- Read each selected file with the `read` tool. Cap any single file at 1500 tokens.
- **Log selected files before the role proposal step:**
  ```
  Selected files for analysis:
    1. README.md — project overview (entry point priority)
    2. src/main.py — application entry point
    [...]
  Omitted: [N] files (test fixtures, generated files, vendor dependencies)
  ```
- Assemble content: `[file_tree header] + [file separator lines] + [concatenated file contents]`.
- Populate `normalized_input.summary` (required for codebase; see truncation strategy).
- Set `normalized_input.type = "codebase"`, `normalized_input.content = <assembled content>`, `normalized_input.file_tree = <find output>`.

**url:**
- Use the `fetch_page` tool with the URL. Default `maxChars = 8000`.
- **URL failure fallback:** If fetched content is fewer than 200 words, warn the user:
  "The fetched page returned very little content (< 200 words). This may be a login-gated page, a redirect, or a dynamic SPA. Please paste the relevant content directly or provide a different URL."
  Re-prompt. Do NOT proceed with empty or near-empty content.
- If content exceeds ~6000 tokens, apply the Large-Input Truncation Strategy.
- Set `normalized_input.type = "url"`, `normalized_input.content = <fetched content or truncated excerpt>`.

**Large-Input Truncation Strategy (all types):**
Trigger: content exceeds ~6000 tokens (~24,000 characters) after reading.
1. Include the full structure first (first 2000 tokens verbatim; for codebase: full file tree + README).
2. Extract key excerpts from the remaining content (function/class signatures, docstrings, config blocks for code; section headings + first paragraph for prose).
3. Insert `[... N lines omitted ...]` at each omission point.
4. Populate `normalized_input.summary`: write a 3–8 sentence plain-language summary of the FULL artifact (before truncation). This travels with every subagent dispatch.
5. Total assembled content must not exceed ~6000 tokens.
</phase>

<phase id="3" name="Infer context">
From the normalized content, infer the three context fields. Do NOT use web searches. Use only what the artifact itself reveals.

- **`purpose`** — What is this artifact trying to accomplish? Be specific (e.g. "REST API for mobile client authentication", not "an API"). State the goal, not what the artifact is.
- **`domain`** — The technical or business domain (e.g. "backend code", "technical writing", "business strategy", "UI/UX design", "data pipeline").
- **`audience`** — Who the artifact is intended for (e.g. "internal developers", "end users", "investors", "regulatory reviewers").

Record as `inferred_context = { purpose, domain, audience }`. These travel to every S02 subagent.
</phase>

<phase id="4" name="Generate role proposal">
Propose 5–10 expert roles whose perspective would materially improve the artifact. Use pure in-context LLM inference from the artifact content — NO web searches.

For each proposed role:
- **Role name** — a specific expert identity (e.g. "Security Auditor", "Performance Engineer", "Technical Writer")
- **Domain** — 2–5 words (e.g. "application security", "distributed systems performance")
- **Focus questions** — 2–4 questions specific to THIS artifact, grounded in the actual content. Not generic category questions. Each question should probe something a reviewer of this role would uniquely notice.
- **Rationale** — one sentence explaining why this expert perspective applies to this specific artifact.

Format the proposal using the display format from templates/role-proposal.md:

---

**[ROLE NAME]**
*[Domain]*

Focus questions for this artifact:
- [Artifact-specific question 1]
- [Artifact-specific question 2]
- [Optional third question]

---

Repeat one block per proposed role. After all role blocks, include the confirmation prompt from templates/role-proposal.md verbatim.
</phase>

<phase id="5" name="User confirmation gate">
Present the role proposal to the user and gate on their confirmation before any research begins.

**Primary path — ask_user_questions available:**

Invoke `ask_user_questions` with:
- Question: "Review the expert roles proposed above. What would you like to do?"
- Options:
  - "Confirm all"
  - "Edit (describe changes)"
  - "Cancel"

If the user selects **"Confirm all"**: proceed to Phase 6.

If the user selects **"Edit (describe changes)"**:
- Follow up with a free-text prompt: "Describe the changes you'd like — which roles to add, remove, or modify."
- Apply the described edits to the role list.
- Re-render the updated role proposal (same format as Phase 4).
- Re-present via `ask_user_questions` with the same three options.
- Loop until the user confirms or cancels.

If the user selects **"Cancel"**:
- Stop. Output: "Expert review cancelled. No analysis will run."
- Do not emit an output package.

**Fallback — ask_user_questions unavailable:**
Present the role proposal as markdown and ask the user to reply with A, B, or C as described in the confirmation prompt from templates/role-proposal.md. Apply the same confirm/edit/cancel logic based on their reply.
</phase>

<phase id="6" name="Emit output package">
After the user has confirmed the role list, assemble and emit the output package per references/output-contract.md.

Populate all required fields:

```json
{
  "confirmed_roles": [
    {
      "role": "Security Auditor",
      "domain": "application security",
      "focus_questions": [
        "Artifact-specific question 1",
        "Artifact-specific question 2"
      ],
      "rationale": "One sentence on why this role applies to this artifact."
    }
  ],
  "normalized_input": {
    "type": "file",
    "content": "... artifact content or key excerpts ...",
    "summary": "Present only when content was truncated — 3–8 sentence plain-language summary.",
    "file_tree": "Present only when type == 'codebase'."
  },
  "inferred_context": {
    "purpose": "What the artifact is trying to accomplish.",
    "domain": "Technical or business domain.",
    "audience": "Who the artifact is for."
  }
}
```

Emit rules (from references/output-contract.md):
1. Emit ONLY after user confirmation. Never emit before Phase 5 completes with "Confirm all".
2. Use the exact field names above — S02 dispatch references them by name.
3. Populate all required fields. `summary` and `file_tree` are present only when triggered by content size or codebase type.
4. Emit as a fenced code block with language tag `json` so downstream agents can parse it reliably.

After emitting the package, state:
"Intake complete. Pass this output package to workflows/research.md (S02) to begin the parallel expert analysis."
</phase>

</workflow>
