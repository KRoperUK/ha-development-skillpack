# Integration Watchdog Recovery

**TL;DR**: Some integrations fail at the integration level — not at the command level. A single config entry reload often recovers them. This guide covers how to detect a known failure signature, throttle reloads to avoid storms, and reload the config entry automatically. The pattern applies to any integration that exhibits recoverable failure modes — cloud APIs, local bridges, polling integrations, and misbehaving local drivers alike.

**Principle**: This guide covers integration-level recovery — detecting that a config entry has become dysfunctional and recycling it. `references/guides/cloud_api_actuation.md` covers command-level delivery guarantees for cloud-backed actuation. Keep the scope narrow: one failure signature, one reload, one cooldown gate. Do not conflate watchdog logic with actuation retry logic.

---

## When to Use This Pattern

Apply a watchdog when an integration exhibits a **known, recurring, recoverable failure mode** that a config entry reload reliably resolves:

| Integration Type | Typical Watchdog Trigger |
|---|---|
| Cloud API (direct) | Known error logged by the integration or its script layer |
| Cloud-relayed local bridge | Bridge reconnect failure, session mutex error |
| Local polling integration | Entity goes unavailable on a recurring schedule |
| Local driver (ESPHome, ZHA, Z-Wave JS) | Known crash or hang logged by the integration |
| MQTT-backed integration | Broker reconnect failure, stale subscription |

Do not apply this pattern speculatively. A watchdog for a healthy integration adds noise and risk. Apply only when you have observed the failure mode and confirmed that a reload resolves it.

**Check for native recovery first.** Some integrations (Z-Wave JS, ZHA) handle reconnection internally — a watchdog reload during native recovery can make things worse. Confirm the integration does not already self-recover before implementing.

---

## Failure Signature Types

Choose the trigger mechanism that matches how the failure manifests:

### Type 1 — Log Signature

The integration or a dependent script logs a known error string. Use `system_log_event` with `event_data.name` scoped to the specific logger. Requires `system_log.fire_event: true` in `configuration.yaml`.

Scope `event_data.name` as narrowly as possible — to the specific component or script logger, not the integration root. A broad logger match will fire on unrelated errors and cause spurious reloads.

After triggering, substring-match the log text inside the action to confirm the specific signature before reloading. Do not reload on any ERROR from that logger — only on the known string.

### Type 2 — Sustained Unavailability

One or more integration-owned entities have been unavailable longer than the integration's normal recovery window. Use a `template` trigger with `for:`.

Tune `for:` to the integration's observed recovery cadence. Too short causes reload storms on normal session resets; too long leaves the integration broken longer than necessary.

### Type 3 — Staleness

The integration is technically available but has stopped updating. Detect via `last_updated` age on a key entity.

```jinja
{% set ent = states.sensor.your_integration_entity %}
{{ ent is not none
   and (as_timestamp(now()) - as_timestamp(ent.last_updated, 0)) | float(0) > 600 }}
```

Use as the `value_template:` on a `trigger: template` with an appropriate `for:`. The `ent is not none` guard prevents errors at startup before the entity is defined.

---

## Anti-Patterns

- Do not reload on every `ERROR` from a broad integration logger.
- Do not combine integration reload watchdogs with device actuation retry logic in the same automation.
- Do not loop reloads inside one automation run.
- Do not reload integrations during normal startup or native recovery unless the failure mode is proven and reload recovery has been validated.

---

## Cooldown Gate

Reload storms occur when the failure condition persists or recurs faster than the integration recovers. Always gate reloads with a cooldown.

**Preferred: `last_triggered` on the automation entity itself.** No helper required. `last_triggered` is `none` until the automation has fired at least once — `as_timestamp(none, 0) | float(0)` yields `0`, which correctly clears the gate on first run.

```yaml
last_reload_ts: >-
  {{ as_timestamp(
       state_attr('automation.your_watchdog_automation_entity_id', 'last_triggered'),
       0
     ) | float(0) }}
cooldown_ok: "{{ as_timestamp(now()) | float(0) - last_reload_ts >= 900 }}"
```

Default cooldown: **900 seconds (15 minutes)**. Tune to the integration's observed recovery time — long enough that a failed reload doesn't immediately retry, short enough that a legitimate recurrence is eventually addressed.

**Cooldown caveats:**
- `last_triggered` reflects the last time the automation *fired*, not the last time a reload was *issued*. If the automation fires on a non-reload path (e.g., a signature mismatch), the cooldown clock still advances. This is acceptable — a non-reload firing is evidence the integration is generating errors, and backing off is the right posture.
- Do not use `last_triggered` as a cooldown in high-frequency automations where it would be reset by unrelated triggers. Watchdog automations fire infrequently by design — this technique is appropriate here and not generally portable.

---

## Reload Action

`homeassistant.reload_config_entry` reloads the config entry that owns a given entity. Pass any entity belonging to the integration's config entry via `target:`, not `data:` — the service takes the entity reference as a target, not a data payload.

A single reload is sufficient. Do not retry on failure — if the reload itself fails, a subsequent watchdog trigger will handle it once the cooldown clears. Log the recovery action at `warning` level for observability; the skeleton below includes the full pattern.

---

## Startup Trigger

