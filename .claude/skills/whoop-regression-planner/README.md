# whoop-regression-planner

Analyzes weekly release notes (Android + iOS) and generates a targeted regression plan scoped to features that actually changed.

## Usage

```
/whoop-regression-planner [week]
```

- `week` is optional. Defaults to the current ISO week (e.g. `2026-W16`).
- Run anytime during the week to get a plan based on builds received so far.
- Run at end of week for the full regression scope.

## Inputs

| File | Description |
|------|-------------|
| `inputs/release-notes/{week}-android.md` | Android builds for the week (append new builds as they arrive) |
| `inputs/release-notes/{week}-ios.md` | iOS builds for the week (append new builds as they arrive) |
| `inputs/components.yaml` | Xray component → feature area mapping |

## How to add a new build

Just paste the raw release notes email content at the top of the relevant week file, separated by `---`.

## Output

- List of affected Xray components with rationale (which PRs triggered each)
- Recommended test cases to include in regression (filtered by component)
- Coverage gaps: components with changes but no mapped test cases
- Summary table ready for team review

## Roadmap

- [ ] Auto-create Xray test execution via API (pending API access)
- [ ] Pull Jira ticket details for richer context (pending Jira API scope)
- [ ] GitHub PR diff analysis for deeper impact assessment
