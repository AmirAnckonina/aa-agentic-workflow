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

**As a plugin (recommended):** distributed via the private `aa-tools` marketplace (dev phase — not published).

```
/plugin install agentic-workflow@aa-tools
```

Updates: bump `version` in `plugin.json`, push, then `/plugin marketplace update aa-tools` + reinstall — the pinned version means releases happen only on version bumps. To publish later, add this repo as an entry in any public marketplace (HTTPS `url` source).

> **Namespacing note:** plugin components are namespaced — skills appear as `agentic-workflow:spec-review`, agents as `agentic-workflow:architect`. Slash usage: `/agentic-workflow:spec-review …`. Doc examples use the short names for readability.

**Dev loop (authoring):** clone and symlink into `~/.claude/` so edits are live without reinstalling:

```bash
git clone https://github.com/AmirAnckonina/agentic-workflow ~/repositories/agentic-workflow
cd ~/.claude
ln -s ~/repositories/agentic-workflow/agents/*.md agents/
ln -s ~/repositories/agentic-workflow/skills/{spec-format,approach-review,spec-review,architect-methodology,coding-standards} skills/
ln -s ~/repositories/agentic-workflow/commands/review-internal.md commands/
```

**Pick one mode** — plugin install and symlinks together create duplicate (namespaced + bare) components. Supersedes the `agentic-workflow` capability in `custom-agentic-tools` (v1); don't install v1 alongside either mode.

Validate before publishing changes: `claude plugin validate . --strict`

## License

MIT
