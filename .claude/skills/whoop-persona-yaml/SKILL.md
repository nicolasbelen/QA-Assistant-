---
name: whoop-persona-yaml
description: >-
  Recommends personas and generates Persona Service / AI Studio YAML (cycles +
  service_data) using inputs/persona examples. Use for /whoop-persona-yaml,
  persona YAML, AI Studio test users.
---

# Persona YAML

Recommend and generate persona YAML files for testing a feature using Persona Service / AI Studio.

## Inputs

The user may provide:

- A feature description, PRD link, or list of test scenarios
- Nothing — ask for the feature or scenario context before proceeding

## Steps

### Phase A — Recommend personas (always do this first)

1. Read `docs/PERSONA_YAML_REFERENCE.md` and `docs/PERSONA_SCHEMA_REFERENCE.md`.
2. Get the feature context: fetch the PRD from Confluence via MCP if a link/key was provided; otherwise use the user's description.
3. Derive **user states** from the PRD or scenarios:
   - Subscription tier (ONE, PEAK, LIFE)
   - Gender / menstrual cycle phase (if relevant)
   - Feature flags required
   - Existing biomarkers / service data (healthspan, advanced-labs, vo2max, etc.)
   - Locale, onboarding state, permissions
4. Propose a **short list** of personas. For each, include:
   - Name (descriptive slug, e.g. `female-follicular-flag-on`)
   - Purpose (which branches / scenarios it covers)
   - High-level `service_data` needs
   - Any assumptions
5. Ask: **"Shall I generate YAML for these N personas?"** Any affirmative reply proceeds. List assumptions clearly.

### Phase B — Generate YAML (after confirmation)

1. Check `inputs/persona/` for a **full example** (cycles + service_data). Use `complete-persona-minimal-template.yaml` as the base if no richer example exists.
   - If no full example with `cycles` exists: **stop** and ask the user to provide one (export from AI Studio or copy `mockpersona.yaml` from persona-service).
2. For each persona:
   - Start from the full example's `cycles` and required top-level fields.
   - Set a unique `persona_key` (e.g. `qa-<feature>-<slug>`).
   - Customize `service_data` per persona from PRD + `inputs/persona/` examples.
   - Use only `service` / `data_class` / `data` structures from Confluence or `inputs/persona/` — do not invent field names.
   - Use **relative dates** (`start_date_days_ago`, `days_until_*`, etc.) — never hardcode absolute dates.
   - Do not include `clinical_intake` in advanced-labs-service data (validator rejects it).
   - Do not include `hidden` in health-service `PutMenstrualCyclesRequest`.
   - `ordered_skus` goes under `account_data`, not at root.
3. Save each persona to `outputs/persona/<feature>-<slug>.yaml`.
4. Output a short summary: one line per file — name and what the persona is for.

## Rules

- **Complete personas only**: every file must have `cycles` + `service_data` (plus required top-level fields).
- Prefer **fewer**, well-justified personas over many similar ones.
- If a service has no example in `inputs/persona/` or Confluence, say so and ask.
- Cite Confluence PersonaAdapter examples page when referencing service schemas:  
  https://whoopinc.atlassian.net/wiki/spaces/SW/pages/4747624609

Full policy: **`CLAUDE.md`** (repo root).
