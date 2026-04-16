# Exploratory Mode

> This guide governs idea triage only — before any design,
> implementation, or testing work begins. Its purpose is to shape an
> unvetted idea into a clear disposition: proceed to intake, chunk,
> redesign, shelve, pass, or build anyway.
>
> Architectural thinking still applies during exploration (e.g.,
> System Impact Classification, feasibility, and constraint awareness),
> but no implementation structure, YAML, or detailed design is produced
> in this phase.
>
> All architecture, implementation, and review standards defined in the
> Skill Pack apply in full once a disposition is reached and work moves
> into intake and design.
>
> If an idea cannot be reconciled with core architectural principles
> during exploration, it should not proceed to intake without redesign
> or explicit acceptance of tradeoffs.

## Purpose

Exploration precedes intake. Its purpose is to triage an idea before
committing design effort. Do not begin the intake process until
exploration produces a disposition.

Exploratory mode is not freeform brainstorming — it is structured
feasibility triage with a defined output.

---

## Session Flow

### Phase 1 — Draw Out the Idea

Begin by drawing out as much thinking as the owner has already done.
The opening may be a single vague sentence or a detailed description
— meet it where it is.

- Rephrase the idea back to the owner to confirm understanding.
- Ask clarifying questions one at a time until enough is known to
  begin axis evaluation. Focus on: intent, expected outcome,
  constraints, dependencies, and household impact.
- If the owner says "I haven't thought about that" or "don't know"
  in response to a question about a material aspect of the expected
  outcome, do not drop it — probe further by suggesting feasible or
  reasonably expected outcomes and ask the owner to react.

### Phase 2 — Summarize and Confirm

Before moving to axis evaluation, summarize what has been gathered:

- Restate the use case, requirements, and any constraints or
  dependencies identified.
- Ask openly: "Anything else? Anything I've missed or
  mischaracterized?"
- Do not proceed to axis evaluation until the owner confirms the
  summary is complete.
- Explicitly ask: "Ready to move into feasibility evaluation?"

### Phase 3 — Axis Evaluation

Evaluate the idea against all applicable axes. This list is not
exhaustive — apply additional axes as the idea demands:

- **Technical feasibility**: is this achievable in HA YAML, or does
  it require AppDaemon, custom integrations, or unsupported behavior?
- **Hardware feasibility**: does the required hardware exist, is it
  available, and does it actually do what is assumed?
- **HA-native boundary**: can this be done with native constructs and
  helpers, or does it push into template sensor or AppDaemon
  territory? Is that complexity justified?
- **Practical value**: is there a real use case, or is this
  interesting to build but unlikely to be used?
- **Over-engineering risk**: is this too clever — solvable more
  simply, or solving a problem that doesn't materially exist?
- **Household acceptance risk**: would this cause annoyance, surprise,
  or loss of trust with other household members?
- **Dependency risk**: does this depend on integrations, devices, or
  behaviors that are unreliable, unproven, or not yet in place?
- **Other**: any feasibility dimension not listed above that
  materially affects whether the idea is worth pursuing.

**Evaluation depth**: evaluate until the disposition is clear or the
direction is evident — not necessarily until every axis is exhausted.
If a fatal flaw emerges, surface it immediately but continue
exploring whether it is addressable before calling a disposition.

**Partial feasibility**: if the infeasible part is peripheral or
mitigatable, propose a redesign or reframe to work around it before
calling a disposition. If the infeasible part is core to the intended
outcome, name it explicitly and call Pass.

### Phase 4 — Convergence

When the discussion has produced enough signal to support a
disposition — and before analysis paralysis sets in — check in:

- Summarize the key findings across axes evaluated.
- Propose a disposition with brief rationale.
- Ask the owner to confirm, adjust, or redirect.

If the idea is too large or complex as stated, propose chunk
boundaries — identify feasible independent pieces, note any
sequencing or prerequisite dependencies, and discuss with the owner
before finalizing. Each confirmed chunk proceeds through intake
separately.

If a session ends without a disposition — either by choice or
because the idea needs more thought — the owner resumes the
exploration in a new session. There is no persistent interim state;
the owner re-establishes context at the start of the next session.

---

## Assistant Posture

More aggressive than design or execution mode on both axes:

- **Critical**: poke holes freely — feasibility, value, complexity,
  hardware assumptions, HA-native limits, household acceptance risk.
  Do not wait to be asked.
- **Creative**: actively propose how an idea could work, what it
  would take, or how it could be chunked into feasible pieces.
  Use "what-if" framing to explore boundaries — a small change in
  scope, hardware, or approach can take an idea from infeasible to
  elegant, or reveal that a promising idea has a fatal flaw just
  outside its assumed boundaries.

Both postures are active throughout the session. Do not default to
one at the expense of the other.

---

## Dispositions

An exploratory session concludes with one of the following:

- **Proceed**: idea is feasible and valuable — begin intake at Step 0.
  Apply full or abbreviated intake based on impact class and novelty.
- **Chunk**: idea is too large or complex as stated — break into
  feasible independent pieces, each proceeding through intake
  separately.
- **Redesign**: idea is directionally sound but technically or
  practically flawed as proposed — identify what would need to change
  before proceeding.
- **Shelve**: idea has real value but is blocked by missing hardware,
  missing integrations, or unresolved dependencies — document and
  revisit when blockers are resolved.
- **Pass**: does not survive feasibility scrutiny at this time —
  weak use case, disproportionate investment, or no viable path
  forward. Re-evaluate if conditions or constraints change.
- **Build it anyway**: no practical use case or the use case is
  marginal, but the idea has genuine learning, experimentation, or
  creative value and the owner has made a conscious decision to
  proceed. Not a bypass — full intake applies based on impact class
  and novelty, same as any other work.

---

## Output

Output depends on disposition:

- **Proceed**: brief feasibility summary + confirmed impact class →
  feeds directly into `guides/new_automation_intake.md`.
- **Chunk**: list of feasible independent pieces with proposed impact
  class for each, sequencing or prerequisite dependencies noted →
  each chunk proceeds through intake separately.
- **Redesign**: description of the flaw and what would need to change
  → revisit when addressed.
- **Shelve**: brief rationale + blocking dependencies + conditions
  that would change the disposition → logged, not pursued further.
- **Pass**: brief rationale + any conditions that would change the
  disposition → logged, not pursued further.
- **Build it anyway**: conscious decision documented + proceed
  directly into `guides/new_automation_intake.md` under full intake.

---

## Relationship to Other Guides

- Exploration concludes before intake begins — see
  `guides/new_automation_intake.md` for the intake process.
- Session mode is defined in `SKILL.md` — see Roles &
  Decision-Making for the full mode definitions.
- Household acceptance risk is evaluated in full during review — see
  `guides/review_and_checklist.md` HAF sub-checklist.
