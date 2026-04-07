# Scenario A — Treasury Anomaly Detection

**Your Role:** Treasury Data Analyst — Operations Risk Team
**Duration:** 50 minutes

---

## The Situation

The Treasury Operations team monitors large-value payment flows to detect anomalies — payments that deviate from established patterns in amount, timing, or counterparty behavior. The team needs a data-driven picture of Q4 2024 payment activity to brief the Head of Treasury Operations.

You have been handed one artifact:

| Artifact | What It Is |
|---|---|
| `data/treasury_payments.xlsx` | 500 flagged payment records from Q4 2024 — one row per payment reviewed by a Treasury analyst |

---

## Your Objective

Use GitHub Copilot to explore and analyze the payment data, detect abnormal patterns, surface anomalies, and identify any trends that require operational attention.

A good outcome in 50 minutes is:
- You know which payment types have the highest confirmed anomaly rates
- You have identified at least one time-based or regional trend
- You have 2–3 plain-English findings ready to brief an operations manager

---

## What You Are NOT Expected To Do

- Build a predictive model
- Connect to live payment systems
- Produce a perfect analysis — a defensible, evidence-backed summary is the goal

---

## Privacy Note

`counterparty_masked` is a masked identifier — it is PII-adjacent. **Do not include it in any visualization, printed DataFrame output, or exported file.** Reference it by name in prompts only — never paste raw values.

---

## Your Output Artifacts

Save these to `outputs/` before the debrief:

| File | What It Contains |
|---|---|
| `outputs/A_profile.md` | Payment dataset profile — row count, null counts, data quality issues |
| `scripts/clean_treasury.py` | Cleaning script — every transformation commented and justified |
| `outputs/A_cleaning_decisions.md` | Data quality decisions + 2–3 plain-English findings ready to brief the Head of Operations |
| `scripts/visualize_treasury.py` | Python script that generates 3 interactive charts |
| `outputs/A_chart_*.html` | 3 interactive HTML charts showing anomaly patterns across payment types and time |

---

## Setup Note

This scenario uses an Excel file. Ensure `openpyxl` is installed:
```
pip install openpyxl
```
Load the data with: `pd.read_excel('data/treasury_payments.xlsx')`

---

## Reference Files (shared across all scenarios)

| File | Use When |
|---|---|
| `reference/PROMPT_PATTERN.md` | Writing better Copilot prompts (RIFCC-DA framework) |
| `reference/COPILOT_COMMANDS.md` | Quick reference for `#filename`, agents, `/` prompts |
| `reference/responsible_use.md` | Governance rules — what data can go into a prompt |
| `VERIFY_BEFORE_SEND.md` | Run through this before attaching any file to Copilot |
