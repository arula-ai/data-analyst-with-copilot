# Scenario C — Product Modernization

**Your Role:** Product Data Analyst — Modernization Planning Team
**Duration:** 50 minutes

---

## The Situation

An engineering leadership team is undertaking a multi-year platform modernization effort to migrate legacy mainframe features to modern cloud-based services. They cannot migrate everything at once and need data-driven prioritization — which features to tackle first, based on usage impact and migration complexity.

You have been handed two artifacts:

| Artifact | What It Is |
|---|---|
| `data/legacy_mainframe.py` | The legacy mainframe source module — 6 functions, each with technical debt marked `# BUG` |
| `data/mainframe_usage.xlsx` | 400 rows of feature usage metrics including monthly active users, error rates, and estimated migration effort |

---

## Your Objective

Use GitHub Copilot to review the legacy code for migration complexity, analyze the usage data to understand business impact, and produce a prioritized list of features to modernize.

A good outcome in 50 minutes is:
- You understand which legacy features carry the highest migration risk based on the code
- You know which features have the highest business impact based on usage data
- You have a ranked list of 3–5 modernization candidates with supporting evidence

---

## What You Are NOT Expected To Do

- Rewrite or fix the legacy code
- Migrate anything
- Produce a perfect analysis — a defensible, data-backed recommendation is the goal

---

## Your Output Artifacts

Save these to `outputs/` before the debrief:

| File | What It Contains |
|---|---|
| `outputs/C_profile.md` | Usage dataset profile — row count, null counts, data quality issues |
| `scripts/clean_mainframe.py` | Cleaning script — every transformation commented and justified |
| `outputs/C_cleaning_decisions.md` | How you handled data quality issues + all 5 critique flaws addressed |
| `scripts/analyze_mainframe.py` | Pandas EDA script — legacy counts by team, top features by usage, high-priority modernization candidates |
| `scripts/visualize_mainframe.py` | Python script that generates 3 interactive charts |
| `outputs/C_chart_*.html` | 3 interactive HTML charts showing usage patterns and modernization priorities |

---

## Setup Note

This scenario uses an Excel file. Ensure `openpyxl` is installed:
```
pip install openpyxl
```
Load the data with: `pd.read_excel('data/mainframe_usage.xlsx')`

---

## Reference Files (shared across all scenarios)

| File | Use When |
|---|---|
| `reference/PROMPT_PATTERN.md` | Writing better Copilot prompts (RIFCC-DA framework) |
| `reference/COPILOT_COMMANDS.md` | Quick reference for `#filename`, agents, `/` prompts |
| `reference/responsible_use.md` | Governance rules — what data can go into a prompt |
| `VERIFY_BEFORE_SEND.md` | Run through this before attaching any file to Copilot |
