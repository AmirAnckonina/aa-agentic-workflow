# Getting Started

> **You are here:** setup and your first run. · [README](../README.md) · [Workflow guide](WORKFLOW.md) · [Design rationale](DESIGN.md)

From zero to a shipped feature in about fifteen minutes. This page covers installation, verifying it actually loaded, wiring your repo's context, and one complete run with real commands.

---

## 1. Prerequisites

| Requirement | Why | Check |
|---|---|---|
| **Claude Code**, current version | Agent `skills:` preloading, `PreToolUse` hooks, nested subagents | `claude --version` |
| **[Superpowers](https://github.com/obra/superpowers)** | TDD, debugging, verification, and brainstorming are all delegated to it — this plugin ships no duplicate | installs automatically (declared dependency) |
| **`jq`** | Powers the Architect write-guard and the Builder spec-gate / git-guard hooks | `jq --version` |

Missing `jq` is not fatal — every hook **fails open**, so the pipeline still runs, just without structural enforcement. On macOS: `brew install jq`.

## 2. Install

The repo is its own marketplace, so installation is two commands:

```bash
claude plugin marketplace add AmirAnckonina/aa-agentic-workflow
```

```bash
claude plugin install aa-agentic-workflow@aa
```

Agents, commands, and skills register on the **next** session — start a fresh one before looking for them.

### Verify it loaded

In a new session, confirm all three surfaces are live:

1. Type `@` — `architect`, `builder`, and `reviewer` should appear in the agent list.
2. Type `/` — `/requirements` and `/review-internal` should appear among the commands.
3. Ask directly: *"which agentic-workflow skills are available?"* — you should see `spec-format`, `approach-review`, `spec-review`, and the rest.

If agents are missing but skills are present, the plugin didn't fully register — see [Troubleshooting](#troubleshooting).

### Local development loop

Working on the plugin itself? Clone it and load it live — no install, edits take effect immediately:

```bash
git clone https://github.com/AmirAnckonina/aa-agentic-workflow ~/repositories/aa-agentic-workflow
```

```bash
claude --plugin-dir ~/repositories/aa-agentic-workflow
```

Reload skills mid-session with `/reload-plugins`; agent and command changes need a session restart. Validate the manifest with `claude plugin validate . --strict`. After editing an *installed* copy, bump `version` in `.claude-plugin/plugin.json` and run `claude plugin update aa-agentic-workflow@aa`.

> The live `--plugin-dir` loop and a marketplace install are mutually exclusive — use one or the other, not both.

## 3. Wire your repo's context (recommended)

**Subagents do not inherit `CLAUDE.md`.** That's deliberate: it makes context an explicit, auditable input rather than an invisible inheritance. Every stage reads a manifest at Step 0 and reports what it read.

Create `docs/agentic-context.md` at the root of the repo you're working in:

```markdown
# Agentic Context
- Architecture: docs/ARCHITECTURE.md
- Conventions: CLAUDE.md
- Domain: docs/domain/billing.md
- Review rules: docs/review-rules.md         # optional — injected into Reviewer Pass 2
- Related repos: ../shared-protos (read-only)
```

Every stage then begins its output with a line like:

```text
Context loaded: docs/agentic-context.md, docs/ARCHITECTURE.md, CLAUDE.md, docs/domain/billing.md
```

That line is your verification the stage worked from the right material. **No manifest is fine** — stages fall back to `CLAUDE.md` plus a `docs/` scan and say so explicitly.

The optional `Review rules` entry is worth knowing about: point it at a file of past incidents, tribal knowledge, and hard-won conventions, and the Reviewer injects those rules into its quality pass.

## 4. Your first feature, end to end

A real T2 run — one feature, one spec, both gates handled at their default settings. Artifacts land in the **target** repo, not in the plugin.

### Step 1 — hand the work to the Architect

```text
@architect Add rate limiting to the POST /logs endpoint.
```

It loads context, proposes a tier and track, and — for an ordinary feature — presents an **inline brief** in chat rather than writing a brief file:

```text
Context loaded: docs/agentic-context.md, CLAUDE.md, internal/api/logs.go
Tier: T2 · track: fast (single service, one viable approach)

Inline brief — token bucket per API key, in-process, 100 req/min.
  Rejected: Redis-backed counter — adds an infra dependency for
  single-instance traffic volumes.
  Key risk: limits reset on deploy. Acceptable at current scale.

Approve the approach?
```

Your nod is the approval. Gate A is waived and the waiver is **recorded** in the spec's `Brief:` line — never silently skipped. The Architect then writes `docs/specs/logs-rate-limit.md` with `Status: Draft` and stops at the Gate B question.

> If a genuine design question surfaces while it writes the spec, it **stops** and promotes the work to a real brief file plus Gate A. Accept the promotion — that's the system working, not stalling.

### Step 2 — Gate B

```text
/spec-review docs/specs/logs-rate-limit.md
```

One fresh-context Opus auditor runs the perspectives the spec's surface actually triggers (Completeness and Scope always, plus Security here because there's an auth surface). Verdict is **Approved** — which flips the spec's status — or **Blocking**, which sends it back to `Draft` with specific findings.

