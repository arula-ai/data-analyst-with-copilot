# GitHub Copilot for Data Analysis — Hands-On Lab

**Lab 3 | Fraud & Transaction Risk Signals | Hartwell Financial Services**

---

## Training Overview

| Property | Value |
|---|---|
| Duration | 90 minutes |
| Audience | Engineers and Analysts |
| Focus | Using Copilot to analyze fraud alert data, generate visualizations, and operate responsibly |
| Approach | Artifact-driven, stage-by-stage lab with RIFCC-DA prompting |
| Dataset | 500 synthetic fraud alert records with 11 intentional data quality issues |

---

## Prerequisites

- VS Code with GitHub Copilot Chat extension installed and authenticated
- Python 3.10+ installed
- `pip install pandas matplotlib seaborn numpy jupyter`
- Basic Python familiarity helpful but not required
- No database setup needed
- **Read `data/schema.md` before starting — it is your ground truth**

---

## Lab Objectives

1. Apply responsible-use and data governance principles before touching financial data
2. Profile a raw alert dataset to identify quality issues and anomalies
3. Generate safe, reversible data cleaning scripts with full transformation justification
4. Conduct exploratory analysis and translate fraud patterns into business insights
5. Create accurate, honest visualizations from cleaned alert data
6. Audit AI-generated code and outputs for policy compliance and risk exposure

---

## Repository Structure

| Folder / File | Purpose | When to Use |
|---|---|---|
| `data/` | Source dataset and schema documentation | Always open — reference throughout lab |
| `exercises/` | Flawed artifacts for validation practice | Stage 2 — spot the errors before trusting Copilot output |
| `notebooks/` | Starter Jupyter notebook | Stages 3 and 4 — your working environment |
| `outputs/` | Where all your lab artifacts go | Every stage — save here |
| `reference/` | RIFCC-DA framework, glossary, policy, commands | As needed throughout |
| `scripts/` | Cleaning scripts generated in Stage 2 | Stage 2 output |
| `templates/` | Pre-structured output templates to fill in | Start of each stage |
| `.github/agents/` | Custom Copilot agent mode files | Activate at the start of each stage |
| `LAB_ACTION_GUIDE.md` | **Primary participant runbook** | Follow this document throughout the entire lab |
| `QUICK_START.md` | Copilot Chat setup in under 5 minutes | Before Stage 0 if you are new to Copilot Chat |
| `VERIFY_BEFORE_SEND.md` | Pre-analysis safety checklist | **Read before Stage 0. Apply at every stage.** |
| `FACILITATOR_GUIDE.md` | Instructor reference — not for participants | Facilitators only |
| `reference/PROMPT_PATTERN.md` | RIFCC-DA prompt framework reference | When writing or improving prompts |
| `reference/responsible_use.md` | Hartwell Financial data use policy | Stage 0 required reading |

---

## Recommended Sequence

| Stage | Time | What You Do |
|---|---|---|
| Pre-lab | 5 min | Read `VERIFY_BEFORE_SEND.md` and `QUICK_START.md` |
| **Stage 0** | 10 min | Data Risk & Policy Review — classify all columns, flag sensitive fields |
| **Stage 1** | 15 min | Data Profiling — identify all quality issues and anomalies |
| **Stage 2** | 20 min | Data Cleaning — generate a safe, commented cleaning script |
| **Stage 3** | 15 min | Exploratory Analysis — find fraud patterns, answer business questions |
| **Stage 4** | 15 min | Visualization — build 4+ labeled, honest charts |
| **Stage 5** | 10 min | Responsible Use Audit — review all generated code and outputs |
| **Stage 6** | 5 min | Executive Summary — 3 insights, 2 recommendations, 1 risk |

---

## Key Files

