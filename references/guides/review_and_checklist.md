# Review & Checklist — How‑To + Rubric (Single Source of Truth)

For new or novel work, complete `references/guides/new_automation_intake.md`
before opening a review. For bug fixes, use
`references/guides/systematic_debugging.md`. Review begins after the relevant
intake or debugging step is complete. DTT validation is mandatory
before deployment approval, but design or patch reviews may occur
before DTT when the artifact is not yet ready to run.

## Review Process Summary

**Before starting**: surgical edits over rewrites — minimum diff footprint; rewrites require explicit approval.

| Step | Gate | Hard stop? |
|------|------|------------|
| 0 | **Security** — scan for secrets/identifying material | ✅ Yes |
| — | **Pre-deployment validation triage** — scan for risk triggers requiring specific validation before deployment approval | |
| 1 | **Impact classification** — Class A–D; determines rigor for all steps below | ✅ Yes for A/B without risk assessment |
| 2 | **KISS** — simplest viable solution; 2–3 options presented for non-trivial problems | |
| 3 | **Syntax & structure** — GUI-friendly YAML, plural keys, alias/note/description placement, comments policy | |
| 4 | **DTT validation** — all Jinja and entity references proven before **deployment approval** | ✅ Yes for deployment |
| 5 | **Traces** — orchestration/timing verified via Automation Traces where needed | |
| 6 | **Live test** — happy-path trigger exercised | |
| 7 | **Intent alignment** — implementation matches stated intent; conditions ordered correctly; network traffic minimized | |
| 8 | **Wait/timeout** — `wait_template` preferred; exclusion lists guard empty string | |
| 9 | **Restart & recovery** — correct `for:` windows; no action delays for staggering | |
| 10 | **Idempotency & chatter** — device call guards; batching; rate-limiting | |
| 11 | **Overrides & safety** — manual/guest/safety modes confirmed to win | |
| 12 | **Backward-compat** — last 12 months of breaking changes reviewed; confirm `BC review: done` or `BC review: N/A` | |
| 13 | **Changelog** — entry added in correct format and location | |
| 14 | **Exceptions** — any deviations documented inline | |
| 15 | **Blueprint validation** — if applicable | |
| 16 | **HAF** — household UX impact reviewed; annoyance risk mitigated | ✅ Yes for shared spaces |
| 17 | **Self-critique & grade** — A- minimum for production; verdict assigned | |

**Grading minimum**: A- for production deployment. Anything below requires fixes or explicit deferral with documented rationale.

Use section **A)** for the full flow, **A1)** for hard stops, **C)** for copy-paste checklists.

## Blocking Gate — Secret & Identifying Material
- Compliant with `references/spec/security.md` (no secret or identifying material present).

If detected:
- Mark as ❌
- Stop review
- Do not continue architectural analysis

## Pre-Deployment Validation Triage

Before deployment approval, scan for risk triggers that require specific validation:

- **Touches physical devices?** Confirm idempotency, chatter control, and manual override behavior.
- **Runs on startup or HA restart?** Confirm startup gate, restart staggering, and unavailable-entity behavior.
- **Uses high-frequency triggers or noisy sensors?** Confirm debounce, rate limit, and oscillation control.
- **Uses Jinja?** Confirm DTT validation and safe unavailable-state handling.
- **Uses time/deadline logic?** Confirm timezone handling, restart resilience, and timer vs `input_datetime` selection.
- **Calls cloud/API/integration services?** Confirm availability handling, bounded retry, cooldowns, and no reload/command storms.
- **Affects shared spaces, sleep, comfort, safety, or household schedules?** Confirm HAF review.
- **Refactors existing behavior?** Confirm surgical diff, preserved intent, and rollback path.

## A) Review Flow (Detailed)

0) **Security**
   - Hard stop if secrets or identifying material are present. See `references/spec/security.md`.

1) **System Impact Classification**
   - Classify by worst-credible failure impact using `references/guides/system_impact_class.md`.
   - Record class, worst-credible failure mode, and any Context Elevation reasoning. Class A/B without completed risk assessment is a hard stop.

2) **KISS Gate**
   - Choose the simplest robust path. For non-trivial problems, compare 2–3 viable options.
   - Reject speculative complexity not required by the stated intent. See `references/guides/architecture_principles.md`.

3) **Syntax & Structure**
   - Use current release -1 YAML/Jinja standards; reject deprecated or "also works" syntax.
   - GUI-friendly YAML, plural keys, alias/note/description placement, comments policy, trigger rules, and changelog rules per `spec/yaml_style.md`.

