---
description: Summarize this repo's pipeline telemetry — features, stages, gate rounds, token usage
argument-hint: "[feature/run name to focus on]"
model: sonnet
---

# Pipeline telemetry report

Aggregated telemetry for this repo (from `.aa-workflow/runs/`):

!`"${CLAUDE_PLUGIN_ROOT}/scripts/aa-report.sh"`

## Your task

Present the JSON above as a readable report. If `$ARGUMENTS` names a feature/run, focus on it; otherwise cover all runs, most recent first.

Per run, show a compact block:

- **Run / branch / spec** — one line.
- **Stages** — table: agent · times run · verdicts (a re-run of the same agent usually means a NEEDS WORK loop — say so).
- **Gates** — table: gate · rounds · mode · verdict trail (e.g. `Blocking → Approved` = one revision cycle; more than 2 rounds is worth flagging).
- **Tokens (pipeline window)** — per model: in / out / cache. This is the delta between the first and last pipeline event in each session, so it approximates pipeline-attributable usage, not the whole session. If `null`, say token data wasn't capturable (single snapshot or transcript format change) — never invent numbers.

Close with one short **Signals** section — only observations the data actually supports, e.g.:
- gates that never blocked anything across many rounds (candidate to lighten),
- repeated NEEDS WORK loops on one agent (candidate for a rules/context fix),
- runs with no gate records at all (pipeline bypassed?).

If the JSON contains an `error` field, explain it plainly (no telemetry yet / jq missing / not a git repo) and stop. Do not scan `.aa-workflow/` yourself; the script output is the single source.
