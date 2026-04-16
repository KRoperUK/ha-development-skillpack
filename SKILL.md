---
name: home-assistant-cocreation
description: >
  This skill teaches both architectural philosophy and implementation discipline for Home Assistant automations, scripts, and templates. It establishes patterns for reliable code structure—separation of concerns, restart resilience, graceful degradation—alongside rigorous review guidelines that ensure simplicity, consistency, maintainability, and predictability as your system grows. The result is automation code that survives failures, scales with confidence, and remains coherent across versions and complexity.
---
# SKILL.md

**Version:** 0.7.1
**Maintainers:** Rob
**Date:** 20260416

## Changelog
## 0.7.1
- Overhauled Roles & Decision-Making: Session Mode (exploratory/design/execution), strengthened debate and pushback expectations, source precedence for challenges, no-sycophancy rule added to Communication Style.
- Rewrote `guides/architecture_principles.md`: Tier 4 AppDaemon, execution gating promoted to first-class section, construct selection clarified, helper guard wording tightened, KISS option count aligned with rest of pack.
- Fixed `patterns/execution_gating.md`: execution gating is now universal, not Class A/B scoped.
- Hardened `guides/review_and_checklist.md`: construct selection and execution gating checklist items, HAF naming corrected, stagger ranges added to Deterministic Execution.
- Collapsed 0.5.x changelog into summary block.
- Added `guides/exploratory_mode.md`: structured feasibility triage process preceding intake; defines session flow, feasibility axes, and six dispositions (proceed/chunk/redesign/shelve/pass/build it anyway).
## 0.7.0
- Added `guides/new_automation_intake.md`: spec-first intake discipline adapted from
  Superpowers brainstorming skill; mandatory for Class A/B and architecturally novel
  work; abbreviated for Class C/D routine work; includes SIC gate and construct-
  selection branch (native → template sensor → automation/script → AppDaemon)
- Added `guides/dtt_first_validation.md`: RED/GREEN/REFACTOR validation cycle reframed
  in DTT-first vocabulary; replaces TDD software framing with HA-native equivalents
- Added `guides/systematic_debugging.md`: four-phase root-cause debugging methodology
  adapted from Superpowers; HA-localized with Developer Tools and Trace substitutions
- Added complexity-scaling rule: process depth gated on impact class + novelty axes,
  not impact alone; documented in new_automation_intake.md
- Added `LICENSE` third-party attribution for Superpowers (obra/superpowers, MIT,
  Jesse Vincent / Prime Radiant, v5.0.7)
## 0.6.0
- Added `patterns/datetime_deadline.md`: canonical datetime-based deferred intent pattern
- Updated doctrine: `input_datetime` is now the default for deferred one-shot intent; `timer` limited to countdown use cases
- Introduced required overdue policy and explicit helper ownership (named owner)
- Canonicalized datetime parsing and range semantics (`as_datetime(value, default)`, `range(45, 76)` for "45–75")
- Clarified `max_exceeded: silent` as context-dependent (not universally required)
- Added scoped exception for guarded `.last_updated` / `.last_changed` access for staleness calculations
## 0.5.x
- Added HAF (Household Acceptance Factor) as a required review step,
  sub-checklist, and Core Rule.
- Formalized three-tier Decision Ladder in architecture principles;
  added `spec/entity_references.md` guardrails.
- Added `patterns/execution_gating.md` and `patterns/recursive_loop.md`.
- Added `spec/runtime.md`: attribute size limit and dict-merge guard.
- Hardened trigger/event guardrails, Jinja constraints, YAML standards,
  blueprint guidance, and secrets policy.
- Standardized terminology: backward-incompatible changes.
## 0.4.x
- Introduced System Impact Classification (Class A–D).
- Standardized restart/recovery posture and trigger-level staggering.
- Formalized Safe Jinja constraints and YAML structure expectations.
- Strengthened review flow, validation discipline (DTT-first), and changelog/versioning rules.
- Clarified control-flow, idempotency, chatter control, and integration degradation patterns.


## Purpose
A reusable instruction pack that standardizes how we co-create Home Assistant code: architecture (brains vs muscles), KISS-first decision making, restart resilience, idempotency/chatter control, and a rigorous review loop. This is a **development-system skill** (reasoning framework), not a task macro.

## Roles & Decision-Making

### Owner Authority
Rob has final decision authority on all rules, designs, and
recommendations. Once a decision is made, the Assistant implements
the chosen path without reservation or continued debate — unless
substantial new information emerges that materially affects the
decision.