Nothing is built until this passes.

### Step 3 — build

```text
@builder Implement docs/specs/logs-rate-limit.md
```

The Builder checks `Status: Approved` before anything else and refuses otherwise. It then works strictly test-first via `superpowers:test-driven-development` and finishes with a Build Report containing an **AC → Test map** — every acceptance criterion paired with the test that proves it.

### Step 4 — commit

```bash
git checkout -b feature/logs-rate-limit && git add -A && git commit -m "Add per-key rate limiting to POST /logs"
```

**The Builder never commits** — a `git-guard` hook blocks it structurally. This is intentional: commits stay a human action, and it guarantees the Reviewer has a real branch diff to review. Do it yourself, or ask the main session to.

### Step 5 — review

```text
/review-internal
```

Two passes. **Pass 1** is the moat: a mechanical per-AC compliance table of code against the Approved spec — every criterion covered by a test, interfaces matching, no unspecified behavior smuggled in, no section silently unimplemented. **Pass 2** delegates to the built-in `/code-review` (plus `/security-review` when the diff touches auth, input handling, or secrets).

The verdict is **SHIP IT**, **NEEDS WORK**, or **BLOCKER**. The terminal report is the deliverable.

### Step 6 — ship (on request)

```text
commit and open a PR
```

Runs `superpowers:finishing-a-development-branch` plus `gh-ops` or `glab-ops`, matched to your actual remote. Git actions only ever happen on explicit request.

## 5. Run modes

Every agent stage can be driven three ways:

| Mode | How | Interactivity | Best for |
|---|---|---|---|
| **Main-session agent** | `claude --agent architect` | Full — gates wait for your reply in place | Design sessions, T2/T3 end to end |
| **Subagent** | `@architect …` inside any session | One-shot — the agent ends its turn at a gate with the question as its result; your next message continues it | Running one stage inside a larger conversation |
| **Headless** | `claude --agent builder -p "…"` | None — stops at gates and prints the pending question | Automation, bounded builds, smoke tests |

Two things hold across all three: **gate skills always run in the main session** (`/approach-review`, `/spec-review`, `/review-internal` are slash commands wherever you are, never subagents), and headless runs need scoped permissions:

```bash
claude --agent builder -p "Implement docs/specs/x.md" --permission-mode acceptEdits --allowedTools "Bash(go:*)" "Skill" "Read" "Glob" "Grep"
```

## Troubleshooting

**Agents don't appear after installing.**
They register on the next session — restart. If they're still missing while skills load fine, the plugin is being picked up as a bare skills directory rather than a plugin. Confirm `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` are both present, then reinstall via the marketplace.

**A stage's output has no `Context loaded:` line.**
It skipped Step 0. Rerun it. If it keeps happening, check that `docs/agentic-context.md` exists at the repo root and lists paths that actually resolve.

**The Builder refuses to start.**
Working as designed — it only accepts `Status: Approved`. Open the spec and check the `**Status:**` field, then run whichever gate is outstanding. For deliberate pre-work outside the pipeline, `AA_GATE_OFF=1` bypasses the spec-gate hook.

**The Builder won't commit.**
Also by design — `git-guard` blocks commit, push, merge, rebase, reset, and `checkout -b`. Read-only git still works. Commit yourself; the guard is Builder-scoped and never touches your own commits.

**The Reviewer says the diff is empty.**
The work isn't committed. Create a feature branch and commit — otherwise the Reviewer falls back to reviewing the working tree and will tell you it did.

**Gate B stops and points at Gate A.**
The spec links a brief that isn't `Approach-Approved`. Either run `/approach-review` on that brief, or — if the work genuinely didn't need it — have the Architect record the waiver in the `Brief:` line. On T3 this is not negotiable: a T3 spec without an approved brief is itself a blocking finding.

**Everything feels too heavy for the change you're making.**
It's probably not a T2. A typo is T0 — just ask in direct chat. A bounded change under three files with clear criteria is T1 — hand it straight to `@builder` with inline acceptance criteria, no spec and no gates. Over-tiering is the most common self-inflicted cost.

---

**Next:** [WORKFLOW.md](WORKFLOW.md) — tiers, gate mechanics, multi-spec features, and the phrases that drive the pipeline.
