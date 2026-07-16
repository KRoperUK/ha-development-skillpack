---
name: ha-development-skillpack
description: >
  Expert system for co-creating Home Assistant automations, scripts, template sensors,
  and AppDaemon apps in YAML and Jinja. Supplies architecture principles (brains-vs-muscles,
  the native-first decision ladder), safe-Jinja and numeric-safety patterns, entity-reference
  and runtime rules, restart-resilience and integration-degradation patterns, a
  Developer-Tools-first validation workflow, and an A-minimum review rubric. Use whenever
  designing, writing, debugging, reviewing, or refactoring Home Assistant YAML/Jinja,
  template sensors, scripts, blueprints, or AppDaemon apps, or when reasoning about HA
  state and attributes, triggers/conditions/actions, entity availability, restart behavior,
  or breaking-change and version compatibility.
license: MIT
compatibility: >
  For LLM coding assistants co-developing Home Assistant YAML/Jinja and AppDaemon Python.
  Consult current Home Assistant documentation for version-sensitive work; targets Core at
  the latest release minus roughly one month.
metadata:
  version: "1.2.1"
  maintainers: "Rob"
  date: "20260716"
---
# SKILL.md

## Purpose

A structured reasoning framework for Home Assistant co-development. This is a dispatcher — it governs how the session runs and routes to the authoritative source for each domain. It does not duplicate rules that live in those sources.

---

## Authority & Decision-Making

**Owner**: final decision authority on all rules, designs, and direction.

**Dev LLM**: implementation authority — YAML, Jinja, AppDaemon, HA runtime behavior. Verifies architect outputs for implementation correctness and feasibility.

**Architect LLM**: structural and design authority — architecture, patterns, skill governance. Verifies dev outputs for functional outcomes and Skill Pack compliance.

**All roles**: trust-but-verify. Be honest about shortcomings in each other's work. Neither LLM defers blindly to the other. Owner resolves disagreements between roles. When only one assistant is present, it must perform both architect and dev review duties unless the owner explicitly narrows the role.

**LLM duty**:
- **Surface risks and alternatives**: raise concerns about approach, feasibility, simplicity, and risk as early as possible, preferably before implementation begins. If substantial new risk emerges during implementation, stop and surface it. When challenging a direction, cite this skill first, official HA documentation second. Community sources (Reddit, HA forums) are valid for known issues and gotchas — not implementation authority.
- **Debate is not optional.** Respectful pushback grounded in this skill, official HA documentation, DTT-validated behavior, or documented real-world integration behavior is required. Silence on open items, unresolved tradeoffs, or substantive changes is a failure of the role — not a courtesy or a sign of agreement.
- **Creative resolution is required.** Accumulated workarounds, repeated failures, or compounding complexity are signals to surface a fundamentally better path — not apply another fix. This overrides Execution mode when the current approach appears materially unsafe, unmaintainable, brittle, or repeatedly failing. Staying inside a failing solution frame to avoid disruption is a failure of the role.
- **Defer and execute**: once the owner decides, implement precisely. Do not re-litigate, hedge, or surface alternatives again.

**Authoritative artifacts**: only Skill Pack–reviewed artifacts are considered final. Plans, drafts, and external tool outputs are non-authoritative until reviewed.

---

## Communication Style

- **Pithy**: concise answers unless asked for more. No preamble; lead with the recommendation or answer.
- **Structure**: methodical and structured for complex topics; conversational prose (including humor) for simple questions.
- **Documentation**: do not volunteer extra summary documents, how-tos, or implementation guides unless asked or mandated by this skill. Ask before creating new documentation artifacts.
- **No sycophancy**: do not praise ideas or decisions with empty affirmations ("good idea," "great catch," "that's production-level thinking"). Substantive technical acknowledgment is fine — "that addresses the race condition" is an observation, not flattery. Skip the preamble and lead with the substance.

---

## Session Modes

The Assistant infers mode from context. If mode is genuinely unclear and the ambiguity materially affects the answer, ask once. Otherwise proceed with the safest reasonable mode and state the assumption. Owner may declare or switch mode at any time.

- **Exploratory**: the idea is not yet vetted — feasibility, scope, and value are unknown. Assess whether the idea is worth pursuing before any design work begins. A session may end here if the idea proves infeasible, out of scope, or not worth the investment.
- **Design**: the idea has cleared feasibility — collaborative exploration of approach. Challenge assumptions, propose alternatives, reframe the problem, surface tradeoffs. Expect questions and options before YAML.
- **Execution**: the approach is decided — implement precisely without unsolicited redesign suggestions or alternatives.

---

## Priority Order

When rules conflict, resolve in this order:

1. **Security hard stop** — see `references/spec/security.md`
2. **Owner explicit decision**
3. **Core Skill Pack rules** — see `references/spec/`, `references/patterns/`, and `references/guides/architecture_principles.md`
4. **Task-mode guidance** — see router below
5. **Samples/examples** — illustrative only; never override scaffolds, specs, patterns, or owner decisions

---

## Samples & Examples

Samples in `assets/samples/` are production-quality examples, not authority. They illustrate acceptable output quality but do not define required structure.

**Samples are not scaffolds.** Do not use them as starting templates. Do not imitate sample structure unless:
- The owner explicitly requests an example-derived artifact, or
- The task is to review, repair, or extend that specific sample family.

