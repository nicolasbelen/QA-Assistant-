---
name: whoop-regression-planner
description: >-
  Analyzes weekly Android + iOS release notes, maps merged PRs to Xray
  components, and outputs a targeted regression plan scoped to features that
  actually changed. Use for /whoop-regression-planner or regression scope,
  weekly regression, release build analysis.
---

# Regression Planner

Generate a targeted regression scope for the week by mapping merged PRs to
Xray components, so only test cases for features that actually changed are
included.

## Inputs

| File | Description |
|------|-------------|
| `inputs/release-notes/{week}-android.md` | Android builds for the week |
| `inputs/release-notes/{week}-ios.md` | iOS builds for the week |
| `inputs/components.yaml` | Xray component → feature area mapping |

## Steps

### 1 — Resolve the target week

- If the user passed a week argument (e.g. `2026-W16`), use it.
- Otherwise default to the **current ISO week** (use today's date from the
  system prompt; format: `YYYY-Www`).

### 2 — Read release notes

Read both files:
- `inputs/release-notes/{week}-android.md`
- `inputs/release-notes/{week}-ios.md`

If a file is missing or contains only the placeholder comment, note that no
builds were received for that platform this week and continue with the other.

For each file, extract every PR entry across **all builds** in the file.
A PR entry looks like:
```
• TICKET-123: Short description of what changed (#PRNUM)
```

Collect them into a unified list with columns: **Ticket**, **Title**,
**Platform** (Android / iOS / Both if same ticket appears on both).

### 3 — Read components.yaml

Read `inputs/components.yaml`. Build an in-memory lookup of:
- `component` → `feature`, `team`, `keywords[]`

### 4 — Map PRs → Components (semantic matching)

For each PR in the unified list, determine which component(s) it affects.

**Matching strategy — apply in order, a PR may match multiple components:**

1. **Team prefix match:** The ticket prefix (e.g. `STREN`, `FROGE`, `BOT`)
   maps to a team. Any component whose `team` field matches that prefix is a
   candidate. Use this as the **starting signal**, not the only one.

2. **Keyword match:** Scan the PR title text against each component's
   `keywords[]` list (case-insensitive). A match on a specific keyword (e.g.
   "autosave", "widget", "community follower") narrows to the most precise
   component.

3. **Semantic inference:** Use your understanding of the PR title's meaning to
   infer the best-fit component even when no keyword matches exactly. For
   example, "Add param to fetch widget, hide while loading" → Widgets.
   "Community follower lookup SHOW MORE analytics" → Community. Explain your
   reasoning briefly.

4. **Prefer precision:** When a team prefix matches multiple components (e.g.
   FROGE covers Weekly Plan, Trends, Journal, Coach, Sleep Planner), use the
   PR title to select the most specific component. If the title is too generic
   to narrow it further, include all plausible components and flag them.

5. **No match:** If a PR cannot be mapped to any component, mark it as
   **Unmapped** and include it in the gaps section.

### 5 — Deduplicate

Multiple PRs may map to the same component. Consolidate so each affected
component appears once, listing all the PRs that triggered it.

### 6 — Output

Produce the following sections in order:

---

#### A. Week summary

```
Week: {week}
Android builds: {count, or "none"}
iOS builds: {count, or "none"}
Total PRs analyzed: {count}
Affected components: {count}
```

---

#### B. Affected components

For each affected component, one block:

```
## {Component Name}
Feature area: {feature}
Team: {team}
Triggered by:
  - [{TICKET}: {title}] ({Platform})
  - ...
Rationale: {1–2 sentences explaining why this component is in scope}
```

Group by feature area for readability.

---

#### C. Recommended regression scope

A table listing the components to include in this week's Xray test execution,
ready for team review:

| Component | Feature Area | PRs | Platform(s) | Priority Signal |
|-----------|-------------|-----|-------------|-----------------|

Priority Signal: assign based on the nature of the change:
- **High** — core user flow touched, security/auth change, or multiple PRs hit the same component
- **Medium** — UI/UX change, analytics, non-critical backend param
- **Low** — config, debug flag, or infra-only change with minimal user impact

---

#### D. Coverage gaps

Components that were triggered but have **no test cases mapped** in Xray
(i.e. the component name appears in `components.yaml` but you have no
baseline CSV data to cross-reference), OR PRs that could not be mapped to
any component at all.

| Ticket | Title | Platform | Reason unmapped |
|--------|-------|----------|-----------------|

If there are no gaps, say "No unmapped PRs this week."

---

#### E. Unmapped PRs

List any PRs that did not match any component, with a brief note on why
(e.g. infra-only, test/tooling change, no keyword/prefix match).

---

#### F. Suggested next steps

1. Review the component list above and remove any false positives.
2. In Xray, create a new Test Execution for this week's regression and add
   test cases filtered by the components in section C.
3. For gaps in section D, consider: (a) creating test cases for those
   components, or (b) flagging the PR for manual exploratory testing.
4. Once Xray API access is available, this step can be automated.

---

## Notes

- This skill is **read-only** — it does not write to Xray. A human reviews
  the plan before executing.
- The mapping is **AI-assisted**: always review the rationale column for
  false positives before loading the test execution.
- To add a new build during the week, paste the raw release notes email at
  the top of the relevant week file (android or ios), separated by `---`.
- If `inputs/components.yaml` is stale, update it from the Jira component
  list (or re-run the importer once API access is available).