| File | Purpose | When to Use |
|---|---|---|
| `data/transaction_alerts.csv` | 500-row fraud alert dataset | Source data for all stages |
| `data/schema.md` | Column definitions, valid ranges, 11 known issues | Ground truth — validate everything against this |
| `LAB_ACTION_GUIDE.md` | Stage-by-stage instructions with review checklists | Primary guide — follow sequentially |
| `reference/PROMPT_PATTERN.md` | RIFCC-DA framework with 6 example prompts | Write better prompts at every stage |
| `reference/responsible_use.md` | Hartwell Financial AI use policy | Required reading for Stage 0 |
| `VERIFY_BEFORE_SEND.md` | Data privacy preflight checklist | Before every prompt involving real-looking data |

---

## Success Criteria

You are done when all of the following exist in `/outputs/`:

- [ ] `00_data_risk_review.md` — sensitivity ratings and handling recommendations for all 15 columns
- [ ] `01_data_profile.md` — at least 8 data quality issues documented with counts and severity
- [ ] `scripts/clean_alerts.py` — commented cleaning script with row count before and after
- [ ] `02_cleaning_decisions.md` — justification for every transformation
- [ ] `03_exploratory_insights.md` — fraud pattern insights written for a business audience
- [ ] `04_visualizations.ipynb` — at least 4 labeled charts with interpretation notes
- [ ] `05_audit_review.md` — code and output compliance review findings
- [ ] `06_executive_summary.md` — 3 insights, 2 recommendations, 1 risk note, 1 data limitation

**No artifact = incomplete lab. No exceptions.**

---

## Course Module Mapping

This lab covers the practical exercises for the following course modules:

| Course Module | Topic | Lab Stage(s) |
|---------------|-------|-------------|
| Module 1 | Setting the Stage — Data Analysis in VS Code | Pre-lab (`QUICK_START.md`, `VERIFY_BEFORE_SEND.md`) |
| Module 2 | Collaborating with Copilot for Data Exploration | Stage 1 (Profiling) + Stage 3 (EDA) |
| Module 3 | Data Cleaning and Transformation with Copilot | Stage 2 (Cleaning) |
| Module 4 | Generating Visualizations with Copilot | Stage 4 (Visualization) |
| Module 5 | Responsible Use — Security, Privacy, and Policy | Stage 0 (Risk Review) + Stage 5 (Audit) |

> Stage 6 (Executive Summary) spans all modules — it synthesizes outputs from every prior stage.

---

## Additional Datasets (Use Case Scenarios)

This repo also contains mock datasets for the other two course use case scenarios:

| Scenario | Dataset | Schema |
|----------|---------|--------|
| Root Cause Analysis (RCA) | `data/rca_app_logs.csv` — 300 synthetic application log entries | `data/rca_schema.md` |
| Product Usage & Modernization | `data/mainframe_usage.xlsx` — 400 synthetic mainframe feature usage records (Excel) | `data/mainframe_schema.md` |
| Operational Anomaly Detection & Trend Analysis | `data/treasury_payments.xlsx` — 500 synthetic Treasury payment records (Excel) | `data/treasury_schema.md` |

These datasets are provided for the three course use case scenarios. Each has a corresponding sub-lab in `LAB_ACTION_GUIDE.md` (Scenarios A, B, and C). The primary 90-minute lab uses `data/transaction_alerts.csv`.

---

## Getting Started

1. Read `VERIFY_BEFORE_SEND.md` — understand what data privacy obligations apply before you open the dataset
2. If new to Copilot Chat, read `QUICK_START.md` — get operational in under 5 minutes
3. Open `LAB_ACTION_GUIDE.md` — follow it stage by stage for the full 90 minutes

---

## Important Reminders

- Validate all generated code before executing it. Copilot produces plausible-looking code that can contain logic errors.
- Document your assumptions at every stage. If Copilot assumes something you haven't verified, flag it.
- Do not include `account_masked` in any output, visualization, chart, or exported file.
- Row counts before and after cleaning are mandatory — silent data loss is not acceptable.
- Business decisions in this lab (what to impute, what to drop, what to escalate) require written justification. "Copilot said so" is not a justification.
