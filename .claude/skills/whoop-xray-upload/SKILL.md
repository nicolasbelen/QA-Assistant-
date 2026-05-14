---
name: whoop-xray-upload
description: >-
  Uploads a generated Xray CSV to Jira/Xray: creates Test issues via Atlassian
  MCP, populates the Gherkin Test Detail field via Xray Cloud GraphQL, and
  optionally links tests to requirement issues. Use for /whoop-xray-upload,
  uploading test cases to Jira, or automating Xray import.
---

# Xray Upload

Create Jira Test issues from a generated CSV and populate the Gherkin/Test Detail field automatically.

## Requires

- `XRAY_CLIENT_ID` and `XRAY_CLIENT_SECRET` in environment (`~/.zshrc`)
- Atlassian MCP connected (provides Jira write access)
- `scripts/xray-set-gherkin.sh` present in workspace

## Inputs

The user may provide:

- A CSV file path (e.g. `outputs/xray/my-feature-test-cases.csv`)
- Nothing — use the most recently modified file in `outputs/xray/`

## Steps

1. **Identify CSV.** Use the path the user gave, or `ls -t outputs/xray/*.csv | head -1` to find the latest.

2. **Read and validate.** Parse the CSV and confirm:
   - Required columns present: `projectKey`, `testType`, `summary`, `gherkin`, `priority`, `labels`
   - No empty `summary` or `gherkin` rows (skip and warn if found)
   - Show the user a preview table (count by priority, first 3 summaries) and ask: **"Upload these N tests to Jira/Xray?"** Any affirmative reply proceeds.

3. **For each row — create Jira Test issue via MCP:**
   - Use `jira_create_issue` with: `projectKey`, issue type `Test`, `summary`, `description`, `priority`, `labels`
   - Record the returned **issue key** (e.g. `SQA-21640`) and **numeric issue ID** (e.g. `538181`) — both are needed
   - If creation fails, log the error and continue with remaining rows

4. **For each created issue — set Gherkin via script:**
   ```bash
   source ~/.zshrc
   printf '%s' "<gherkin content from CSV row>" | ./scripts/xray-set-gherkin.sh <numeric_issue_id>
   ```
   - Use the numeric ID (not the key) — Xray GraphQL requires it
   - If the script returns an error, log it and continue

5. **Requirement links (if `requirementIssueKey` column is present):**
   - For each created issue that has a `requirementIssueKey` value, use the MCP to link:
     - Link type: `is tested by` (inward) — the requirement is tested by the new Test
   - If `requirementIssueKey2` etc. are present, link those too

6. **Report results.** Print a summary table:

   | # | Summary | Issue Key | Gherkin | Req Link |
   |---|---------|-----------|---------|----------|
   | 1 | ... | SQA-XXXXX | ✓ | ✓ |
   | 2 | ... | SQA-XXXXX | ✓ | — |

   List any failures separately with their error messages.

## Notes

- Jira issue type must be `Test` (Xray Test type in SQA) — do not use `Task` or `Story`
- The numeric issue ID is returned by `jira_create_issue` in the `id` field of the response
- Gherkin content must start with `Feature:` on the first line
- `priority` values in SQA use P0–P4 directly (no name mapping needed)
- Labels: semicolon-separated inside one CSV cell (e.g. `smoke;regression`)

Full policy: **`CLAUDE.md`** (repo root).
