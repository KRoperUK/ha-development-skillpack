# Cloud API Actuation

**TL;DR**: Cloud-backed entities lie. A service call that succeeds at the transport level may not change the device state. Confirm the state changed, retry once, notify if still wrong, and add a recovery trigger so directives that arrived during an outage aren't silently lost.

**Principle**: A successful service call to a cloud-backed entity does not guarantee a successful state change. Authentication sessions expire, rate limits fire, and entity availability churns independently of device state — treat this as normal operating condition, not an edge case. Apply this guide whenever the controlling integration routes through a cloud API or cloud relay. Local RF (Zigbee, Z-Wave, Thread) and direct LAN integrations do not require this treatment.

The *expected state* — what the automation has determined the entity should be in — may come from a directive sensor, a condition derived inside the automation, or a caller-supplied argument. The pattern is the same regardless of source.

---

## Required Patterns

### 1. Recovery Trigger

Every cloud-backed actuation automation **must** include a trigger that fires when the entity returns from `unavailable` or `unknown`. Without it, any expected state that arrived during an outage window is silently lost — never enforced until the next external trigger, which may be hours away or never.

```yaml
- alias: Entity recovered from unavailable or unknown
  trigger: state
  entity_id: switch.your_cloud_entity
  from:
    - unavailable
    - unknown
  to:
    - "on"
    - "off"
  id: entity_recovered
```

Adjust `to:` to match the valid states of the entity domain (`climate` recovers to `heat` / `cool` / `off`, not `on` / `off`).

### 2. Branch Gate Must Include Unavailable and Unknown

The condition guarding each actuation branch must include `unavailable` and `unknown` alongside the opposite binary state. Without them, the branch silently skips when the entity returns from unavailable:

```yaml
# ✅ Correct — fires on recovery from unavailable/unknown
- condition: state
  entity_id: switch.your_cloud_entity
  state:
    - "off"
    - unavailable
    - unknown

# ❌ Wrong — silently skips when entity recovers from unavailable
- condition: state
  entity_id: switch.your_cloud_entity
  state: "off"
```

This applies to every branch reachable via the `entity_recovered` trigger.

### 3. continue_on_error on Every Service Call

All service calls to cloud-backed entities must use `continue_on_error: true`. Without it, a transient API failure aborts the entire action sequence — including the confirmation wait and retry that follow:

```yaml
- action: switch.turn_on
  target:
    entity_id: switch.your_cloud_entity
  continue_on_error: true
  data: {}
```

### 4. Confirm → Retry → Notify

After every service call, wait for confirmation, retry once on failure, and notify if still unconfirmed. Never assume the call worked:

```yaml
# Attempt
- action: switch.turn_on
  target:
    entity_id: switch.your_cloud_entity
  continue_on_error: true
  data: {}

# Confirm — wait up to 1 minute
- wait_template: "{{ is_state('switch.your_cloud_entity', 'on') }}"
  timeout:
    minutes: 1
  continue_on_timeout: true

# Retry once if not confirmed
- if:
    - condition: template
      value_template: "{{ not is_state('switch.your_cloud_entity', 'on') }}"
  then:
    - action: switch.turn_on
      target:
        entity_id: switch.your_cloud_entity
      continue_on_error: true
      data: {}
    - wait_template: "{{ is_state('switch.your_cloud_entity', 'on') }}"
      timeout:
        seconds: 10
      continue_on_timeout: true
    - if:
        - condition: template
          value_template: "{{ not is_state('switch.your_cloud_entity', 'on') }}"
      then:
        - action: persistent_notification.create
          data:
            notification_id: your_entity_failed_on
            title: "Your Device — Failed to Turn ON"
            message: >-
              your_cloud_entity failed to confirm ON after retry.
              Current state: {{ states('switch.your_cloud_entity') }}.
              Manual check required.
```

Default timeouts: **1 minute** for initial confirmation, **10 seconds** for retry. Adjust to the device's known response characteristics.

### 5. Stable Notification IDs with Auto-Dismiss

Use a fixed `notification_id` per failure type so repeated failures overwrite rather than stack. Dismiss on recovery so notifications reflect actual system state — never leave a stale failure notification up after the system has self-corrected:

```yaml
- action: persistent_notification.dismiss
  data:
    notification_id: your_entity_failed_on
```

