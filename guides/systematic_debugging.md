# Systematic Debugging

**Source:** Adapted from Superpowers `systematic-debugging` skill
(obra/superpowers, MIT License, Jesse Vincent / Prime Radiant, v5.0.7)
**Skill Pack Version:** 0.7.0

## Purpose

Random fixes waste time and create new problems. Quick patches mask
underlying issues.

**Core principle:** Always find root cause before attempting fixes.
Symptom fixes are failure.

**Scope:** This guide applies directly to YAML and Jinja — automations,
scripts, blueprints, and template sensors. The four-phase methodology
applies conceptually to AppDaemon Python, shell scripts, and other
valid HA code integrations, though the specific validation surfaces
(DTT, Traces) are YAML/Jinja-native. For AppDaemon, substitute
appropriate Python debugging and logging techniques at the validation
steps.

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you have not completed Phase 1, you cannot propose fixes.

## Quick Reference

| Phase | Key Activities | Gate to Next Phase |
|---|---|---|
| **1. Root Cause** | Read failure, check changes, isolate to logic vs. orchestration surface, trace data flow | Understand WHAT and WHERE |
| **2. Pattern** | Find working examples, compare against Skill Pack, rule out HA-specific failure modes | Identify the difference |
| **3. Hypothesis** | Form specific theory, test minimally, validate in DTT before any change | Confirmed or revised hypothesis |
| **4. Implementation** | Single surgical fix, DTT re-validation, verify no regressions | Bug resolved or architecture questioned |

---

## When to Use

Use for any issue:
- Automation not firing or firing incorrectly
- Script not executing or producing unexpected results
- Blueprint behaving differently than expected
- Template sensor not loading, or returning wrong or unexpected value
- Dashboard card not displaying correct data or controls
- Helper not updating or holding incorrect state
- Integration or device state behaving unexpectedly
- A previous fix that didn't hold

**Use this especially when:**
- A "quick fix" seems obvious
- You have already tried something that didn't work
- The automation was working and suddenly stopped
- Behavior is intermittent or state-dependent

**Never skip when:**
- The issue seems simple (simple issues have root causes too)
- You are under time pressure (systematic is faster than thrashing)
- You have already tried multiple fixes (stop and investigate)

## The Four Phases

Complete each phase before proceeding to the next.

---

### Phase 1: Root Cause Investigation

**Before attempting any fix:**

#### 1. Read the failure carefully

- What is the exact observed behavior?
- What is the expected behavior?
- When did it start? What changed?
- Is it reproducible every time, or intermittent?

If not reproducible, do not guess. Check Logbook for the relevant
entity's state history over the time window when failures occurred.
Check whether the automation has an existing trace from the last
time it fired or failed to fire — traces persist and may contain
the evidence you need without triggering the issue again.

#### 2. Check recent changes

- Was YAML modified recently?
- Was an entity renamed, removed, or re-paired?
- Did a HA core update or app (add-on) update occur? Check for
  backward-incompatible changes in the last 12 months affecting
  this artifact.
- Did a HACS-managed integration update, lose connection, or
  change behavior?

#### 3. Isolate the failure surface

Failures occur on one of two surfaces. Identify which before
investigating further. Do not attempt to fix orchestration issues
until logic is validated in DTT, and do not modify logic based
solely on trace output.

**Logic failures** — the template, condition, or computed value
is producing the wrong result. Validate in Developer Tools →
Templates:
- Does the template sensor return the expected value?
- Does the condition evaluate correctly given current state?
- Do safe defaults produce the expected fallback output?
- Run DTT pre-flight to confirm all entity references are valid
  (usable-state checks via `has_value()` and defined-entity checks
  where required). See `guides/dtt_first_validation.md` and
  `cookbooks/dtt_techniques.md`.

**Orchestration failures** — the logic is correct but the
automation, script, or blueprint is not behaving as expected.
Check Automation Traces:
- Did the trigger fire?
- Did conditions pass or fail, and why?
- Did the correct action branch execute?
- Did a script or service call fail?

A trace showing a condition failed does not tell you whether the
underlying template logic is correct. Always validate logic in DTT
independently before concluding the logic is fine.

#### 4. Trace the data flow

When a wrong value is deep in the system, trace it backward:
- Where does the bad value first appear?
- What produced that value?
- What produced the input to that producer?
- Keep tracing upstream until you find the origin

Fix at the source, not at the symptom.

---

### Phase 2: Pattern Analysis

**Find the pattern before fixing:**

#### 1. Find working examples

- Is there a similar automation, script, or sensor that works
  correctly?
- What is structurally different between the working and broken
  versions?

#### 2. Compare against Skill Pack patterns

- Does the YAML match expected Skill Pack structure?
- Are trigger types, condition syntax, and action structure correct?
- Are entity references valid? Run DTT pre-flight if not already
  done.
- Are Safe Jinja rules followed — defaults, filters, no Python
  methods?

#### 3. Identify all differences

List every difference between working and broken, however small.
Do not assume anything "can't matter" — in HA, subtle differences
in state values, trigger platform, condition ordering, or entity
naming frequently cause unexpected behavior.

