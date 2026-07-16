# Action Hygiene

Governs service-call behavior: when to call, how to guard, how to batch, and how to rate-limit. Applies to device calls, lighting control, notification actions, and integration actuation.

---

## Idempotency & Guard Calls

- Guard service calls with cheap desired-vs-current checks when the check is reliable and does not compromise response speed or recovery behavior.
- Batch via native groups, integration groups, or carefully scoped HA areas when membership is intentional and HAF-safe.
- Prefer scripts for reusable fan-outs or multi-step device orchestration; direct automation service calls are acceptable for simple, local, single-purpose actions.
- Retry once for likely transient errors; use `continue_on_error: true` only when justified by impact classification and downstream recovery behavior.

---

## Action Response Data

Some actions return data rather than only performing side effects. Capture it with `response_variable` and read it from later steps.

- **Capture pattern**: `action: weather.get_forecasts` (or `calendar.get_events`, `todo.get_items`, etc.) with `response_variable: result`, then consume `{{ result[...] }}` downstream.
- **Some actions only return data** (they have no side effect) and *require* `response_variable` — omitting it is a config error, not a silent no-op.
- **Errors surface as raised exceptions**, not return codes: a failed action stops the sequence unless you deliberately set `continue_on_error: true`. Don't expect an error to appear as a value in the response.
- **Prefer response data over scraping** helper/attribute state for information that does not naturally live in an entity's state (forecasts, event lists, query results). It is fetched on demand and avoids polluting the recorder with transient data.

---

## Chatter Control

- Debounce per room/zone; coalesce related changes and act once.
- Rate-limit noisy inputs; prefer event-driven triggers over `time_pattern` polling unless periodic reconciliation is intentional.
- Prefer native Zigbee/Z-Wave groups or intentionally scoped HA groups/areas to reduce bus traffic; avoid broad areas where membership drift could create HAF.
- Logging is for debugging and significant failure paths; production logs should not create routine noise.

---

## Lighting Control Paths

### ON-Path — Speed Priority

For off → on behavior, prioritize fast, predictable activation.

- Use minimal gates: security, safety, overrides, and cheap eligibility checks only.
- Apply `light.turn_on` quickly through the narrowest reliable target.
- Compute brightness, color temperature, and color values cheaply.
- Prefer group or area targeting only when membership is intentional and HAF-safe.
- Small transitions, such as 1.5 seconds, may smooth spikes without materially delaying response.

### ADJUST-Path — Overhead Optimized

For on → brightness/color tuning, prioritize low chatter and stable behavior.

- Batch updates where possible.
- Use idempotent guards before repeated tuning calls.
- Rate-limit presence, lux, and environmental feedback loops.

### OFF-Path — Validation Priority

For on → off behavior, prioritize correctness over speed.

- Respect presence, manual overrides, safety gates, and shared-space HAF concerns.
- Prefer graceful transitions where user-visible.
- Log only when user-visible, diagnostic, or exceptional.
