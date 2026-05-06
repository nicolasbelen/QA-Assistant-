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
- **Creating or editing Jira test issues via Atlassian MCP** (e.g. `createJiraIssue`, `editJiraIssue`) does **not** populate the **Xray section** (e.g. Gherkin scenarios). Xray uses its own REST API and custom fields; the current Atlassian MCP exposes Jira core/issue fields only.
- **Preferred workflow:** Generate **Xray-compatible CSV** (including a `gherkin` column) in `outputs/xray/`, then use **Xray's CSV import** in Jira to create/update test cases with Gherkin.
- **Optional — set Gherkin via script:** If this workspace includes `scripts/xray-set-gherkin.sh` and the user has set `JIRA_EMAIL` and `JIRA_API_TOKEN` (and optionally `XRAY_GHERKIN_FIELD_ID`), the agent can run the script to push Gherkin to an existing Test. (Scripts are not bundled here by default; copy from **Test-Case-Designer** if needed.)

## Xray/Jira export defaults
- projectKey (required for CSV export): SQA
- Priority mapping:
  - P1 = Critical
  - P2 = High
  - P3 = Normal

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
