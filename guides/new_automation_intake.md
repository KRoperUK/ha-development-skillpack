# New Automation Intake

**Source:** Adapted from Superpowers `brainstorming` skill
(obra/superpowers, MIT License, Jesse Vincent / Prime Radiant, v5.0.7)


## Purpose

State the design before writing any YAML. Clarify intent, select the
right construct, and classify impact before opening a design session.
Unexamined assumptions cause more wasted work than complex problems.

If the idea has not yet been vetted for feasibility, apply
`guides/exploratory_mode.md` before opening intake.

**Core principle:** No new automation, script, or template sensor may
be designed without applying this intake process first. See escape
hatches below for defined exceptions.

## Quick Reference

**Is this a bug fix?** → `guides/systematic_debugging.md`, not here
**Does an escape hatch apply?** → see Escape Hatches section
**Impact class + novelty?** → determines full or abbreviated intake

| Path | Steps |
|---|---|
| Unvetted idea | `guides/exploratory_mode.md` before intake |
| Full intake | 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 (DTT) → YAML |
| Abbreviated intake | 0 → 1 → 2 → 3 → 7 (DTT) → YAML |
| Bug fix | `guides/systematic_debugging.md` |
| Escape hatch | Skill Pack standards still apply |

---

## Process Depth Gate

Process depth is determined by two axes — **impact class** and
**novelty**. Apply both before deciding which path to take.

| | Routine (known pattern) | Architecturally novel |
|---|---|---|
| **Class A / B** | Full intake | Full intake |
| **Class C / D** | Abbreviated intake | Full intake |

**Bug fixes to existing designs:** Skip intake entirely. Go directly
to `guides/systematic_debugging.md`.

**New support sensors for existing automations:** Abbreviated intake
unless the sensor introduces new system boundaries or cross-system
logic.

**Novelty defined:** An automation is architecturally novel if it
introduces new system boundaries, new construct types not previously
used in this system, new cross-system dependencies, or design
patterns not already established in the Skill Pack.

---

## Escape Hatches

The following request types are exempt from intake. Skill Pack
implementation standards still apply in full — the escape hatch
waives the intake *process*, not the quality bar.

### 1. Throwaway automations

Explicitly temporary artifacts with no production intent — reminders
to delete deprecated items, one-time baseline captures, one-time
diagnostic automations. Must be explicitly declared as throwaway at
the time of the request. If there is any ambiguity about whether it
is throwaway, apply abbreviated intake.

### 2. Structurally simple automations

All of the following must be true:
- No more than 2 triggers, both using native (non-template) platforms
- No more than 1 condition
- No more than 2 actions
- Any branching (`choose` or `if/then`) is limited to `trigger.id`
  routing only — no condition evaluation inside branches
- Class A or B automations are **ineligible** for this escape hatch
  regardless of structural simplicity

### 3. Helping a friend

When explicitly assisting another HA user with their artifacts rather
than building for this system. Skill Pack implementation standards
still apply — the escape hatch waives the intake process, not the
quality bar.

---

## Intake Process

### Full Intake

Complete all steps in order. Do not proceed to design until each
step is done.

#### Step 0 — Check for Existing Solutions

Before classifying impact or selecting a construct, determine
whether this problem is already solved or partially solved:

- Does an existing automation, script, or template sensor already
  handle this behavior or could be extended to do so?
- Is there a relevant Skill Pack pattern in `patterns/` or
  `samples/` that covers this use case?

If yes: evaluate extension vs. new artifact **after** completing
Step 1 (SIC). A meaningful change to an existing Class A/B artifact
requires the same rigor as a new one. Document why extension was
chosen or ruled out before proceeding.

If no existing solution: proceed to Step 1.

#### Step 1 — System Impact Classification

Classify by worst-credible impact if the automation fails. See
`guides/system_impact_class.md`. Record:
- Selected class (A / B / C / D)
- Worst-credible failure mode
- Any Context Elevation reasoning

Classification determines required rigor for all subsequent steps.
If classification is ambiguous, assume the more severe class and
confirm before proceeding.

#### Step 2 — Construct Selection

Apply the decision ladder in order. Stop at the first tier that
solves the problem. Do not skip tiers.

1. **Native construct** — can a built-in trigger, condition, or
   action cover this without Jinja? Native constructs validate at
   load time and fail loudly; templates fail silently at runtime.

2. **Built-in helper** — can a helper replace a template sensor?
   Helpers are declarative, handle unavailable states gracefully,
   and require no Jinja. Common substitutions: sum/average →
   `min_max`; binary any-on/all-on → `group`; rate of change →
   `derivative`; threshold with hysteresis → `threshold`.

