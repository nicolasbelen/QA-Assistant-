# QA Agent Context (Source of Truth)

## Confluence PRD discovery
- Confluence site: whoopinc.atlassian.net
- Preferred PRD location (fill at least ONE):
  - Space key(s): SQ
  - PRD label(s): prd
  - PRD parent/ancestor page ID(s): <OPTIONAL>

## Label conventions
- Label conventions page: https://whoopinc.atlassian.net/wiki/spaces/SQ/pages/4579328348/How+to+Create+Test+Cases+in+Xray
- Always fetch this page via Atlassian MCP when assigning labels. Use only labels defined there.

## Existing test baseline (dedupe source)
- Baselines are **per-feature** — do not de-duplicate across features.
- Naming convention: `inputs/<feature-name>-existing-tests.csv`
- When generating tests for a feature, ask the user if a baseline exists for that specific feature before scanning.
- Example: `inputs/january-jumpstart-existing-tests.csv` (54 tests — January Jumpstart 2026)

## Xray / Jira — Gherkin and API
- Xray Cloud stores Gherkin in its own proprietary backend — **not** as a Jira custom field. No `customfield_XXXXX` exists for it; the Jira REST API cannot set it.
- **Automated workflow (preferred):** Use `/whoop-xray-upload` skill — creates Jira Test issues via Atlassian MCP and sets Gherkin via `scripts/xray-set-gherkin.sh` (Xray GraphQL API).
- **Manual fallback:** Generate CSV in `outputs/xray/`, upload via Xray Test Case Importer in Jira UI.
- **Gherkin API details:** Uses `updateGherkinTestDefinition` GraphQL mutation at `https://xray.cloud.getxray.app/api/v2/graphql`. Requires the **numeric Jira issue ID** (e.g. `538180`), not the key. Auth via Xray JWT (`XRAY_CLIENT_ID` + `XRAY_CLIENT_SECRET`).

## Xray/Jira export defaults
- projectKey (required for CSV export): SQA
- Priority mapping (SQA uses P0–P4 directly — do not map to Critical/High/Normal):
  - P1 = P1
  - P2 = P2
  - P3 = P3

## Output folder
- Write generated exports to: outputs/xray/

## Xray Test Case Importer (saved mapping)
- 7-column comma CSV + template JSON: `inputs/xray-test-case-importer-config.json` — load on **File import** in Xray; **Labels** may still need one manual map unless you use a JSON **exported from Xray** after mapping once. See `inputs/XRAY_IMPORTER_README.md`.
- **Tests → requirement (coverage):** optional column `requirementIssueKey`; map to **`Link Test "is tested by" (inward)`** in Xray (WHOOP confirmed). Guide `docs/XRAY_CSV_REQUIREMENT_LINKS.md`; 8-column JSON template `inputs/xray-test-case-importer-config-8col-with-requirement-link.json` — re-export from Jira after mapping.
- **Create requirement tickets first:** bulk **New Feature** via **Jira** CSV import, then put keys in Xray CSV `requirementIssueKey`. Optional Jira CSV samples + workflow doc: copy from **Test-Case-Designer** (`inputs/jira-csv-*.csv`, `docs/JIRA_CSV_NEW_FEATURES_WORKFLOW.md`) if you want guided trials in-repo.

## Persona YAML (Persona Service / AI Studio)
- Persona example YAMLs (templates for generation): inputs/persona/
- Persona output folder (generated persona YAMLs): outputs/persona/
- Reference doc: docs/PERSONA_YAML_REFERENCE.md
- Schema doc: docs/PERSONA_SCHEMA_REFERENCE.md
