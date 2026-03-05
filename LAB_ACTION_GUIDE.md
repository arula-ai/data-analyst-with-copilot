# GitHub Copilot for Data Analysis — Lab Action Guide

**90-Minute Hands-On Lab**
**Workflow:** Risk Review → Data Profiling → Cleaning → Exploratory Analysis → Visualization → Audit → Executive Summary

---

## Quick Reference

| Stage | Agent | Prompt (type `/` in chat) | Input | Core Artifacts |
|-------|-------|--------------------------|-------|----------------|
| 0 | Data Risk Reviewer | `/data-risk-reviewer` | `transaction_alerts.csv` + `schema.md` | `outputs/00_data_risk_review.md` |
| 1 | Data Profiling Analyst | `/data-profiling-analyst` | `transaction_alerts.csv` | `outputs/01_data_profile.md` |
| 2 | Data Cleaning Engineer | `/data-cleaning-engineer` | `transaction_alerts.csv` + `01_data_profile.md` | `scripts/clean_alerts.py` + `outputs/02_cleaning_decisions.md` |
| 3 | Exploratory Data Analyst | `/exploratory-data-analyst` | cleaned dataset | `outputs/03_exploratory_insights.md` |
| 4 | Visualization Architect | `/visualization-architect` | cleaned dataset | `outputs/04_visualizations.ipynb` |
| 5 | Responsible Use Auditor | `/responsible-use-auditor` | all scripts + all outputs | `outputs/05_audit_review.md` |
| 6 | — | — | all outputs | `outputs/06_executive_summary.md` |

**Total Duration:** 90 minutes

---

## How to Use Agents

Agents are selected using the **Agent Selector Dropdown** in Copilot Chat (not by typing `@`).

1. Open Copilot Chat (`Ctrl+Shift+I` / `Cmd+Shift+I`)
2. Click the **Agent Selector Dropdown** (top of chat panel)
3. Select the appropriate agent for your stage
4. Type your prompt and press Enter

The agent constrains how Copilot responds — it acts as a specialist for that stage's task.

---

## How to Use Prompts

Each stage has a **custom prompt file** in `.github/prompts/`. These are pre-written, structured instructions that load automatically when invoked. You have two ways to use them:

### Option A — Invoke with `/` (recommended)

Type `/` in the Copilot Chat input box — a picker appears listing all available prompts. Select the one for your stage:

```
/data-risk-reviewer
```

The full prompt template loads automatically. Then attach the required files using `#filename` and send.

> **Important:** After invoking the prompt with `/`, still attach the data files it asks for. The prompt file tells Copilot *how* to respond — the `#filename` attachments give it the actual data to analyze.

### Option B — Manual copy/paste (fallback)

If the `/` picker doesn't show the prompts, or you want to customize the instruction before sending, copy the prompt text from the stage steps below and paste it directly into Copilot Chat.

Both options produce the same result. Use Option A as your default — it's faster and ensures you're using the validated prompt structure for each stage.

---

## Before You Begin

### Workspace Setup

This repository is your working environment for the full lab. Understand the folder layout before you start:

| Folder | What goes here |
|--------|---------------|
| `data/` | Source datasets and schema files — read-only. Never modify these. |
| `scripts/` | Your generated cleaning scripts (Stage 2 output) |
| `outputs/` | All deliverables — one file per stage |
| `templates/` | Pre-structured output templates — copy and fill in |
| `notebooks/` | Jupyter notebook for visualization work (Stage 4) |
| `reference/` | Policy docs, prompt framework, glossary — consult throughout |
| `.github/agents/` | Custom Copilot agent modes — select from dropdown in each stage |
| `.github/prompts/` | Custom prompt files — invoke with `/prompt-name` in Copilot Chat |

**Before opening any dataset:** Open `data/schema.md` and read the column definitions. This is your ground truth. Copilot does not know what your columns mean unless you tell it — the schema is how you tell it.

### Using Data Files with Copilot

