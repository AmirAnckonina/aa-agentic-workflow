#!/bin/sh
# aa-telemetry.sh — append-only pipeline telemetry. FAIL-OPEN BY CONTRACT:
# every failure path exits 0; telemetry must never break the pipeline.
#
# Usage (hook payload on stdin):
#   aa-telemetry.sh stage <agent>   Stop/SubagentStop hook in an agent's frontmatter
#   aa-telemetry.sh gate            PostToolUse hook (matcher: Skill), plugin-level
#
# Records land in <repo>/.aa-workflow/runs/<YYYY-MM>.jsonl, one JSON object per
# line, schema v1. Opt out with AA_TELEMETRY_OFF=1. Requires jq (skips without).
#
# Token counts are CUMULATIVE session usage parsed from the transcript, which is
# not a stable contract across Claude Code versions — any parse failure records
# null. Per-stage deltas are derived at report time, never here.

[ "${AA_TELEMETRY_OFF:-0}" = "1" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

MODE="${1:-stage}"
AGENT_ARG="${2:-}"

PAYLOAD=$(cat 2>/dev/null) || exit 0
[ -n "$PAYLOAD" ] || exit 0

CWD=$(printf '%s' "$PAYLOAD" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$CWD" ] || CWD=$(pwd)
ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -n "$ROOT" ] || exit 0

SESSION=$(printf '%s' "$PAYLOAD" | jq -r '.session_id // empty' 2>/dev/null)
BRANCH=$(git -C "$ROOT" branch --show-current 2>/dev/null)
TOPIC=$(printf '%s' "$BRANCH" | sed -E 's#^[a-z]+/##; s/^[A-Za-z]+-[0-9]+-//')

# Best-effort spec attribution — same containment-then-token logic as the
# builder spec-gate hook.
SPEC=""
SPECDIR="$ROOT/docs/specs"
if [ -d "$SPECDIR" ] && [ -n "$TOPIC" ]; then
  for f in "$SPECDIR"/*.md; do
    [ -e "$f" ] || continue
    b=$(basename "$f" .md)
    case "$TOPIC" in *"$b"*) SPEC="docs/specs/$b.md"; break ;; esac
  done
  if [ -z "$SPEC" ]; then
    for f in "$SPECDIR"/*.md; do
      [ -e "$f" ] || continue
      b=$(basename "$f")
      for tok in $(printf '%s' "$TOPIC" | tr '-' ' '); do
        [ ${#tok} -ge 4 ] || continue
        case "$b" in *"$tok"*) SPEC="docs/specs/$b"; break 2 ;; esac
      done
    done
  fi
fi

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
OUTDIR="$ROOT/.aa-workflow/runs"
mkdir -p "$OUTDIR" 2>/dev/null || exit 0
OUT="$OUTDIR/$(date -u +%Y-%m).jsonl"

case "$MODE" in
stage)
  AGENT="$AGENT_ARG"
  [ -n "$AGENT" ] || AGENT=$(printf '%s' "$PAYLOAD" | jq -r '.agent_type // "unknown"' 2>/dev/null)

  LAST=$(printf '%s' "$PAYLOAD" | jq -r '.last_assistant_message // ""' 2>/dev/null | head -c 20000)
  VERDICT=null
  case "$LAST" in
    *BLOCKER*)                                    VERDICT='"BLOCKER"' ;;
    *"NEEDS WORK"*)                               VERDICT='"NEEDS WORK"' ;;
    *"SHIP IT"*)                                  VERDICT='"SHIP IT"' ;;
    *"Result: Blocked"*|*"Result:** Blocked"*)    VERDICT='"Blocked"' ;;
    *"Result: Complete"*|*"Result:** Complete"*)  VERDICT='"Complete"' ;;
    *RETHINK*)                                    VERDICT='"RETHINK"' ;;
    *"Approach-Approved"*)                        VERDICT='"Approach-Approved"' ;;
  esac

  TOKENS=null
  TP=$(printf '%s' "$PAYLOAD" | jq -r '.transcript_path // empty' 2>/dev/null)
  if [ -n "$TP" ] && [ -r "$TP" ]; then
    TOKENS=$(jq -nR '
      [inputs | fromjson? | .message? | select(type == "object")
       | select(.usage != null and .model != null) | {m: .model, u: .usage}]
      | group_by(.m)
      | map({key: .[0].m, value: {
          in:          (map(.u.input_tokens // 0) | add),
          out:         (map(.u.output_tokens // 0) | add),
          cache_read:  (map(.u.cache_read_input_tokens // 0) | add),
          cache_write: (map(.u.cache_creation_input_tokens // 0) | add)}})
      | from_entries' "$TP" 2>/dev/null) || TOKENS=null
    [ -n "$TOKENS" ] || TOKENS=null
  fi

  jq -cn --arg ts "$TS" --arg agent "$AGENT" --arg session "$SESSION" \
     --arg branch "$BRANCH" --arg run "$TOPIC" --arg spec "$SPEC" \
     --argjson verdict "$VERDICT" --argjson tokens "$TOKENS" \
     '{v: 1, ts: $ts, event: "stage_stop", agent: $agent, session: $session,
       branch: $branch, run: $run,
       spec: (if $spec == "" then null else $spec end),
       verdict: $verdict, tokens_cum: $tokens}' >> "$OUT" 2>/dev/null
  ;;

gate)
  SKILL=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.skill // .tool_input.name // empty' 2>/dev/null)
  case "$SKILL" in
    *approach-review|*spec-review|*review-internal) : ;;
    *) exit 0 ;;
  esac
  SKILL_SHORT=${SKILL##*:}

  RESP=$(printf '%s' "$PAYLOAD" | jq -r \
    '(.tool_response // "") | if type == "string" then . else tojson end' 2>/dev/null | head -c 20000)

  GMODE=null
  case "$RESP" in
    *panel*) GMODE='"panel"' ;;
    *lite*)  GMODE='"lite"' ;;
  esac

  VERDICT=null
  case "$RESP" in
    *"Not Approved"*) VERDICT='"Not Approved"' ;;
    *BLOCKER*)        VERDICT='"BLOCKER"' ;;
    *"NEEDS WORK"*)   VERDICT='"NEEDS WORK"' ;;
    *"SHIP IT"*)      VERDICT='"SHIP IT"' ;;
    *RETHINK*)        VERDICT='"RETHINK"' ;;
    *Blocking*)       VERDICT='"Blocking"' ;;
    *PASS*)           VERDICT='"PASS"' ;;
    *Approved*)       VERDICT='"Approved"' ;;
  esac

  DUR=$(printf '%s' "$PAYLOAD" | jq -r '.duration_ms // 0' 2>/dev/null)
  case "$DUR" in ''|*[!0-9]*) DUR=0 ;; esac

  jq -cn --arg ts "$TS" --arg skill "$SKILL_SHORT" --arg session "$SESSION" \
     --arg branch "$BRANCH" --arg run "$TOPIC" --arg spec "$SPEC" \
     --argjson verdict "$VERDICT" --argjson gmode "$GMODE" --argjson dur "$DUR" \
     '{v: 1, ts: $ts, event: "gate_run", skill: $skill, mode: $gmode,
       session: $session, branch: $branch, run: $run,
       spec: (if $spec == "" then null else $spec end),
       verdict: $verdict, duration_ms: $dur}' >> "$OUT" 2>/dev/null
  ;;
esac

exit 0