Include a startup reload only for integrations with known post-restart initialization failures. This is prophylactic — do not gate it on a log signature or failure condition. Use the standard non-critical stagger (`range(45, 76) | random` seconds on `timer.ha_startup_delay → idle`). Omit it if the integration initializes reliably after restart. The skeleton below includes the full trigger shape.

---

## Complete Skeleton

After first save, confirm the automation entity ID used by the `last_triggered` cooldown self-reference. Rename drift will break the cooldown.

```yaml
alias: Your Integration - Watchdog reload
description: >
  Reloads the your_integration config entry on HA startup and when [describe
  failure signature]. Cooldown uses the watchdog automation's own `last_triggered`
  attribute; this intentionally avoids a helper and accepts that any watchdog
  firing can start the cooldown window. Requires system_log.fire_event: true if
  using log signature trigger.


  **CHANGELOG:**

  - YYYYMMDD-HHMM: Initial implementation.

mode: single
max_exceeded: silent

triggers:
  - alias: Post-restart reload gate
    id: ha_restart
    trigger: state
    entity_id: timer.ha_startup_delay
    from: active
    to: idle
    for:
      seconds: "{{ range(45, 76) | random }}"

  - alias: Known failure signature detected
    id: integration_error_detected
    trigger: event
    event_type: system_log_event
    event_data:
      level: ERROR
      name: homeassistant.components.your_integration.your_component

conditions:
  - alias: Startup timer is idle
    condition: state
    entity_id: timer.ha_startup_delay
    state: idle

actions:
  - alias: Route by trigger ID
    choose:
      - alias: Post-restart reload
        conditions:
          - condition: trigger
            id: ha_restart
        sequence:
          - alias: Reload config entry
            action: homeassistant.reload_config_entry
            target:
              entity_id: sensor.your_integration_owned_entity

      - alias: Failure signature reload path
        conditions:
          - condition: trigger
            id: integration_error_detected
        sequence:
          - alias: Resolve log text and cooldown
            variables:
              raw_message: "{{ trigger.event.data.message | default('') }}"
              raw_exception: "{{ trigger.event.data.exception | default('') }}"
              message_text: >-
                {% if raw_message is sequence and raw_message is not string %}
                  {{ raw_message | join(' ') | lower | trim }}
                {% else %}
                  {{ raw_message | string | lower | trim }}
                {% endif %}
              exception_text: >-
                {% if raw_exception is sequence and raw_exception is not string %}
                  {{ raw_exception | join(' ') | lower | trim }}
                {% else %}
                  {{ raw_exception | string | lower | trim }}
                {% endif %}
              log_text: "{{ (message_text ~ ' ' ~ exception_text) | lower | trim }}"
              signature_detected: >-
                {{ 'your known error substring' in log_text }}
              now_ts: "{{ as_timestamp(now()) | float(0) }}"
              last_reload_ts: >-
                {{ as_timestamp(
                     state_attr('automation.your_watchdog_automation_entity_id', 'last_triggered'),
                     0
                   ) | float(0) }}
              cooldown_ok: "{{ now_ts - last_reload_ts >= 900 }}"

          - alias: Continue only on confirmed signature and clear cooldown
            if:
              - alias: Known failure signature confirmed
                condition: template
                value_template: "{{ signature_detected }}"
              - alias: Cooldown clear
                condition: template
                value_template: "{{ cooldown_ok }}"
            then:
              - alias: Reload config entry
                action: homeassistant.reload_config_entry
                target:
                  entity_id: sensor.your_integration_owned_entity

              - alias: Log recovery action
                action: system_log.write
                data:
                  level: warning
                  logger: homeassistant.automation.your_watchdog
                  message: "Reloaded your_integration config entry after detected failure."
            else:
              - alias: Skipped — no signature match or cooldown active
                stop: "No signature match or cooldown active"
```

Adapt the trigger block for Type 2 (sustained unavailability) or Type 3 (staleness) failure signatures by replacing the `system_log_event` trigger and removing the log-parsing variables. The cooldown, reload, and routing structure remain the same.

---

## Pattern Checklist

- [ ] Failure mode observed and confirmed recoverable by reload before implementing
- [ ] Trigger scoped as narrowly as possible (specific logger, specific entity, tuned `for:`)
- [ ] Log signature substring-matched inside the action, not relied on from trigger filter alone
- [ ] Cooldown gate present; `last_triggered` used unless per-path cooldowns are required
- [ ] Cooldown window tuned to integration's observed recovery cadence
- [ ] `homeassistant.reload_config_entry` uses `target:` not `data:`
- [ ] Single reload only — no retry loop
- [ ] Recovery action logged at `warning` level
- [ ] Startup trigger present only if post-restart failures are observed
- [ ] Startup suppression, if present, does not block required recovery
- [ ] `mode: single` + `max_exceeded: silent` on the automation
- [ ] `system_log.fire_event: true` confirmed in `configuration.yaml` if using log signature trigger
- [ ] Automation entity ID in `state_attr` cooldown confirmed after first save

## See Also

- `references/guides/cloud_api_actuation.md` — Command-level delivery guarantees for cloud-backed actuation; complements this guide for integrations that need both watchdog and actuation reliability
- `references/patterns/integration_degradation.md` — Sensor-side degradation and staleness handling for integrations that go silent
- `references/patterns/restart_resilience.md` — Startup delay and stagger patterns
- `references/guides/system_impact_class.md` — Impact classification; higher-class systems may warrant shorter cooldowns or additional notification on reload