**Files inside this repository** — use the `#filename` syntax in Copilot Chat to attach them:
```
Attach #transaction_alerts.csv and #schema.md before sending.
```
Type `#` in the Copilot Chat input and VS Code will show a file picker.

**Files outside this repository** — do not attach external files containing real or sensitive data. If you need to analyze a file from outside this repo, copy only the relevant non-sensitive portion into a new file in `data/` first, then use `#filename` to attach it. Never paste raw data rows directly into a Copilot prompt.

### VS Code Extensions

Install these before starting if you haven't already:
- **Rainbow CSV** (`mechatroner.rainbow-csv`) — colorizes CSV columns in the editor so you can visually inspect raw data without opening it in Excel
- **Data Wrangler** (`ms-toolsai.datawrangler`) — interactive data preview panel for `.csv` and `.xlsx` files; use it to spot obvious anomalies before writing profiling code

Install via Extensions panel (`Ctrl+Shift+X`), search by name.

### Pre-Lab Checklist

- [ ] VS Code is open with Copilot Chat enabled — test with `Ctrl+Shift+I`
- [ ] `data/transaction_alerts.csv` is visible in the file explorer
- [ ] You have read `VERIFY_BEFORE_SEND.md` — do this now if you haven't
- [ ] `data/schema.md` is your ground truth for all column definitions and valid ranges
- [ ] All outputs go in the `/outputs/` folder — use the templates in `/templates/` to structure them
- [ ] Click the Agent Selector Dropdown to verify all 6 custom agents appear

---

## Stage 0 — Data Risk & Policy Review (10 min)

**Agent:** Data Risk Reviewer (select from dropdown)

**Objective:** Classify every column in the dataset by sensitivity and document what must not appear in any output.

### Actions

1. **Open input files:**

   ```
   data/transaction_alerts.csv
   data/schema.md
   reference/responsible_use.md
   ```

   Read `reference/responsible_use.md` first — understand what "Internal" classification means before activating Copilot.

2. **Select agent:** Click Agent Selector Dropdown → **Data Risk Reviewer**

3. **Enter prompt — choose one:**

   **Option A — Invoke prompt file (recommended):**
   ```
   /data-risk-reviewer
   ```
   Then attach `#transaction_alerts.csv` and `#schema.md` when prompted.

   **Option B — Manual prompt (fallback):**
   ```
   Using #schema.md and #transaction_alerts.csv, classify each of the 15 columns
   by sensitivity tier (Public / Internal / Confidential / Restricted).
   For each column: note the risk and recommend specific handling.
   Flag account_masked explicitly. List all columns that must not appear in any output.
   ```

4. **Review output for:**
   - All 15 columns assessed with a sensitivity tier
   - `account_masked` flagged as requiring caution — not just "low risk"
   - At least 3 specific handling recommendations documented
   - A clear list of columns that must NOT appear in any output or visualization

5. **Save to:** `outputs/00_data_risk_review.md`
   *(Use template: `templates/00_data_risk_review_template.md`)*
   Record your name and date in the analyst sign-off section.

**Hand-Off:** Paste into Copilot Chat:
> *"Summarize what I found in Stage 0 in 3 bullet points."*
> Save as `outputs/00_handoff.md`

---

## Stage 1 — Data Profiling (15 min)

**Agent:** Data Profiling Analyst (select from dropdown)

**Objective:** Generate profiling code to document data quality issues, null counts, and anomalies across all 15 columns.

### Actions

1. **Open input file:**

   ```
   data/transaction_alerts.csv
   ```

2. **Select agent:** Click Agent Selector Dropdown → **Data Profiling Analyst**

3. **Enter prompt — choose one:**

   **Option A — Invoke prompt file (recommended):**
   ```
   /data-profiling-analyst
   ```
   Then attach `#transaction_alerts.csv` and `#schema.md` when prompted.

   **Option B — Manual prompt (fallback):**
   ```
   Generate a pandas profiling script for #transaction_alerts.csv.
   Print: row count, null count per column (as count and %), value_counts for
   all categorical columns, describe() for all numeric columns.
   Flag values outside the valid ranges defined in #schema.md.
   Do not modify the dataframe.
   ```

