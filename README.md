# aa-agentic-workflow

A governance-first SDLC pipeline for Claude Code: **Architect → gates → Builder → Reviewer**, with spec-as-source-of-truth and structurally enforced approval gates.

- **Owns:** artifacts (Requirements doc, Approach Brief, Task Map, Spec), gates (`/requirements`, `/approach-review`, `/spec-review`), role agents, the status lifecycle, `R#` requirement→task→spec traceability, spec-compliance review.
- **Delegates:** intent exploration + TDD / debugging / verification discipline → [Superpowers](https://github.com/obra/superpowers) (required); generic quality review → built-in `/code-review`.

**Spec-driven (Model A):** hand a feature to `@architect`; it designs the brief, then **decomposes into task-specs only when the feature is more than one spec** — spec-then-tasks, decomposition ungated for T1/T2. `/requirements` is an optional EARS front stage. A known single task skips straight to `@architect`/`@builder`, unchanged. See [docs/EXAMPLES.md](docs/EXAMPLES.md).

**Start here:** [docs/WORKFLOW.md](docs/WORKFLOW.md) (operating manual) · [docs/DESIGN.md](docs/DESIGN.md) (rationale & decisions).

## Layout

```
agents/      architect · builder · reviewer
skills/      requirements-composition · decomposition · spec-format · approach-review · spec-review · architect-methodology · coding-standards
commands/    requirements · review-internal
docs/        DESIGN.md · WORKFLOW.md · EXAMPLES.md
```

## Dependencies

- **Superpowers plugin** — required. Agents invoke `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `brainstorming`.
- **Claude Code** — current version (agent `skills:` preloading, hooks, nested subagents).
- `jq` — architect write-guard hook (fails open if absent).

## Install

**Dev phase (current):** the repo loads in place as a *skills-dir plugin* — one symlink, live edits, no marketplace, no install step:

```bash
git clone https://github.com/AmirAnckonina/aa-agentic-workflow ~/repositories/aa-agentic-workflow
ln -s ~/repositories/aa-agentic-workflow ~/.claude/skills/aa-agentic-workflow
```

Next session it appears as `aa-agentic-workflow@skills-dir`. Edit the repo → changes are live in the next session. Remove = delete the symlink.

**Distribution (later, when stable):** add this repo as an entry in any marketplace (HTTPS `url` source recommended) and install `agentic-workflow@<marketplace>`. Version is pinned in `plugin.json`, so releases ship on version bumps. Validate first: `claude plugin validate . --strict`.

**Prerequisite (not a manifest dependency):** the [Superpowers](https://github.com/obra/superpowers) plugin must be installed — agents invoke its TDD/debugging/verification skills and stop with a clear message if missing. Kept out of `plugin.json` `dependencies` deliberately: zero coupling, no cross-marketplace resolution machinery.

> **Namespacing:** plugin components are namespaced — `/aa-agentic-workflow:spec-review`, `@aa-agentic-workflow:architect`. Doc examples use short names for readability.

Supersedes the `agentic-workflow` capability in `custom-agentic-tools` (v1) — don't run both.

## License

MIT
