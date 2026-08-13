---
description: "Optional front stage — compose raw needs into a structured, gated Requirements doc (user stories + EARS acceptance criteria with R# IDs). Standalone entry to the pipeline; output feeds @architect."
argument-hint: "[the raw need, or a path to notes]"
model: sonnet
---

# Compose Requirements

Invoke the **aa-requirements-composition** skill (via the Skill tool) to turn a raw need into a structured, gated Requirements doc.

- If `$ARGUMENTS` is provided, treat it as the raw need (or a path to notes) to compose from.
- If `$ARGUMENTS` is empty, ask the user for the need in one line, then proceed.

Follow the skill exactly: load context (`Context loaded:` line first), interview via `superpowers:brainstorming` (or reuse an existing brainstorming design doc), draft `docs/requirements/<feature>.md` with EARS acceptance criteria + `R#` IDs, and gate on **no open `[NEEDS CLARIFICATION]` markers + explicit user approval** before setting `Status: Approved`.

Standalone by design — stop when the doc is Approved. The next step is `@architect` (which designs, then decomposes only if the feature is more than one spec).
