# Event-Driven Templates (Patterns)

- Triggers include only entities that change outcomes; add HA startup gate:
  - Critical: `for: {seconds: <10}`
  - Non‑critical: `for: {seconds: '{{ range(45, 76) | random }}' }`
- State shape: short enums (`execute`, `conserve`, `hold`) or JSON map for batch ops.
- Attributes: `reason` + metrics; commented `#debug_…` attrs for quick flip‑on.
- Safe reads: `states()`/`state_attr()` with defaults; normalized strings; precompute vars.
- Hysteresis/cooldowns: implement in automation or via attributes; avoid jitter.
- Momentary happenings are events, not state: don't model a transient occurrence (button press, doorbell, scene activation) as a sticky template-sensor state that flips on then back off after a delay. Trigger on the underlying event (event trigger / event entity) instead — a sensor forced to hold `on` for N seconds is fragile across restarts and races.
- Don’ts: `.get()`, `.items()`, `.split()`, `.append()`, `.replace()`, `.format()`, `.total_seconds()`.
- Prefer `has_value()` to raw `states() not in ['unknown','unavailable','']` checks: `has_value()` is the safe, idiomatic HA mechanism for availability. If the source is known to emit blank strings, add and (states(...)|trim) != ''.
