# Performance & Chatter

- Prefer **event‑driven** over time‑pattern polling. If polling is required, enforce a minimum **60s** interval unless critical.
- Batch updates by **group/area**; avoid rapid repeated per‑device calls.
- Use `repeat: for_each:` for controlled fan‑outs; avoid unbounded loops; keep iterations <10 per tick.
- Keep templates efficient: precompute; avoid repeated `states()` calls.
- Avoid INFO‑level log spam; enable DEBUG only during active debugging via a helper switch.

## Recorder / Database Cost

Every state change **and** every attribute change is written to the recorder database and drives history, logbook, and statistics. Authoring choices directly affect DB size and query speed.

- **Attributes ride with state**: when a frequently-changing entity also carries many or large attributes, each change persists the whole attribute set. Keep attributes on high-churn entities minimal.
- **Attributes are for dynamic info that explains the current state** — not static metadata (firmware version, model, config). Static facts do not belong in `extra_state_attributes`; they bloat every recorded row and never change.
- **Don't republish raw upstream facts** as attributes (see `references/patterns/template_sensor_attributes.md`); consumers should read source entities directly. Snapshot only when auditability requires a fixed decision-point value.
- For unavoidably noisy diagnostic entities or attributes, prefer excluding them from the recorder (recorder `exclude`/attribute filtering) over silently paying the write cost.