4. **Run the generated code.** Do not trust Copilot's output without executing it — check the actual numbers.

5. **Enter follow-up prompt** (paste your actual script output):

   ```
   I ran the profiling script and found these results: [paste output].
   Which issues need to be fixed before analysis, and which might be meaningful fraud signals?
   ```

6. **Review output for:**
   - Row count documented (must be 500)
   - Null counts documented for all 15 columns
   - At least 8 data quality issues identified with column name, description, and count
   - `prior_alerts_90d` sentinel value 999 flagged separately — including it would skew fraud rate calculations
   - Results reflect actual data, not Copilot's assumptions

7. **Save to:** `outputs/01_data_profile.md`
   *(Use template: `templates/01_data_profile_template.md`)*

**Hand-Off:** Paste into Copilot Chat:
> *"Summarize what I found in Stage 1 in 3 bullet points."*
> Save as `outputs/01_handoff.md`

---

## Stage 2 — Data Cleaning (20 min)

**Agent:** Data Cleaning Engineer (select from dropdown)

**Objective:** Generate a safe, reversible cleaning script with a written justification for every transformation.

### Actions

1. **Open input files:**

   ```
   data/transaction_alerts.csv
   outputs/01_data_profile.md
   exercises/flawed_cleaning_script.py
   ```

   Identify all 6 labeled errors in `flawed_cleaning_script.py` before writing your own — this primes you to recognize the same mistakes in Copilot-generated code.

2. **Select agent:** Click Agent Selector Dropdown → **Data Cleaning Engineer**

3. **Enter prompt — choose one:**

   **Option A — Invoke prompt file (recommended):**
   ```
   /data-cleaning-engineer
   ```
   Then attach `#transaction_alerts.csv` and `#01_data_profile.md` when prompted.

   **Option B — Manual prompt (fallback):**
   ```
   Using the issues found in #01_data_profile.md, generate scripts/clean_alerts.py
   to clean #transaction_alerts.csv.
   Every transformation must have an inline comment explaining the business justification.
   Print row count before cleaning, after each major step, and at the end.
   Save the cleaned data to data/transaction_alerts_clean.csv — do not overwrite the original.
   ```

4. **Review the code line by line** before running it. Verify each transformation has a justification comment.

5. **Enter follow-up prompt:**

   ```
   For the negative transaction_amount values: what are the business-valid options
   for handling them in a fraud alert dataset? What assumption does each option make?
   ```

6. **Review output for:**
   - Every row drop or imputation has a written justification in both the code and the decisions doc
   - Row count documented before AND after cleaning
   - `account_masked` never printed, exported, or referenced in cleaning logic unnecessarily
   - Negative `transaction_amount` values handled with explicit business justification
   - Date format inconsistencies in `escalation_date` resolved
   - `analyst_confidence = -1` excluded from any mean/average calculation

7. **Save to:** `scripts/clean_alerts.py` + `outputs/02_cleaning_decisions.md`
   *(Use template: `templates/02_cleaning_decisions_template.md`)*

   > **Reusability note:** `clean_alerts.py` is a reusable script. To run it against a new month of alert data, change the input path at the top of the script (e.g., `INPUT_FILE = 'data/transaction_alerts_jan2025.csv'`). The cleaning logic applies to any dataset with the same schema.

**Hand-Off:** Paste into Copilot Chat:
> *"Summarize what I found in Stage 2 in 3 bullet points."*
> Save as `outputs/02_handoff.md`

---

## Stage 2B — SQL Data Exploration (Bonus, 10 min)

**Agent:** Data Cleaning Engineer (select from dropdown)

**Objective:** Use SQL via Python's built-in `sqlite3` to explore and query the cleaned dataset — no additional installs required.

> **This stage is optional.** Complete it after Stage 2 if time allows or you want to practice SQL-based data interrogation alongside Python.

### Actions

1. **Open input file:**

   ```
   data/transaction_alerts_clean.csv
   ```

2. **Select agent:** Click Agent Selector Dropdown → **Data Cleaning Engineer**

