# GitHub Copilot for Data Analysis — Hands-On Lab

**Lab 3 | Copilot Data Analysis Lab**

---

## Training Overview

| Property | Value |
|---|---|
| Duration | 90 minutes |
| Audience | Engineers and Analysts |
| Focus | Using Copilot to profile, clean, query, and visualize operational data — and doing it responsibly |
| Approach | Scenario-based, artifact-driven lab with RIFCC-DA prompting |
| Format | 3 parallel sub-labs — pick one scenario and work through it end-to-end |

---

## Prerequisites

- VS Code with GitHub Copilot Chat extension installed and authenticated
- Python 3.10+ installed
- `pip install pandas matplotlib seaborn numpy jupyter openpyxl`
- Basic Python familiarity helpful but not required
- No database setup needed

---

## Choose Your Scenario

This lab has three self-contained sub-labs. All three are identical in structure. Pick the one most relevant to your role, or whichever your facilitator assigns.

| Sub-Lab | Scenario | Company | Dataset | Format |
|---|---|---|---|---|
| **A** | Root Cause Analysis (RCA) | Orion Payments Inc. | `rca_app_logs.csv` — 300 application log entries | CSV |
| **B** | Product Modernization | Centrix Financial Systems | `mainframe_usage.xlsx` — 400 mainframe feature records | Excel |
| **C** | Treasury Anomaly Detection | Meridian Asset Management | `treasury_payments.xlsx` — 500 Treasury payment records | Excel |

Each sub-lab lives in `scenarios/sub-lab-[A/B/C]-[name]/`. Everything you need is inside that folder.

---

## Lab Objectives

1. Apply responsible-use and data governance principles before touching financial or operational data
2. Profile a raw dataset to identify quality issues, sentinel values, and anomalies
3. Generate safe, reversible data cleaning scripts with full transformation justification
4. Run SQL pattern queries using sqlite3 to surface operational signals
5. Create accurate, honest visualizations from cleaned data
6. Critically evaluate Copilot-generated outputs for correctness and policy compliance

---

## Repository Structure

| Folder / File | Purpose | When to Use |
|---|---|---|
| `scenarios/sub-lab-A-rca/` | Sub-Lab A — RCA scenario, all files self-contained | If you chose Scenario A |
| `scenarios/sub-lab-B-modernization/` | Sub-Lab B — Modernization scenario, all files self-contained | If you chose Scenario B |
| `scenarios/sub-lab-C-treasury/` | Sub-Lab C — Treasury scenario, all files self-contained | If you chose Scenario C |
| `reference/` | RIFCC-DA framework, glossary, responsible use policy, commands | As needed throughout |
| `templates/` | Generic output templates for Stages 1, 2, and 3 | Start of each stage |
| `.github/agents/` | Custom Copilot agent mode files | Activate at the start of each stage |
| `.github/prompts/` | Named Copilot prompt files | Invoke with `/` in Copilot Chat |
| `outputs/` | Where all your deliverables go | Every stage — save here |
| `scripts/` | Cleaning scripts you generate in Stage 2 | Stage 2 output |
| `LAB_ACTION_GUIDE.md` | **Primary participant runbook** | Follow this document throughout the lab |
| `QUICK_START.md` | Copilot Chat setup in under 5 minutes | Before starting if you are new to Copilot Chat |
| `VERIFY_BEFORE_SEND.md` | Pre-prompt safety checklist | Read before Stage 1. Apply at every stage. |
| `FACILITATOR_GUIDE.md` | Instructor reference — not for participants | Facilitators only |

---

## Sub-Lab Structure (all 3 are identical)

Each sub-lab contains:

```
scenarios/sub-lab-[X]-[name]/
├── SCENARIO_BRIEF.md        ← Start here — half-page context for your role
├── SUB_LAB_GUIDE.md         ← Stage-by-stage instructions (50 min)
├── data/                    ← Dataset and schema for this scenario
├── exercises/               ← Flawed analysis artifact — spot the errors
└── starter_notebook.ipynb   ← Pre-loaded Jupyter notebook
```

---

## Session Flow

| Block | Time | What Happens |
|---|---|---|
| **Shared Demo** | 0–30 min | Facilitator-led: workspace setup, RIFCC-DA framework, first agent demo |
| **Scenario Pick** | 30–32 min | You choose Sub-Lab A, B, or C |
| **Scenario Sprint** | 32–82 min | Work through your chosen sub-lab (3 stages) |
| **Group Debrief** | 82–90 min | Each group shares 1 finding + 1 risk they caught |

### Scenario Sprint — 3 Stages (50 min)

| Stage | Time | What You Do | Agent |
|---|---|---|---|
| **Stage 1** | 10 min | Profile the dataset — find all quality issues | Data Profiling Analyst |
| **Stage 2** | 25 min | Clean the data + run SQL pattern queries via sqlite3 | Data Cleaning Engineer |
| **Stage 3** | 15 min | Build 3 labeled charts, export PNGs, run sharing checklist | Visualization Architect |

---

## Deliverables

You need 3 artifacts in `outputs/` to complete the lab:

- [ ] `01_data_profile.md` — quality issues documented with counts and severity
- [ ] `02_cleaning_decisions.md` — every transformation justified
- [ ] `03_visualization_notes.md` + exported chart PNGs — 3 labeled charts with sharing checklist complete

---

## Key Reference Files

| File | Purpose |
|---|---|
| `reference/PROMPT_PATTERN.md` | RIFCC-DA framework — how to write effective Copilot prompts |
| `reference/responsible_use.md` | Meridian/Orion/Centrix AI use policy (fictional, training vehicle) |
| `reference/GLOSSARY.md` | Terms and definitions |
| `VERIFY_BEFORE_SEND.md` | Data privacy preflight checklist — apply before every prompt |

---

## Getting Started

1. Read `VERIFY_BEFORE_SEND.md` — understand what privacy obligations apply before opening any dataset
2. If new to Copilot Chat, read `QUICK_START.md` — get operational in under 5 minutes
3. Open `LAB_ACTION_GUIDE.md` — follow it for the full 90-minute session
4. When the facilitator calls scenario selection, open your chosen `scenarios/sub-lab-[X]/SCENARIO_BRIEF.md`

---

## Important Reminders

- Validate all generated code before executing it. Copilot produces plausible-looking code that can contain logic errors.
- Never include PII-adjacent fields in any output, chart, or exported file (`counterparty_masked`, `account_masked`).
- Row counts before and after cleaning are mandatory — silent data loss is not acceptable.
- Sentinel values (999, -1, 9999) must be excluded from all calculations — not treated as real data.
- "Copilot said so" is not a business justification. Every transformation decision requires written reasoning.

---

## Course Module Mapping

| Course Module | Topic | Lab Coverage |
|---|---|---|
| Module 1 | Setting the Stage — Data Analysis in VS Code | Shared demo block (`QUICK_START.md`, workspace setup) |
| Module 2 | Collaborating with Copilot for Data Exploration | Stage 1 (Profiling) |
| Module 3 | Data Cleaning and Transformation with Copilot | Stage 2 (Cleaning + SQL) |
| Module 4 | Generating Visualizations with Copilot | Stage 3 (Visualization) |
| Module 5 | Responsible Use — Security, Privacy, and Policy | `VERIFY_BEFORE_SEND.md` + Group Debrief |
