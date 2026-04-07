# Lab Action Guide

## Module Map — Where Each Part of This Lab Lives

> The course outline has 5 modules. Here is how they map to what you will do in this lab.

| Module | Topic | Where in This Lab | Key Files |
|--------|-------|-------------------|-----------|
| **Module 1** | Setting the Stage — VS Code Setup | Stage 0: Scenario Setup (this page) | `requirements.txt`, `VERIFY_BEFORE_SEND.md` |
| **Pre-step** | Code Review — Form Hypotheses Before Analysis | Scenarios B + C only: read `data/app_service.py` or `data/legacy_mainframe.py` with Exploratory Data Analyst agent before Phase 1 | `data/app_service.py` (B), `data/legacy_mainframe.py` (C) |
| **Module 2** | Collaborating with Copilot for Data Exploration | Phase 1 — Data Ingestion & Quality Assessment; Phase 2B — Exploratory Analysis | dataset + schema for your scenario; `outputs/[A/B/C]_profile.md` |
| **Module 3** | Data Cleaning & Transformation | Phase 2A — Data Cleaning (Python + SQL) | `scripts/clean_[treasury/logs/mainframe].py` |
| **Module 4** | Generating Visualizations | Phase 3 — Insight Visualization & Reporting | `scripts/visualize_[treasury/logs/mainframe].py`; `outputs/*.html` |
| **Module 5** | Responsible Use — Security, Privacy, Policy | VERIFY_BEFORE_SEND.md + Governance section (bottom of this guide) | `VERIFY_BEFORE_SEND.md`, `reference/responsible_use.md` |

---

## Prerequisites Installation

Before starting the lab, ensure all required dependencies are installed by running the following command in your terminal:

```
pip install -r requirements.txt
```

This installs all packages needed for data analysis, visualization, and reporting across all scenarios.

### Required VS Code Extensions

Install these before the lab begins. Open the Extensions panel (`Ctrl+Shift+X` / `Cmd+Shift+X`) and search for each:

| Extension | Purpose | Install Command |
|-----------|---------|-----------------|
| **GitHub Copilot + Copilot Chat** | AI assistance for all phases | Required |
| **Python + Pylance** | Code execution and IntelliSense | Required |
| **Jupyter** | Notebook support for exploratory work | Recommended |

---

### Importing Data Not In Your Repo

> **In this lab session:** All your data files are already in the `data/` folder — you do not need to import anything. This section covers the real-world pattern for when you receive external data files after the session.

If a stakeholder sends you a data file outside the repo (e.g., via email or shared drive):

1. **Drag the file** into the `data/` folder in VS Code's Explorer panel — or save it directly there
2. **Reference it in Copilot** using `#filename` syntax: `Profile #my_external_file.csv using pandas.`
3. **What Copilot sees:** Only what you explicitly attach with `#filename` or what is in your open editor tab — it does **not** see your full filesystem.

> **Governance reminder:** Before attaching any external file, check its classification against `reference/responsible_use.md`. If it is Confidential or Restricted tier, do not attach it to Copilot Chat — process it locally only.

---

## Enterprise Usage Considerations

**Production-Grade Analytics:** In production financial services environments, analytics workflows are highly governed:

- **Script-Based Workflows**: Analysis is typically converted to Python scripts (`.py` files) for better version control, code review, CI/CD integration, and automated execution.
- **Reproducibility**: Artifacts must be reproducible without manual intervention.

The lab artifacts reflect this enterprise reality: All phases generate production-ready `.py` scripts (`profile_*.py`, `clean_*.py`, `visualize_*.py`) that output automated reports, cleaned data, and self-contained interactive HTML dashboards.

## Quick Reference

