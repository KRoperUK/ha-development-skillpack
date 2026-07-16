# Home Assistant Development Skill Pack

**An opinionated prompt, design-principle, and pattern set for co-creating Home Assistant YAML/Jinja and AppDaemon apps with an LLM.**

This repository is an [Agent Skill](https://agentskills.io) — a `SKILL.md` entry point plus supporting references, scripts, and assets. Drop it into a skills-aware assistant (Claude Code, Kiro, and similar) or use `SKILL.md` as a project/system file with any capable model.

---

## What this is

A structured reasoning framework for Home Assistant co-development. It compiles the things that have worked — and the failure modes LLMs still get wrong — into a dispatcher (`SKILL.md`) that routes each task to the authoritative source for that domain.

It is:

- a common set of design principles and guardrails,
- safe-Jinja, numeric-safety, and entity-reference patterns,
- a Developer-Tools-first validation discipline,
- a review rubric with an A- production bar,
- and a mental model for discussing automations before any YAML is written.

It reflects strong, personal opinions about what works — not a universal framework or an official Home Assistant approach.

## What this is not

- Not a drop-in set of automations, scripts, or blueprints.
- Not guaranteed correct for anyone else's setup.
- Not exhaustive across every HA domain.
- Not an official Home Assistant project.

---

## Structure

```
ha-development-skillpack/
├── SKILL.md            # Dispatcher: session rules, priority order, task router, artifact map
├── references/         # On-demand docs loaded when a task needs them
│   ├── guides/         # Architecture, intake, debugging, review, AppDaemon, cloud/watchdog
│   ├── patterns/       # Reusable patterns (action hygiene, execution gating, restart resilience…)
│   ├── spec/           # Authoritative rules (yaml_style, runtime, safety, security, entity refs…)
│   ├── snippets/       # Jinja do/don't idioms
│   ├── cookbooks/      # Debugging and DTT technique walkthroughs
│   └── glossary.md
├── assets/
│   ├── scaffolds/      # Canonical starting structures (automation, script, template sensor…)
│   └── samples/        # Production-quality illustrative examples
├── scripts/            # Helper shell tools (entity snapshot, template lint)
├── changelog.md
└── LICENSE
```

`SKILL.md` is the only file an assistant needs to read first. It references each leaf resource directly (one hop), so the rest of the tree is loaded progressively, on demand.

---

## How to use it

Point your assistant at `SKILL.md` and let it route. A typical flow runs in three passes, ideally across separate sessions:

1. **Architect** — discuss the design in plain English, present options with tradeoffs, pressure-test the approach, and define acceptance criteria before any code is written.
2. **Implement** — resolve open questions, then build the agreed design against these rules.
3. **Review** — act as a grumpy senior reviewer: YAML/Jinja correctness, fit to design, restart behavior, edge cases, and strict adherence to the pack. Try to break it.

Each pass feeds back into the previous one: design is pressure-tested before coding, and code is pressure-tested before it ships.

---

## Grounding

Guidance is aligned with the official [Home Assistant developer documentation](https://developers.home-assistant.io) and current HA Core behavior. When training data and the docs disagree, the official docs win — the pack says so explicitly and expects assistants to verify version-sensitive syntax against the running Core version.

---

## Feedback welcome

Shared in the hope that others spot flaws, failure modes, or better ways to structure the same ideas. If your reaction is "this wouldn't work for me," that's expected — it's tailored to a specific instance and set of interests. The structure may still spark useful ideas.

## License

MIT. Use, fork, modify, or ignore freely. No warranty, no claims.