3. **Enter prompt:**

   ```
   Using #transaction_alerts_clean.csv, generate a Python script that:
   1. Loads the CSV into a pandas DataFrame
   2. Writes it to an in-memory SQLite database using df.to_sql()
   3. Runs the following SQL queries and prints results:
      - Count of rows by alert_type
      - Average risk_score by region (excluding any nulls)
      - Count of confirmed fraud (fraud_confirmed = 1) by client_segment
      - Top 5 analyst_ids by number of alerts handled
   Use sqlite3 from the Python standard library only. No external packages.
   ```

4. **Enter follow-up prompt:**

   ```
   Now write a SQL query that finds all alerts where risk_score > 0.8
   AND fraud_confirmed = 1, ordered by transaction_amount descending.
   Explain what this query is useful for in a fraud operations context.
   ```

5. **Review output for:**
   - No external library imports — only `sqlite3`, `pandas`, and standard library
   - SQL queries return meaningful counts, not empty results
   - Results consistent with what your Python cleaning script produced

6. **Save to:** `scripts/explore_alerts.sql` *(optional — paste the SQL queries only, no Python wrapper)*

---

## Stage 3 — Exploratory Analysis (15 min)

**Agent:** Exploratory Data Analyst (select from dropdown)

**Objective:** Answer business questions about fraud patterns using the cleaned dataset and translate findings into plain-English insights.

### Actions

1. **Open input file:**

   ```
   data/transaction_alerts_clean.csv
   ```

2. **Select agent:** Click Agent Selector Dropdown → **Exploratory Data Analyst**

3. **Enter prompt — choose one:**

   **Option A — Invoke prompt file (recommended):**
   ```
   /exploratory-data-analyst
   ```
   Then attach `#transaction_alerts_clean.csv` when prompted.

   **Option B — Manual prompt (fallback):**
   ```
   Using data/transaction_alerts_clean.csv and #schema.md:
   What alert types have the highest confirmed fraud rates by region?
   Show the code, then explain the finding in plain English for a fraud operations manager.
   State all assumptions. Do not claim causation from correlation.
   ```

4. **Enter second prompt:**

   ```
   Which client segment (Retail, Business, Premier, Institutional) has the highest
   fraud confirmation rate? Is this meaningful given the sample sizes? State your assumptions.
   ```

5. **Review output for:**
   - At least 3 specific business questions answered in plain English
   - All percentages cross-checked against raw counts
   - No causal claims — "correlates with" not "causes"
   - Assumptions explicitly listed (e.g., "this excludes rows with null transaction_amount")
   - Limitations explicitly listed (e.g., "this covers only Q4 2024")

6. **Quality checkpoint** — before saving, open `reference/data_quality_storytelling.md` and run the Pre-Sharing Checklist against your findings:
   - Every percentage has a raw count behind it
   - No causal language ("causes") — only correlational ("correlates with")
   - Sample sizes disclosed for all subgroup comparisons
   - All null exclusions documented

7. **Save to:** `outputs/03_exploratory_insights.md`
   *(Use template: `templates/03_exploratory_insights_template.md`)*

**Hand-Off:** Paste into Copilot Chat:
> *"Summarize what I found in Stage 3 in 3 bullet points."*
> Save as `outputs/03_handoff.md`

---

## Stage 4 — Visualization (15 min)

**Agent:** Visualization Architect (select from dropdown)

**Objective:** Generate at least 4 labeled, honest charts from the cleaned dataset.

### Actions

1. **Open input files:**

   ```
   data/transaction_alerts_clean.csv
   exercises/flawed_visualization.py
   notebooks/starter_analysis.ipynb
   ```

   Identify all 4 labeled errors in `flawed_visualization.py` — know what a bad chart looks like before building a good one.

2. **Select agent:** Click Agent Selector Dropdown → **Visualization Architect**