Auto-dismiss fires on the same path that clears the failure condition: expected state confirmed, HA restart, or entity returning from unavailable in the confirmed state.

### 6. Sustained Unavailability: Notify and Hold

Notify once when the entity has been unavailable long enough to matter, then leave it in its last known state. Do not attempt repeated corrective actuation — the recovery trigger handles re-execution when the entity comes back:

```yaml
# In triggers block:
- trigger: template
  value_template: "{{ is_state('switch.your_cloud_entity', 'unavailable') }}"
  for:
    minutes: 5
  id: entity_unavailable
  alias: Entity unavailable for 5 minutes

# In actions block:
- if:
    - condition: trigger
      id: entity_unavailable
  then:
    - action: persistent_notification.create
      data:
        notification_id: your_entity_unavailable
        title: "Your Device — Unavailable"
        message: >-
          switch.your_cloud_entity has been unavailable for 5 minutes.
          Last known state preserved. Manual check required if this persists.

- if:
    - condition: trigger
      id: entity_recovered
  then:
    - action: persistent_notification.dismiss
      data:
        notification_id: your_entity_unavailable
```

The 5-minute threshold avoids noise from brief session resets. Tune to the integration's observed recovery cadence.

---

## Complete Trigger Set

Missing any one of these leaves a gap in coverage:

| Trigger ID | What fires it | Gap it closes |
|---|---|---|
| `state_changed` or `directive_changed` | Primary expected-state signal changes | Normal operation path |
| `ha_restart` | `timer.ha_startup_delay` goes idle | State drift during HA downtime |
| `entity_recovered` | Entity returns from `unavailable` / `unknown` | Expected state lost during cloud outage |
| `entity_unavailable` | Template trigger with `for: minutes: 5` | Sustained outage notification |

`ha_restart` uses the canonical `timer.ha_startup_delay` idle pattern with `range(45, 76) | random` stagger. See `/patterns/restart_resilience.md`.

---

## When to Apply This Guide

| Integration Type | Typical Failure Modes | Apply? |
|---|---|---|
| Cloud API (direct) | Session expiry, token refresh, rate limiting (429), maintenance windows | **Yes** |
| Cloud-relayed local protocol (cloud → bridge → device) | All of the above plus bridge connectivity | **Yes** |
| MQTT → cloud relay | MQTT broker restart, cloud downtime, credential expiry | **Yes** |
| Local LAN / direct IP | Network resets, DHCP churn, firmware reboots | Usually not; `continue_on_error` as a minimum |
| Local RF (Zigbee, Z-Wave, Thread) | Device sleep, RF congestion, mesh routing | No |
| HA-native helpers | HA restart only | No |

**Read-only cloud integrations**: actuation patterns do not apply, but the sustained-unavailability notification pattern still applies to downstream automations consuming their sensor data.

---

## Pattern Checklist

- [ ] Recovery trigger present (`from: [unavailable, unknown]`, valid `to:` states for the domain)
- [ ] Recovery trigger ID included in every actuation branch's trigger ID gate
- [ ] Branch condition state list includes `unavailable` and `unknown` alongside the opposite binary state
- [ ] All service calls have `continue_on_error: true`
- [ ] Confirmation `wait_template` after every service call with `continue_on_timeout: true`
- [ ] Single retry on failed confirmation
- [ ] Persistent notification on unconfirmed failure after retry (stable `notification_id`)
- [ ] Persistent notification on sustained unavailability (stable `notification_id`, tuned `for:` threshold)
- [ ] Auto-dismiss on recovery for all notifications
- [ ] No corrective actuation during sustained unavailability — recovery trigger handles it
- [ ] `ha_restart` trigger present, using `timer.ha_startup_delay` with randomized stagger

## See Also

- `/guides/integration_watchdog.md` — Integration-level recovery via config entry reload; complements this guide when the integration itself needs recycling, not just the command retried
- `/patterns/integration_degradation.md` — Sensor-side degradation, staleness, and source tiering for cloud-backed template sensors
- `/patterns/restart_resilience.md` — Startup delay and stagger patterns
- `/spec/notifications.md` — Notification ID conventions and auto-dismiss discipline
- `/guides/system_impact_class.md` — Impact classification; Class A/B systems warrant stricter confirmation thresholds
