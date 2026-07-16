# Entity References

## Prefer entity_id over device_id

- **Always use `entity_id`** in triggers, conditions, actions, and service call targets.
- `device_id` is an internal registry identifier that changes silently when a device is removed and re-added (re-pair, coordinator swap, exclusion/inclusion). Automations break with no error — they simply stop executing.
- `entity_id` stability comes from the integration assigning a stable **`unique_id`**: the entity registry pins the `entity_id` to that `unique_id`, so it survives re-pairs. It changes only if a user manually renames the `entity_id` in the registry (renaming the *friendly name* does not change it). This is why the friendly/display name must never be used as an addressing handle.

## Never reference by display name

- Reference entities by `entity_id` (or, in integration code, `unique_id`) — never by the friendly/display name. Users can rename the registry name freely, and the registry name wins over any integration-supplied name.

## Disabled entities are not addressable

- A registry entity that is disabled (`disabled_by` = user, integration, or config entry) is **not added to Home Assistant** and cannot be referenced by an automation, script, or template until it is re-enabled. Referencing one behaves like referencing a missing entity: it reads as unavailable/None. Confirm the entity is enabled during entity pre-flight.

## Device automations are frozen — build on entities

- Device-automation triggers/conditions/actions are a UX convenience layer over ordinary state/event/service constructs and add no capability. New device automations are no longer accepted upstream. For new work, author against **entity state triggers, event triggers, and service actions** directly — this is also more stable and more explicit than device_id-based automations.

## Target selectors

- Use `entity_id` in `target:` blocks. Use `area_id`, `floor_id`, or `label_id` when the intent is broadcast control across a location or label group (e.g., turn off all lights in an area). Entity targets auto-resolve to their device/area; device targets auto-resolve to their area — target the narrowest level the action actually needs.
- Areas can carry a designated temperature and humidity entity plus a `floor_id`, `aliases`, and `labels`. When logic needs "the temperature of this area," read the area's designated temperature entity rather than hard-coding a specific sensor.

## ZHA button/remote exception

- Buttons and remotes that fire events only and have no state entity cannot use state triggers. For these, use a `zha_event` trigger with `device_ieee` (the hardware MAC address).
- Document in the automation `description:` that the trigger relies on a ZHA MAC address and must be updated if the physical device is swapped.
