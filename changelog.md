## Changelog
## 0.7.3
- Overhauled dtt_techniques.md with extremely successful scaffolding for uncovering issues
- Moved skill changelog into its own file
## 0.7.2
- Refined review checklist: added optional HALMark-inspired safety-level summary under Self-Critique, strengthened KISS native-first guidance, and clarified simpler-alternative handling.
- Updated license/provenance notes to reflect incorporation of the HALMark stewardship/safety-level review model.
- Resolved documentation/tooling ambiguity in /samples and HOWTO.md
- Clarified unique trigger ID
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
