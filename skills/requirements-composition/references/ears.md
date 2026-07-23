# EARS — Easy Approach to Requirements Syntax

EARS gently constrains natural language into a fixed clause order with a tiny keyword set. It removes ambiguity, vagueness, and incompleteness while staying readable — which is exactly what makes each acceptance criterion **mappable to one test and traceable through implementation**. (Origin: Mavin et al., Rolls-Royce, IEEE RE'09; used at Airbus, Bosch, NASA, Siemens.)

## The keyword is `SHALL`

Every EARS requirement states what the system **SHALL** do. The clause(s) in front of `SHALL` set the condition. There are six patterns — pick the simplest one that fits.

| Pattern | Template | When to use |
|---|---|---|
| **Ubiquitous** | THE SYSTEM SHALL `<response>` | Always-true property, no trigger or precondition |
| **Event-driven** | WHEN `<trigger>`, THE SYSTEM SHALL `<response>` | A response to a specific event/input |
| **State-driven** | WHILE `<precondition>`, THE SYSTEM SHALL `<response>` | Behavior that holds during a state |
| **Optional-feature** | WHERE `<feature is included>`, THE SYSTEM SHALL `<response>` | Behavior tied to an optional/configurable feature |
| **Unwanted-behavior** | IF `<unwanted trigger>`, THEN THE SYSTEM SHALL `<response>` | Error handling, validation, guardrails |
| **Complex** | WHILE `<precondition>`, WHEN `<trigger>`, THE SYSTEM SHALL `<response>` | Combine a state and an event |

## Examples

- **R1** (event) — WHEN a user submits the login form with valid credentials, THE SYSTEM SHALL establish an authenticated session and redirect to the dashboard.
- **R2** (unwanted) — IF a user submits the login form five times with an invalid password within one minute, THEN THE SYSTEM SHALL lock the account for fifteen minutes.
- **R3** (state) — WHILE a payment is being processed, THE SYSTEM SHALL prevent the user from submitting the same order again.
- **R4** (ubiquitous) — THE SYSTEM SHALL store passwords only as salted hashes.
- **R5** (optional) — WHERE two-factor authentication is enabled for an account, THE SYSTEM SHALL require a valid TOTP code before establishing a session.
- **R6** (complex) — WHILE the export job is running, WHEN the user requests cancellation, THE SYSTEM SHALL stop the job and delete any partial output.

## Rules for good criteria

- **One requirement, one behavior.** If you need "and also", split into two `R#`s.
- **Testable.** A criterion you cannot write a pass/fail test against is not done — rewrite it. Ban "fast", "user-friendly", "robust"; state the observable behavior or the measurable threshold.
- **Name the actor as the system.** The response is what *the system* does, not what the user does.
- **Cover the unhappy paths.** Every meaningful event-driven requirement usually implies one or more `IF … THEN` guardrails — write them explicitly.
- **Stable IDs.** Once assigned, an `R#` does not get renumbered — the task map and specs reference it. Add new ones with the next number; retire one by marking it removed, not by reusing its number.