3. **Enter prompt — choose one:**

   **Option A — Invoke prompt file (recommended):**
   ```
   /visualization-architect
   ```
   Then attach `#transaction_alerts_clean.csv` when prompted.

   **Option B — Manual prompt (fallback):**
   ```
   Using data/transaction_alerts_clean.csv and #schema.md, generate 4 charts
   as Jupyter notebook cells:
   1. risk_score distribution by fraud_confirmed status
   2. Confirmed fraud rate by alert_type (bar chart)
   3. transaction_amount distribution by client_segment (box plot)
   4. prior_alerts_90d vs confirmed fraud rate (bar chart)
   Rules: Y-axis starts at 0. No 3D charts. No account_masked in any chart.
   All axes labeled with units. All charts titled.
   Follow each chart cell with a 2–3 sentence markdown interpretation.
   ```

4. **Review each chart** before saving:
   - All 4 charts have titles
   - All axes labeled with units (e.g., "Transaction Amount ($)", "Fraud Confirmation Rate (%)")
   - Y-axis starts at 0 — no truncated scales
   - No 3D charts
   - `account_masked` not visible in any chart
   - Each chart followed by a 2–3 sentence interpretation cell

5. **Export charts as images:**

   ```
   For each of the 4 charts, add plt.savefig() before plt.show():
   plt.savefig('outputs/chart_01_risk_score_distribution.png', bbox_inches='tight', dpi=150)
   ```

   Compliance note: verify no `account_masked` values appear in any exported image before saving.

6. **Save to:** `outputs/04_visualizations.ipynb`

   > **Connecting to reporting outputs:** The charts in this notebook feed directly into Stage 6 (Executive Summary). Export each chart as a PNG using `plt.savefig('outputs/chart_name.png', dpi=150, bbox_inches='tight')` so they can be embedded in the executive summary document or shared with stakeholders without requiring a running notebook environment.

**Hand-Off:** Paste into Copilot Chat:
> *"Summarize what I found in Stage 4 in 3 bullet points."*
> Save as `outputs/04_handoff.md`

---

## Stage 5 — Responsible Use Audit (10 min)

**Agent:** Responsible Use Auditor (select from dropdown)

**Objective:** Review all generated code and outputs for security risks, privacy violations, and policy compliance issues.

### Actions

1. **Open input files:**

   ```
   scripts/clean_alerts.py
   outputs/04_visualizations.ipynb
   ```

2. **Select agent:** Click Agent Selector Dropdown → **Responsible Use Auditor**

3. **Enter prompt — choose one:**

   **Option A — Invoke prompt file (recommended):**
   ```
   /responsible-use-auditor
   ```
   Then attach `#clean_alerts.py`, `#03_exploratory_insights.md`, and `#04_visualizations.ipynb` when prompted.

   **Option B — Manual prompt (fallback):**
   ```
   Review #clean_alerts.py for: external network calls, hardcoded sensitive values,
   operations that modify the source file, and any logic that could expose account_masked.
   Rate each finding: Low / Medium / High / Critical.
   ```

4. **Enter second prompt:**

   ```
   Review #04_visualizations.ipynb for: account_masked in chart labels,
   unmasked data in output cells, and chart integrity issues.
   ```

5. **Review output for:**
   - `clean_alerts.py` reviewed line by line — not just summarized
   - Any external library calls identified and flagged
   - `account_masked` confirmed absent from all chart outputs and print statements
   - At least one finding documented (even "no issues" must show evidence of review)
   - Required corrective actions listed or explicitly stated as "none required"

6. **Save to:** `outputs/05_audit_review.md`
   *(Use template: `templates/05_audit_review_template.md`)*

**Hand-Off:** Paste into Copilot Chat:
> *"Summarize what I found in Stage 5 in 3 bullet points."*
> Save as `outputs/05_handoff.md`

---

## Stage 6 — Executive Summary (5 min)

**Agent:** None — write this yourself, use Copilot only for drafting assistance.

**Objective:** Write a 1-page summary for a VP of Fraud Operations — 3 insights, 2 recommendations, 1 risk, 1 limitation.

### Actions

1. **Open input file:**

   ```
   templates/06_executive_summary_template.md
   ```

