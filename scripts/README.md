# Scripts

Helper scripts for QA agent workflows. All scripts source credentials from `~/.zshrc`.

## xray-set-gherkin.sh

Sets the Gherkin/Test Detail field on an existing Xray Cloud Test issue via GraphQL.

**Requires:** `XRAY_CLIENT_ID`, `XRAY_CLIENT_SECRET` in environment.

```bash
source ~/.zshrc
printf 'Feature: Login\n  Scenario: Valid login\n    Given ...' \
  | ./scripts/xray-set-gherkin.sh <numeric_issue_id>
```

The numeric issue ID is the Jira `id` field (e.g. `538180`), **not** the issue key (`SQA-21639`).
Use the `/whoop-xray-upload` skill to run this automatically for a full CSV batch.
