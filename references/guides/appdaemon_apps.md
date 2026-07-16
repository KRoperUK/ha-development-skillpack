# AppDaemon Apps

AppDaemon is **Tier 4** of the decision ladder (`references/guides/architecture_principles.md`): reach for it only when YAML — native constructs, helpers, and template sensors — cannot cleanly express the need. Good fits: long-lived in-memory state, multi-step workflows, complex orchestration, and coordination with external systems. Also acceptable when a YAML solution technically works but has become hard to reason about, test, or maintain.

Choosing AppDaemon does **not** relax the Skill Pack. Impact classification, overrides-first, restart resilience, execution gating, HAF, and the review standard all still apply. AppDaemon changes the implementation language, not the invariants.

---

## HA runtime invariants still apply

- **States are strings.** `self.get_state('sensor.x')` returns a string (or `None`). Coerce explicitly (`float(...)`, `int(...)`, `== 'on'`); never assume numeric or boolean typing.
- **Guard unavailable/unknown before acting.** In a state callback, return early when the new value is `None`, `"unavailable"`, or `"unknown"` — mirrors the DTT `has_value()` discipline. Distinguish `unavailable` (source unreachable) from `unknown` (reachable, value missing) only when the app must react differently.
- **Address by `entity_id`, never by display name or `device_id`.** Same reasoning as `references/spec/entity_references.md`; a disabled entity is not addressable.
- **Overrides first.** Evaluate manual/guest/safety overrides at the top of every callback before any actuation, exactly as in YAML.
- **Restart resilience.** AppDaemon restarts independently of HA and reconnects. Do not assume in-memory state survives a restart — persist deferred intent (e.g. an `input_datetime` deadline) rather than relying on a variable, and re-derive state from HA on `initialize()`. Stagger restart-time work; do not stampede devices on reconnect.

---

## Concurrency: keep callbacks fast and non-blocking

AppDaemon dispatches callbacks on worker threads. A callback that blocks ties up a worker and delays every other callback — the same "never stall the loop" lesson the HA core applies to its event loop.

- **Never block a callback** with `time.sleep()`, synchronous network/file I/O, or long CPU work. Schedule instead: `self.run_in(cb, delay)`, `self.run_every(...)`, `self.run_daily(...)`, or an `async def` app with `await self.sleep(...)`.
- **Prefer event-driven registration over polling.** Use `self.listen_state(...)` and `self.listen_event(...)` rather than periodic scans; use scheduler callbacks for genuinely time-based work. This matches the YAML trigger order-of-preference.
- **Be deliberate about shared mutable state.** Multiple callbacks can run on different threads. Guard shared structures (locks or an async single-threaded app) and keep per-callback work small and idempotent.
- **Bound retries and cooldowns**; do not busy-loop waiting for a device or API to recover — schedule a re-check.

---

## Talk to HA through the AppDaemon API only

Interact with Home Assistant exclusively through the AppDaemon API — do not reach into HA internals or bypass the plugin:

- Read: `self.get_state(entity, attribute=...)`
- React: `self.listen_state(cb, entity, ...)`, `self.listen_event(cb, event)`
- Act: `self.call_service("domain/service", ...)` and `self.set_state(...)`
- Schedule: `self.run_in`, `self.run_every`, `self.run_daily`, `self.create_task`

State-change callback signature and the canonical guard:

```python
def on_change(self, entity, attribute, old, new, **kwargs):
    if new in (None, "unavailable", "unknown"):
        return  # no usable value — do nothing
    # overrides-first, then act
    if self.get_state("input_boolean.guest_mode") == "on":
        return
    value = float(new)
    ...
```

---

## Observability & discipline

- Log sparingly and meaningfully: `self.log(...)` for significant events, `level="DEBUG"` for detail left off in production. Never log secrets or identifying material (`references/spec/security.md`).
- Keep apps decomposed and testable — small callbacks, clear responsibilities, pure computation separated from actuation ("brains vs muscles" still holds). Prefer well-named helper methods over one large callback.
- Document non-obvious logic with full-sentence Python comments (AppDaemon Python is not GUI-stripped, unlike automation/script YAML).
- Validate behavior paths before shipping: normal, unavailable/unknown inputs, startup/reconnect, and boundary values. This is the AppDaemon equivalent of DTT-first validation.