4) **DTT Probes — Mandatory Before Deployment Approval**
   - Validate Jinja logic and entity references before deployment approval. See `references/guides/dtt_first_validation.md`.
   - If DTT passes but deployed behavior fails, switch to `references/guides/systematic_debugging.md`.

5) **Traces vs DTT**
   - DTT proves template logic; Automation Traces verify orchestration/timing only when needed.

6) **Live Test**
   - Exercise a happy-path trigger when feasible. Observe Logbook only for significant events.

7) **Best-in-Class Review (Intent Alignment)**
   - For all code, ask:
     1. **Primary intent?** (Lights ON = speed; Lights OFF = validation; Recovery = network efficiency; Notification = reliability)
     2. **Implementation matches intent?** (Minimize checks for ON; rich validation for OFF; sequential+guarded for recovery)
     3. **Conditions in right place?** (Cheap checks first in conditions block; expensive operations only on needed paths)
     4. **Network traffic minimized?** (Z-Wave/Zigbee sequential+delayed; HA helpers redundant-call-safe; light transitions batched)

8) **Wait Conditions & Timeouts**
   - Prefer `wait_template` with timeout and `continue_on_timeout: true` where feasible.
   - Guard exclusion lists for empty string `''` (e.g., `not in ['dead','unknown','unavailable','']`).

9) **Restart & Recovery**
   - Apply `references/patterns/restart_resilience.md`. Restart staggering uses trigger-level `for:` only — no action delays.

10) **Idempotency & Chatter**
    - Guard device calls; batch by group/area; rate-limit noisy inputs; minimal bounded retry.

11) **Overrides & Safety**
    - Manual/guest/safety modes always win. See `references/spec/safety.md`.

12) **Backward-Incompatible Changes**
    - Review last 12 months of HA breaking changes when applicable. Response must confirm `BC review: done` or `BC review: N/A`.

13) **Changelog & Versioning**
    - Add changelog entry per `spec/yaml_style.md`.

14) **Exceptions**
    - Deviations allowed only when documented inline in the artifact.

15) **Blueprint Validation (if used)**
    - Confirm compliance with the official Home Assistant blueprint schema and validate at least one instantiated artifact against all standard automation/script expectations before approval.

16) **Household UX / Annoyance Risk Review (HAF) completed**
    - Confirm the change does not introduce new human-impact failure modes. High-impact risks must be mitigated, documented as accepted tradeoffs, or the change must not ship.

17) **Self-Critique & Verdict**
    - Confirm no TODOs/placeholders, contradictions, scope expansion, unresolved ambiguity, or intent mismatch.
    - Document risks, alternatives, rollback, verdict, and letter grade. A- is minimum for production deployment.

      **Grading scale:**
      - **A** — fully Skill Pack compliant; passes all checklists; HAF
        clear; DTT validated; no caveats
      - **A-** — production-ready with one intentional, documented
        deviation that poses zero reliability, safety, or HAF risk;
        deployable as-is; a future session will know exactly why it
        is the way it is
      - **B** — deployable but has known unintentional or undocumented
        debt that is not production or outcome critical; deploy now,
        fix in a follow-up session
      - **C** — needs revision before shipping; reliability, safety,
        HAF, or Skill Pack compliance issues present that are fixable
        in session
      - **D** — significant architectural or safety issues; requires
        redesign, not just fixes; do not ship as-is
      - **F** — hard stop; secrets present, Class A/B safety violation,
        or fundamental design failure

### Optional Safety-Level Summary
When useful, summarize the highest safety level demonstrated:

- **L0 — Syntax Safe:** YAML/Jinja parses and schema shape is valid.
- **L1 — Type Safe:** HA state types, casts, fallbacks, and unavailable values are handled.
- **L2 — Behavior Safe:** DTT validation covers normal, unavailable, startup, and boundary states.
- **L3 — Steward Safe:** edits are surgical; entity IDs, aliases, comments, scope, and user intent are preserved.
- **L4 — Operator Safe:** live validation surfaces such as config check, traces, logs, or Developer Tools confirm behavior.

This summary does not replace the Skill Pack checklist, verdict, or grade.

---

## A1) Hard Stop — Do Not Approve If Any Are True

- [ ] DTT validation not completed before deployment
- [ ] Entity references not confirmed through appropriate validation: defined-entity checks where existence matters; `has_value()` where usable state matters
- [ ] Behavior not defined in observable HA state terms
- [ ] Restart and unavailable-entity behavior undefined
- [ ] Manual override interactions not accounted for
- [ ] Class A/B artifact without completed risk assessment
- [ ] HAF review not completed for artifacts affecting shared spaces or household schedules

---

## B) Verdicts
- **Production‑ready** · **Low‑risk w/ notes** · **Needs revision** · **Do not ship**

