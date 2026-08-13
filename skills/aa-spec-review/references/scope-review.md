# Scope — Auditor Charter

**Accountable for:** two questions — *is this one unit?* and *is it exactly what was asked?*

## Traps worth hunting

- **Unit violations** (split candidates — propose the boundary and ordering):
  - more than ~12 acceptance criteria, or more than 3 components modified
  - independent capabilities that could ship and be tested separately
  - "Phase 1" and "Phase 2" living in the same spec
- **Gold-plating:** anything present that wasn't asked for and isn't justified. Classic shapes: an abstraction with a single implementation, extension points for hypothetical futures, config-driven behavior that won't change, a new library or infrastructure where existing pieces would do.
- **Under-delivery:** anything asked for that the spec quietly dropped — re-read the original request and diff it against the spec.
- **Unstated assumptions:** decisions the Architect made that the user never stated and the spec doesn't flag as open questions.
- **Builder-autonomy violations:** pseudocode, step-by-step algorithms, prescribed variable names, test code, or before/after diffs inside the spec — the spec owns *what*, the Builder owns *how*. Convert each to an AC or an interface, then cut it.
- Future speculation outside the single allowed form (a one-line Constraints note: "Phase 2 will add X — design for extensibility but do not implement").

## Judgment line

Over-engineering needs a concrete, near-term requirement to justify itself — "we might need it later" fails. But don't invert into minimalism-policing: if the spec's extra piece is small and the user asked for it, it's in scope.
