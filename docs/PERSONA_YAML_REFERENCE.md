# Persona YAML Reference

This doc summarizes the **persona YAML** format used by Persona Service / AI Studio to create test users with the right state and data. Use it when recommending personas or generating YAML files.

## What persona YAML does

A **complete** persona YAML has two main parts:

1. **Cycles** (and any other base user data): WHOOP cycle/sleep/strain/HRV data that defines the user's "device" state. This is required for Persona Service to create a valid user. Structure comes from persona-service (e.g. `TestUser`, `FakeCycleRequest`, `FakeActivity`) and is typically generated from the PersonaData Google Sheet or AI Studio, or copied from `persona-service` `test-users` (e.g. `mockpersona.yaml`).
2. **service_data**: A list of service + data-class + payload that Persona Service uses to call each service's `addUserData` (PersonaAdapter) — feature flags, health-service menstrual data, advanced-labs, etc.

**Important:** YAML that contains only `service_data` is **not** a complete persona. The agent must include the **cycles** (and other required top-level fields) when generating persona files.

**Schema and template:** The full Persona YAML schema and a minimal valid template are in:
- **Schema reference:** `docs/PERSONA_SCHEMA_REFERENCE.md` (all top-level fields, cycles, week_plans, account_data, service_data; omit sections you are not using).
- **Minimal template:** `inputs/persona/complete-persona-minimal-template.yaml` (required fields + one cycle with sleep/recovery; copy and add your `service_data`).

## Top-level structure (complete persona)

```yaml
# 1. CYCLES (required) — structure from persona-service / AI Studio / full example in inputs/persona/
cycles:   # or the key used in your persona-service (e.g. single_cycles, cycle_requests, etc.)
  # ... WHOOP cycle/sleep/strain/HRV data per persona-service schema ...

# 2. SERVICE_DATA (required) — PersonaAdapter payloads per service
service_data:
  - service: <service-name>
    data_class: <RequestClassName>
    data:
      # ...
  - service: ...
    data_class: ...
    data: ...
```

- **cycles**: Use the structure from `docs/PERSONA_SCHEMA_REFERENCE.md` and `inputs/persona/complete-persona-minimal-template.yaml` (PersonaCycleData with sleep + recovery + activities_for_day + behavior_inputs). Or copy from a full example in `inputs/persona/`.
- **service**: Logical service name (e.g. `feature-flags`, `health-service`, `advanced-labs-service`).
- **data_class**: Exact request class name used by that service's PersonaAdapter.
- **data**: Map of field names to values matching the schema for `data_class`. Use **relative** dates where possible (see below).

## Date and time conventions

- Prefer **relative** values so personas work regardless of when they're run:
  - `start_date_days_ago`, `days_until_*`, `test_date_days_ago`, `upload_date_days_ago`, `created_days_ago`, etc.
- Avoid hardcoded absolute dates unless the schema requires them.

## Where to get exact schemas and examples

- **Complete persona (cycles + service_data):**
  You **must** have at least one **full** persona YAML in `inputs/persona/` that includes the **cycles** section (e.g. copy `mockpersona.yaml` from persona-service `persona-service-jobs/src/test/resources/test-users/` or `persona-service-common/src/main/resources/test-users/`, or export from AI Studio). The agent will reuse that cycles structure and only vary `service_data` when generating new personas.
- **Confluence — PersonaAdapter examples** (service_data snippets only):
  https://whoopinc.atlassian.net/wiki/spaces/SW/pages/4747624609
- **Implementing the PersonaAdapter** (how services expose schema + addUserData):
  https://whoopinc.atlassian.net/wiki/spaces/SW/pages/4434887557
- **Persona Service Expansion** (overview, PersonaAdapter model, QA):
  https://whoopinc.atlassian.net/wiki/spaces/SW/pages/4378034244
- **Deprecated — User Creation / mockpersona** (references TestUser, FakeCycleRequest, test-users):
  https://whoopinc.atlassian.net/wiki/spaces/SQ/pages/4299391497

## Mapping test scenarios to personas

1. From the feature/PRD, list **user states** that affect behavior: subscription, gender/cycle phase, feature flags, existing biomarkers, whoop age, locale, etc.
2. Group scenarios that need the **same** user state into one persona.
3. For each persona, include only the **service_data** entries needed for that state (e.g. one persona = "female + follicular" → health-service cycle + optional AL; another = "feature flag on" → feature-flags only).
4. Reuse **only** `service` / `data_class` / `data` structures that appear in the Confluence examples or in `inputs/persona/`; do not invent new fields or classes.

## Quick reference: services and data_classes (from Confluence)

| Service               | data_class (example)                          |
|-----------------------|-----------------------------------------------|
| feature-flags         | PersonaFeatureFlagRequest                     |
| health-service        | CycleStatsRequest, PutMenstrualCyclesRequest, PutPredictedNextPeriodWindowRequest |
| healthspan-service    | UpsertWhoopAgeRequest                         |
| vo2max-service        | UpsertVo2MaxScoreRequest, UpsertManualEntryRequest |
| hr-zones-service      | UpsertHrZoneTimesRequest                     |
| context-service       | PersonaSaveContextRequest                     |
| advanced-labs-service | AdvancedLabsPersonaDataUploadRequest          |
| coaching-service      | PersonaUpsertHealthMonitorAlertThresholdV2Request |
| milestones-service    | MarkAllMilestonesSeenRequest                  |

(Other services may exist; always cross-check with Confluence or `inputs/persona/` examples.)
