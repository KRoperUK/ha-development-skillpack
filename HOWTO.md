# HOWTO (Onboarding & Table of Contents)

Use this as your entry point. The skill is a reasoning framework and development discipline for designing, validating, debugging, and reviewing robust HA YAML, Jinja, and AppDaemon code.

## Quick Start — Which Guide to Use

New automation, script, or template sensor? → `guides/new_automation_intake.md`
Bug or unexpected behavior? → `guides/systematic_debugging.md`
Writing or validating Jinja logic? → `guides/dtt_first_validation.md` + `cookbooks/dtt_techniques.md`
Reviewing before deployment? → `guides/review_and_checklist.md`
Quick debugging tools reference? → `cookbooks/debugging.md`

If unsure: intake for new work, debugging for existing behavior.

## Layout & Naming (kept here exclusively)

- `guides/` — intake, review, validation, debugging, and principles
- `patterns/` — behavioral design patterns (restart resilience, datetime deadlines, idempotency, chatter control, lighting paths, execution gating)
- `cookbooks/` — DTT techniques & debugging quick-reference (see `guides/` for full methodology)
- `snippets/` — isolated Jinja fragments and do/don't examples; not standalone deployable code
- `templates/` — automation/script/template_sensor scaffolds + option matrix
- `samples/` — complete, coherent YAML artifacts with alias: everywhere and YAML changelogs
- `tools/` — helper shell scripts (`entity_snapshot.sh`, `lint_templates.sh`)
- `spec/` — focused guardrails (runtime, triggers, safety, security, formatting, notifications, performance, entity references)

**Entity naming:** `area_device_purpose` (e.g., `bedroom_ceiling_light`).
**Timestamped files (optional):** `<category>–YYYYMMDD–HHMM.yaml`.

## Workflow

1) **New work**: apply `/guides/new_automation_intake.md` before
   any design or YAML. Escape hatches defined in that guide.
2) **Bug fixes**: go directly to `/guides/systematic_debugging.md`.
3) Draft using `/templates/*.yaml` (automation/script/template_sensor).
4) Check `/spec/*` guardrails (runtime, triggers, safety, security,
   formatting, notifications, performance, entity references).
5) Validate logic in **DTT** first — see `/guides/dtt_first_validation.md`
   for the full validation cycle.
6) **Reviewers** make a good‑faith pass to catch Jinja issues
   **before** running `tools/lint_templates.sh`.
7) Run the linter, then submit PR following
   `/guides/review_and_checklist.md`.
8) Include concise **CHANGELOG** in YAML descriptions or `#` comments;
   **do not** keep changelog in `SKILL.md`.

## Glossary (no shorthand assumptions)

- **HA**: Home Assistant
- **DTT**: Developer Tools → **Template**
- **DTT-first**: Developer Tools → Templates validation before any deployment; see `guides/dtt_first_validation.md`
- **BC**: **Backward-Incompatible Change** (often called a **breaking change**) — a change that requires user configuration updates or removes/deprecates existing HA schema, keys, attributes, services, or behavior.
- **HAF**: **Household Acceptance Factor** — acceptance of all in the home for automation behavior and nuisance alerts.
- **Idempotent**: Running the same action again doesn't change state
- **Brains vs Muscles**: templates decide; automations/scripts act
- **Hysteresis**: guards to prevent oscillation between states
- **SIC**: System Impact Classification — worst-credible impact rating (Class A–D) assigned before design; see `guides/system_impact_class.md`
- **Staggering**: randomized restart delay to avoid storms
- **Timezone**: America/Los_Angeles (local time)

- See `guides/validator_flow.md` for the human validator checklist.
- See `patterns/template_sensor_attributes.md` for attribute design.
