# Input Handling Reference

**Path:** `references/input-handling.md`
**Used by:** `workflows/intake.md` — phases 1 (detect) and 2 (normalize).

---

## Detection Rules

Determine input type by examining what the user submitted. Apply rules in order; first match wins.

| Type | Detection Condition | Examples |
|------|---------------------|---------|
| `url` | Starts with `http://` or `https://` | `https://example.com/docs` |
| `file` | Starts with `/`, `./`, or `../`; OR contains a file extension (`.py`, `.md`, `.json`, etc.); AND refers to a single file, not a directory | `./src/auth.py`, `/home/user/report.md`, `config.yaml` |
| `codebase` | Is a directory path (ends with `/`, or path exists and `bash` confirms it's a directory); OR user explicitly says "this is a codebase" / "this is a project" | `./my-project/`, `/home/user/repo` |
| `text` | Everything else — inline text with no path separators, no URL prefix, no file extension pattern | Pasted prose, code snippet, raw content |

**Ambiguity fallback:** If the input is ambiguous (e.g. a bare word that could be a filename or text), prompt the user: "Is this a file path, or should I treat it as inline text?"

---

## Normalization Steps

### `text` — Inline text

1. Use the input as-is. No tool calls required.
2. If input exceeds ~6000 tokens, apply truncation strategy (see below).
3. Set `normalized_input.type = "text"`, `normalized_input.content = <full text or truncated excerpt>`.

### `file` — Single file

1. Use the `read` tool with the provided path.
2. If the file does not exist, stop and report: "File not found at `[path]`. Please verify the path and try again."
3. If the file exceeds ~6000 tokens, apply truncation strategy (see below).
4. Set `normalized_input.type = "file"`, `normalized_input.content = <file contents or truncated excerpt>`.

### `codebase` — Directory / project

1. Use `bash` with `find [path] -type f | sort` to enumerate all files. Capture as `file_tree`.
2. From the file list, select up to **20 representative files** using this priority order:
   - README files (any extension)
   - Entry points: `main.*`, `index.*`, `app.*`, `server.*`, `__init__.py`, `__main__.py`
   - Configuration: `pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, `*.config.*`, `.env.example`
   - Core business logic files (largest files in non-test, non-vendor directories)
   - Test files (sample — 1–2 representative tests)
3. Read each selected file with the `read` tool. If any single file exceeds 1500 tokens, read the first 1500 tokens only.
4. **Log selected files** in intake output: list the files chosen and why (e.g. "entry point", "config"). This lets the user verify selection quality and override if needed.
5. Assemble content as: `[file_tree header] + [file separator lines] + [concatenated file contents]`.
6. Set `normalized_input.type = "codebase"`, `normalized_input.content = <assembled content>`, `normalized_input.file_tree = <find output>`.
7. Always set `normalized_input.summary` for codebase inputs (see truncation strategy).

### `url` — Remote URL

1. Use the `fetch_page` tool with the URL. Default `maxChars = 8000`.
2. **URL failure fallback:** If the fetched content is fewer than 200 words:
   - Warn: "The fetched page returned very little content (< 200 words). This may be a login-gated page, a redirect, or a dynamic SPA. Please paste the relevant content directly or provide a different URL."
   - Re-prompt for input. Do NOT proceed with an empty or near-empty artifact.
3. If content exceeds ~6000 tokens, apply truncation strategy.
4. Set `normalized_input.type = "url"`, `normalized_input.content = <fetched content or truncated excerpt>`.

---

## Large-Input Truncation Strategy

**Trigger:** Input content exceeds ~6000 tokens (approx. 24,000 characters) after reading.

**Goal:** Preserve structural understanding while fitting within context budget.

**Steps:**

1. Include the **full structure** first:
   - For text/file: include the first 2000 tokens verbatim (opening, imports, headers — whatever establishes context).
   - For codebase: always include the file tree and README in full.
2. From the remaining content, extract **key excerpts** — sections that appear most relevant to understanding the artifact's purpose and architecture:
   - For code: function/class signatures, docstrings, configuration blocks. Omit implementation bodies where signatures are self-explanatory.
   - For prose: opening and closing sections; section headings with first paragraph of each section.
3. Insert a marker at each omission point: `[... N lines omitted ...]`
4. **Populate `normalized_input.summary`**: Write a 3–8 sentence plain-language summary of the FULL artifact (before truncation). This summary travels with every subagent dispatch so experts have semantic coverage beyond the excerpts.
5. Total assembled content (structure + excerpts + markers) should not exceed ~6000 tokens.

**Codebase-specific:** Prefer omitting large implementation files over omitting config and entry-point files. A subagent with no config context cannot assess configuration issues; a subagent with no implementation detail can still reason from signatures and structure.

---

## Codebase File Selection — Logging Requirement

When processing a `codebase` input, the intake workflow MUST log:

```
Selected files for analysis:
  1. README.md — project overview (entry point priority)
  2. src/main.py — application entry point
  3. pyproject.toml — project configuration
  4. src/auth/handler.py — core business logic (largest non-test file)
  [...]
Omitted: [N] files (test fixtures, generated files, vendor dependencies)
```

This log must appear in the intake workflow's output before the role proposal step, so the user can object to the selection before committing to a full analysis run.

---

## No Web Searches in Intake

The intake workflow must NOT perform web searches (no `search-the-web`, no `fetch_page` for supplementary research). Role identification is in-context inference only — based on what the artifact contains, not external documentation. `fetch_page` is permitted ONLY for the `url` input type above (reading the submitted artifact itself).
