---
description: "Internal code review — reviews the current branch against the Architect's spec (Pass 1: spec compliance; Pass 2: delegated /code-review) and prints the verdict report to the terminal. Git actions optional, on request only."
argument-hint: "[focus areas or notes]"
model: sonnet
---

# Internal Code Review

Review the current branch's implementation against the Architect's spec.

## Context

**Branch:** !`git branch --show-current`

**Recent changes:**
!`git diff --stat`

## Workflow

### Step 1: Run the Review
Use the Agent tool to invoke the **reviewer** agent:
- **subagent_type:** `reviewer`
- **description:** "Internal code review"
- **prompt:** Construct the prompt including:
  1. "INTERNAL MODE review."
  2. Include the branch name and change summary from the Context section above.
  3. If `$ARGUMENTS` is not empty, add: "Focus areas / notes from the user: $ARGUMENTS"
  4. If `$ARGUMENTS` is empty, omit focus areas — the reviewer runs a full review by default.

### Step 2: Handle the PASS 1 ONLY Fallback
If the reviewer's report is marked **PASS 1 ONLY** (it could not invoke the built-in `code-review` skill from its subagent context):
1. Relay the Pass 1 report first (per Step 3 rules).
2. Then invoke the built-in **code-review** skill yourself from this session, at the effort the reviewer named (feature → medium, system change → high). If the reviewer reported a repo review-rules file, include its contents as review guidance.
3. Combine: apply the reviewer's verdict rules to the union of findings and state the final verdict yourself.

### Step 3: Present Results
Relay the **complete review report verbatim** to the user. This MUST include ALL of the following — do NOT summarize or omit any section:
1. TL;DR and Verdict
2. The full **Spec Compliance (Pass 1) table** and the **AC Coverage table**
3. The Quality (Pass 2) line — what was delegated, at what effort, with which repo rules
4. Findings Summary (counts by severity)
5. Critical & Important findings with details

Do NOT convert tables into narrative text. Reproduce them as markdown tables exactly as the reviewer produced them.

### Step 4: Close Out
**The terminal report is the deliverable — the command ends there.**

- If **SHIP IT**: append one line: *"Review passed. Git actions available on request (commit / push / PR-MR)."* Take NO git action unless the user explicitly asks in a follow-up.
- If **NEEDS WORK / BLOCKER**: the findings list is the close-out. Do NOT offer git actions.

**Do NOT suggest compile/build commands.** The reviewer already ran tests and linter — do not re-verify.
