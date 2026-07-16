# Architecture Principles

## Operating Rules

- **Impact classification**: Classify worst-credible failure impact (Class A–D) before any design work begins.
- **KISS**: Generate 3–5 options internally, present 2–3 viable ones, and choose the simplest robust path.
- **Decision ladder**: Native construct → helper → template sensor → AppDaemon. Stop at the first tier that solves the problem.
- **Brains vs muscles**: Template sensors compute directives, intent, and reason; automations/scripts react deterministically and perform actuation.
- **Overrides first**: Manual overrides, safety gates, and house/guest modes are evaluated before normal logic — no exceptions.
- **Fast-fail ordering**: Override/safety gates first, cheap state/existence checks second, expensive Jinja last.
- **Construct selection**: Use `choose` only for provably mutually exclusive branches. Use `if/then/else` for overlapping or prioritized conditions. `elif` is not valid in HA YAML.
- **Startup gating**: Gate non-trivial restart-sensitive work on `timer.ha_startup_delay → idle`; use trigger-level `for:` for startup staggering.

## 0) System Impact Classification
See: `references/guides/system_impact_class.md`

- Before any architectural decisions are made, classify the system by **worst-credible impact if it fails** (Class A–D).
- Classification determines required rigor, defensive programming posture, and acceptable tradeoffs for all subsequent design decisions.
- If classification is ambiguous, assume the more severe class and confirm before proceeding.

## 1) Simplicity (KISS)
- For complex problems, generate **3–5 candidate approaches** internally, filter for feasibility, and present the **2–3 viable options** — choose the simplest robust path.
- Eliminate unnecessary triggers, helpers, conditions, and branches; resist premature abstraction.

## 2) Separation of Concerns & Authority Scoping (Brains vs Muscles)
- Separate *decision-making* from *actuation* to limit control radius and manage risk.
- **Template sensors ("brains")** compute directives, intent, and `reason`; treated as non-authoritative output.
- **Automations and scripts ("muscles")** react deterministically and idempotently; all physical device control is centralized and auditable.
- Scope authority deliberately based on System Impact Class: prefer **read, display, notify, or suggest** behaviors over direct actuation; escalate to **direct control** only when those approaches cannot meet safety, reliability, or correctness requirements.

### Decision Ladder
Apply in order. Stop at the first tier that solves the problem. Do not skip tiers.

- **Tier 1 — Native construct**: Can a built-in trigger, condition, or action cover this without Jinja? Native constructs validate at load time and fail loudly; templates fail silently at runtime. Common substitutions: `{{ states('x') | float > 25 }}` → `numeric_state` condition with `above: 25`; `{{ is_state('x', 'on') and is_state('y', 'on') }}` → `condition: and` with state conditions; `{{ now().hour >= 9 }}` → `condition: time` with `after: "09:00:00"`.

- **Tier 2 — Built-in helper**: Can a helper replace a template sensor? Helpers are declarative, handle unavailable states gracefully, and require no Jinja. Common substitutions: sum/average → `min_max`; binary any-on/all-on → `group`; rate of change → `derivative`; cross-threshold → `threshold` (includes built-in hysteresis); consumption tracking → `utility_meter`.

- **Tier 3 — Template sensor**: Only if tiers 1 and 2 cannot solve it. Computes directives, intent, and `reason`; treated as non-authoritative output.

Tier 4 — AppDaemon: Preferred when YAML is insufficient — long-lived state, multi-step workflows, complex orchestration, or external system coordination. Consider AppDaemon also when YAML solutions become difficult to reason about, test, or maintain — not only when they are impossible. Skill Pack constraints still apply for all HA behavior (state handling, restart resilience, overrides); Superpowers-style decomposition and testing may be used for implementation discipline. See `references/guides/appdaemon_apps.md` for AppDaemon-specific authoring rules (non-blocking callbacks, HA API usage, the unavailable/unknown guard).

## 3) Execution Gating & Control Flow
- **Execution gating**: automations gate on positive evidence — no action executes unless all required conditions are provably met; default to no action on uncertainty. See `references/patterns/execution_gating.md`.
- **Overrides first**: manual overrides, guest/house-sitter modes, and safety coordinators take priority over all other logic. Override checks must be the first condition evaluated — earliest `if` condition or first `choose` branch — so the escape hatch always works.
- **Construct selection**: use `choose` only for provably mutually exclusive branches discriminated by trigger ID, entity state, or other HA-native discriminator. Use `if/then/else` for prioritized execution where conditions may overlap. `elif` is not valid in HA YAML.

## 4) Intent-First Paths
- **Lighting ON-path**: speed priority; minimal gates; central script applies targets fast.
- **ADJUST-path**: overhead optimized; idempotent guards; batch & rate-limit.
- **OFF-path**: validation priority; respect presence/overrides; graceful transitions.

## 5) Restart Resilience
- Gate on `timer.ha_startup_delay → idle`. Use trigger-level `for:`:
  - Critical (safety/security): **<10s fixed**
  - Non-critical: **45–75s randomized**
- No action-level delays for staggering; use the trigger's `for:` only.
- Prefer persisted deferred-intent deadlines using `input_datetime` over long `for:` for restart-safe behavior (see: `references/patterns/datetime_deadline.md`).
- Use `timer` only when modeling countdown semantics (UX, cancelable grace windows, protective cooldowns).

## 6) Determinism & Cost
- Cheap checks first; heavy Jinja last; precompute commonly used values.
- Avoid repeated `states()` calls; cache into variables.
- No templated randomization in critical paths unless documented as an accepted tradeoff.
- **Fast-fail condition ordering**: order conditions to short-circuit early on common rejection cases — prioritize likely failures and cheap checks (entity existence, simple state matches, override/safety gates) before expensive Jinja evaluation. Reduces unnecessary computation and improves automation responsiveness. Applies to both the top-level `conditions:` block and `if/then` branches within actions.

## 7) Idempotency & Chatter
- Guard physical device calls versus current state; avoid unnecessary chatter guards on HA-native helper writes where the write is cheap and deterministic.
- Use groups/areas; `repeat: for_each:`.
- Minimal bounded retry; avoid chatty loops.

## 8) Observability
- Template sensors expose `state` and human-readable `reason` (only when complex logic exists); keep `#debug_*` attrs commented for quick enabling.
- Production logging is rare and meaningful; otherwise silent.

## 9) Backward Compatibility
- Refactors or enhancements MUST review Home Assistant release notes and proactively address **backward-incompatible changes** and **deprecations** from the last **12 months** affecting entities, services, attributes, templates, schemas, or any other artifact modified by the change.

## 10) Ownership & Collaboration
- Healthy debate welcome; **owner's call is final** and the skill defers.