2. **Quality checkpoint** — open `reference/data_quality_storytelling.md` and apply the Audience Calibration table for "VP / Executive" before writing a single word.

3. Fill in the Context paragraph yourself — do not delegate this to Copilot.

4. Draft your 3 key insights in plain English. No code, no jargon, no percentages without context. Apply the One-Sentence Test from the storytelling guide to each finding.

5. **Enter prompt** (Copilot Chat, no agent selected):

   ```
   Draft an executive summary for a VP of Fraud Operations based on these findings:
   [paste your 3 key findings from Stage 3].
   Format: 3 numbered insights, 2 actionable recommendations, 1 risk note, 1 data limitation.
   Plain English. No jargon. No code. Maximum 400 words.
   ```

6. Verify every claim is traceable to a Stage 3 finding before saving.

7. **Review output for:**
   - Exactly 3 key insights — no more, no less
   - Exactly 2 actionable recommendations tied to the insights
   - At least 1 explicit risk note
   - At least 1 data limitation
   - Written for a non-technical executive — no code, no SQL, no pandas references
   - No `account_masked` or identifiable information anywhere in the document

8. **Save to:** `outputs/06_executive_summary.md`
   *(Use template: `templates/06_executive_summary_template.md`)*

---

## Completion Checklist

- [ ] `outputs/00_data_risk_review.md` — sensitivity ratings and handling recommendations
- [ ] `outputs/01_data_profile.md` — at least 8 data quality issues documented
- [ ] `scripts/clean_alerts.py` — commented cleaning script with row counts before/after
- [ ] `outputs/02_cleaning_decisions.md` — justification for every transformation
- [ ] `outputs/03_exploratory_insights.md` — fraud pattern insights in plain English
- [ ] `outputs/04_visualizations.ipynb` — at least 4 labeled charts with interpretations
- [ ] `outputs/05_audit_review.md` — code and output compliance review
- [ ] `outputs/06_executive_summary.md` — 3 insights, 2 recommendations, 1 risk, 1 limitation

**No artifact = incomplete lab. No exceptions.**

---

---

## Alternative Scenarios

> **Complete the main lab (Stages 0–6) first.** These scenarios are extension exercises that apply the same Copilot workflow to two additional datasets. Each takes approximately 20–30 minutes.

---

### Scenario A — Root Cause Analysis (RCA)

**Dataset:** `data/rca_app_logs.csv` — 300 synthetic application log entries from a fictional microservices platform
**Codebase:** `data/app_service.py` — stub Python microservices application with intentional defects
**Schema:** `data/rca_schema.md`
**Goal:** Review the application source code to form hypotheses, then validate those hypotheses against log data.

#### Stage A0 — Codebase Review

**Agent:** Exploratory Data Analyst (select from dropdown)

1. **Open input file:**
   ```
   data/app_service.py
   ```

2. **Select agent:** Click Agent Selector Dropdown → **Exploratory Data Analyst**

3. **Enter prompt:**
   ```
   Review #app_service.py. Identify every comment marked BUG and explain what failure
   each defect could produce at runtime. For each defect: class name, line description,
   failure mode (what goes wrong), and which log_level you would expect in rca_app_logs.csv
   (INFO / WARN / ERROR / FATAL). Plain English. No code fixes.
   ```

4. **Review output for:** Which services are likely to produce the most ERROR/FATAL entries based on the code defects. Note your hypotheses — you will test them against the log data in Stage A1.

#### Stage A1 — Log Profiling

**Agent:** Data Profiling Analyst (select from dropdown)

1. **Open input file:**
   ```
   data/rca_app_logs.csv
   ```

2. **Select agent:** Click Agent Selector Dropdown → **Data Profiling Analyst**

3. **Enter prompt:**
   ```
   Profile #rca_app_logs.csv using pandas.
   Print: total row count, log_level distribution (value_counts), ERROR and FATAL count
   by service_name, null count per column, duplicate request_id count.
   Flag any service with more than 5 FATAL log entries.
   ```

4. **Review output for:** null response_time_ms count, duplicate request_ids, mixed timestamp formats

