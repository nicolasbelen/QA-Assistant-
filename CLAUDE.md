# WHOOP QA — PRD-grounded test design

**Portable instructions:** This document is **self-contained**. You do **not** need Cursor, `.cursor/rules/`, or any other editor config. When a companion file **`.claude/QA_AGENT_CONTEXT.md`** exists, read it **first** for org-specific keys, paths, and Confluence hints; if it is missing, ask the user for that information (see **Configuration you must have** below).

---

## Mission

Help QA produce **accurate**, **non-duplicative**, **PRD-grounded** artifacts: test cases, coverage thinking, risks/gaps/questions, **Xray-ready CSV**, and optionally **persona YAML**.

---

## Hard rules

1. **Do not guess requirements.** If PRD or acceptance criteria are not available, say so and ask for a Confluence link, issue key, or pasted goals/requirements/AC.
2. Prefer **Confluence** (or user-provided doc) over memory as the source of truth.
3. Label any guess as **Assumptions**.
4. In narrative outputs, always separate:
   - **Confirmed from PRD** (or source doc)
   - **Assumptions / suggestions**
   - **Open questions**
5. **Priority values in Xray CSV must match Jira priority scheme names exactly** (e.g. `Critical`, `High`, `Normal`) — `P1`/`P2`/`P3` will silently fail on import unless the importer maps them. If priority names are unknown, ask the user before generating CSV.

---

## Configuration you must have

Before PRD or test work, resolve:

| Item | Why |
|------|-----|
| Jira **`projectKey`** (e.g. `SQA`) | Required on every Xray CSV row |
| **Jira priority names** actually used by the project | CSV `priority` must match scheme names (often `Critical`, `High`, `Normal`) — not raw `P1` unless mapped |
| **Baseline tests CSV** path (if deduping) | Avoid duplicate test intent |
| **Confluence** space / label / ancestor (if using MCP search) | Narrow PRD search |

These defaults live in **`.claude/QA_AGENT_CONTEXT.md`** when present. If that file is absent, ask the user to supply the table above inline.

### QA_AGENT_CONTEXT.md — minimal template

If the user needs to create this file, use the following as the starting template (fill in all values before saving):

```markdown
# QA Agent Context

## Jira
projectKey: SQA                        # e.g. SQA, WHOOP
priorityNames: Critical, High, Normal  # exact names from Jira priority scheme
jiraBaseUrl: https://your-org.atlassian.net

## Confluence
spaceKey: QA                           # primary space to search for PRDs
labelFilter: prd                       # label used on PRD pages (if any)
ancestorPageId:                        # optional: ancestor page ID to narrow search

## Paths
baselineTestsCsv: inputs/existing_tests.csv
personaExamplesDir: inputs/persona/
```

---

## MCP setup (required for Confluence/Jira integration)

This agent uses the **Atlassian MCP** server to search Confluence and read Jira issues. Without it, every PRD retrieval step falls back to asking for a link or pasted content.

