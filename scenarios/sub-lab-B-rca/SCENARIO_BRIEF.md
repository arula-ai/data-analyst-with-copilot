# Scenario B — Root Cause Analysis

**Your Role:** Platform Reliability Analyst
**Duration:** 50 minutes

---

## The Situation

A microservices platform that processes real-time payment transactions has been experiencing service degradation. Over the past week, the on-call team has received escalating alerts — transactions are failing intermittently, response times have spiked, and some errors are disappearing without explanation.

You have been handed two artifacts:

| Artifact | What It Is |
|---|---|
| `data/app_service.py` | The platform source code — 5 service classes, each with intentional defects marked `# BUG` |
| `data/rca_app_logs.csv` | 300 log entries from the past 24 hours across all 5 services |

---

## Your Objective

Use GitHub Copilot to analyze the codebase and logs, correlate error patterns with code defects, and identify the most likely root cause of the service degradation.

A good outcome in 50 minutes is:
- You know which service is generating the most failures and why
- You have log evidence that confirms or contradicts your hypothesis from the code review
- You have 2–3 actionable findings written in plain English for an engineering manager

---

## What You Are NOT Expected To Do

- Fix the code
- Explain every line of the source file
- Produce a perfect analysis — an honest, evidence-backed hypothesis is the goal

---

## Privacy Note

`user_id_masked` is a masked identifier — it is PII-adjacent. **Do not include it in any visualization, printed DataFrame output, or exported file.**

---

## Your Output Artifacts

Save these to `outputs/` before the debrief:

| File | What It Contains |
|---|---|
| `outputs/B_profile.md` | Log dataset profile — row count, null counts, error distribution by service |
| `scripts/clean_logs.py` | Cleaning script — every transformation commented and justified |
| `outputs/B_cleaning_decisions.md` | How you handled data quality issues in the logs + all 5 critique flaws addressed |
| `scripts/analyze_logs.py` | Pandas EDA script — error counts by service, response times, highest-failure service identified |
| `scripts/visualize_logs.py` | Python script that generates 3 interactive charts |
| `outputs/B_chart_*.html` | 3 interactive HTML charts showing error patterns across services and time |

---

## Reference Files (shared across all scenarios)

| File | Use When |
|---|---|
| `reference/PROMPT_PATTERN.md` | Writing better Copilot prompts (RIFCC-DA framework) |
| `reference/COPILOT_COMMANDS.md` | Quick reference for `#filename`, agents, `/` prompts |
| `reference/responsible_use.md` | Governance rules — what data can go into a prompt |
| `VERIFY_BEFORE_SEND.md` | Run through this before attaching any file to Copilot |