#### Stage A2 — Pattern Analysis

**Agent:** Exploratory Data Analyst (select from dropdown)

3. **Enter prompt:**
   ```
   Using #rca_app_logs.csv and #rca_schema.md:
   Which service_name has the highest ERROR + FATAL rate as a percentage of its total log entries?
   Is there a time-based pattern — do errors cluster at specific hours?
   Show code and plain-English interpretation.
   ```

4. **Enter follow-up prompt:**
   ```
   For the service with the highest error rate: are there specific error_codes that repeat?
   What does the pattern suggest about the root cause?
   ```

#### Stage A3 — RCA Output

5. **Enter prompt** (no agent):
   ```
   Based on the log analysis above, draft a root cause analysis summary with:
   - Most likely failing service and evidence
   - Top 2 error patterns observed
   - 1 hypothesis for root cause
   - 1 recommended next investigation step
   Plain English. Maximum 300 words.
   ```

6. **Save to:** `outputs/rca_findings.md`

---

### Scenario B — Product Usage & Modernization Analysis

**Dataset:** `data/mainframe_usage.xlsx` — 400 synthetic mainframe feature usage records
**Codebase:** `data/legacy_mainframe.py` — stub legacy Python module implementing the mainframe features
**Schema:** `data/mainframe_schema.md`
**Goal:** Review the legacy source code to understand which features are technically complex to migrate, then use the usage data to prioritize modernization by business impact.

> **Note:** This scenario uses an Excel file (`.xlsx`). Use `pd.read_excel('data/mainframe_usage.xlsx')` to load it. Requires `openpyxl`: `pip install openpyxl`.

#### Stage B0 — Legacy Code Review

**Agent:** Exploratory Data Analyst (select from dropdown)

1. **Open input file:**
   ```
   data/legacy_mainframe.py
   ```

2. **Select agent:** Click Agent Selector Dropdown → **Exploratory Data Analyst**

3. **Enter prompt:**
   ```
   Review #legacy_mainframe.py. For each function: function name, what it does in plain English,
   which defect (marked BUG) it contains, and why that defect would make migration to a modern
   service more complex or risky. Do not fix the code — describe only.
   ```

4. **Review output for:** Which functions have the most complex migration risks (hardcoded values, no error handling, no idempotency). Note which function names correspond to feature_name values in mainframe_usage.xlsx — you will cross-reference these in Stage B1.

#### Stage B1 — Usage Profiling

**Agent:** Data Profiling Analyst (select from dropdown)

1. **Open input file:**
   ```
   data/mainframe_usage.xlsx
   data/mainframe_schema.md
   ```

2. **Select agent:** Click Agent Selector Dropdown → **Data Profiling Analyst**

3. **Enter prompt:**
   ```
   Profile data/mainframe_usage.xlsx using pandas (pd.read_excel).
   Print: row count, null count per column, negative error_rate_pct count,
   sentinel 9999 count in estimated_migration_effort_days,
   value_counts for team, legacy_flag, and modernization_priority.
   Flag all data quality issues found.
   ```

#### Stage B2 — Feature Analysis

**Agent:** Exploratory Data Analyst (select from dropdown)

3. **Enter prompt:**
   ```
   Using data/mainframe_usage.xlsx and #mainframe_schema.md:
   Which team has the highest proportion of legacy features (legacy_flag = True)?
   Which features have the highest monthly_active_users AND are still on legacy infrastructure?
   Exclude rows where monthly_active_users is null. Show code and plain-English findings.
   ```

4. **Enter follow-up prompt:**
   ```
   Rank the top 5 legacy features by modernization_priority = 'High' AND monthly_active_users descending.
   Exclude rows where estimated_migration_effort_days = 9999 (effort unknown).
   These are the highest-impact, highest-readiness modernization candidates.
   ```

#### Stage B3 — Modernization Recommendation

5. **Enter prompt** (no agent):
   ```
   Based on the analysis above, draft a modernization recommendation with:
   - Top 3 features recommended for immediate modernization and why
   - Which team has the most critical legacy exposure
   - 1 data quality caveat that affects the reliability of this analysis
   Plain English. No code. Maximum 400 words.
   ```

