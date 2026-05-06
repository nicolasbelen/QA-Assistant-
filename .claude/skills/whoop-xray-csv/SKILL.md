---
name: whoop-xray-csv
description: >-
  Builds validated WHOOP Xray CSV from markdown tests: comma delimiter matching
  inputs/xray-test-case-importer-config.json, Jira priority names, semicolon
  labels, optional requirementIssueKey. Use for /whoop-xray-csv, CSV import, or
  fixing Xray importer errors.
---

# Xray CSV

Convert a markdown test suite to a validated, Xray-ready CSV.

## Inputs

The user may provide:

- A path to a markdown test file (e.g. `outputs/my-feature-test-cases.md`)
- The most recently generated test table in the conversation
- Nothing — ask which source to use

## Steps

1. Read `.claude/QA_AGENT_CONTEXT.md` for: `projectKey`, Jira priority scheme names, label conventions URL.
2. **Label conventions.** Fetch the Confluence URL from context (if present). Use only labels defined there. If inaccessible, note it and ask the user to verify labels before import.
3. **Load importer config** (this repo): `inputs/xray-test-case-importer-config.json` (7 columns, **comma** `,` as CSV column delimiter) or `inputs/xray-test-case-importer-config-8col-with-requirement-link.json` when `requirementIssueKey` is used. **Importer Setup → CSV Delimiter** must match the file (`comma` for these templates). See `inputs/XRAY_IMPORTER_README.md`.
4. **Build the CSV.** Minimum columns:

   `projectKey`, `testType`, `summary`, `description`, `gherkin`, `priority`, `labels`

   Add `requirementIssueKey` (and `requirementIssueKey2`, …) if the user provides Jira story/feature keys. Map in Xray to **`Link Test "is tested by" (inward)`** — see `docs/XRAY_CSV_REQUIREMENT_LINKS.md`.

   Rules:

   - UTF-8, correct CSV quoting (commas/newlines inside quoted fields; `""` for escaped quotes)
   - **Column delimiter:** **comma (`,`)** for WHOOP templates in `inputs/` — user must set the same in Xray importer. (Xray’s *tutorial* semicolon CSVs are a different shape; if you emit semicolon-separated columns, set importer delimiter to `;` instead.)
   - **Labels inside one cell:** semicolon-separated: `smoke;regression`; quote the field if the cell contains `;` and could be ambiguous.
   - **Priority:** Jira scheme names from context (e.g. `Critical`, `High`, `Normal`) — not `P1`/`P2`/`P3` unless the importer maps them.
   - **gherkin:** `Feature:` / `Scenario:` with Given/When/Then
   - **description:** PRD source (title + URL) and requirement key(s) covered

5. **Normalize (optional).** If `scripts/xray-csv-normalize-for-import.py` exists in the workspace, run it per `scripts/README.md`. This repo does not bundle scripts by default.

6. **Validation checklist before declaring done:**

   - [ ] No partial rows, all required cells filled
   - [ ] UTF-8, valid quoting
   - [ ] Priority values match Jira scheme
   - [ ] Labels verified against org doc (or flagged for user verification)
   - [ ] `requirementIssueKey` column present only if keys were provided; mapping doc read

7. **Review summary.** Print counts by priority / type / area.
8. Ask the user to **confirm** before upload.

## Output

Save to `outputs/xray/<feature>-test-cases.csv`.

Full policy: **`CLAUDE.md`** (repo root).
