---
name: whoop-prd-summary
description: >-
  Fetches a WHOOP PRD from Confluence via Atlassian MCP and writes the standard
  PRD summary (Overview, Goals, AC, QA Notes). Use for /whoop-prd-summary,
  Confluence PRDs, acceptance criteria, or before test design.
---

# PRD summary

Fetch a PRD from Confluence and produce a structured summary.

## Inputs

The user may provide:

- A Confluence page title or URL
- A Jira issue key (e.g. `SQA-1234`)
- Nothing — in which case, ask for one of the above

## Steps

1. Read `.claude/QA_AGENT_CONTEXT.md` if present (space key, label filter, ancestor page ID, label conventions URL).
2. Use Atlassian MCP to search Confluence for the PRD:
   - If a URL or page title was given, fetch that page directly.
   - If a Jira key was given, fetch the issue and follow any linked Confluence pages.
   - If nothing was given, ask the user for a title, URL, or Jira key before proceeding.
3. Fetch the top **1–3** most relevant pages. Do not fetch dozens.
4. Write the summary using these headings:
   - **Overview**
   - **Goals**
   - **Non-goals**
   - **Key Requirements**
   - **Acceptance Criteria** (verbatim or near-verbatim from the PRD)
   - **Open Questions / Ambiguities**
   - **QA Notes** (high-risk areas, dependencies, missing AC, unclear edge cases)
5. End with **PRD link(s)** (page title + URL as returned by MCP).

## Rules

- Do not guess requirements. If the PRD is not accessible, say so and ask for a link or pasted content.
- Label anything not directly in the PRD as **Assumption**.
- Separate clearly: **Confirmed from PRD** vs **Assumptions / suggestions** vs **Open questions**.

Full policy: **`CLAUDE.md`** (repo root).
