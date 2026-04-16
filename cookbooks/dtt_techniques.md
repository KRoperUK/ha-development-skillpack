# Developer Tools Template (DTT) Techniques

## Entity pre-flight validation

Run before any other DTT validation. One `has_value()` call per
entity used in the artifact — no exceptions:

```jinja
{# Pre-flight: validate all entities used in this artifact #}
{{ has_value('sensor.rob_s_bedroom_temp') }}
{{ has_value('binary_sensor.front_door') }}
{{ has_value('input_boolean.guest_mode') }}
```

All lines should return `true` under normal operating conditions.
If any return `false`, determine whether this reflects a naming or
reference issue or a valid transient state before proceeding.

If a naming issue is suspected, attempt discovery before stopping:

```jinja
{# Surface candidates by area, label, or integration #}
{{ area_entities('Rob\'s Bedroom') | list }}
{{ label_entities('climate') | list }}
{{ integration_entities('zwave_js') | list }}
```

If discovery surfaces the correct name, update and re-run pre-flight.
If not, stop and request the validated name — do not guess, infer,
or normalize spelling by assumption.

See `guides/dtt_first_validation.md` for the full entity validation
doctrine including usable-state vs. existence distinction.

---

## Batch queries (default approach)

Validate logic in a single combined DTT expression that matches the
real decision path. This is the default — not an optimization.
Fragmented checks hide interaction failures and produce false
confidence. See `guides/dtt_first_validation.md` for full doctrine.

Break into smaller expressions only when a technical constraint
prevents combination. Convenience and readability are not valid
reasons to split.

**Good** (one query, all related outputs):

```jinja
{# Validate: sources, tiers, safe defaults, and state outcome together #}
Primary: {{ states('sensor.api_data') }}, Proxy: {{ has_value('binary_sensor.local_witness') }}
Tier: {% if states('sensor.api_data') != 'unavailable' %}primary{% elif has_value('binary_sensor.local_witness') %}proxy{% else %}default{% endif %}
Safe value: {{ states('sensor.api_data') | float(0) if states('sensor.api_data') != 'unavailable' else 0 }}
{{ { 'all_checks': true, 'ready_for_deploy': true } | tojson }}
```

**Bad** (atomic tests, context lost):

```
Query 1: {{ states('sensor.api_data') }}
Query 2: {{ has_value('binary_sensor.local_witness') }}
Query 3: {{ states('sensor.api_data') | float(0) }}
```

---

## Mock variables for state simulation

Use temporary `{% set %}` variables to simulate entity states that
are not currently live — unavailable sensors, startup conditions,
degraded integrations — without modifying real entities.

This is the preferred technique when current live state is favorable
but your expectations include failure paths.

```jinja
{# Simulate: primary unavailable, proxy available #}
{% set mock_temp = 'unavailable' %}
{% set mock_fallback = '72.5' %}

Result: {{ mock_fallback | float(0) if mock_temp == 'unavailable' else mock_temp | float(0) }}
Safe default applied: {{ mock_temp == 'unavailable' }}
```

Mock variables substitute for `states()` calls during logic
validation only — replace them with real entity references before
deployment. Never ship `{% set mock_* %}` variables in production
artifacts.

---

## Inspect basics

```jinja
{{ states('sensor.power') | float(0) }}
{{ state_attr('light.kitchen','brightness') | int(0) }}
```

---

## Check availability & normalize

```jinja
{% set ok = has_value('sensor.foo') %}
{% set cond = states('sensor.condition') | lower | trim %}
```

---

## Package debug JSON

```jinja
{{ {
  'export_w': states('sensor.solar_export_3m_avg') | float(0),
  'buy': states('sensor.energy_buy_rate') | float(0)
} | tojson }}
```

---

## Avoid Python methods (use Jinja filters instead)

**`.items()`** → use `dict2items` filter:

```jinja
{% for p in (d | dict2items) %}{{ p.key }}={{ p.value }}{% endfor %}
```

**`.get(key, default)`** → use bracket access with `default` filter:

```jinja
{% set val = d['temperature'] | default(72, true) %}
```

Or for HA attributes (not dict access):

```jinja
{% set val = state_attr('sensor.payload', 'temperature') | default(72, true) %}
```

**`.split(sep)`** → use `split()` filter:

```jinja
{% set parts = states('sensor.csv_data') | split(',') %}
{{ parts[0] if (parts | length) > 0 else '' }},
{{ parts[1] if (parts | length) > 1 else '' }}
```

**`.append(item)`** → use list concatenation (reassign—lists don't
mutate in place):

```jinja
{% set xs = xs + ['c'] %}
```

**`.lower()` / `.upper()`** → use filters:

```jinja
{% set s = states('sensor.foo') | lower %}
```

**`len(x)`** → use `| length` filter:

```jinja
{% if (parts | length) > 1 %}...{% endif %}
```

---

## Time math (safe)

```jinja
{% set lc = states['sensor.foo'].last_changed if states['sensor.foo'] is not none else none %}
{% set age = (as_timestamp(now()) - as_timestamp(lc)) if lc else none %}
```

---

## Testing with Unavailable/Degraded Entities

Test graceful degradation in DTT by querying your full template
logic in one batch (see "Batch queries (default approach)"). Use
mock variables (see "Mock variables for state simulation") to
simulate missing or malformed data, then verify in one shot:

- Sensor stays available (doesn't cascade failure)
- `data_quality` and `reasoning` accurately reflect which tier is active
- Safe defaults applied (`| float(0)`, `| from_json(default=[])`)
- Downstream sensors still render without errors

**Example (batch query with mocks)**:

```jinja
{# Test: primary API down, proxy available; fetch all outcomes in one query #}
{% set mock_primary = 'unavailable' %}
{% set mock_proxy = 'on' %}
{% set mock_age_s = 450 %}
{% set is_stale = mock_age_s > 300 %}

Primary available: {{ mock_primary != 'unavailable' }}
Is stale: {{ is_stale }}
Active tier: {% if mock_primary != 'unavailable' and not is_stale %}primary{% elif mock_proxy in ['on', true] %}proxy{% else %}default{% endif %}
Safe default: {{ 0 if mock_primary == 'unavailable' else 42 }}
Data quality: {% if mock_primary != 'unavailable' and not is_stale %}fully_operational{% elif is_stale %}degraded_stale{% elif mock_proxy in ['on', true] %}degraded_proxy{% else %}no_data{% endif %}
{{ { 'test_matrix': ['primary_only', 'primary_stale', 'primary_proxy', 'all_down'], 'ready': true } | tojson }}
```

**Test matrix**: Run one query per scenario (primary only,
primary+stale, primary+proxy, all down). Verify state,
`data_quality`, and safe defaults together. DTT validates logic,
not timing or race conditions — validate behavior in real runtime
after logic checks pass.
