# Persona YAML Schema Reference

Complete reference for the Persona YAML schema. **Omit any section you are not using**; only include required fields and the sections needed for your test scenario.

---

## Top-level fields

| Field | Required | Type | Default / Notes |
|-------|----------|------|-----------------|
| **persona_key** | ✓ | string | Unique identifier (alphanumeric, dashes, underscores only). Used to reference the persona. |
| **first_name** | | string | Default "Agneta". Random if omitted (faker). |
| **last_name** | | string | Default "El-Mahdi". Random if omitted. |
| **email_prefix** | | string | Custom email prefix; empty = auto-generated. |
| **birthday** | | array | Use birthday **or** age, not both. |
| **age** | | number | User age in years. Affects physiological baselines. |
| **fitness_level** | | string | Affects strain/recovery baselines. |
| **gender** | | string | Biological gender. Affects physiological baselines (e.g. heart rate, HRV). |
| **strap_type** | ✓ | enum | Default `HARVARD`. Options: UNKNOWN, KENMORE, COPLEY, HARVARD, GOOSE, MAVERICK. |
| **height** | ✓ | integer | Default `170` (cm). Used for BMI etc. |
| **pregnancy_due_date_days** | | integer | Days until due date (pregnant users only). |
| **most_recent_day_with_cycle_data** | | array | Most recent date for cycle data; defaults to today. Cycles generated backwards from this. |
| **journal_onboarding_completed** | ✓ | boolean | Default `true`. When true, journal features available without onboarding. |
| **all_feature_onboarding_completed** | ✓ | boolean | Default `false`. When true, skip all onboarding. |
| **cycles** | ✓ | array | Ordered list of daily cycle data. Each item: **PersonaCycleData**, **RobotCycleData**, or **EmptyCycleData**. |
| **cycles_repeat_count** | | integer | Number of times to repeat the cycles list for more history. |
| **week_plans** | ✓ | array | Week plan configs (first = current week). Target goals, activity goals, behavior goals. |
| **impacts** | | object | behavior_impacts, recovery_activity_impacts, auto_impacts. |
| **service_data** | ✓ | array | Custom service data (feature-flags, health-service, advanced-labs-service, etc.). See Confluence PersonaAdapter examples. |
| **account_data** | | object | Membership, billing, country. See below. **ordered_skus** lives here if needed, not at root. |

---

## cycles (required array)

Each element must include the **type discriminator** `cycle_type` so the parser can resolve the subtype:

- **`cycle_type: persona`** — PersonaCycleData (custom day: strain, sleep, recovery, steps, activities, behavior_inputs, optional per-cycle service_data).
- **`cycle_type: robot`** — RobotCycleData (`robot_data.s3_key` to load prebuilt dataset).
- **`cycle_type: empty`** — EmptyCycleData (no data for that day).

### PersonaCycleData (one day; use `cycle_type: persona`)

| Field | Required | Default / Notes |
|-------|----------|-----------------|
| **cycle_type** | ✓ | Must be `persona` for this subtype. |
| **day_strain** | ✓ | number, default 12. |
| **sleep** | ✓ | object. See Sleep below. |
| **recovery** | ✓ | object. See Recovery below. |
| **steps** | | integer; omit to not track steps. |
| **stress** | | object (base_score, variance, hours, stress_patterns). |
| **weight_details** | | object (weight_kg, weight_source, etc.). |
| **activities_for_day** | ✓ | array (can be `[]`). Each: type, start_time, duration, strain, average_heart_rate, etc. |
| **behavior_inputs** | ✓ | array (can be `[]`). Each: behavior_tracker_internal_name, answered_yes, magnitude_input_value. |
| **cycle_date** | | array (ISO date) to pin cycle to exact date. |
| **service_data** | | array (per-cycle service data; optional). |

### Sleep (required object inside cycle)

