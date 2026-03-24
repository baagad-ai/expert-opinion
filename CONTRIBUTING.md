# Contributing to expert-opinion

Contributions are welcome — whether you're adding new expert roles to the taxonomy, improving examples, fixing documentation, or proposing changes to the synthesis schema.

## Adding a Role to the Taxonomy

The role taxonomy lives in [`references/role-taxonomy.md`](references/role-taxonomy.md). It defines every named expert role the skill can propose, along with each role's domain, default focus areas, and the artifact types it applies to.

To add a new role, follow the step-by-step **append-role template** in the taxonomy file itself:

→ See [**Extending the Taxonomy**](references/role-taxonomy.md#extending-the-taxonomy) in `references/role-taxonomy.md` for the exact process.

Do not duplicate the template here — the taxonomy file is the single source of truth for role definitions. Adding a role there is all that's needed for the skill to propose it during panel selection.

## Contribution Workflow

1. **Fork** the repository on GitHub (`github.com/baagad-ai/expert-opinion`).
2. **Create a feature branch** from `main` with a descriptive name (e.g., `add-role-devrel-engineer` or `fix-synthesis-schema-contradiction-block`).
3. **Make your changes.** If you're adding a role, follow the taxonomy template. If you're adding an example, follow the structure in `examples/` (input.md + roles-proposed.md + synthesis-output.md using the schema from `templates/synthesis-doc.md`).
4. **Open a pull request** against `main`. In the PR description, explain what you changed and why — particularly for role additions, note which artifact types the new role applies to and what gap it fills that existing roles don't cover.
5. A maintainer will review and merge, or ask follow-up questions in the PR thread.

## Code of Conduct

Be respectful, constructive, and inclusive in all interactions — in PR reviews, issue comments, and discussions. Disagreement on technical direction is welcome and expected; personal criticism is not. If a proposed change isn't a good fit for this project, a maintainer will explain why and suggest alternatives where possible. Everyone contributing here is doing so to make the skill more useful — approach feedback with that assumption.

## Filing Issues

When filing a bug report or feature request, include:

- **What you expected** the skill to do, and what it did instead.
- **Steps to reproduce** — the artifact you reviewed, the roles you selected, and the synthesis section where the problem appeared.
- **GSD version** — run `npx gsd --version` and include the output.
- **Skill version** — the version from `npx skills list` or the commit hash if you're running from source.

For feature requests, describe the gap you're trying to fill and (if applicable) the expert role or artifact type you think is underserved by the current taxonomy.
