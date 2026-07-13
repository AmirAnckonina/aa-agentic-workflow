# Scope Review — Extended Checklist

## Coherence: Is This One Thing?

- [ ] Can the spec be described in one sentence without using "and" to join two independent capabilities?
- [ ] Do all acceptance criteria contribute to the same user-facing outcome?
- [ ] Could any subset of the ACs be shipped independently and provide value on its own? (If yes — split candidate)
- [ ] Are there two clearly separable data models or two unrelated API surfaces in one spec?
- [ ] Does the spec serve one type of user/caller, or multiple with conflicting needs?

## Split Criteria (Mandatory Check)

Split if ANY of the following is true:

- [ ] More than 12 acceptance criteria → split by capability boundary
- [ ] More than 3 components being modified → evaluate if changes are truly coupled
- [ ] Independent capabilities that could be implemented and tested separately → split
- [ ] "Phase 1" and "Phase 2" appear in the same spec → split at phase boundary
- [ ] Different team members could implement different parts without stepping on each other → split

If a split is warranted — propose the boundary and the ordering (which spec is a prerequisite for which).

## Requirement Alignment

- [ ] Re-read the original user request. Does the spec deliver exactly what was asked?
- [ ] Is there anything in the spec that was NOT asked for? (gold-plating)
- [ ] Is there anything that WAS asked for but is NOT in the spec? (under-delivery)
- [ ] If the spec deviates from the request — is the deviation explicitly justified?
- [ ] Are any assumptions made by the Architect that were not stated in the requirements?
  If yes — are they flagged as open questions for the user?

## Over-Engineering Detection

Flag any of these patterns:

| Pattern | Sign of over-engineering |
|---|---|
| Abstract base class / interface for a single implementation | Premature abstraction — one implementation doesn't need an interface |
| Plugin system / extension points | Only justified if multiple implementations are coming soon |
| Event sourcing for simple CRUD | Adds complexity without clear benefit for the stated requirements |
| Custom framework/DSL | Almost always wrong — use existing conventions |
| Generic solution for a specific problem | "We might need this later" is not a requirement |
| Config-driven behavior for behavior that won't change | Adds complexity, reduces clarity |
| Multiple layers of indirection | Repository → Service → UseCase → Handler for a simple read |
| Feature flags for permanent behavior | Only needed for gradual rollout or A/B testing |

For each flagged pattern: is there a concrete, near-term requirement that justifies the complexity?
If not — recommend the simpler approach.

## Under-Specification Detection

Flag any of these patterns:

| Pattern | Sign of under-specification |
|---|---|
| Section is one sentence for a non-trivial concept | Needs more depth |
| "TBD", "TODO", or "as needed" in any section | Not ready for Builder |
| Error handling says only "return error" | Must specify status code, message, and recovery |
| Interfaces section is empty or missing | Builder cannot start without it |
| Acceptance criteria fewer than 2 items for a non-trivial feature | Under-specified |
| No failure modes for a spec with external dependencies | Must enumerate them |
| Security Considerations says "N/A" for an authenticated endpoint | Must be reviewed |

## Future Speculation

- [ ] Does the spec include implementation notes for features not being built now?
- [ ] Are there comments like "in the future we should..." or "we might later add..."?
- [ ] Are there extension points designed for hypothetical future requirements?
- [ ] Is there dead code or placeholder implementations for future features?

Rule: Future work belongs in `Constraints` as a single note ("Phase 2 will add X — design for extensibility but do not implement"). It must not appear anywhere else in the spec.

## Dependency Creep

- [ ] Does the spec introduce new libraries that aren't already in the project?
  - Is each new library justified? Is there an existing alternative in the codebase?
  - What is the maintenance burden and security exposure of the new dependency?
- [ ] Does the spec introduce new infrastructure? (new DB, new queue, new service)
  - Is it proportional to the requirement?
  - Could the requirement be met with existing infrastructure?
- [ ] Does the spec require changes to shared/core components?
  - Are those changes backward-compatible?
  - Do they affect teams or services not mentioned in the spec?

## Builder Autonomy Violation

The spec must define WHAT, not HOW. Flag these:

- [ ] Pseudocode or algorithm steps in the spec body (Builder's job)
- [ ] Specific variable names, method names, or loop structures prescribed
- [ ] "Do X, then Y, then Z" step-by-step instructions inside a spec section
- [ ] Test code or mock implementations included in the spec
- [ ] Before/after code diffs showing implementation changes

For each violation: convert it to an acceptance criterion or an interface definition, then remove the implementation detail.