| Scenario | Phase | Agent | Prompt | Core Artifact |
|---|---|---|---|---|
| **A — Treasury Anomaly Detection** | Phase 1 — Data Ingestion & Quality Assessment | Data Profiling Analyst | `/data-profiling-analyst` | `outputs/A_profile.md` |
| | Phase 2 — Data Cleaning & Exploratory Analysis | Data Cleaning Engineer → Exploratory Data Analyst | `/data-cleaning-engineer` | `scripts/clean_treasury.py` |
| | Phase 3 — Insight Visualization & Reporting | Visualization Architect | `/visualization-architect` | `scripts/visualize_treasury.py` |
| **B — Root Cause Analysis** | Phase 1 — Data Ingestion & Quality Assessment | Data Profiling Analyst | `/data-profiling-analyst` | `outputs/B_profile.md` |
| | Phase 2 — Analysis Critique, Cleaning & Exploratory Analysis | Data Cleaning Engineer → Exploratory Data Analyst | `/data-cleaning-engineer` | `scripts/clean_logs.py` |
| | Phase 3 — Insight Visualization & Reporting | Visualization Architect | `/visualization-architect` | `scripts/visualize_logs.py` |
| **C — Product Modernization** | Phase 1 — Data Ingestion & Quality Assessment | Data Profiling Analyst | `/data-profiling-analyst` | `outputs/C_profile.md` |
| | Phase 2 — Analysis Critique, Cleaning & Exploratory Analysis | Data Cleaning Engineer → Exploratory Data Analyst | `/data-cleaning-engineer` | `scripts/clean_mainframe.py` |
| | Phase 3 — Insight Visualization & Reporting | Visualization Architect | `/visualization-architect` | `scripts/visualize_mainframe.py` |

---

## How to Use Agents

Agents are selected using the **Agent Selector Dropdown** in Copilot Chat (not by typing `@`).

1. Open Copilot Chat (`Ctrl+Shift+I` / `Cmd+Shift+I`)
2. Click the **Agent Selector Dropdown** (top of chat panel)
3. Select the appropriate agent for your stage
4. Type your prompt and press Enter

## Available Agents

| Agent | Purpose |
|---|---|
| Exploratory Data Analyst | Pre-step code review (Scenarios B and C); EDA business questions in Phase 2B (all scenarios) |
| Data Profiling Analyst | Phase 1 — profile the dataset |
| Data Cleaning Engineer | Phase 2 — generate cleaning script |
| Visualization Architect | Phase 3 — build and export charts |
| Data Risk Reviewer | Optional: classify columns by sensitivity tier before Phase 1 |
| Responsible Use Auditor | Optional: compliance audit of all outputs after Phase 3 |

## Available Prompts

Type `/` in Copilot Chat to see all available slash commands:

| Slash Command | Agent | Purpose |
|---|---|---|
| `/data-profiling-analyst` | Data Profiling Analyst | Profile dataset, flag all quality issues with counts and percentages |
| `/data-cleaning-engineer` | Data Cleaning Engineer | Generate cleaning script with inline justification comments |
| `/exploratory-data-analyst` | Exploratory Data Analyst | Answer specific business questions with pandas |
| `/visualization-architect` | Visualization Architect | Build 3 labeled interactive charts and export as HTML |
| `/data-risk-reviewer` | Data Risk Reviewer | Classify every column by sensitivity tier, flag PII-adjacent fields |
| `/responsible-use-auditor` | Responsible Use Auditor | Audit all scripts and outputs for policy compliance |
| `/eda-analysis` | Exploratory Data Analyst | Run all Phase 2B treasury EDA analyses in one shot and write briefing bullets to `outputs/A_cleaning_decisions.md` |

> **Attaching files:** Use `#filename` syntax in your prompt to attach any file from your workspace. Always attach both the dataset and the schema — Copilot uses the schema to understand column definitions and generate more accurate code.

> **File-based handoffs:** Each stage saves its output to `outputs/`. The next stage attaches that file with `#filename` — you never need to copy-paste terminal output into chat.

> **Saving Copilot-generated code:** When Copilot generates a script in the chat panel, it does NOT automatically create a file. To save it: hover over the code block in the response → click **Insert into New File** (the file icon), then save it with the correct name (e.g., `scripts/profile_treasury.py`). Alternatively, copy the code → create a new file in VS Code (`Ctrl+N`) → paste → `Ctrl+S` and name it. Every "Run the script" step in this guide assumes the file has already been saved.

> **Attaching files with `#`:** Type `#` in Copilot Chat and a file picker appears. Use the picker to navigate to the file — this is more reliable than typing the filename manually, especially for files in subdirectories. If a file doesn't appear, open it in VS Code first (`Ctrl+Click` the filename in Explorer), then try the `#` picker again.

---

## Stage 0 – Scenario Setup (10 min)

> **Pick one scenario** — the one most relevant to your role, or whichever your facilitator assigns. Work through it end-to-end for the full sprint. Scenarios B and C include a 5-minute Pre-step code review before Phase 1. Scenario A starts directly at Phase 1.

### For Facilitators

