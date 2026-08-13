#!/bin/sh
# aa-report.sh — aggregate <repo>/.aa-workflow/runs/*.jsonl into a per-feature
# JSON summary on stdout. Deterministic aggregation only; presentation is the
# /aa-report command's job.
#
# Token note: stage_stop records carry CUMULATIVE session usage (tokens_cum).
# This script derives per-session deltas (last snapshot minus first) as the
# pipeline-window usage; sessions with a single snapshot contribute null.

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo '{"error":"not a git repository"}'; exit 0; }
DIR="$ROOT/.aa-workflow/runs"
if ! ls "$DIR"/*.jsonl >/dev/null 2>&1; then
  echo '{"error":"no telemetry recorded yet","dir":"'"$DIR"'"}'
  exit 0
fi
command -v jq >/dev/null 2>&1 || { echo '{"error":"jq not installed"}'; exit 0; }

cat "$DIR"/*.jsonl 2>/dev/null | jq -s '
  def sumfields($a; $b):
    { in:          (($b.in // 0)          - ($a.in // 0)),
      out:         (($b.out // 0)         - ($a.out // 0)),
      cache_read:  (($b.cache_read // 0)  - ($a.cache_read // 0)),
      cache_write: (($b.cache_write // 0) - ($a.cache_write // 0)) };

  def session_delta:                       # array of tokens_cum snapshots (non-null, in ts order)
    if length >= 2 then
      .[0] as $first | .[-1] as $last
      | ($last | to_entries
         | map({key, value: sumfields(($first[.key] // {}); .value)})
         | from_entries)
    else null end;

  def merge_models($acc; $d):
    reduce ($d | to_entries[]) as $e ($acc;
      .[$e.key] = {
        in:          ((.[$e.key].in // 0)          + $e.value.in),
        out:         ((.[$e.key].out // 0)         + $e.value.out),
        cache_read:  ((.[$e.key].cache_read // 0)  + $e.value.cache_read),
        cache_write: ((.[$e.key].cache_write // 0) + $e.value.cache_write) });

  map(select(type == "object" and .v == 1))
  | group_by(.run // "unattributed")
  | map(
      sort_by(.ts) as $recs
      | {
          run:      ($recs[0].run // "unattributed"),
          branches: ($recs | map(.branch) | map(select(. != null and . != "")) | unique),
          specs:    ($recs | map(.spec)   | map(select(. != null)) | unique),
          first_ts: $recs[0].ts,
          last_ts:  $recs[-1].ts,
          sessions: ($recs | map(.session) | map(select(. != null and . != "")) | unique | length),
          stages:   ($recs | map(select(.event == "stage_stop")) | group_by(.agent)
                     | map({agent: .[0].agent, runs: length,
                            verdicts: (map(.verdict) | map(select(. != null)))})),
          gates:    ($recs | map(select(.event == "gate_run")) | group_by(.skill)
                     | map({gate: .[0].skill, rounds: length,
                            modes: (map(.mode) | map(select(. != null)) | unique),
                            verdicts: (map(.verdict) | map(select(. != null))),
                            last_verdict: (map(.verdict) | map(select(. != null)) | last)})),
          tokens_pipeline_window:
            ($recs | map(select(.event == "stage_stop" and .tokens_cum != null))
             | group_by(.session)
             | map(map(.tokens_cum) | session_delta)
             | map(select(. != null))
             | if length == 0 then null
               else reduce .[] as $d ({}; merge_models(.; $d)) end)
        })
  | { generated: (now | todate), runs: . }
'
exit 0