#### 4. Check HA-specific failure modes

Rule out each of these explicitly before forming a hypothesis:

- **Restart state**: did `unknown` or `unavailable` at startup
  prevent the automation from ever reaching the correct state?
  Check whether the startup delay gate fired correctly.
- **Race condition**: did two automations or triggers interact in
  unexpected order? Check trace timing.
- **Recursive loop**: does the trigger entity match the action
  target? See `patterns/recursive_loop.md`.
- **Chatter**: is a noisy sensor firing the automation repeatedly?
  Check whether chatter guards are in place for physical devices.
- **Mode conflict**: is `mode: single` silently dropping runs that
  should execute? Consider whether `mode: queued` is more
  appropriate.
- **Integration degradation**: is an upstream sensor returning
  `unavailable` and propagating through logic that lacks safe
  defaults? See `patterns/integration_degradation.md`.
- **Override suppression**: is a manual override, guest mode, or
  safety coordinator correctly — or incorrectly — blocking
  execution?

---

### Phase 3: Hypothesis and Testing

#### 1. Form a single hypothesis

State clearly: "I think X is the root cause because Y."

Be specific. "Something is wrong with the template" is not a
hypothesis. "The `| float(0)` default is masking an unavailable
state and producing a false zero that passes the condition check"
is a hypothesis.

#### 2. Test minimally

Make the smallest possible change to test the hypothesis. One
variable at a time. Do not fix multiple things at once — you will
not know what worked.

#### 3. Validate in DTT before deploying any change

Confirm the hypothesis holds in Developer Tools → Templates before
modifying any live automation, script, or blueprint. If the
hypothesis involves orchestration behavior, use a trace to verify
after DTT confirms the logic is correct.

#### 4. When the cause is unclear

Do not propose a fix based on incomplete understanding. Attempt to
resolve the uncertainty proactively first:
- Run additional DTT queries to narrow the failure point
- Check area, label, or integration entity lists to verify
  references
- Re-read the trace for missed signals
- Check Logbook for state history around the failure window
- Check HA documentation for the specific trigger or condition
  platform involved

Stopping to ask is the last resort, not the first response.

---

### Phase 4: Implementation

**Fix the root cause, not the symptom:**

#### 1. Implement a single fix

Address the root cause identified. One change at a time. No
"while I'm here" improvements. No bundled refactoring unless
explicitly approved. Favor surgical edits over rewrites.

#### 2. Validate the fix

- Does DTT confirm correct logic output after the change?
- Does the automation, script, or blueprint behave correctly in
  a live test?
- Are other automations, scripts, or sensors unaffected?
- If the fix touched a template sensor, re-run full DTT validation
  per `guides/dtt_first_validation.md`.

#### 3. If the fix doesn't work — stop

Count how many fixes have been attempted:

- **Fewer than 3:** Return to Phase 1 with the new information.
  Something in the root cause analysis was incomplete.
- **3 or more:** Stop. Do not attempt another fix. This pattern
  indicates an architectural problem, not a bug.

#### 4. If 3+ fixes have failed: question the architecture

Signals of an architectural problem in HA terms:
- Each fix reveals a new problem in a different automation or
  sensor
- The brains/muscles separation has broken down — business logic
  has leaked into automations instead of living in template sensors
- Multiple automations are creating conflicting state
- Safe defaults are masking a deeper data quality problem

Stop and address the architectural question before proceeding.
See `guides/architecture_principles.md`.

---

## Red Flags — Stop and Return to Phase 1

If you catch yourself thinking any of these, stop immediately:

- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "One more fix attempt" (when 2+ have already failed)
- Proposing solutions before completing data flow trace
- Each fix revealing a new problem in a different place
- "The trace looked fine" without validating logic in DTT

**All of these mean: stop. Return to Phase 1.**

**If 3+ fixes have failed:** question the architecture before
attempting anything else.

---

## Common Rationalization Failures

| Excuse | Reality |
|---|---|
| "Issue is simple, don't need process" | Simple issues have root causes. Process is fast for simple bugs. |
| "Quick fix first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "The trace looked fine" | Traces show orchestration, not logic correctness. Validate logic in DTT independently. |
| "The template looks right" | Validate in DTT. Looking right proves nothing. |
| "It was working before the update" | HA core, app, and HACS-managed integration updates all require explicit review. Check the last 12 months. |
| "Multiple fixes at once saves time" | Cannot isolate what worked. Creates new bugs. |
| "One more fix attempt" (after 2+) | 3+ failures = architectural problem. Question the design, not the symptom. |
| "I don't know, I'll ask" | Attempt to resolve proactively first — DTT queries, entity discovery, trace re-review, Logbook history, HA docs. |

---

## Relationship to DTT-First Validation

Systematic debugging is the path for **existing behavior that is
wrong**. DTT-first validation is the gate for **new logic before
deployment**.

If debugging reveals that logic was deployed without DTT validation,
that is a process gap — apply full DTT validation as part of the
fix, not after.