- [ ] Participants have VS Code with GitHub Copilot Chat enabled
- [ ] Repository is open in VS Code
- [ ] Confirm `outputs/` and `scripts/` directories exist at the repo root (scripts save there — if missing, create them before starting)
- [ ] Verify `.github/agents/` folder is present — agents must appear in the dropdown
- [ ] Verify `.github/prompts/` folder is present — all 6 slash commands must appear with `/`
- [ ] Verify `openpyxl` is installed: `pip install openpyxl` (required for Scenarios A and C)

### For Participants

1. **Setup Checklist**
   - [ ] Open this repository in VS Code
   - [ ] Verify Copilot Chat is active (`Ctrl+Shift+I`)
   - [ ] Click Agent Selector Dropdown to confirm all 6 agents appear
   - [ ] Type `/` in Copilot Chat to confirm all 6 prompts appear
   - [ ] Read `VERIFY_BEFORE_SEND.md` — it is a checklist; open it and confirm each item applies to your output before attaching any file to Copilot or sharing anything outside VS Code

2. **Directory Orientation**
   ```
   data/                            ← All datasets, schemas, and source code
   scenarios/
   ├── sub-lab-A-treasury/
   │   ├── SCENARIO_BRIEF.md        ← Read this before Phase 1
   │   └── exercises/               ← Flawed analysis artifact + SQL cleaning reference + answer key
   ├── sub-lab-B-rca/               ← Same structure
   └── sub-lab-C-modernization/     ← Same structure
   outputs/                         ← All deliverables go here
   scripts/                         ← Your cleaning and visualization scripts go here
   templates/                       ← Copy these to outputs/ for each stage
   reference/                       ← RIFCC-DA framework, policy, glossary, notebooks guide
   ```

3. Read your scenario's `SCENARIO_BRIEF.md` before beginning Phase 1.

### Iterative Prompting Demo — Module 2 Skill

> **Practice before your sprint.** The biggest Copilot mistake in data analysis is accepting the first response. Iterative prompting means refining your request until the output is precise, constrained, and validated.

**Example: Going from vague to precise (3 iterations)**

| Iteration | Prompt | Problem |
|-----------|--------|---------|
| Too vague | `"Analyze this data"` | Copilot produces generic `describe()` output — no constraints, no format |
| Better | `"Profile treasury_payments.xlsx and flag quality issues"` | Better scope, but may include PII, use external libraries, miss sentinel values |
| Precise (RIFCC-DA) | `"Role: Data Profiling Analyst. Inputs: #data/treasury_payments.xlsx and #data/treasury_schema.md. Format: Python pandas script printing row count, null counts per column, sentinel flag counts. Constraints: pandas only, no counterparty_masked in output. Checks: flag any column with null % > 5%, flag values outside schema-defined ranges."` | Complete — role, inputs, format, constraints, checks all specified |

**Try it yourself (2 minutes):**
1. Open Copilot Chat with the **Data Profiling Analyst** agent selected
2. Send the "Too vague" prompt — observe the output
3. Send the "Precise" prompt — compare specificity and constraint compliance
4. Add one more refinement of your own based on what the third prompt is still missing

> This is the core skill of the lab. Every Phase 1–3 prompt you write should be at "Precise" quality before you run any generated code.

---

## Scenario Sprint — Choose Your Sub-Lab

Pick one scenario and open its guide. All phase content, prompts, checklists, and debrief questions live in the sub-lab guide.

| Scenario | File to Open |
|----------|-------------|
| **A — Treasury Anomaly Detection** | `scenarios/sub-lab-A-treasury/SUB_LAB_GUIDE.md` |
| **B — Root Cause Analysis** | `scenarios/sub-lab-B-rca/SUB_LAB_GUIDE.md` |
| **C — Product Modernization** | `scenarios/sub-lab-C-modernization/SUB_LAB_GUIDE.md` |

> Return to this guide for the **Group Debrief** and **Governance Quick Reference** below once your scenario sprint is complete.

---

## Group Debrief

Each participant shares (30 seconds, facilitator-led):

1. **One finding** — state it in one sentence as you would to a VP or Operations Manager
2. **One risk you caught** — a data quality issue or Copilot error that would have affected the analysis
3. **One Copilot correction** — something Copilot generated that you had to fix, and why

The facilitator will ask:
- "Did anyone catch Copilot repeating a flaw from the pre-written analysis?"
- "Did anyone catch Copilot generating output that included a PII-adjacent field?"
- "What's the difference between Copilot making an assumption versus making a mistake?"

---

## Governance Quick Reference — What Data Can Copilot See?

> **Module 5 — Dos and Don'ts.** This answers the most common governance question in enterprise AI use.

### What Copilot DOES See

