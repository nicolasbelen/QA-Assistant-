# Linking imported Xray tests to requirements (CSV)

Goal: when importing Tests with the [Xray Test Case Importer](https://getxraydocs.atlassian.net/wiki/spaces/XRAYCLOUD/pages/44565062/Importing+Tests+using+Test+Case+Importer), each row can create a **Jira issue link** from the **Test** to a **requirement / story / feature** issue. In the requirement’s **Traceability / Coverage** view, that shows as the test **testing** (covering) that requirement — often described as **“is tested by”** from the requirement side, depending on Xray/Jira wording.

This repo’s **comma CSV** layout adds an optional column **`requirementIssueKey`** (Jira key only, e.g. `SQA-20336`).

## Two-step workflow (yes — this is the intended pattern)

**New Feature** (and similar) are normal **Jira issue types**, not something the Xray Test Case Importer creates. Your flow is valid:

1. **Jira CSV import** — bulk-create **New Feature** (or Story, etc.) issues in project **SQA**. Jira assigns keys (`SQA-20336`, …).
2. **Xray Test Case Importer CSV** — put those keys in **`requirementIssueKey`** so each **Xray Test** links to the right feature. On the feature issue, **Linked work items → is tested by** lists those tests (as in your **SQA-20336** view).

Optional extras (not bundled in this slim repo): Jira CSV samples and a step-by-step **Jira CSV → Xray CSV** workflow can be copied from the **Test-Case-Designer** template repository (`docs/JIRA_CSV_NEW_FEATURES_WORKFLOW.md`, `inputs/jira-csv-import-new-features-sample.csv`, `inputs/jira-csv-new-features-trial-2rows.csv`).

Use Jira’s [CSV issue import](https://support.atlassian.com/jira-cloud-administration/docs/import-issues-from-a-csv-file/) and map columns in the wizard; **Issue Type** must match the project exactly (e.g. **`New Feature`**, as on [SQA-20336](https://whoopinc.atlassian.net/browse/SQA-20336)).

If the project has **required fields** (Component, etc.), add columns for them or the import will fail — check the **New Feature** create screen in Jira.

## What the Xray test CSV does *not* do

- The **Xray** importer does **not** create **New Feature** / requirement issues — only Tests (and related Xray types). Use **Jira’s** importer for requirements.
- It does **not** replace Xray **Test Executions** or **Test Plans**; it only adds **issue links** used for coverage.

## Column and value

| CSV column (header) | Example value | Meaning |
|---------------------|---------------|---------|
| `requirementIssueKey` | `SQA-20336` | One Jira issue key per row: the requirement/story this test should cover. |

- Use the **project key + number** exactly as in Jira (`SQA-20336`, not a URL).
- If one test must cover **several** requirements, Xray’s documentation states you can use **multiple CSV columns**, each mapped to the same link type (see [Link fields](https://getxraydocs.atlassian.net/wiki/spaces/XRAYCLOUD/pages/44565062/Importing+Tests+using+Test+Case+Importer) § 2.1.6.11). Add e.g. `requirementIssueKey2`, `requirementIssueKey3` with the same mapping.

Official semicolon-style sample with a link column: [import_manual_gherkin_automated_tests_links.csv](https://raw.githubusercontent.com/Xray-App/tutorial-test-case-importer/main/cloud/import_manual_gherkin_automated_tests_links.csv) (column `Links` → issue key `EWB-39`).

## Map fields (Xray UI)

1. Import your CSV as usual (encoding UTF-8, delimiter matching your file — comma for repo exports).
2. On **Map fields**, map **`requirementIssueKey`** to a **Link** target — **not** under the **XRAY** block that lists *Issue ID*, *Test Type*, *Gherkin Definition*, etc.

### Do **not** use these for `requirementIssueKey`

| What you might see | What it actually is | Why `SQA-20336` fails |
|--------------------|---------------------|------------------------|
| **Issue key** (Native / Jira) | Identifies an **existing Test** issue to **update** on import | Expects a **Test** key, not a New Feature / Story |
| **Issue ID** (Xray) | **Test case identifier** to **group CSV rows** into one manual test (same id = same test) | Expects your internal id (e.g. `1`, `TC-01`), **not** a Jira requirement key |

Those fields are documented for different jobs; they will **not** create **requirement coverage** links.

### What **to** map

Scroll the same dropdown to **Link** / **Issue links** (not the **XRAY** block with *Issue ID*, *Gherkin*, etc.).

**Confirmed for WHOOP (`whoopinc.atlassian.net` / SQA, Xray Test Case Importer):** map **`requirementIssueKey`** to:

- **`Link Test "is tested by" (inward)`**

After import, the **requirement / New Feature** issue (e.g. `SQA-20336`) should list the new tests under **Linked work items → is tested by**.

It is **not** *Gherkin Definition*, *Issue ID*, or *Issue key* (update existing test).

If the list is long, use search/filter or expand **Link** vs **XRAY** until you see the **Link Test** entries.

### Other Jira / Xray instances (inward vs outward)

The same relationship can appear under two names (**tests** vs **is tested by**) and **inward** vs **outward**. If **`Link Test "is tested by" (inward)`** is wrong on another site, try **`Link Test "tests" (outward)`** with the same requirement key column — only one orientation should show coverage correctly on the requirement. See also [StackOverflow: requirement linkage via importer](https://stackoverflow.com/questions/71411388/requirement-status-not-updating-when-the-linkage-is-created-via-test-importer).

3. If status on the requirement does not update after import, check Xray project settings (**coverable issue types**, indexing). See e.g. [this discussion](https://stackoverflow.com/questions/71411388/requirement-status-not-updating-when-the-linkage-is-created-via-test-importer).

## Hierarchy: feature vs granular requirements

- **All tests → one feature issue:** put the same key (e.g. `SQA-20336`) in `requirementIssueKey` on every row.
- **Tests → specific acceptance criteria / sub-requirements:** use a **different Jira issue key per row** (each sub-requirement must exist as an issue). The **parent feature** can still be a separate Epic/Story; linking strategy is a process choice (link only leaves, or link both parent and child using two columns).

## Importer JSON

Hand-edited `jira.field` entries for **Link** types are easy to get wrong. After you map **`requirementIssueKey`** once successfully, **export** the importer configuration from Jira and replace or merge into `inputs/xray-test-case-importer-config-8col-with-requirement-link.json` (see `inputs/XRAY_IMPORTER_README.md`).

## Sample file

Add a smoke CSV under `outputs/xray/` after your first successful link import, or copy `xray-import-with-requirement-link-sample.csv` from the **Test-Case-Designer** template repo.
