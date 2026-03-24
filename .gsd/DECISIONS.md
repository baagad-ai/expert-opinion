# Decisions Register

<!-- Append-only. Never edit or remove existing rows.
     To reverse a decision, add a new row that supersedes it.
     Read this file at the start of any planning or research phase. -->

| # | When | Scope | Decision | Choice | Rationale | Revisable? | Made By |
|---|------|-------|----------|--------|-----------|------------|---------|
| D001 | 2026-03-24 | distribution | Skill installation scope | Open-source GitHub repo; users install globally or project-local via copy | User wants to publish publicly; no per-project lock-in | Yes | human |
| D002 | 2026-03-24 | architecture | Role identification strategy | Hybrid: LLM proposes roles, user confirms before research dispatch | Prevents wasted compute on unwanted roles; keeps user in control; better quality than fully dynamic | Yes | collaborative |
| D003 | 2026-03-24 | architecture | Research execution model | Parallel subagents — one isolated context per confirmed expert role | Depth per role without context pollution across roles; speed across roles simultaneously | No | collaborative |
| D004 | 2026-03-24 | architecture | Skill complexity pattern | Router pattern (SKILL.md + workflows/ + references/ + templates/) | Three distinct workflow phases (intake, research, synthesis) each need different references; essential principles must not be skippable | No | agent |
| D005 | 2026-03-24 | architecture | Synthesis approach | Orchestrating agent (not a subagent) reads all expert reports and synthesizes | Synthesis requires full context of all reports; parallel agents can't self-synthesize without sharing context | No | agent |
| D006 | 2026-03-24 | scope | External API requirement | No external API keys required for core function | Reduce installation friction; work with standard GSD tools (web search, file read, bash, LSP) | Yes | agent |
| D007 | 2026-03-24 | skill authoring | Output contract schema format | TypeScript interface syntax (IntakeOutputPackage, ConfirmedRole, NormalizedInput, InferredContext) plus prose field definitions | Dual format gives downstream agents machine-readable structure and intent; TypeScript interfaces are familiar to LLMs and unambiguous about type shapes | Yes | agent |
| D008 | 2026-03-24 | skill authoring | SKILL.md extensibility pattern | Commented-out placeholder route blocks in <routing> for S02/S03 | Safe forward extension: downstream slices uncomment and fill without touching existing structure or routing logic | Yes | agent |
| D009 | 2026-03-24 | skill authoring | Input type detection ordering | url → file → codebase → text (most-specific first) | Prevents misclassification: a URL string would match as text if text is checked first; a directory could match as file; ordering by specificity eliminates ambiguity | No | agent |
| D010 | 2026-03-24 | skill authoring | Subagent prompt structure | Four named XML sections: fill_instructions → large_input_note → prompt_template → output_instructions | Named sections make each K003 component independently auditable via grep; named XML is also machine-parseable without a markdown parser | Yes | agent |
| D011 | 2026-03-24 | architecture | Incomplete subagent report handling | Flag-not-repair: populate missing_sections list, emit report verbatim — never edit, patch, or discard | Silent repair hides errors from downstream synthesis; structured missing_sections gives S03 precise information about what to work around vs. what to flag | No | agent |
| D012 | 2026-03-24 | skill authoring | Contradictions section omission rule | <contradictions> block is omitted entirely from output when no contradictions are found (not present as empty XML) | Empty XML sections are misleading — their absence is informative; omission is the correct signal | No | agent |
| D013 | 2026-03-24 | skill authoring | Route description content policy | Route <description> enumerates what the route produces and where it saves output, not just what it does | Downstream agents using SKILL.md as a router map need to know what the route delivers, not just its behavior | Yes | agent |