**One-time setup:** The Atlassian MCP server must be registered in your Claude Code settings (`~/.claude/settings.json` or the workspace `settings.json`). See the [Atlassian MCP documentation](https://github.com/sooperset/mcp-atlassian) for the server command and required environment variables (`CONFLUENCE_URL`, `CONFLUENCE_USERNAME`, `CONFLUENCE_API_TOKEN`, `JIRA_URL`, `JIRA_USERNAME`, `JIRA_API_TOKEN`).

Once configured, this agent will use MCP tools to search and fetch Confluence pages and Jira issues directly.

---

## Tools

- **Atlassian MCP** (configured in Claude Code settings): use **Confluence search + page fetch** for PRDs; use **Jira** operations only with awareness that **Xray Gherkin** may not populate via core Jira edit — prefer CSV import for tests with Gherkin.
- **Shell / scripts:** Only when the user's workspace includes them (e.g. `scripts/xray-csv-normalize-for-import.py`, `scripts/write-xray-cloud-smoke-csv.py`, `scripts/xray-set-gherkin.sh`). Otherwise describe the steps in prose.

---

## Confluence retrieval (PRDs, AC, label conventions)

When the task depends on PRDs, designs, or acceptance criteria:

1. Use **Atlassian MCP** (or user-provided link) to find the PRD. Apply constraints from **`.claude/QA_AGENT_CONTEXT.md`** if present (space key(s), label(s) such as `prd`, optional ancestor page id). If constraints are missing, search broadly and **ask the user to confirm** the correct page.
2. Fetch the **top 1–3** most relevant pages. Do not fetch dozens.
3. In every deliverable that uses the PRD, cite **page title** and **URL** (as returned by the tool).
4. If Confluence access **fails**, state that explicitly and ask for a **link** or **pasted** goals, requirements, and acceptance criteria.

---

## PRD summary format

When summarizing a PRD (markdown), use these headings:

- Overview
- Goals
- Non-goals
- Key Requirements
- Acceptance Criteria (verbatim or near-verbatim)
- Open Questions / Ambiguities
- QA Notes (high-risk areas, dependencies)

End with **PRD link(s)**.

**PRD summary workflow:** If title/link not provided, ask → search Confluence → fetch → write summary in this format → include links.

---

## Test cases — markdown table (review / lightweight)

When producing tests as a **table only** (no repo files), use:

| ID | Title | Preconditions | Steps | Expected Result | Test Data | Priority | Type (Functional/Negative/Regression) |

Rules:

- Prefer **fewer, higher-value** tests over many shallow ones.
- Include **negative** and **boundary** cases.
- If information is missing, add **Assumptions** at the bottom.

**From PRD — extra asks if missing:** PRD link/title, platforms (iOS/Android/Web/API), in/out of scope, environments (staging/prod) and feature flags, analytics/telemetry expectations.

**From PRD — steps:** find/fetch PRD → extract requirements + AC → fill table → add short **Coverage map** (which requirement → which test IDs) → assumptions and open questions.

---

## Baseline tests and de-duplication

- Baselines are **per-feature**. Ask the user if a baseline exists for the specific feature before scanning (e.g. `inputs/<feature-name>-existing-tests.csv`). Do **not** de-duplicate across features.
- If no baseline exists for this feature, say so; generate net-new tests and recommend they export one from Xray after import.
- When generating new tests: **scan** baseline for the same **intent** (even different wording) and **avoid duplicates**; **reuse** conventions for priority labels, tags, folder paths, and test types when visible in the baseline.
- **Persistence:** Treat a newly supplied export as the new baseline; if you maintain `.claude/QA_AGENT_CONTEXT.md`, update the baseline path there when it changes.

---

## Coverage estimate (mandatory before full test generation)

**Before** writing the full final test set, you **must** produce a **Coverage estimate** that includes:

- Identified user **journeys / flows**
- **UX states** and branches (toggles, permissions, empty states, error states)
- **Field types** and validations (date/time/numeric/currency)
- **Platforms** / surfaces (web/iOS/android/API) if stated
- Proposed **target test count** (a range is fine) + rationale
- **Missing information** you still need

Then ask explicitly: **"Shall I proceed to generate the full test suite?"**

Any affirmative reply ("yes", "go ahead", "looks good", "proceed") counts as confirmation — do **not** ask again. Do **not** produce the full final suite until the user confirms (unless they already confirmed in the same message as the request).

While reading any source, flag ambiguities, conflicts, missing AC, or unclear edge cases as **Open Questions / Risks**.

---

## Test generation — sources

Use **one** of these (or combine):

| Source | Action |
|--------|--------|
| **PRD in Confluence** | Retrieve per **Confluence retrieval** above, then coverage estimate → confirmed tests. |
| **Flow / Bug Bash / checklist / PDF** | Read from the path or attachment the user provides. |
| **Flows described in chat** | Treat as requirements; clarify main flow and variants. |

---

## Test generation — scope (what to cover)

For each feature or flow:

- **Happy paths** — all important variants
- **Error states** — validation, invalid input, server/network, expired links, etc.
- **Onboarding / first use** — visibility, clarity
- **Edge cases** — cancel/back, modals, deeplinks, offline, boundaries

Weave in **Special handling** (next section) wherever the PRD implies those concerns.

---

## Labels (Xray / QA conventions)

- Before assigning labels, **try** to locate the Confluence page that defines **test/Xray label** conventions (same search tools as PRDs). Use **only** labels that match that doc.
- If that doc cannot be found, use **sensible** labels and **state clearly** in the deliverable that the user must verify labels against their org's label doc **before** Xray import.

---

## Each test case — required fields (for markdown + CSV)

- **Summary** — short, unique title
- **Description** — what is verified; **source** (PRD title + URL); Figma if provided; analytics checks if required
- **Gherkin** — `Feature:` / `Scenario:` with **Given / When / Then** (and **And**) when appropriate
- **Priority** — P1 / P2 / P3 for *human planning*; for **CSV import**, use Jira **priority scheme names** (see **Xray CSV** below)
- **Labels** — in **markdown** you may list comma-separated for readability; in **Xray CSV** prefer **semicolon-separated** inside one cell for official Xray Cloud samples

---

## Dual output (when writing files in a repo)

When the user wants repository-style deliverables:

1. **Markdown review file** — e.g. `outputs/<feature>-test-cases.md` with every case: Summary, Description, Gherkin, Priority, Labels.
2. **Xray CSV** — e.g. `outputs/xray/<feature>-test-cases.csv` with at least: `projectKey`, `testType`, `summary`, `description`, `gherkin`, `priority`, `labels`.

Use UTF-8, correct CSV quoting (commas/newlines inside quoted fields; double quotes escaped as `""`).

### Requirement / feature traceability (`requirementIssueKey`)

- If the user gives Jira **requirement / story / feature** keys, add optional column **`requirementIssueKey`** (and `requirementIssueKey2`, … if one test covers multiple issues, per Xray docs) **after** `labels`.
- Value = **issue key only** (e.g. `SQA-20336`), not a URL.
- In **Xray Test Case Importer → Map fields**, map this column under **Link** / issue links — **not** "Issue key" (update existing Test) or Xray **Issue ID** (row grouping). **WHOOP SQA confirmed mapping:** **`Link Test "is tested by" (inward)`** so the requirement shows imported tests under coverage / linked work.
- **Jira** CSV import creates **New Feature** (or Story) issues first; **Xray** CSV import creates **Tests** and links them. Put the created keys in `requirementIssueKey`.
- Document in each row's **description** which requirement key(s) the test covers.
- If the user supplies **no** keys, **omit** the column and note that links can be added in Jira or a follow-up import.

---

## Special handling (always consider)

Include coverage ideas for:

- Required vs optional inputs
- Boundary limits (min/max/length/precision)
- Date/time/currency/numeric formatting + locale variants
- Search: empty results, partial matches, typo tolerance if applicable
- Add/remove flows, confirmations, save/cancel, back navigation
- Errors: offline, server error, validation, timeouts
- i18n where relevant
- Accessibility: screen reader labels, focus order, dynamic updates, haptics if PRD states them
- Onboarding: first-use visibility, feature flags, permission prompts
- Analytics/event validation if the PRD implies instrumentation

---

## Xray CSV — columns, importer, validation

### Minimum columns

UTF-8 CSV; each row a test (unless your template uses Issue Id for multi-step manual — follow user template). Minimum columns:

- `testType`
- `gherkin`
- `summary`
- `description`
- `projectKey`
- `priority`
- `labels`

### Optional columns (only if user baseline or importer supports them)

- `tags`, `folderPath`, `testKind` (Functional/Negative/Regression, etc.)
- `requirementIssueKey` (+ `requirementIssueKey2`, …) as above

### Foldering (logical)

Use `folderPath` or description structure such as:

`Feature > Subfeature > Interaction`
and/or
`UX Phase > Defaults | Edge Cases | Negative | Tracking | Accessibility`

### Delimiter (critical)

- **This repo’s** saved importer JSON (`inputs/xray-test-case-importer-config.json`) expects **comma (`,`)** as the **CSV column delimiter**. In **Xray Test Case Importer → Setup**, set **CSV Delimiter** to **comma** for generated exports that follow that template.
- Official **Xray Cloud tutorial** sample files often use **semicolon (`;`)** as the column delimiter instead — that is also valid if you generate a semicolon-shaped file; **always match** file delimiter and importer setting. If they differ, **every** column misaligns and **Priority / Labels** fail.

### Header names

Xray tutorials use display names like **Test Priority**, **Test Summary**, **Test type**, **Project key**, **Gherkin definition**, **Issue Id**. Your CSV may use `priority`, `summary`, etc. as long as the user **maps** columns explicitly in the importer.

### Priority values

- Values must match **Jira priority names** in the target project (spelling and case), e.g. `High`, `Low`.
- **`P1` / `P2` / `P3` often fail** unless the importer maps them. WHOOP SQA mapping: **P1 = Critical, P2 = High, P3 = Normal** (defined in `.claude/QA_AGENT_CONTEXT.md`).
- If priority mapping is painful, skip mapping on import and bulk-edit priority in Jira afterward.

### Labels (multiple labels in one cell)

- Prefer **semicolons**: `smoke;regression`.
- Comma-separated labels in one cell are often **one** label string to the importer.
- If the **file** delimiter is `;`, **quote** the labels field when it contains `;`: `"smoke;xray-verify"`.

### Saved importer JSON (optional, when repo present)

- Load `inputs/xray-test-case-importer-config.json` on File import when available; **re-export** mapping JSON from Jira/Xray after you map **labels → Labels** once and keep that file under version control for repeatability (`inputs/XRAY_IMPORTER_README.md` when present).
- Requirement link template: `inputs/xray-test-case-importer-config-8col-with-requirement-link.json` — verify **Link** mapping against a real export from your Jira.

### Scripts (optional, when repo present)

When the workspace contains these scripts, use them. Otherwise describe the equivalent steps in prose.

```bash
python3 scripts/xray-csv-normalize-for-import.py outputs/xray/my-tests.csv \
  -o outputs/xray/my-tests-xray-import.csv

python3 scripts/xray-csv-normalize-for-import.py outputs/xray/my-tests.csv \
  -o outputs/xray/my-tests-xray-import.csv --labels-delimiter ';'
```

Regenerate semicolon smoke CSV: `python3 scripts/write-xray-cloud-smoke-csv.py`.
Push Gherkin to an existing Test: `./scripts/xray-set-gherkin.sh <ISSUE_KEY> "..."` with `JIRA_EMAIL`, `JIRA_API_TOKEN` set (`scripts/README.md`).

### Before calling CSV work "done"

- Valid quoting, UTF-8, no partial rows, required cells filled
- Short **review summary** (counts by priority / type / area)
- Ask user to **confirm** before upload
- Remind about **label** verification if Confluence label doc was not used

More samples: [Xray tutorial importer (cloud)](https://github.com/Xray-App/tutorial-test-case-importer/tree/main/cloud).

---

## Persona YAML (Persona Service / AI Studio)

### Purpose

Recommend **personas** needed to test a feature; after confirmation, emit **persona YAML** used to create users in the right state.

### Non-negotiable structure

A **complete** persona has:

1. **`cycles`** — WHOOP cycle/sleep/strain/HRV (base user state)
2. **`service_data`** — PersonaAdapter payloads (feature flags, health-service, advanced-labs, etc.)

YAML with **only** `service_data` is **invalid** for creating a full user.

### Workflow A — recommend personas

From PRD or scenarios:

1. Derive **user states** (subscription tier, cycle phase, flags, biomarkers, locale, onboarding, etc.).
2. Propose a **short list**: name, **purpose** (which branches), high-level **service_data** needs.
3. Ask: **"Shall I generate YAML for these N personas?"** and list assumptions. Any affirmative reply proceeds.

### Workflow B — generate YAML (after confirmation)

1. Read **`docs/PERSONA_YAML_REFERENCE.md`** when the workspace includes it.
2. Require at least one **full** example under `inputs/persona/` (**cycles** + **`service_data`**). If missing, **stop** and ask the user to add a full export (AI Studio or persona-service test users).
3. **Merge** `cycles` and other top-level base keys from that example into each new file; customize **`service_data`** per persona from PRD + examples.
4. **One file per persona**, e.g. `outputs/persona/<feature>-<slug>.yaml`.
5. Prefer **relative dates** (`start_date_days_ago`, `days_until_*`, `test_date_days_ago`).
6. **Do not invent** `data_class` or field names — only reuse from examples or Confluence.
7. Output a **short summary** of files and what each persona is for.

### Rules

- **Complete personas only** (`cycles` + `service_data`).
- Prefer **fewer**, well-justified personas.
- If a service has **no** example in repo/docs, say so and ask for an example or Confluence link.

---

## Recommended workspace layout (when using files)

| Path | Purpose |
|------|---------|
| `.claude/QA_AGENT_CONTEXT.md` | Org-specific config (projectKey, priority names, Confluence space, paths) |
| `inputs/<feature>-existing-tests.csv` | Per-feature baseline for dedupe (see `.claude/QA_AGENT_CONTEXT.md`) |
| `inputs/persona/*.yaml` | Full persona examples |
| `inputs/xray-test-case-importer-config.json` | Saved Xray importer column mapping |
| `outputs/` | Human-readable test `.md` files |
| `outputs/xray/` | Xray CSV exports |
| `outputs/persona/` | Generated persona YAML |
| `scripts/` | Optional normalize / smoke / gherkin helpers |
| `docs/PERSONA_YAML_REFERENCE.md` | Persona YAML field reference |

---

## Claude Code skills

Claude Code discovers **project skills** as **folders** under `.claude/skills/`, each containing a **`SKILL.md`** with YAML frontmatter (`name`, `description`). The `name` value is typically how you invoke or reference the skill (e.g. `/whoop-prd-summary`).

This repo includes:

| Folder | `name` (frontmatter) | What it does |
|--------|----------------------|----------------|
| `.claude/skills/whoop-prd-summary/` | `whoop-prd-summary` | Confluence PRD fetch + standard PRD summary |
| `.claude/skills/whoop-test-cases/` | `whoop-test-cases` | Coverage estimate → confirm → tests + optional dual MD/CSV |
| `.claude/skills/whoop-xray-csv/` | `whoop-xray-csv` | Xray CSV build/validate (comma CSV aligned to `inputs/xray-test-case-importer-config.json`) |
| `.claude/skills/whoop-persona-yaml/` | `whoop-persona-yaml` | Persona recommend → YAML |
| `.claude/skills/whoop-regression-planner/` | `whoop-regression-planner` | Weekly regression scope from release notes → affected Xray components |

**`CLAUDE.md` remains authoritative** if a skill file is missing or outdated.

**Permissions:** ensure `.claude/settings.local.json` (or global settings) allows **Write** to this project so the agent can create `outputs/` and `outputs/xray/`.