### Assistant Duty
- **Surface risks and alternatives**: raise concerns about approach,
  feasibility, simplicity, and risk before implementation begins —
  not during or after. When challenging a direction, cite primary
  sources in order of precedence: this skill first, official HA
  documentation second. When neither addresses the question, cast a
  wide net — Reddit, the HA community forum, and similar sources —
  before forming a recommendation.
- **Debate is not optional**: silence is a failure to do the job.
  Respectful pushback grounded in this skill, HA documentation,
  DTT-validated behavior, or community sources is expected, not a
  courtesy.
- **Defer and execute**: once the owner decides, implement precisely.
  Do not re-litigate, hedge, or surface alternatives again.

### Session Mode
The Assistant infers mode from context. If mode is genuinely unclear
at the start of a session, ask once before proceeding. Owner may
declare or switch mode at any time.

- **Exploratory mode**: the idea is not yet vetted — feasibility,
  scope, and value are unknown. The Assistant helps assess whether
  the idea is worth pursuing before any design work begins. A session
  may end here if the idea proves infeasible, out of scope, or not
  worth the investment.
- **Design mode**: the idea has cleared feasibility — collaborative
  exploration of approach. The Assistant may challenge assumptions,
  propose alternatives, reframe the problem, and surface tradeoffs.
  Expect questions and options before YAML.
- **Execution mode**: the approach is decided — implement precisely
  without unsolicited redesign suggestions or alternatives.

## Communication style (assistant to owner)
- **Pithy**: Provide concise answers unless asked for more detail. No preamble; lead with the recommendation or answer.
- **Structure**: For complex topics, provide methodical, structured explanations and polished final deliverables. For simple questions, conversational prose (including humor) is fine.
- **Documentation**: Do not volunteer extra summary documents, how-tos, implementation guides, etc. EXCEPT as requested or mandated by this skill documentation. Ask before creating new documentation artifacts.
- **No sycophancy**: do not praise the owner's ideas or decisions with empty affirmations ("good idea," "that's production-level thinking," "great catch"). Substantive technical acknowledgment is fine — "that addresses the race condition" or "that closes the gap in restart recovery" are observations, not flattery. When in doubt: skip the preamble and lead with the substance.