| What | How it gets to Copilot |
|------|------------------------|
| Your typed prompt text | Always sent |
| Files you attach with `#filename` | Explicitly attached — you control this |
| Your currently open editor tab | Auto-sent as context in some VS Code configurations |

### What Copilot DOES NOT See

| What | Why |
|------|-----|
| Your full repository | Not indexed unless explicitly attached |
| Terminal output | Not sent unless you paste it into chat |
| Files in `outputs/` or `scripts/` | Not auto-attached — use `#filename` to reference |
| Your file system outside the workspace | No access |

### Data Classification — What You Can Attach

| Classification | Examples in This Lab | Copilot OK? |
|----------------|----------------------|-------------|
| **Public** | Chart titles, aggregated statistics | Yes |
| **Internal** | Feature names, team names, log levels | Yes, with care |
| **Confidential** | `counterparty_masked`, `user_id_masked`, financial totals | Attach schema only — never row-level data |
| **Restricted** | Real PII, production credentials | Never attach to Copilot Chat |

### Dos ✅ | Don'ts ❌

**Do:**
- Attach `#schema.md` files — Copilot uses metadata context, not raw data rows
- Drop PII-adjacent columns from DataFrames before attaching CSV files to prompts
- Review every generated script line-by-line before running
- Document every assumption Copilot made in your cleaning decisions

**Don't:**
- Copy-paste terminal output containing PII-adjacent field values into chat
- Accept visualization code that references a PII column in hover text without checking
- Deploy any Copilot-generated script without human review
- Use "Copilot said so" as a business justification for a data decision

> Full policy: `reference/responsible_use.md` | Full preflight checklist: `VERIFY_BEFORE_SEND.md`

---

## Reference Files

| File | When to Use |
|---|---|
| `reference/PROMPT_PATTERN.md` | Write better prompts — RIFCC-DA framework and examples |
| `reference/responsible_use.md` | Governance and data handling policy |
| `reference/GLOSSARY.md` | Definitions for terms used throughout the lab |
| `reference/COPILOT_COMMANDS.md` | Keyboard shortcuts, agents, and all 6 slash commands |
| `reference/data_quality_storytelling.md` | How to communicate findings to a business audience |
| `reference/notebooks_and_jupyter.md` | When to use notebooks vs. scripts; Jupyter setup guide |
| `VERIFY_BEFORE_SEND.md` | Privacy preflight checklist — apply before every prompt |

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Agent not in dropdown | Verify `.github/agents/` folder exists at workspace root with `.agent.md` files |
| Slash command `/` not showing prompts | Verify `.github/prompts/` folder exists with `.prompt.md` files |
| Copilot Chat responds with "To generate tests, open a file and select code to test" | You accidentally selected the built-in `/tests` command — use the Agent dropdown to select the agent first, then type your prompt without browsing `/` commands |
| Copilot Chat not opening | Check extension status bar — sign out and back into GitHub |
| `import pandas` fails | Run `pip install -r requirements.txt` in terminal |
| `import plotly` error | Run `pip install -r requirements.txt` — required for all Phase 3 charts |
| HTML file not opening | Right-click → Open With → Browser. No server needed. |
| Hover tooltip shows PII field | Drop the column before passing to Plotly: `df.drop(columns=['counterparty_masked'])` |
| `import openpyxl` error | Run `pip install -r requirements.txt` — required for Scenarios A and C |
| Excel file not loading | Confirm you are using `pd.read_excel('data/filename.xlsx')` from the workspace root |
| Script fails with FileNotFoundError | Run scripts from the workspace root, not from inside a subfolder |
| Output too generic | Attach files explicitly with `#filename` — do not rely on Copilot's general knowledge |
| `pd.to_datetime()` error | Use `errors='coerce'` — some date columns have mixed formats (intentional) |
| Anomaly rate > 1.0 (Scenario A) | Check you excluded `anomaly_confirmed = 2` before calculating rate |
| Scatter shows 9999 points (Scenario C) | Add `df = df[df['estimated_migration_effort_days'] != 9999]` before plotting |
| PII field in chart output or hover (Scenario A) | Drop before passing to Plotly: `df.drop(columns=['counterparty_masked'])` |
| PII field in chart output or hover (Scenario B) | Drop before passing to Plotly: `df.drop(columns=['user_id_masked'])` |
| Notebook kernel not found | Open Command Palette → "Python: Select Interpreter" → choose Python 3.11 |
| External data file not found by Copilot | Drag the file into the `data/` folder first, then reference with `#filename` |
