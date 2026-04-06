# GitHub Copilot for Data Analysis — Hands-On Lab

**Copilot Data Analysis Lab**

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

## Learning Objectives

By the end of this lab, participants will be able to:

1. Apply Copilot within VS Code to transform raw datasets into meaningful analytical insights while adhering to company security and privacy policies
2. Create compelling data visualizations by leveraging Copilot's code generation capabilities to explore and interpret datasets
3. Evaluate the appropriateness and accuracy of Copilot-generated code for data analysis tasks before implementation
4. Analyze complex datasets using Copilot assistance to identify patterns, trends, and actionable insights that inform business decisions
5. Implement responsible-use practices when collaborating with Copilot to ensure all data handling complies with organizational policies
6. **Governance:** Apply dos and don'ts for following Copilot — understand what data can be connected and used within an IDE
7. **Quality Controls:** Establish best practices for quality-checking analytics before sharing to ensure accurate storytelling

---

## Prerequisites

- VS Code with GitHub Copilot Chat extension installed and authenticated
- Python 3.10+ installed
- `pip install -r requirements.txt`
- Run `python scripts/verify_setup.py` to confirm your environment is ready
- Basic Python familiarity helpful but not required
- No database setup needed

**Required VS Code Extensions** (install via `Ctrl+Shift+X`):
- **Jupyter** — notebook support for exploratory work (recommended)

> **Codespace users:** Open this repo in a GitHub Codespace (`.devcontainer/` is pre-configured) — all dependencies install automatically.

---

## Choose Your Scenario

This lab has three self-contained sub-labs. All three are identical in phase structure (Phase 1 → 2 → 3). Scenarios B and C include a 5-minute Pre-step code review before Phase 1 that Scenario A does not. Pick the one most relevant to your role, or whichever your facilitator assigns.

| Sub-Lab | Scenario | Company | Dataset | Format |
|---|---|---|---|---|
| **A** | Treasury Anomaly Detection | Meridian Asset Management | `treasury_payments.xlsx` — 500 Treasury payment records | Excel |
| **B** | Root Cause Analysis (RCA) | Orion Payments Inc. | `rca_app_logs.csv` — 300 application log entries | CSV |
| **C** | Product Modernization | Centrix Financial Systems | `mainframe_usage.xlsx` — 400 mainframe feature records | Excel |

Each sub-lab lives in `scenarios/sub-lab-[A/B/C]-[name]/`. Datasets and schema files are shared — they live in `data/` at the repo root, not inside the scenario folder.

---

## Enterprise Usage Considerations

**Production-Grade Analytics:** In production financial services environments, analytics workflows are highly governed:

- **Script-Based Workflows**: Analysis is typically converted to Python scripts (`.py` files) for better version control, code review, CI/CD integration, and automated execution.
- **Reproducibility**: Artifacts must be reproducible without manual intervention.

The lab artifacts reflect this enterprise reality: All phases generate production-ready `.py` scripts (`profile_*.py`, `clean_*.py`, `visualize_*.py`) that output automated reports, cleaned data, and self-contained interactive HTML dashboards.

---

## Repository Structure

| Folder / File | Purpose | When to Use |
|---|---|---|
| `scenarios/sub-lab-A-treasury/` | Sub-Lab A — Treasury Anomaly Detection, all files self-contained | If you chose Scenario A |
| `scenarios/sub-lab-B-rca/` | Sub-Lab B — Root Cause Analysis, all files self-contained | If you chose Scenario B |
| `scenarios/sub-lab-C-modernization/` | Sub-Lab C — Product Modernization, all files self-contained | If you chose Scenario C |
| `reference/` | RIFCC-DA framework, glossary, responsible use policy, commands | As needed throughout |
| `templates/` | Generic output templates for Phases 1, 2, and 3 | Start of each phase |
| `.github/agents/` | Custom Copilot agent mode files | Activate at the start of each phase |
| `.github/prompts/` | Named Copilot prompt files | Invoke with `/` in Copilot Chat |
| `outputs/` | Where all your deliverables go | Every phase — save here |
| `scripts/` | Cleaning scripts you generate in Phase 2 | Phase 2 output |
| `LAB_ACTION_GUIDE.md` | **Primary participant runbook** | Follow this document throughout the lab |
| `QUICK_START.md` | Copilot Chat setup in under 5 minutes | Before starting if you are new to Copilot Chat |
| `VERIFY_BEFORE_SEND.md` | Pre-prompt safety checklist | Read before Phase 1. Apply at every phase. |
| `FACILITATOR_GUIDE.md` | Instructor reference — not for participants | Facilitators only |

