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

> **Status: pre-packaging (M2 pending).** Plugin manifest + marketplace distribution are the next milestone. Until then, symlink manually into `~/.claude/`:

```bash
git clone <this-repo> ~/repositories/agentic-workflow
cd ~/.claude
ln -s ~/repositories/agentic-workflow/agents/*.md agents/
ln -s ~/repositories/agentic-workflow/skills/{spec-format,approach-review,spec-review,architect-methodology,coding-standards} skills/
ln -s ~/repositories/agentic-workflow/commands/review-internal.md commands/
```

Supersedes the `agentic-workflow` capability in `custom-agentic-tools` (v1) — don't install both at once (name collisions on agents/skills).

## License

MIT