6. **Save to:** `outputs/modernization_recommendations.md`

---

### Scenario C — Operational Anomaly Detection & Trend Analysis

**Dataset:** `data/treasury_payments.xlsx` — 500 synthetic Treasury payment records from Meridian Asset Management
**Schema:** `data/treasury_schema.md`
**Goal:** Detect abnormal payment patterns, surface anomalies, and identify trends requiring operational attention.

> **Note:** This scenario uses an Excel file (`.xlsx`). Use `pd.read_excel('data/treasury_payments.xlsx')` to load it. Requires `openpyxl`: `pip install openpyxl`.

#### Stage C1 — Payment Data Profiling

**Agent:** Data Profiling Analyst (select from dropdown)

1. **Open input files:**
   ```
   data/treasury_payments.xlsx
   data/treasury_schema.md
   ```

2. **Select agent:** Click Agent Selector Dropdown → **Data Profiling Analyst**

3. **Enter prompt:**
   ```
   Profile data/treasury_payments.xlsx using pandas (pd.read_excel).
   Print: row count, null count per column, payment_type value_counts,
   negative payment_amount count, sentinel 999 count in prior_alerts_90d,
   anomaly_confirmed value_counts, risk_score values > 1.0, blank review_status count,
   duplicate payment_id count, mixed date format count in payment_date.
   Flag every data quality issue found with column name, description, and count.
   ```

4. **Review output for:** all 11 issues identified (see `data/treasury_schema.md` Known Issues section)

---

#### Stage C2 — Anomaly & Trend Analysis

**Agent:** Exploratory Data Analyst (select from dropdown)

1. **Open input file:**
   ```
   data/treasury_payments.xlsx
   ```

2. **Select agent:** Click Agent Selector Dropdown → **Exploratory Data Analyst**

3. **Enter prompt:**
   ```
   Using data/treasury_payments.xlsx and #treasury_schema.md:
   Which payment_type has the highest confirmed anomaly rate (anomaly_confirmed = 1)?
   Is there a correlation between payment_amount and anomaly_confirmed?
   Exclude rows where anomaly_confirmed = 2 and payment_amount is null or negative.
   Show code and plain-English findings with supporting statistics.
   ```

4. **Enter follow-up prompt:**
   ```
   Are there regional patterns in confirmed anomalies — which region has the highest anomaly rate?
   Is there a time-based trend in payment_date — do anomalies cluster in specific weeks of Q4 2024?
   Exclude analyst_confidence = -1 and prior_alerts_90d = 999 from all calculations.
   Plain-English interpretation required for each finding.
   ```

5. **Review output for:** findings stated in plain English, all exclusions documented, no causal claims

---

#### Stage C3 — Treasury Operations Report

6. **Enter prompt** (no agent):
   ```
   Based on the analysis above, draft a treasury operations summary with:
   - Top 2 anomaly patterns observed, with supporting evidence (numbers from the analysis)
   - 1 trend that requires operational attention and why
   - 1 data quality caveat that limits confidence in these findings
   Written for a Treasury Operations Manager. Plain English. No code. Maximum 350 words.
   ```

7. **Save to:** `outputs/treasury_findings.md`

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Agent not in dropdown | Verify `.github/agents/` folder exists with `.agent.md` files |
| Copilot Chat not opening | Check extension status bar — sign out and back into GitHub |
| Jupyter kernel not starting | `Ctrl+Shift+P` → "Python: Select Interpreter" → choose Python 3.10+ |
| `import pandas` fails | Run `pip install pandas matplotlib seaborn numpy jupyter` in terminal |
| CSV not loading in notebook | Verify notebook uses `'../data/transaction_alerts.csv'` (relative path) |
| Output too generic | Reference files with `#transaction_alerts.csv` — use the `#` file picker |
| `pd.to_datetime()` error on dates | Use `errors='coerce'` — 5 rows have MM/DD/YYYY format (intentional issue) |