Include only if using PersonaCycleData. Key fields (all have defaults):
`sleep_score`, `cycles_count`, `disturbances`, `in_sleep_efficiency`, `respiratory_rate`, `normal`, `significant`, `projected_sleep_hours`, `projected_score`, `time_in_bed_hours`, `quality_duration_hours`, `arousal_time_hours`, `credit_from_naps_hours`, `debt_post_hours`, `debt_pre_hours`, `habitual_sleep_need_hours`, `latency_hours`, `light_sleep_duration_hours`, `need_from_strain_hours`, `rem_sleep_duration_hours`, `sleep_need_hours`, `slow_wave_sleep_duration_hours`, `wake_duration_hours`, `no_data_duration_hours`, `total_wake_events`. Optional: `optimal_sleep_times`.

### Recovery (required object inside cycle)

Include only if using PersonaCycleData. Key fields:
`recovery_score`, `resting_heart_rate`, `hrv`, `spo2`, `hr_baseline`, `rhr_component`, `hrv_component`, `normal`, `history_size`, `recovery_rate`, `skin_temperature`, `hrv_rmssd`. Optional: `prob_covid`.

---

## week_plans (required array)

First item = current week; rest = past weeks. Each item can include:
`preset_plan_name`, `create_target_goal_requests`, `create_activity_goal_requests`, `create_behavior_goal_requests`.
Omit or use minimal `{}` if not testing week plans.

---

## account_data (optional)

| Field | Required | Default / Notes |
|-------|----------|-----------------|
| **country_code** | ✓ | string, default "US". |
| **province** | | default "MA". |
| **membership_type** | ✓ | enum: SUBSCRIBER, NON_ADMIN_FAMILY_MEMBER, ELITE. Default ELITE. |
| **membership_tier** | ✓ | enum: ONE, PEAK, LIFE. Default PEAK. |
| **renew_subscription_immediately** | ✓ | boolean, default false. |
| **active** | | boolean. |
| **billing_type** | | STANDARD, FOUNDING_MEMBER, FAMILY_ADMIN. |
| **billing_status** | | PENDING, TRIALING, ACTIVE, PAUSED, etc. |
| **billing_currency** | | aed, aud, eur, usd, gbp, cad, nzd, etc. |
| **billing_renewal_cadence** | | MONTHLY, ANNUAL. |
| **billing_renewal_seconds_from_now** | | integer. |
| **activation_days_ago** | | default 0. |
| **initial_commitment_days** | | default 0. |
| **initial_membership_days** | | default 0. |
| **ordered_skus** | ✓ | array (required when using account_data; not valid at root level). |

---

## service_data (required array)

List of service payloads. Each item: `service`, `data_class`, `data`; optional per-item: `cycle_date`, `cycle_id`, `sleep_id`.
Available services (examples): blood-pressure-service, ai-experiences-service, context-service, feature-flags, healthspan-service, health-service, milestones-service, hr-zones-service, vo2max-service, arrhythmia-service, persona-service, advanced-labs-service, streaks-service, coaching-service, weightlifting-service.
See Confluence PersonaAdapter examples (https://whoopinc.atlassian.net/wiki/spaces/SW/pages/4747624609) for exact `data_class` and `data` shapes.

**Validation notes (AI Studio / persona validator):**
- **ordered_skus** is not valid at root level; use under `account_data` if needed.
- **health-service** `PutMenstrualCyclesRequest`: do not include `hidden` in `data`.
- **advanced-labs-service** `AdvancedLabsPersonaDataUploadRequest`: do not include `clinical_intake` in `data` (validator rejects it even if present in some Confluence examples).

---

## impacts (optional)

- **behavior_impacts** (array): journal_behavior_name, yes_count, no_count, impact_value, typical_impact_value, eligibility.
- **recovery_activity_impacts** (array): recovery_activity_name, yes_count, no_count, impact_value, typical_impact_value, eligibility.
- **auto_impacts** (array): name (e.g. CONSISTENT_BED_TIME, STRAIN), treatment, yes_count, no_count, impact_value, eligibility.

Omit entire section if not testing impacts.
