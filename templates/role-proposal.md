<!-- role-proposal.md — display template for the role confirmation UX
     Path: templates/role-proposal.md
     Used by: workflows/intake.md — the intake workflow renders one entry per proposed role,
              then presents the confirmation prompt below.

     USAGE FOR INTAKE WORKFLOW:
     For each proposed role, render its entry block (substituting real values).
     After all roles, render the confirmation prompt verbatim.
     The focus questions MUST be specific to the current artifact — do not use generic questions.
-->

---

**[ROLE NAME]**
*[Domain — e.g. application security, distributed systems, UX design]*

Focus questions for this artifact:
- [Specific question this expert will investigate — tailored to what was submitted]
- [Second specific question — grounded in the actual content, not a generic category]
- [Optional third question — add when the artifact has a clear third dimension for this role]

---

**[ROLE NAME 2]**
*[Domain]*

Focus questions for this artifact:
- [...]
- [...]

---

<!-- Repeat one block per proposed role (5–10 total). -->

---

CONFIRMATION PROMPT (render this after all role entries):

```
I've identified [N] expert perspectives relevant to your artifact.
Each expert will investigate specific aspects of your submission in parallel,
then I'll synthesize their findings into a prioritized audit document.

Review the roles above. What would you like to do?

Options:
  A) Confirm all — proceed with these roles as listed
  B) Edit — describe which roles to add, remove, or modify
  C) Cancel — stop here
```

<!-- The intake workflow presents this prompt via ask_user_questions with options:
       - "Confirm all"
       - "Edit (describe changes)"
       - "Cancel"
     If the user selects "Edit", follow up with a free-text prompt for their edits,
     update the role list accordingly, and re-present this display.
     If ask_user_questions is unavailable, present as markdown and ask user to reply. -->
