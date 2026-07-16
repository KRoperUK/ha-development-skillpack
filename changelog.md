## Changelog

## 1.2.0 - 20260716
- Overhauled into a true [Agent Skill](https://agentskills.io): `SKILL.md` entry point with conformant frontmatter (name matches the repository, when-to-use description, `license`, `compatibility`, `metadata`), on-demand docs under `references/`, executables under `scripts/`, scaffolds and samples under `assets/`, and every internal reference expressed as a one-hop relative path.
- Aligned guidance with the official Home Assistant developer docs: house formatting and quoting standards in `references/spec/yaml_style.md`; `unique_id`-grounded stability, disabled-entity and frozen-device-automation notes, and area/floor/label targeting in `references/spec/entity_references.md`; `unavailable` vs `unknown` semantics in `references/snippets/jinja_patterns.md`; AwesomeVersion gating and CalVer format in `references/spec/runtime.md`; momentary-events-are-not-state in `references/patterns/event_driven_templates.md`.
- Added `references/guides/appdaemon_apps.md` (non-blocking callbacks, HA-API-only interaction, the unavailable/unknown guard, restart resilience) and wired it into the task router, artifact map, always-apply rules, decision ladder, and review checklist.
- Refreshed the README for the new structure and dropped the legacy restructure notice.