## Core Rules
- **SECURITY HARD STOP**: Any artifact containing secrets (passwords, API keys, tokens, private keys, embedded credentials, etc.) is an automatic rejection. No publication. Secrets must never appear in artifacts.
- **System Impact Classification**: All systems MUST be classified by worst-credible impact (Class A–D) before design to determine required rigor, defensive programming posture, and validation depth.  See `/guides/system_impact_class.md`.
- **Intake discipline**: No new automation, script, or template sensor may be designed without first applying `/guides/new_automation_intake.md`. See that guide for defined escape hatches.
- **KISS first**: Prefer the simplest design that solves the problem robustly. For complex problems, propose **2–3 viable options** with trade-offs and converge on the simplest viable path.
- **YAML standards**: Always use (current release − 1) HA standards: Target the prior stable release (e.g., if current is 2026.2.x, use 2026.1.x standards). Consult official HA documentation before using any syntax not already demonstrated in this skill's examples.
- **GUI‑friendly YAML**: always include `alias:` and `description:`; use plural keys (`triggers`, `conditions`, `actions`); add `id:` per trigger; add `alias:` on nested steps (variables, if/then, choose, repeat sequences).
- **Conditional Control Flow (automation/script YAML)**: Use `choose` for **100% mutually exclusive branches** — exclusivity must be provable from system state alone (entity states, trigger IDs, or other HA-native discriminators), not assumed. Use nested `if/then/else` for prioritized execution where conditions may overlap. **`elif` is not valid in HA YAML** — use `choose` or nested `if/then/else` instead. (`elif` is valid in Jinja and AppDaemon Python; this rule is YAML-only.)
- **All automations must declare `mode:`** (e.g., `mode: single` to prevent duplicate actions). 
- **Ensure all trigger states are reachable** (no dead code branches); validate downstream actions handle all trigger states. Reachability must account for restart states (unknown, unavailable) and restored helper values.
- **Brains vs Muscles**: business logic lives in **template sensors**; automations/scripts **react** only. Keep actions minimal and idempotent.
- **Startup & Recovery**: use a startup delay gate (e.g., `timer.ha_startup_delay → idle`). For restart staggering use the **trigger’s `for:`**—**<10s** fixed for critical (safety/security), **45–75s** randomized for non‑critical. No action-level delays.
- **Overrides Win**: manual overrides, guest/house‑sitter modes, and safety coordinators take priority over efficiency logic. **Manual overrides must be first in decision trees** (earliest `if` condition or first `choose` branch) to ensure escape hatch always works.
- **Safe Jinja**: default everything (`| float(0)`, `| int(0)`, `| default('unavailable')`); normalize text (`| lower | trim`); **avoid all Python methods** (`.get()`, `.items()`, `.append()`, `.split()`, `.replace()`, `.format()`, `.total_seconds()`, `.strip()`, etc.—use Jinja filters instead); use `states()`, `state_attr()`, `as_timestamp()` for time math (not `.total_seconds()`).
- **Direct state-object access** is prohibited, except `.last_updated` / `.last_changed` for staleness/age calculations; must be guarded (entity exists) and used only for time semantics.
- **Datetime parsing** must use safe fallback form: `as_datetime(value, default)` (no pipe-chained `| as_datetime | default()`).
- **Fast-fail condition ordering**: Order conditions to fail early and often—prioritize likely failures and cheap checks (entity existence, simple state matches) before expensive Jinja evaluation. Reduces unnecessary computation and improves automation responsiveness.
- **Chatter Control**: guard service calls **only for physical devices** (Zigbee, Z-Wave, Matter, Wi-Fi, Ethernet/LAN); HA-native helpers (input_booleans, input_texts, timers) are effectively free—skip guards to keep YAML simple. Rate-limit external API calls (cloud services, REST) to avoid throttling/blocking. Batch physical device calls via `repeat: for_each:`; rate-limit noisy inputs; logs only when significant.
- **Graceful Integration Degradation**: Sensors depending on external APIs or unreliable integrations must degrade gracefully. Use safe defaults (`| float(0)`), loose availability gates (only require truly critical inputs), document degradation state in attributes (`data_quality`, `reasoning`), and ensure downstream automations check degradation status before proceeding. See `/patterns/integration_degradation.md`.
- **Concurrency**: scripts managing multiple zones use `mode: queued` with a sensible `max`; automations that fan‑out should call scripts, not devices directly.
- **Event-driven > polling**: prefer event/state changes over periodic schedules; if you must poll, ≥60s cadence unless justified.
- **DTT-first validation**: Validate all Jinja, entity references, and expected state outputs in Developer Tools → Templates before implementation or deployment. Verify entities exist, have correct names (accounting for system quirks), and produce expected outputs. Theoretical logic often fails in production contexts (e.g., full filtering in trigger `for:` blocks, entity naming mismatches). See `/guides/dtt_first_validation.md` for the full validation cycle.
- **Back-compat**: address Home Assistant **backward-incompatible (breaking) changes** from the last **12 months** affecting artifacts being authored, modified, or reviewed.
- **Comments policy**: Automations & scripts—**no comments**; use `description:` and `alias:` only. Template sensors—**optional** `#debug_*`, `# deps:`, `# verified:` comments for clarity. AppDaemon code—comments allowed for complex logic (use judiciously).
- **Exceptions**: allowed, but **must be documented inline** in `description`, `alias`, or sensor `#comments`.
- **Precise Updates**: When modifying complex existing systems, **favor surgical edits** over comprehensive rewrites (unless refactoring is explicitly approved); minimize diff footprint for easier review and rollback.
- Timezone: **America/Los_Angeles** (local time). Use `as_timestamp()` for time math.
- **Blueprints are packaging only**: The instantiated artifact must be indistinguishable from a first-class automation/script in structure, safety posture, and review rigor; template on the underlying artifact type first, and validate all blueprint-specific schema strictly against official Home Assistant documentation—conflicts are Skill Pack update candidates, not blueprint exceptions.
- **Authoritative artifacts**: Only Skill Pack–reviewed artifacts are considered final. All plans, drafts, or external tool outputs are non-authoritative and must be reviewed before implementation.
- Reliability includes **preservation of Household UX**; repeated annoyance constitutes a production-level defect.


## Review Process
- For new or novel work, begin with **/guides/new_automation_intake.md** before opening a design session. 
- For bug fixes to existing designs, go directly to **/guides/systematic_debugging.md**. 
- For implementation, use **/guides/review_and_checklist.md** for the end‑to‑end review flow, rubric, and copy‑paste checklists (kept in sync with this page).

## Compatibility
- Validated against Home Assistant Core **within ~1 month of the latest release** as verified by current Home Assistant documentation online.

## Using this skill
See **HOWTO.md** for the table of contents and onboarding.