3. **Template sensor (brains)** — only if tiers 1 and 2 cannot
   solve it. Computes directives and intent; treated as
   non-authoritative output.

4. **AppDaemon** — preferred when YAML is insufficient for the
   requirements: long-lived state, multi-step workflows, complex
   orchestration, or external system coordination. Skill Pack
   constraints still apply for all HA behavior (state handling,
   restart resilience, overrides); Superpowers-style decomposition
   and testing may be used for implementation discipline.

Document the selected construct and why higher tiers were ruled out.

#### Step 3 — Clarify Intent

Ask one question at a time when clarifying ambiguous requirements.
Establish:
- What observable state change defines success?
- What should happen when key entities are unavailable?
- What should happen at startup before helpers are restored?
- Are there manual override or guest mode interactions?
- What downstream automations or sensors depend on this?
- What is the household UX impact — who else will be affected and
  how?

Do not proceed to Step 4 until success is expressible in observable
HA state terms, not behavioral descriptions.

#### Step 4 — Develop and Evaluate Approaches

This step is internal work before any proposal is made. Generate
3–5 candidate approaches, then evaluate and filter before
presenting anything.

For each candidate, evaluate against:
- HA feasibility — is this achievable with the selected construct
  from Step 2?
- Restart resilience — does it survive HA restart and entity
  unavailability?
- Skill Pack compatibility — does it follow Core Rules and
  existing patterns?
- HAF implications — could this annoy or disrupt household members?
- Simplicity — is there a simpler approach that achieves the same
  outcome?

Discard candidates that fail any evaluation. Repeat until 2–3
viable approaches remain. Do not proceed to Step 5 until the
viable set is confirmed internally.

#### Step 5 — Propose Approaches for Selection

Present the 2–3 viable approaches from Step 4 with trade-offs.
Lead with the recommended option and explain why. Cover for each:
- Simplicity vs. flexibility trade-off
- Restart resilience implications
- Impact on existing automations or sensors
- Household UX implications

Do not proceed to Step 6 until an approach is selected.

#### Step 6 — Present Design for Approval

Present the design in sections scaled to complexity. Cover:
- Trigger strategy and mode
- Brains location (which tier from Step 2)
- Failure modes: restart, unavailable entities, manual override
- Conditions and their ordering (fast-fail first)
- Action structure
- Household UX review: could this annoy, surprise, or disrupt
  household members who did not ask for this automation?

Get explicit approval before proceeding to implementation. If any
section raises questions, resolve them before moving on.

Designs produced during intake are non-authoritative until
implemented and validated under Skill Pack standards.

#### Step 7 — DTT-First Validation

Before writing any YAML, validate all Jinja logic and entity
references in Developer Tools → Templates. See
`guides/dtt_first_validation.md` for the full validation cycle.

No implementation YAML until DTT validation passes.

---

### Abbreviated Intake

For Class C/D routine work and new support sensors without new
system boundaries. Complete Steps 0–3 and Step 7 only, then
proceed directly to implementation.

- **Step 0**: Check for existing solutions. If extending an
  existing artifact, complete Step 1 before deciding.
- **Step 1**: Classify impact. If Class A or B is possible, switch
  to full intake immediately.
- **Step 2**: Select construct. Document the choice.
- **Step 3**: State the observable success condition, key failure
  paths, and household UX impact in one or two sentences.

DTT-first validation (Step 7) is still required before deployment.

---

## Key Principles

- **KISS first** — remove unnecessary triggers, helpers, conditions,
  and branches from all designs; resist premature abstraction
- **Observable state terms** — success must be expressible as
  entity states, not behavioral descriptions
- **Simple is not exempt** — even simple automations have
  unexamined assumptions; abbreviated intake takes minutes
- **Overrides first** — design must account for manual override,
  guest mode, and safety coordinator interactions before any
  other logic
- **Household UX first** — repeated annoyance is a production-level
  defect. Every design must account for how it affects household
  members who did not ask for automation. Review HAF implications
  before approving any design that affects shared spaces, schedules,
  or device behavior visible to others. See
  `guides/review_and_checklist.md` HAF sub-checklist.

---

## Relationship to Other Guides

- For unvetted ideas, apply `guides/exploratory_mode.md` before opening intake
- For implementation standards, see `SKILL.md` Core Rules
- For review and validation, see `guides/review_and_checklist.md`
- For DTT validation, see `guides/dtt_first_validation.md`
- For debugging existing behavior, see
  `guides/systematic_debugging.md` instead of this guide
- For impact classification, see `guides/system_impact_class.md`
