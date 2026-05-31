# Review & Checklist — How‑To + Rubric (Single Source of Truth)

For new or novel work, complete `/guides/new_automation_intake.md`
before opening a review. For bug fixes, use
`/guides/systematic_debugging.md`. Review begins after intake is
complete and DTT validation has passed.

Use this for every change. Goal: **simplest robust** solution that is restart‑safe, idempotent, and observable.

## Blocking Gate — Secret & Identifying Material
- Compliant with `spec/security.md` (no secret or identifying material present).

If detected:
- Mark as ❌
- Stop review
- Do not continue architectural analysis

## A) Review Flow (Detailed)
0) **System Impact Classification**: Before review, classify the system by **worst-credible impact if it fails** (Class A–D) using `/guides/system_impact_class.md`.
   - Record the selected class.
   - Briefly note the worst-credible failure mode.
   - Document any **Context Elevation** reasoning if applicable.
   - The assigned class determines the required rigor for all subsequent review steps.
1) **KISS gate**
   - Prefer Home Assistant native functionality, helpers, integrations, triggers, and conditions over custom YAML/Jinja when they express the behavior clearly, deterministically, and with less long-term maintenance risk.
   - Propose a simpler alternative when one is materially simpler; document why rejected if not chosen.
   - Remove any triggers, conditions, actions, or logic not required by the stated intent — do not add complexity in anticipation of requirements that do not exist yet.
   - For complex problems, generate 3–5 candidate approaches internally, filter for feasibility, and present the **2–3 viable options** — choose the simplest viable option.
2) **Syntax & Structure**
   - Use **current release -1** as minimum YAML/Jinja standards (per Home Assistant docs); reject deprecated or "also works" syntax.
   - GUI‑friendly YAML: `alias`, `description`; plural keys; `id:` per trigger; `alias:` at all levels (triggers/conditions/actions/variables/repeat branches).
   - **Comments only in template sensors** (`#debug_*`, `# deps:`, `# verified:`). Automations and scripts use `alias:` and `description:` only.
3) **DTT Probes (Developer Tools → Template) — Mandatory Pre-Deployment**
   - See `/guides/dtt_first_validation.md` for the full validation
     cycle including entity pre-flight, consolidated expression
     requirements, and mock variable patterns.
   - Validate all Jinja logic and entity references in Developer
     Tools → Templates before deployment. Confirm entity references
     via `has_value()` pre-flight (usable-state check) and
     defined-entity validation where required.
   - For unavailable or degraded states, use mock variables
     (`{% set %}` substitutions) to validate logic branches — do
     not rely solely on current live state.
   - If logic passes DTT but fails after deployment, the discrepancy
     is a diagnostic signal — go to `/guides/systematic_debugging.md`
     rather than iterating blindly in DTT.
   - See `cookbooks/dtt_techniques.md` for patterns.
4) **Traces vs DTT**
   - Use **DTT** for template logic and unit‑style checks.
   - Use **Automation Traces** only when orchestration/timing must be verified. No repo‑wide `store_traces: true` mandate.
5) **Live Test**
   - Exercise a happy‑path trigger. Observe Logbook only for significant events; otherwise remain silent.
6) **Best-in-Class Review (Intent Alignment)**
   - For all code, ask:
     1. **Primary intent?** (Lights ON = speed; Lights OFF = validation; Recovery = network efficiency; Notification = reliability)
     2. **Implementation matches intent?** (Minimize checks for ON; rich validation for OFF; sequential+guarded for recovery)
     3. **Conditions in right place?** (Cheap checks first in conditions block; expensive operations only on needed paths)
     4. **Network traffic minimized?** (Z-Wave/Zigbee sequential+delayed; HA helpers redundant-call-safe; light transitions batched)
7) **Wait Conditions & Timeouts**
   - Prefer `wait_template` with timeout over fixed delays when feasible.
   - Include `continue_on_timeout: true` for graceful fallthrough.
   - Guard exclusion lists: always check for empty string `''` in negation filters (e.g., `not in ['dead','unknown','unavailable','']`).