---

## Sub-Lab Structure

Each sub-lab contains:

```
scenarios/sub-lab-[X]-[name]/
├── SCENARIO_BRIEF.md        ← Start here — half-page context for your role
├── SUB_LAB_GUIDE.md         ← Scenario walkthrough (50 min)
└── exercises/               ← Flawed analysis artifact — spot the errors

data/                        ← All datasets and schemas (shared across all scenarios)
```

---

## Session Flow

| Block | Time | What Happens |
|---|---|---|
| **Shared Demo** | 0–30 min | Facilitator-led: workspace setup, RIFCC-DA framework, first agent demo |
| **Scenario Pick** | 30–32 min | You choose Sub-Lab A, B, or C |
| **Scenario Sprint** | 32–82 min | Work through your chosen sub-lab (3 phases) |
| **Group Debrief** | 82–90 min | Each group shares 1 finding + 1 risk they caught |

### Scenario Sprint — 3 Phases (50 min)

| Phase | Time | What You Do | Agent |
|---|---|---|---|
| **Phase 1** | 10 min | Profile the dataset — find all quality issues | Data Profiling Analyst |
| **Phase 2** | 25 min | Clean the data + run exploratory analysis with Pandas | Data Cleaning Engineer |
| **Phase 3** | 15 min | Build 3 labeled charts, export interactive HTML files, run sharing checklist | Visualization Architect |

---

## Deliverables

You need 3 artifacts in `outputs/` to complete the lab (prefixed with your scenario letter — A, B, or C):

- [ ] `[X]_profile.md` — quality issues documented with counts and severity
- [ ] `[X]_cleaning_decisions.md` — every transformation justified
- [ ] `[X]_chart_*.html` — 3 labeled interactive charts exported as self-contained HTML files, sharing checklist complete

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
- Never include PII-adjacent fields in any output, chart, or exported file (`counterparty_masked`, `user_id_masked`).
- Row counts before and after cleaning are mandatory — silent data loss is not acceptable.
- Sentinel values (999, -1, 9999) must be excluded from all calculations — not treated as real data.
- "Copilot said so" is not a business justification. Every transformation decision requires written reasoning.

---

## Course Module Mapping

| Course Module | Topic | Lab Coverage | Key Files |
|---|---|---|---|
| Module 1 | Setting the Stage — Data Analysis in VS Code | Stage 0: Workspace setup, importing data, Jupyter notebooks | `QUICK_START.md`, `LAB_ACTION_GUIDE.md` Stage 0 |
| Module 2 | Collaborating with Copilot for Data Exploration | Phase 1: Data profiling, schema-grounded prompts, iterative prompting demo | Phase 1 of each scenario |
| Module 3 | Data Cleaning and Transformation with Copilot | Phase 2: Python + SQL cleaning scripts, code validation before execution | Phase 2 of each scenario + SQL reference files |
| Module 4 | Generating Visualizations with Copilot | Phase 3: Chart generation, accuracy review, multi-format export & sharing | Phase 3 of each scenario |
| Module 5 | Responsible Use — Security, Privacy, and Policy | Governance Quick Reference in `LAB_ACTION_GUIDE.md`, `VERIFY_BEFORE_SEND.md`, Group Debrief | `VERIFY_BEFORE_SEND.md`, `reference/responsible_use.md` |