## C) Copy‑Paste Checklists
### Master
- [ ] KISS & scope confirmed; simpler alternative considered and ruled out; no complexity added beyond current requirements
- [ ] GUI-friendly automation/script YAML; `alias:` confirmed at schema-supported levels within automations/scripts; `description:` confirmed for automations/scripts; schema-supported naming/documentation confirmed for YAML-defined entities; `id:` per automation trigger; `alias:` confirmed absent from template sensors, input helpers, arbitrary variable mappings, and other YAML-defined entities.
- [ ] **House formatting & quoting confirmed** per `spec/yaml_style.md`: 2-space indent, lowercase `true`/`false`, block style, implicit nulls, defaults omitted; IDs/types/schema-enums unquoted, free text quoted, `'on'`/`'off'` state values quoted; `target:` used to address entities/devices/areas; `action:`/`condition:`/`sequence:` authored as a list of mappings
- [ ] `max_exceeded: silent` evaluated for automations that fire frequently or have significant risk of exceeding `max`
- [ ] **Comments policy**: automations/scripts confirmed comment-free — GUI strips comments silently; artifact-level context in `description:`; concise trace identity in nested `alias:`; non-obvious step-level rationale in nested `note:` where schema-supported. Template sensors confirmed with `# CHANGELOG:` and commented `#debug_*` attributes. AppDaemon comments for complex logic only.
- [ ] **Startup triggers** confirmed only where post-restart actions needed (state recovery, initialization); not present for passive automations
- [ ] Brains vs muscles confirmed; scripts for fan‑outs; concurrency verified sane
- [ ] **Construct selection confirmed:** choose used only for provably mutually exclusive branches (discriminated by trigger ID, entity state, or other HA-native discriminator); if/then/else used for prioritized execution where conditions may overlap; no elif in YAML
- [ ] **Execution gating confirmed:** automations gate on positive evidence — no action executes unless all required conditions are provably met; default to no action on uncertainty
- [ ] Restart gates confirmed on triggers (`timer.ha_startup_delay` w/ appropriate `for:`); no action delays present
- [ ] State trigger `to:`/`from:` and event trigger `event_type:` confirmed as **literal string matches only** — never Jinja; `for:` confirmed accepts Jinja where used; `platform: template` + `value_template:` used for evaluated expressions
- [ ] Jinja safety confirmed: safe defaults present (`| float(0)`, `| int(0)`)
- [ ] Python method use reviewed: no methods on HA-returned or JSON-derived objects; `.get()` / `.items()` allowed only on known literal dicts per `snippets/jinja_patterns.md`; `.total_seconds()` avoided except for guarded `.last_changed` / `.last_updated` staleness/age semantics
- [ ] No direct state-object access confirmed except `.last_updated` / `.last_changed` for staleness/age; guarded and used only for time semantics
- [ ] String normalization confirmed: `| lower | trim`
- [ ] Time math confirmed: `as_timestamp()` preferred for timestamp math; `.total_seconds()` used only for guarded `.last_changed` / `.last_updated` staleness/age semantics where explicitly allowed
- [ ] Deferred-intent datetime helpers confirmed canonical pattern (full datetime, sentinel `2999-01-01 00:00:00`, no null/blank, literal sentinel comparison)
  - Does NOT apply to non-deferred timestamps (e.g., chatter-control like "last applied", "last run")
- [ ] Type safety confirmed: raw/typed variables separated; comparisons use typed with tolerance
- [ ] Availability/existence confirmed: defined-entity validation used where existence matters; `has_value()` used where usable state matters; blank-string guard added for sources known to emit blanks (1)
- [ ] Event-driven confirmed preferred; polling ≥60s and justified where used
- [ ] Fast-fail condition ordering confirmed: cheap checks first; likely failures early; expensive Jinja last
- [ ] Chatter confirmed minimized; idempotent guards present; groups/areas used; rate‑limit applied as needed
- [ ] Observability confirmed: `reason` attr present where external or ambiguous inputs exist; production logs only for significant events
- [ ] DTT validation completed per `references/guides/dtt_first_validation.md`; entity pre-flight confirmed; traces referenced if orchestration validated
- [ ] Best-in-class review completed: intent clarity, implementation alignment, condition placement, network efficiency confirmed
- [ ] Wait strategies confirmed: `wait_template` used where applicable; exclusion lists guard empty string; `continue_on_timeout: true` present
- [ ] Backward-incompatible changes (12 months) reviewed and confirmed
- [ ] Exceptions documented inline using the artifact's supported documentation channel (`description:`/`alias:`/`note:` for automations/scripts where schema-supported; comments for YAML-defined entities)
- [ ] Risks/alternatives/rollback documented; letter grade assigned; verdict chosen
- [ ] Household UX / Annoyance Risk Review (HAF) completed (see sub-checklist)