8) **Restart & Recovery**
   - Critical paths: **fixed `<10s` `for:`** on `timer.ha_startup_delay` trigger.
   - Non‑critical: **randomized `for:` (e.g., 45–75s)** on the trigger.
   - No artificial `delay` actions for staggering; use the trigger's `for:` instead.
9) **Idempotency & Chatter**
   - Guard device calls; batch by group/area; rate‑limit noisy inputs; minimal bounded retry.
10) **Overrides & Safety**
    - Manual/guest/safety modes always win. See `/spec/safety.md` for patterns.
11) **Backward-Incompatible Changes (12 months)**
    - Any refactor or enhancement MUST review the last 12 months of Home Assistant release notes and proactively adapt for **backward-incompatible (breaking) changes** affecting schemas, services, attributes, or behavior.
    - The reviewer must confirm in their response: **"BC review: done"** or **"BC review: N/A"**.
12) **Changelog & Versioning**
    - Format: `YYYYMMDD-HHMM: Single sentence summary.`
    - Timezone: **America/Los_Angeles** (local time).
  a) **Automations & Scripts**
    - Add **CHANGELOG** block in YAML `description:` (not YAML `#` comments).
    - `description:` is Markdown-rendered; when using list items (`- ...`), a blank line MUST separate `CHANGELOG:` from the first item.
  b) **YAML-defined entities (e.g., template sensors)**
    - Use YAML `# CHANGELOG:` comments near the top of the definition.
13) **Exceptions**
    - Deviations allowed **only if documented inline** (in `description`, `alias`, or sensor comments).
14) **Self‑Critique & Verdict**
    - Pre-output sanity scan: no unresolved TODOs/placeholders, no internal contradictions, no unrequested scope expansion, no unresolved ambiguity, and no mismatch between stated intent and delivered artifact.
    - Risks, alternatives, rollback. Verdict categories below.
    - Assign a letter grade using the scale below. Anything below
      A- must have fixes proposed or applied before the session ends,
      unless the artifact is explicitly throwaway or testing scope.
      If a fix requires a redesign out of scope for the current
      session, document the grade and do not deploy.

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

    ## Optional Safety-Level Summary
    When useful, summarize the highest safety level demonstrated:

    - **L0 — Syntax Safe:** YAML/Jinja parses and schema shape is valid.
    - **L1 — Type Safe:** HA state types, casts, fallbacks, and unavailable values are handled.
    - **L2 — Behavior Safe:** DTT validation covers normal, unavailable, startup, and boundary states.
    - **L3 — Steward Safe:** edits are surgical; entity IDs, aliases, comments, scope, and user intent are preserved.
    - **L4 — Operator Safe:** live validation surfaces such as config check, traces, logs, or Developer Tools confirm behavior.

    This summary does not replace the Skill Pack checklist, verdict, or grade.        
        
15) **Blueprint Validation (if used)**
    - Confirm compliance with the official Home Assistant blueprint schema and validate at least one instantiated artifact against all standard automation/script expectations before approval.
16) **Household UX / Annoyance Risk Review (HAF) completed**
    - Confirm the change does not introduce new human-impact failure modes. High-impact risks must be mitigated, documented as accepted tradeoffs, or the change must not ship.

---

## A1) Hard Stop — Do Not Approve If Any Are True

