# Completeness — Auditor Charter

**Accountable for:** one question — *can the Builder implement this spec without guessing?* Every guess the spec forces is a finding; everything the Builder can already infer from the codebase is not.

## Traps worth hunting

- **Untestable acceptance criteria.** Flag any AC matching these patterns:

| Anti-pattern | Fix |
|---|---|
| "should work correctly", "handles errors gracefully" | name the observable behavior / the specific errors and responses |
| "should be fast" | a concrete target, only if one actually matters |
| "properly validates", "as needed" | list what is validated / the condition |

  Each AC should map to one observable outcome a test can assert.
- Interface signatures missing parameter types, return types, or error/exception cases — the Builder implements these *as-is*, so a hole here becomes an invented contract.
- External calls whose failure case is unspecified: what does the caller see on timeout/error?
- Requirements asked for but only partially covered by the ACs — re-read the original request/`R#` lines and check the mapping both ways.
- A wrongly-`N/A`'d section: `N/A — reason` is a first-class answer; challenge it **only when the reason is false** (e.g., "no external input" on a spec that parses user uploads). Never demand content for a section whose N/A reason holds.
- Placeholder text where the Builder needs substance: "TBD", "TODO", a one-liner standing in for a real contract.
- A bug-fix spec that addresses the symptom without naming the root cause — a null check with no account of why the null arrives is a guess wearing a fix.

## Judgment line

Completeness means *sufficient for this Builder in this codebase* — not exhaustive. Conventions the codebase already enforces (error wrapping style, logging shape, test layout) don't need restating in the spec, and their absence is not a gap.
