---
name: whoop-test-cases
description: >-
  WHOOP QA test suite from PRD, doc, or chat: baseline dedupe per feature,
  mandatory coverage estimate, markdown table, optional dual Xray CSV. Use for
  /whoop-test-cases, test cases, coverage estimate, or Xray-ready tests.
---

# Test cases

Generate a complete, PRD-grounded test suite for a feature or flow.

## Inputs

The user may provide:

- A Confluence PRD title, URL, or Jira key
- A description of the feature/flow in chat
- A file path to a checklist, bug bash, or flow doc
- Path to **this feature’s** baseline CSV (see context file)

## Steps

1. Read `.claude/QA_AGENT_CONTEXT.md` (`projectKey`, priority names, Confluence space, label conventions URL).
2. **Get the PRD or flow.** Use Atlassian MCP for Confluence, or read the user’s file / chat description. Ask if nothing was provided.
3. **Baseline (per feature only).** Baselines are **not** shared across features.
   - Ask whether a baseline CSV exists for **this** feature (convention: `inputs/<feature-name>-existing-tests.csv`, or any path the user gives).
   - If the file exists, scan for duplicate **intent** (same scenario, different wording) and avoid duplicates; reuse tag/folder/type conventions from the CSV.
   - If no baseline exists, say so and proceed with net-new tests.
4. **Coverage estimate first** — before writing any tests, produce:
   - Identified user journeys / flows
   - UX states and branches (toggles, permissions, empty states, errors)
   - Field types and validations
   - Platforms / surfaces if stated
   - Proposed target test count (range) + rationale
   - Missing information still needed  
   Then ask: **"Shall I proceed to generate the full test suite?"** Any affirmative reply ("yes", "go ahead", "looks good", "proceed") is confirmation. Do not generate the full suite until confirmed.
5. **Generate tests.** Produce a markdown table:

   | ID | Title | Preconditions | Steps | Expected Result | Test Data | Priority | Type |

   Cover: happy paths, error states, onboarding/first-use, edge cases (cancel/back, offline, boundaries).  
   Always include negative and boundary cases.  
   Apply **Special handling** from **`CLAUDE.md`** (required vs optional inputs, boundaries, date/time/currency, i18n, accessibility, analytics if the PRD implies it).

6. **Coverage map.** After the table, add a short map: which requirement/AC → which test IDs.

7. **Label conventions.** If `.claude/QA_AGENT_CONTEXT.md` lists a **Label conventions** Confluence URL, fetch it via MCP and use only labels defined there. If the page is inaccessible, use sensible labels and note that the user must verify them before import.

8. **Dual output (when the user wants files in this repo).** In addition to the table in chat:
   - Save review markdown to `outputs/<feature>-test-cases.md` (Summary, Description, Gherkin, Priority, Labels per case in readable sections, or embedded table + Gherkin blocks).
   - Save Xray CSV to `outputs/xray/<feature>-test-cases.csv` following **`whoop-xray-csv`** / **`CLAUDE.md`** (*Xray CSV*): comma file delimiter for this repo’s `inputs/xray-test-case-importer-config.json`, Jira priority **names** in `priority`, semicolons inside `labels`, UTF-8 quoting.

9. End with **Assumptions** and **Open Questions / Risks**.

## Output

- Cite PRD page title + URL in every deliverable.
- Priority: use human labels (P1/P2/P3) in markdown; use Jira priority scheme names (e.g. Critical, High, Normal) in CSV.

Full policy: **`CLAUDE.md`** (repo root).
