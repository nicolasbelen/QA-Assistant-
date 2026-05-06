# QA-Assistant

WHOOP QA assistant for **Confluence-grounded** PRD summaries, **test cases** (coverage estimate → confirmation → suite), **Xray CSV** (comma layout + importer JSON in `inputs/`), and **persona YAML**.

## Quick start

1. **Claude Code** — open this folder as the project root so **`CLAUDE.md`** loads.
2. **Config** — edit **`.claude/QA_AGENT_CONTEXT.md`** (Confluence space, `projectKey`, per-feature baseline naming, label conventions URL).
3. **Atlassian MCP** — required for live Confluence/Jira; see **`CLAUDE.md`** → *MCP setup*.
4. **Permissions** — **`.claude/settings.local.json`** allows Read/Write under `QA-Agent/QA-Assistant-/`; widen or narrow paths if you move the repo.

## Layout

| Path | Purpose |
|------|---------|
| `CLAUDE.md` | Full portable instructions (source of truth) |
| `.claude/QA_AGENT_CONTEXT.md` | Org-specific keys, URLs, baseline conventions |
| `.claude/skills/*/SKILL.md` | Claude Code skills (YAML frontmatter + workflow) |
| `inputs/xray-test-case-importer-config*.json` | Xray importer column mapping templates |
| `inputs/XRAY_IMPORTER_README.md` | How to load JSON and fix label mapping |
| `docs/XRAY_CSV_REQUIREMENT_LINKS.md` | `requirementIssueKey` + WHOOP link mapping |
| `inputs/persona/` | Example persona YAMLs |
| `docs/PERSONA_*.md` | Persona structure reference |
| `outputs/`, `outputs/xray/`, `outputs/persona/` | Generated artifacts (create as needed) |

## Optional extras

Copy from **Test-Case-Designer** if you want: `scripts/` (CSV normalize, Gherkin push), Jira bulk CSV samples, `docs/JIRA_CSV_NEW_FEATURES_WORKFLOW.md`.