- [ ] DTT validation not completed before deployment
- [ ] Entity references not confirmed via `has_value()` pre-flight
      and defined-entity validation where required
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
- [ ] GUI‑friendly automation/script YAML; `alias:` confirmed at all levels; `description:` at automation/script/sensor level; `id:` per trigger
- [ ] `max_exceeded: silent` evaluated for automations that fire frequently or have significant risk of exceeding `max`
- [ ] **Comments policy**: Automations/scripts confirmed comment-free YAML; intent in `alias:` and `description:` only. Template sensors confirmed with inline comments and commented `#debug_*` attributes. AppDaemon comments for complex logic only
- [ ] **Startup triggers** confirmed only where post-restart actions needed (state recovery, initialization); not present for passive automations
- [ ] Brains vs muscles confirmed; scripts for fan‑outs; concurrency verified sane
- [ ] **Construct selection confirmed:** choose used only for provably mutually exclusive branches (discriminated by trigger ID, entity state, or other HA-native discriminator); if/then/else used for prioritized execution where conditions may overlap; no elif in YAML
- [ ] **Execution gating confirmed:** automations gate on positive evidence — no action executes unless all required conditions are provably met; default to no action on uncertainty
- [ ] Restart gates confirmed on triggers (`timer.ha_startup_delay` w/ appropriate `for:`); no action delays present
- [ ] State trigger `to:`/`from:` and event trigger `event_type:` confirmed as **literal string matches only** — never Jinja; `for:` confirmed accepts Jinja where used; `platform: template` + `value_template:` used for evaluated expressions
- [ ] Jinja safety confirmed: safe defaults present (`| float(0)`, `| int(0)`)
- [ ] No Python methods confirmed (`.get()`, `.items()`, `.total_seconds()`, etc.)
- [ ] No direct state-object access confirmed except `.last_updated` / `.last_changed` for staleness/age; guarded and used only for time semantics
- [ ] String normalization confirmed: `| lower | trim`
- [ ] Time math confirmed: `as_timestamp()` not `.total_seconds()`
- [ ] Deferred-intent datetime helpers confirmed canonical pattern (full datetime, sentinel `2999-01-01 00:00:00`, no null/blank, literal sentinel comparison)
  - Does NOT apply to non-deferred timestamps (e.g., chatter-control like "last applied", "last run")
- [ ] Type safety confirmed: raw/typed variables separated; comparisons use typed with tolerance
- [ ] Availability confirmed: `has_value()` used for entity checks (1)
- [ ] Event-driven confirmed preferred; polling ≥60s and justified where used
- [ ] Fast-fail condition ordering confirmed: cheap checks first; likely failures early; expensive Jinja last
- [ ] Chatter confirmed minimized; idempotent guards present; groups/areas used; rate‑limit applied as needed
- [ ] Observability confirmed: `reason` attr present where external or ambiguous inputs exist; production logs only for significant events
- [ ] DTT validation completed per `/guides/dtt_first_validation.md`; entity pre-flight confirmed; traces referenced if orchestration validated
- [ ] Best-in-class review completed: intent clarity, implementation alignment, condition placement, network efficiency confirmed
- [ ] Wait strategies confirmed: `wait_template` used where applicable; exclusion lists guard empty string; `continue_on_timeout: true` present
- [ ] Backward-incompatible changes (12 months) reviewed and confirmed
- [ ] Exceptions documented inline (description/alias/comments)
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
- [ ] No logging; description/alias carry intent only
- [ ] Trigger coverage: each trigger ID referenced exactly once; else: branch logs trigger.id for catch-all validation
- [ ] Empty `metadata: {}`/`data: {}` blocks: acceptable if GUI-edited (editor auto-adds); remove only in pure-YAML workflows
- [ ] Automation/script CHANGELOG formatting correct:
  - two blank lines before **CHANGELOG:**
  - `**CHANGELOG:**` (bold + caps)
  - one blank line after header
  - one blank line between each entry

### Script Sub‑Checklist
- [ ] `mode` and `max` reflect expected concurrency
- [ ] Centralizes device calls; idempotent guard; optional bounded retry
- [ ] No logging except significant failure paths
- [ ] No comments; description/alias carry context

### Template Sensor Sub‑Checklist
- [ ] Minimal trigger set + HA startup gate
- [ ] Clear directive state + `reason` attribute
- [ ] Safe reads; expected commented `#debug_…` attributes present
- [ ] Optional `# deps:` and `# verified:` documentation for clarity
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
