# Xray Test Case Importer — saved configuration

## File

- **`xray-test-case-importer-config.json`** — Intended layout for WHOOP **SQA** and our **7-column comma CSV** (delimiter `,`, list delimiter `;` in Setup).

## CSV column order (0-based indexes in JSON)

| Index | CSV column (example header) | Maps to |
|------|-----------------------------|---------|
| 0 | `projectKey` | Project key |
| 1 | `testType` | Xray Test Type |
| 2 | `summary` | Summary |
| 3 | `description` | Description |
| 4 | `gherkin` | Gherkin definition |
| 5 | `priority` | Priority (Native) |
| 6 | `labels` | **Labels (Jira – Native)** |

- **List delimiter (Setup):** semicolon (`;`) — use `label-a;label-b` inside the **labels** cell.

---

## Why Labels might still show “Don’t map” after loading JSON

[Xray Cloud’s docs](https://getxraydocs.atlassian.net/wiki/spaces/XRAYCLOUD/pages/44565062/Importing+Tests+using+Test+Case+Importer) describe the saved file as coming from **“the last import made with this file or a similar one.”** In practice:

1. **Load the config on the right step** — The wizard usually offers **“existing configuration”** on the **File import** step (same place as encoding + CSV delimiter), not only on Setup. If JSON is only applied partially, **Labels** may not pre-fill on Map fields.
2. **Hand-edited JSON is not guaranteed to match your site** — Xray Cloud may expect an **export produced by Xray** after you map fields once. Repo JSON is a best-effort template; internal IDs can differ by version.
3. **“Similar” CSV shape** — Column count/order should match what was used when the configuration was saved. Extra/missing columns can shift indices so index `6` is no longer `labels`.

---

## Reliable workflow (recommended)

1. Run the importer with your CSV (e.g. smoke sample).
2. On **Map fields**, set **labels** → **Labels (Jira – Native)** (and any other fields).
3. Complete the import (or cancel after verifying mapping if your flow allows).
4. **Export / save configuration** from Xray (exact control name varies: e.g. save settings for next import).
5. Replace **`inputs/xray-test-case-importer-config.json`** in this repo with that export so the team shares the **same file Xray generated**.

After that, loading **that** file on **File import** should restore **Labels** and the rest for **similar** CSVs.

---

## Checklist if auto-map still fails

- [ ] JSON selected on **File import** (encoding/delimiter step), not only later steps.
- [ ] CSV has **exactly seven** columns in the order above (no BOM-only extra column — avoid Excel “UTF-8 CSV” quirks if columns shift).
- [ ] Delimiter in JSON matches file: `"config.delimiter": ","`.
- [ ] Replace repo JSON with a fresh **export from your Jira** after a successful map (strongest fix).

---

## Changing project or layout

- Edit `config.project.key` if importing into another Jira project (and re-export from Xray when possible).
- If you add/remove/reorder CSV columns, **re-map in the UI once** and re-export JSON — don’t hand-edit `column.index` unless you’ve verified it against an Xray export.

---

## Requirement / feature traceability (8 columns + link)

To link each imported **Test** to a Jira **requirement / story / feature** issue (coverage / “is tested by” on the requirement side):

1. Add column **`requirementIssueKey`** after **`labels`** (column index **7** in zero-based order). Value = one issue key per row, e.g. `SQA-20336`.
2. On **Map fields**, map that column to the **Link** target used for **Tests** / requirement coverage (exact label depends on Xray version — see **`docs/XRAY_CSV_REQUIREMENT_LINKS.md`**).
3. **Map `requirementIssueKey`:** **`Link Test "is tested by" (inward)`** — confirmed for WHOOP SQA. Template JSON `inputs/xray-test-case-importer-config-8col-with-requirement-link.json` is best-effort; **export** config from Jira after a successful map and prefer that file.

The requirement issue must **already exist** in Jira; the importer only creates links, not the feature ticket.