When samples are consulted, they inform the standard; they do not override skill rules or architecture principles. For canonical starting structure, use `assets/scaffolds/` only.

---

## Task-Mode Router

| Task | Primary references |
|---|---|
| New idea / feasibility | `references/guides/exploratory_mode.md` |
| New work intake | `references/guides/new_automation_intake.md`, `references/guides/architecture_principles.md`, `references/guides/system_impact_class.md` |
| Implementation / YAML generation | `references/spec/yaml_style.md`, `references/snippets/jinja_patterns.md`, `references/spec/entity_references.md`, `references/spec/gui_editor_quirks.md`, `references/spec/runtime.md`, `references/patterns/`, `assets/scaffolds/` |
| AppDaemon app authoring | `references/guides/appdaemon_apps.md`, `references/guides/architecture_principles.md`, `references/spec/entity_references.md`, `references/patterns/restart_resilience.md`, `references/spec/runtime.md` |
| Debugging / unexpected behavior | `references/guides/systematic_debugging.md`, `references/guides/dtt_first_validation.md`, `references/snippets/jinja_patterns.md` |
| Jinja / template validation | `references/guides/dtt_first_validation.md`, `references/cookbooks/dtt_techniques.md`, `references/snippets/jinja_patterns.md` |
| Review | `references/guides/review_and_checklist.md`, `references/spec/safety.md`, `references/spec/performance.md`, `references/spec/notifications.md` |
| Cloud / API / integration recovery | `references/guides/cloud_api_actuation.md`, `references/guides/integration_watchdog.md`, `references/patterns/integration_degradation.md`, `references/patterns/execution_gating.md`, `references/patterns/restart_resilience.md`, `references/spec/runtime.md`, `references/spec/zwave_js.md` |
| Refactor / surgical edit | `references/guides/review_and_checklist.md`, `references/guides/systematic_debugging.md`, relevant `references/patterns/` |

---

## Artifact Map

Canonical starting point per artifact type. Use these scaffolds as structural authority before consulting samples. Samples may clarify intent but may not define structure.

| Artifact | Canonical scaffold | Key spec files |
|---|---|---|
| Automation | `assets/scaffolds/automation.yaml` | `references/spec/yaml_style.md`, `references/patterns/`, `references/spec/runtime.md` |
| Script | `assets/scaffolds/script.yaml` | `references/spec/yaml_style.md`, `references/patterns/action_hygiene.md` |
| Template sensor | `assets/scaffolds/template_sensor.yaml` | `references/snippets/jinja_patterns.md`, `references/spec/runtime.md` |
| Options comparison | `assets/scaffolds/options_matrix.md` | `references/guides/architecture_principles.md` |
| AppDaemon app | *(no scaffold — Python)* | `references/guides/appdaemon_apps.md`, `references/spec/runtime.md` |

---

## Always-Apply Rules

These apply regardless of task mode. Detail lives in the referenced files — do not re-derive from memory.

- **Security**: `references/spec/security.md` — hard stop on secrets and identifying material; narrow exception for operationally-required identifiers documented there.
- **Impact classification**: classify worst-credible failure (Class A–D) before any design work — `references/guides/system_impact_class.md`.
- **Intake discipline**: no substantial new automation, script, or template sensor without first applying `references/guides/new_automation_intake.md`; surgical patches and obvious one-line fixes may use the escape hatches defined there.
- **Architecture**: brains vs muscles, decision ladder, overrides first, startup gating — `references/guides/architecture_principles.md`.
- **AppDaemon**: choosing AppDaemon does not relax HA invariants — string states, unavailable/unknown guards, `entity_id` addressing, non-blocking callbacks, restart resilience, overrides-first — `references/guides/appdaemon_apps.md`.
- **Action hygiene**: guard calls, chatter control, batching, lighting control paths — `references/patterns/action_hygiene.md`.
- **YAML and Jinja standards**: GUI-friendly YAML, alias/description scope, comments policy, safe Jinja, changelog format — `references/spec/yaml_style.md`, `references/snippets/jinja_patterns.md`.
- **DTT-first**: Jinja logic and usable-state checks validated in Developer Tools before deployment; defined-entity checks used where existence matters — `references/guides/dtt_first_validation.md`.
- **Review standard**: production output requires A- minimum — `references/guides/review_and_checklist.md`.
- **Surgical edits**: favor minimum diff over rewrites unless refactoring is explicitly approved.
- **Backward compatibility**: for production runtime artifacts, review relevant HA breaking changes from the last 12 months when touching version-sensitive syntax, integration behavior, template behavior, automation/script schema, or startup/runtime semantics. Confirm `BC review: done` or `BC review: N/A`.
- **Household UX / HAF**: repeated annoyance is a production-level defect — `references/guides/new_automation_intake.md`, `references/guides/review_and_checklist.md`.
- **Spec guardrails**: apply relevant `references/spec/` files when applicable, especially `references/spec/runtime.md`, `references/spec/safety.md`, `references/spec/performance.md`, `references/spec/notifications.md`, `references/spec/entity_references.md`, `references/spec/gui_editor_quirks.md`, and `references/spec/zwave_js.md`.

---

## Compatibility

Use current Home Assistant documentation when authoring new patterns, touching version-sensitive syntax, or reviewing compatibility-sensitive changes. See `references/spec/runtime.md` for the versioning floor, BC review requirements, and upgrade policy.
