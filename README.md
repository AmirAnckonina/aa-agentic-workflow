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
- `jq` — powers the Architect write-guard and the Builder spec-gate / git-guard hooks (all fail open if absent).

## Install

The repo is its own marketplace (`.claude-plugin/marketplace.json`, marketplace name `aa`), so it installs in two commands:

```bash
claude plugin marketplace add AmirAnckonina/aa-agentic-workflow
claude plugin install aa-agentic-workflow@aa
```

Agents (`@architect`, `@builder`, `@reviewer`), commands (`/requirements`, `/review-internal`), and the skills load on the **next** session.

**Local dev loop.** Clone, then either load it live (no install — reflects edits; `/reload-plugins` for skills, restart for agents/commands) or install from the local path:

```bash
git clone https://github.com/AmirAnckonina/aa-agentic-workflow ~/repositories/aa-agentic-workflow
claude --plugin-dir ~/repositories/aa-agentic-workflow            # live, no install
# — or install from the local marketplace —
claude plugin marketplace add ~/repositories/aa-agentic-workflow
claude plugin install aa-agentic-workflow@aa
```

After editing an installed copy, bump `version` in `plugin.json` and run `claude plugin update aa-agentic-workflow@aa`. Validate the manifest with `claude plugin validate . --strict`.

**Dependency:** [Superpowers](https://github.com/obra/superpowers) is declared in `plugin.json` `dependencies` and resolves from the official marketplace, so `claude plugin install` pulls it automatically. Agents also check for its skills at Step 0 and stop with a clear message if it is somehow absent.

> **Namespacing:** plugin components are namespaced — `/aa-agentic-workflow:spec-review`, `@aa-agentic-workflow:architect`. Doc examples use short names for readability.

Supersedes the `agentic-workflow` capability in `custom-agentic-tools` (v1) — don't run both.

## License

MIT
