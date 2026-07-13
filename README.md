# agentic-workflow

A governance-first SDLC pipeline for Claude Code: **Architect → gates → Builder → Reviewer**, with spec-as-source-of-truth and structurally enforced approval gates.

- **Owns:** artifacts (Approach Brief, Spec), gates (`/approach-review`, `/spec-review`), role agents, the status lifecycle, spec-compliance review.
- **Delegates:** TDD / debugging / verification discipline → [Superpowers](https://github.com/obra/superpowers) (required); generic quality review → built-in `/code-review`.

**Start here:** [docs/WORKFLOW.md](docs/WORKFLOW.md) (operating manual) · [docs/DESIGN.md](docs/DESIGN.md) (rationale & decisions).

## Layout

```
agents/      architect · builder · reviewer
skills/      spec-format · approach-review · spec-review · architect-methodology · coding-standards
commands/    review-internal
docs/        DESIGN.md · WORKFLOW.md
```

## Dependencies

- **Superpowers plugin** — required. Agents invoke `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `brainstorming`.
- **Claude Code** — current version (agent `skills:` preloading, hooks, nested subagents).
- `jq` — architect write-guard hook (fails open if absent).

## Install

**Dev phase (current):** the repo loads in place as a *skills-dir plugin* — one symlink, live edits, no marketplace, no install step:

```bash
git clone https://github.com/AmirAnckonina/agentic-workflow ~/repositories/agentic-workflow
ln -s ~/repositories/agentic-workflow ~/.claude/skills/agentic-workflow
```

Next session it appears as `agentic-workflow@skills-dir`. Edit the repo → changes are live in the next session. Remove = delete the symlink.

**Distribution (later, when stable):** add this repo as an entry in any marketplace (HTTPS `url` source recommended) and install `agentic-workflow@<marketplace>`. Version is pinned in `plugin.json`, so releases ship on version bumps. Validate first: `claude plugin validate . --strict`.

**Prerequisite (not a manifest dependency):** the [Superpowers](https://github.com/obra/superpowers) plugin must be installed — agents invoke its TDD/debugging/verification skills and stop with a clear message if missing. Kept out of `plugin.json` `dependencies` deliberately: zero coupling, no cross-marketplace resolution machinery.

> **Namespacing:** plugin components are namespaced — `/agentic-workflow:spec-review`, `@agentic-workflow:architect`. Doc examples use short names for readability.

Supersedes the `agentic-workflow` capability in `custom-agentic-tools` (v1) — don't run both.

## License

MIT