### Automation Sub‑Checklist
- [ ] Minimal, precise triggers; unique `id` and `alias`
  - Note: trigger id uniqueness is required when triggers route to different evaluation paths. Multiple triggers may share an id when they intentionally collapse to a single identical evaluation sequence.
- [ ] Randomized vs fixed `for:` per criticality on HA restart
- [ ] Variables computed once at the narrowest appropriate scope; branches small & ordered cheap→expensive
- [ ] Deferred-intent datetime helpers (deadline-style `input_datetime`) declare owner and overdue policy in `description:` and implement explicit consume behavior (clear or re-arm)
- [ ] No device calls inside loops without guards
- [ ] No recursive loop: if trigger entity == action target entity, a `to:` constraint and re-entry condition are mandatory
- [ ] Logging absent unless documenting significant failure or diagnostic paths; description/alias carry normal intent
- [ ] Trigger coverage: each trigger ID or intentionally collapsed trigger group is handled by exactly one evaluation path; catch-all branches log `trigger.id` only for significant diagnostic validation
- [ ] Empty `metadata: {}`/`data: {}` blocks: acceptable if GUI-edited (editor auto-adds); remove only in pure-YAML workflows
- [ ] Automation/script CHANGELOG formatting correct:
  - newest entry first
  - two blank lines before **CHANGELOG:**
  - `**CHANGELOG:**` (bold + caps)
  - one blank line after header
  - one blank line between each entry
- [ ] `description:` prose paragraphs are single unbroken lines — no internal wrapping; line breaks only between paragraphs and within CHANGELOG block

### Script Sub‑Checklist
- [ ] `mode` and `max` reflect expected concurrency
- [ ] Centralizes device calls; idempotent guard; optional bounded retry
- [ ] No logging except significant failure paths
- [ ] No comments; description/alias carry context

### Template Sensor Sub‑Checklist
- [ ] Minimal trigger set + HA startup gate
- [ ] Clear directive state + `reason` attribute
- [ ] Safe reads; expected commented `#debug_*` attributes present
- [ ] Accumulating dict-merge sensors: byte-length pre-check before commit (`proposed | tojson | length > 16384`)

### Time Math & Timezone Safety Sub-Checklist
- [ ] Conversions explicit and consistent (`as_timestamp()` for math; `as_datetime()` only for parsing/display)
- [ ] Local vs UTC intentional (`now()` vs `utcnow()`); no mixing within a calculation
- [ ] Staleness/age math safe for `none`/invalid datetimes (guard + safe default like `999999`)
- [ ] Time-of-day logic uses numeric comparisons (hour/minutes), not `"HH:MM"` string comparisons
- [ ] Randomized delays/schedules correct and deterministic for intent (inclusive ranges; `range(45, 76)` for "45–75")
- [ ] Once-per-day schedules account for DST (anchored `at:` vs elapsed-time logic)
- [ ] Datetime comparisons avoid Python methods; use timestamp filters for day-level logic (e.g., no `.date()`)
- [ ] Datetime parsing uses safe fallback (`as_datetime(value, default)`)

### Datetime vs Timer Selection
- [ ] `input_datetime` used for persisted deferred intent (restart-safe deadlines, gating)
- [ ] `timer` used only for:
  - countdown UX
  - cancelable grace windows
  - protective cooldowns (e.g., compressor or API lockout)
- [ ] Timer usage includes explicit justification if not obvious

### Deterministic Execution
- [ ] No templated randomization in critical paths (or documented as accepted tradeoff)
- [ ] Post-restart gates use <10s fixed for: for critical paths (safety/security); 45–75s random for: for non-critical (prevents thundering herd)

### Household UX / Annoyance Risk Sub-Checklist *(aka Household Acceptance Factor – HAF)*
**This review is performed AFTER all technical, structural, and safety checks are complete.**

- [ ] False-trigger probability evaluated
- [ ] Oscillation / repeated toggle risk evaluated
- [ ] Notification fatigue risk evaluated
- [ ] Sleep disruption risk evaluated (late night / early morning behavior)
- [ ] Manual override conflict evaluated ("automation fighting humans")
- [ ] Restart recovery annoyance evaluated
- [ ] Sensor chatter / flapping risk evaluated
- [ ] Guest-mode behavior considered
- [ ] Silent failure modes identified
- [ ] Trust erosion vectors identified (conditions that would cause someone to disable the automation)
- [ ] High-impact annoyance risks mitigated, documented, or explicitly accepted as tradeoffs

-----
(1) If the source is known to emit blank strings, add and (states(...)|trim) != ''.
