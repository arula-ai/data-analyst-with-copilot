# Lab Action Guide

You will complete all three scenarios in order: A, B, then C. Finish each scenario fully before moving to the next.

## Quick Reference

| Scenario | Phase | Agent | Prompt | Core Artifact |
|---|---|---|---|---|
| **A — Treasury Anomaly Detection** | Phase 1 — Data Ingestion & Quality Assessment | Data Profiling Analyst | `/data-profiling-analyst` | `outputs/A_profile.md` |
| | Phase 2 — Data Cleaning & Exploratory Analysis | Data Cleaning Engineer → Exploratory Data Analyst | `/data-cleaning-engineer` | `scripts/clean_treasury.py` |
| | Phase 3 — Insight Visualization & Reporting | Visualization Architect | `/visualization-architect` | `outputs/A_visualizations.ipynb` |
| **B — Root Cause Analysis** | Phase 1 — Data Ingestion & Quality Assessment | Data Profiling Analyst | `/data-profiling-analyst` | `outputs/B_profile.md` |
| | Phase 2 — Analysis Critique, Cleaning & SQL Interrogation | Data Cleaning Engineer | `/data-cleaning-engineer` | `scripts/clean_logs.py` |
| | Phase 3 — Insight Visualization & Reporting | Visualization Architect | `/visualization-architect` | `outputs/B_visualizations.ipynb` |
| **C — Product Modernization** | Phase 1 — Data Ingestion & Quality Assessment | Data Profiling Analyst | `/data-profiling-analyst` | `outputs/C_profile.md` |
| | Phase 2 — Analysis Critique, Cleaning & SQL Prioritization | Data Cleaning Engineer | `/data-cleaning-engineer` | `scripts/clean_mainframe.py` |
| | Phase 3 — Insight Visualization & Reporting | Visualization Architect | `/visualization-architect` | `outputs/C_visualizations.ipynb` |

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
| Exploratory Data Analyst | Pre-step code review (Scenarios B and C) |
| Data Profiling Analyst | Stage 1 — profile the dataset |
| Data Cleaning Engineer | Stage 2 — generate cleaning script |
| Visualization Architect | Stage 3 — build and export charts |

## Available Prompts

| Prompt | Purpose |
|---|---|
| `/data-profiling-analyst` | Profile dataset, flag quality issues |
| `/data-cleaning-engineer` | Generate cleaning script with justifications |
| `/visualization-architect` | Build labeled charts as notebook cells |

> **Attaching files:** Use `#filename` syntax in your prompt to attach any file from your workspace. Always attach both the dataset and the schema — Copilot uses the schema to understand column definitions and generate more accurate code.

> **File-based handoffs:** Each stage saves its output to `outputs/`. The next stage attaches that file with `#filename` — you never need to copy-paste terminal output into chat.

---

## Stage 0 – Scenario Setup (5 min)

### For Facilitators

- [ ] Participants have VS Code with GitHub Copilot Chat enabled
- [ ] Repository is open in VS Code
- [ ] Verify `.github/agents/` folder is present — agents must appear in the dropdown
- [ ] Verify `openpyxl` is installed: `pip install openpyxl` (required for Scenarios A and C)

### For Participants

1. **Setup Checklist**
   - [ ] Open this repository in VS Code
   - [ ] Verify Copilot Chat is active (`Ctrl+Shift+I`)
   - [ ] Click Agent Selector Dropdown to confirm agents appear
   - [ ] Type `/` in Copilot Chat to confirm prompts appear
   - [ ] Read `VERIFY_BEFORE_SEND.md` — apply before every prompt

2. **Directory Orientation**
   ```
   data/                            ← All datasets, schemas, and source code
   scenarios/
   ├── sub-lab-A-treasury/
   │   ├── SCENARIO_BRIEF.md        ← Read this before Phase 1
   │   ├── exercises/               ← Flawed analysis artifact (used in Phase 2 of Scenarios B and C)
   │   └── starter_notebook.ipynb   ← Your working notebook for Stage 3
   ├── sub-lab-B-rca/               ← Same structure
   └── sub-lab-C-modernization/     ← Same structure
   outputs/                         ← All deliverables go here
   scripts/                         ← Your cleaning scripts go here
   templates/                       ← Copy these to outputs/ for each stage
   reference/                       ← RIFCC-DA framework, policy, glossary
   ```

3. Read `scenarios/sub-lab-A-treasury/SCENARIO_BRIEF.md` before beginning Phase 1.

---

## Scenario A — Treasury Anomaly Detection

> You have been given an Excel dataset of 500 flagged treasury payments. Using Copilot, explore and analyze the data to detect abnormal payment patterns, surface anomalies, and identify trends that may require operational attention.

---

## Phase 1 – Data Ingestion & Quality Assessment (10 min)

**Agent:** Data Profiling Analyst (select from dropdown)
**Prompt:** `/data-profiling-analyst`

> **`counterparty_masked` is PII-adjacent** — never include it in any output, chart, or print statement.

### Actions

1. **Open and inspect the raw data before prompting:**
   ```
   data/treasury_payments.xlsx
   data/treasury_schema.md
   ```
   Read the Known Issues section in `treasury_schema.md` before writing any prompt. Sentinel values (`999` in `prior_alerts_90d`, `-1` in `analyst_confidence`), invalid flag values (`anomaly_confirmed = 2`), and PII-adjacent columns (`counterparty_masked`) are all documented there.

2. **Select agent:** Click Agent Selector Dropdown → **Data Profiling Analyst**

3. **Prompt**

   **Option 1 — Prompt file (recommended):**
   Type `/data-profiling-analyst` in Copilot Chat, then attach `#treasury_payments.xlsx` and `#treasury_schema.md`. The schema gives Copilot the column definitions and valid ranges it needs to distinguish sentinel values from genuine data.

   **Option 2 — Custom prompt:**
   ```
   Profile data/treasury_payments.xlsx using pandas (pd.read_excel, requires openpyxl).
   Print: row count, null count per column (count and %), value_counts for payment_type,
   region, client_segment, and review_status, describe() for numeric columns.
   Flag: negative payment_amount values, sentinel 999 in prior_alerts_90d,
   analyst_confidence = -1 (treat as "not rated" — not a real score),
   anomaly_confirmed = 2 (invalid for a binary flag), blank review_status entries,
   duplicate payment_id count, mixed date formats in payment_date.
   Do not modify the dataframe. Do not print counterparty_masked values.
   ```

4. **Run the generated script from the terminal:**
   ```
   python scripts/profile_treasury.py
   ```
   The script prints results to the terminal **and** automatically saves the quality summary to `outputs/A_profile.md`. Review the actual numbers before proceeding — do not move to Phase 2 until you have confirmed the row count and quality issues match `treasury_schema.md`.

   > `outputs/A_profile.md` is the handoff to Phase 2 — attach it with `#A_profile.md` in your next prompt.

5. **Review output for:**
   - [ ] Row count documented (must be 500)
   - [ ] All known data quality issues identified (see `treasury_schema.md` Known Issues)
   - [ ] Sentinel `999` in `prior_alerts_90d` flagged separately from nulls
   - [ ] Sentinel `-1` in `analyst_confidence` flagged separately — noted as "not rated"
   - [ ] `anomaly_confirmed = 2` flagged as invalid for a binary flag
   - [ ] `counterparty_masked` noted as PII-adjacent
   - [ ] Mixed date formats in `payment_date` flagged

---

## Phase 2 – Data Cleaning & Exploratory Analysis (20 min)

### Part A — Data Cleaning (10 min)

**Agent:** Data Cleaning Engineer (select from dropdown)
**Prompt:** `/data-cleaning-engineer`

1. **Select agent:** Click Agent Selector Dropdown → **Data Cleaning Engineer**

2. **Prompt**

   **Option 1 — Prompt file (recommended):**
   Type `/data-cleaning-engineer` in Copilot Chat, then attach `#treasury_payments.xlsx` and `#A_profile.md`. The profile doc contains the issues to fix — Copilot uses it to generate targeted cleaning logic.

   **Option 2 — Custom prompt:**
   ```
   Using the issues in #A_profile.md, generate scripts/clean_treasury.py to clean
   data/treasury_payments.xlsx (use pd.read_excel). Every transformation must have
   an inline comment explaining the business justification. Print row count before
   cleaning, after each major step, and at the end. Save cleaned data to
   data/treasury_payments_clean.csv. pandas only. Do not overwrite the original xlsx.
   Do not include counterparty_masked in any printed output.
   ```

3. **Review the code line by line before running.** Verify:
   - `anomaly_confirmed = 2` rows handled with explicit justification — not silently dropped
   - `prior_alerts_90d = 999` excluded from calculations — not imputed as a real value
   - `analyst_confidence = -1` excluded from all averaging — treated as "not rated"
   - Negative `payment_amount` handled with business justification
   - Mixed date formats resolved with `pd.to_datetime(errors='coerce')`
   - `counterparty_masked` never printed in row-level output

4. **Run the script from the terminal:**
   ```
   python scripts/clean_treasury.py
   ```
   Confirm row counts print at each step and `data/treasury_payments_clean.csv` is created.

5. **Follow-up prompt:**
   ```
   For the anomaly_confirmed = 2 rows: what are the business-valid options for handling them?
   What assumption does each option make about the validity of these records?
   ```

6. **Review output for:**
   - [ ] Every transformation has a written justification comment
   - [ ] Row count documented before AND after cleaning
   - [ ] `counterparty_masked` never printed, exported, or referenced unnecessarily
   - [ ] All three sentinel exclusions documented in cleaning decisions

7. **Save to:** `scripts/clean_treasury.py` + `outputs/A_cleaning_decisions.md`
   *(Use template: `templates/cleaning_decisions_template.md`)*

### Part B — Exploratory Analysis (10 min)

**Agent:** Exploratory Data Analyst (select from dropdown)

8. **Select agent:** Click Agent Selector Dropdown → **Exploratory Data Analyst**

9. **Custom prompt:**
   ```
   Using #treasury_payments_clean.csv, answer these three business questions with pandas:
   1. Anomaly confirmation rate by payment_type — exclude rows where anomaly_confirmed = 2.
      Which payment type has the highest confirmed anomaly rate?
   2. Weekly trend in confirmed anomalies — parse payment_date, group by week, count
      anomaly_confirmed = 1. Is the rate increasing, decreasing, or stable?
   3. Regional pattern — average payment_amount by region for confirmed anomalies only.
      Which region has the highest average confirmed anomaly amount?
   Print results for each question. Do not include counterparty_masked in any output.
   ```

10. **Review output for:**
    - [ ] Anomaly rates calculated on clean rows only (no `anomaly_confirmed = 2`)
    - [ ] `counterparty_masked` absent from all printed results
    - [ ] Each of the 3 business questions answered with actual numbers

11. **Document findings** — note the answers to all 3 questions in `outputs/A_cleaning_decisions.md`.

---

## Phase 3 – Insight Visualization & Reporting (15 min)

**Agent:** Visualization Architect (select from dropdown)
**Prompt:** `/visualization-architect`

### Actions

1. **Open:** `scenarios/sub-lab-A-treasury/starter_notebook.ipynb`

2. **Select agent:** Click Agent Selector Dropdown → **Visualization Architect**

3. **Prompt**

   **Option 1 — Prompt file (recommended):**
   Type `/visualization-architect` in Copilot Chat, then attach `#treasury_payments_clean.csv`.

   **Option 2 — Custom prompt:**
   ```
   Using data/treasury_payments_clean.csv, generate 3 interactive charts as Jupyter notebook cells using plotly.express:
   1. Confirmed anomaly rate by payment_type (bar chart)
      — exclude rows where anomaly_confirmed is not 0 or 1
   2. payment_amount distribution for confirmed anomalies only (histogram)
   3. Confirmed anomaly count by week (line chart — parse payment_date first, group by week)
   Rules: Y-axis starts at 0 (fig.update_yaxes(rangemode='tozero')). No 3D charts.
   No counterparty_masked in any chart label, axis, or hover field.
   All axes labeled with units. All charts titled.
   Export each chart: fig.write_html('outputs/A_chart_0N_name.html')
   Follow each chart with a 2-sentence markdown interpretation.
   ```

4. **Review each chart before saving:**
   - [ ] All 3 charts have descriptive titles
   - [ ] Axes labeled with units (e.g., "Confirmed Anomaly Rate", "Payment Amount ($)", "Week")
   - [ ] Y-axis starts at 0 (`rangemode='tozero'`) — confirm `fig.update_yaxes` is in the code
   - [ ] `counterparty_masked` not visible in chart labels, axis values, or hover tooltips
   - [ ] Anomaly rate chart excludes `anomaly_confirmed = 2` — confirm in the code
   - [ ] Each chart followed by a markdown interpretation cell

5. **Export charts as interactive HTML** — confirm each chart cell includes:
   ```python
   fig.write_html('outputs/A_chart_01_anomaly_by_type.html')
   ```
   Filenames: `A_chart_01_anomaly_by_type.html`, `A_chart_02_amount_distribution.html`, `A_chart_03_anomaly_trend.html`

   Each `.html` is a self-contained interactive file — open in any browser, no server needed. Hover over data points to explore values.

6. **Before sharing any exported file:**
   - [ ] `counterparty_masked` not visible in the chart (including hover tooltips)
   - [ ] File reviewed by you — not accepted directly from Copilot output
   - [ ] Sharing destination is within approved internal channels only

7. **Save notebook to:** `outputs/A_visualizations.ipynb`

### Completion Checklist — Scenario A

- [ ] `outputs/A_profile.md` — payment dataset profiled, all known quality issues documented
- [ ] `scripts/clean_treasury.py` — runs without error; row counts before/after printed
- [ ] `outputs/A_cleaning_decisions.md` — every transformation justified; sentinel handling for `prior_alerts_90d = 999`, `analyst_confidence = -1`, and `anomaly_confirmed = 2` each documented; answers to 3 business questions recorded
- [ ] `outputs/A_visualizations.ipynb` — 3 labeled interactive charts with interpretation cells; HTML exports saved to `outputs/`
- [ ] `counterparty_masked` absent from all outputs, charts, and printed DataFrames
- [ ] Sentinel values (`prior_alerts_90d = 999`, `analyst_confidence = -1`) excluded from all calculations

**Bonus (if time permits):** Open `scenarios/sub-lab-A-treasury/exercises/flawed_treasury_analysis.md`. Now that you have done the analysis yourself — can you spot what the previous analyst got wrong?

**For the debrief:**
1. Which payment type has the highest confirmed anomaly rate — and what trend you observed week over week
2. One data quality issue that could have produced misleading anomaly rates if uncorrected
3. One thing Copilot generated that you had to correct

---

## Scenario B — Root Cause Analysis

> You have been given the platform source code and 300 log entries. Using Copilot, analyze the logs, interpret error patterns, correlate code behavior, and identify the most likely root cause of the incident.

---

## Pre-Step — Codebase Review (5 min)

**Agent:** Exploratory Data Analyst (select from dropdown)

Before touching the log data, read the source code to form a hypothesis about what can fail. Code tells you what *can* go wrong — logs tell you what *did* go wrong.

1. **Open:** `data/app_service.py`

2. **Select agent:** Click Agent Selector Dropdown → **Exploratory Data Analyst**

3. **Custom prompt:**
   ```
   Review #app_service.py. Identify every comment marked BUG and explain what failure
   each defect could produce at runtime. For each defect: which class, what the defect is,
   what failure mode it produces, and which log_level you would expect to see in
   rca_app_logs.csv (INFO / WARN / ERROR / FATAL).
   Plain English only. Do not fix the code.
   ```

4. **Review output for:**
   - Each BUG comment identified and explained
   - A predicted log_level per defect
   - At least one defect that explains intermittent vs. consistent failures

5. **Write down your hypothesis:** Which service do you expect to have the most ERROR/FATAL entries? You will validate this in Phase 2.

---

## Phase 1 – Data Ingestion & Quality Assessment (10 min)

**Agent:** Data Profiling Analyst (select from dropdown)
**Prompt:** `/data-profiling-analyst`

> **`user_id_masked` is PII-adjacent** — never include it in any output, chart, or print statement.

### Actions

1. **Open and inspect the raw data before prompting:**
   ```
   data/rca_app_logs.csv
   data/rca_schema.md
   ```
   Read `rca_schema.md` — the Known Issues section documents duplicates, expected nulls on FATAL rows, and invalid message fields.

2. **Select agent:** Click Agent Selector Dropdown → **Data Profiling Analyst**

3. **Prompt**

   **Option 1 — Prompt file (recommended):**
   Type `/data-profiling-analyst` in Copilot Chat, then attach `#rca_app_logs.csv` and `#rca_schema.md`.

   **Option 2 — Custom prompt:**
   ```
   Profile data/rca_app_logs.csv using pandas only.
   Print: total row count, log_level distribution (value_counts), ERROR and FATAL count
   by service_name, null count per column, duplicate request_id count.
   Flag any service with more than 5 FATAL log entries.
   Flag columns where null % > 5%.
   Do not modify the dataframe. Do not print user_id_masked values.
   ```

4. **Run the generated script from the terminal:**
   ```
   python scripts/profile_logs.py
   ```
   The script prints results to the terminal **and** automatically saves the quality summary to `outputs/B_profile.md`. Review the actual numbers — confirm row count and error distribution before proceeding.

   > `outputs/B_profile.md` is the handoff to Phase 2 — attach it with `#B_profile.md` in your next prompt.

5. **Review output for:**
   - [ ] Total row count documented (must be 300)
   - [ ] `log_level` distribution documented with counts
   - [ ] ERROR + FATAL count per `service_name`
   - [ ] Null counts documented for all columns
   - [ ] Duplicate `request_id` count documented
   - [ ] Mixed timestamp formats flagged
   - [ ] `user_id_masked` noted as PII-adjacent

---

## Phase 2 – Analysis Critique, Cleaning & SQL Interrogation (25 min)

**Agent:** Data Cleaning Engineer (select from dropdown)
**Prompt:** `/data-cleaning-engineer`

### Step 1 — Critique the Flawed Analysis (5 min)

The previous RCA analyst produced a report with embedded errors. Before generating your own script, use Copilot to identify every flaw — this prevents you from repeating the same mistakes.

1. **Select agent:** Click Agent Selector Dropdown → **Data Cleaning Engineer**

2. **Custom prompt:**
   ```
   Review #flawed_rca_analysis.md and #B_profile.md.
   Identify every analytical flaw in the report. For each flaw:
   1. State the claim made in the report
   2. Explain why it is wrong (logical, statistical, or data quality error)
   3. State what the correct approach would be, referencing specific issues from B_profile.md
   ```

3. **Review output for:**
   - [ ] All 5 flaws identified (the document contains exactly 5)
   - [ ] Each flaw linked to a specific data quality issue (duplicates, sentinel values, causal vs. correlational claims, or completeness errors)
   - [ ] Correct approach stated for each — not just "this is wrong"

### Step 2 — Generate the Corrected Cleaning Script (10 min)

4. **Follow-up prompt** (same agent, same session):
   ```
   Now generate scripts/clean_logs.py that correctly cleans data/rca_app_logs.csv,
   avoiding all the flaws identified above. Every transformation must have an inline
   comment explaining the business justification. Print row count before cleaning,
   after each major step, and at the end. Save cleaned data to data/rca_app_logs_clean.csv.
   Do not overwrite the original. pandas only. Do not print user_id_masked values.
   ```

5. **Review the code line by line before running.** Verify:
   - Duplicate `request_id` rows removed with justification
   - Mixed timestamp formats resolved using `pd.to_datetime(errors='coerce')`
   - Null `response_time_ms` on FATAL rows retained — schema says these are expected nulls
   - Null `response_time_ms` on ERROR rows documented — not silently dropped
   - `user_id_masked` never printed in row-level output

6. **Run the script from the terminal:**
   ```
   python scripts/clean_logs.py
   ```
   Confirm row counts print at each step and `data/rca_app_logs_clean.csv` is created.

7. **Review output for:**
   - [ ] Every transformation has a written justification comment
   - [ ] Row count documented before AND after cleaning
   - [ ] Duplicate removal documented with count
   - [ ] Null `response_time_ms` on FATAL rows retained with comment
   - [ ] `user_id_masked` never printed, exported, or referenced unnecessarily

8. **Save to:** `scripts/clean_logs.py` + `outputs/B_cleaning_decisions.md`
   *(Use template: `templates/cleaning_decisions_template.md`)*

### Step 3 — SQL Interrogation (10 min)

9. **Custom prompt:**
   ```
   Using data/rca_app_logs_clean.csv, generate a Python script that:
   1. Loads the CSV into a pandas DataFrame
   2. Writes it to an in-memory SQLite database using sqlite3 (standard library — no installs)
      conn = sqlite3.connect(':memory:')
      df.to_sql('logs', conn, index=False)
   3. Runs these SQL queries and prints results:
      - Count of rows grouped by service_name and log_level, ordered by service_name
      - Average response_time_ms by service_name (exclude nulls)
      - All ERROR and FATAL rows for the service with the highest failure rate
      - Count of duplicate request_ids remaining (should be 0 after cleaning)
   Do not include user_id_masked in any SELECT output.
   ```

10. **Follow-up prompt:**
    ```
    Write a SQL query that finds all rows where log_level IN ('ERROR', 'FATAL')
    AND response_time_ms IS NOT NULL, ordered by response_time_ms descending.
    Does the service with the most failures also have the highest response times?
    Does this confirm or contradict your original hypothesis from the code review?
    ```

11. **Review output for:**
    - [ ] Counts consistent with profiling results
    - [ ] No `user_id_masked` in printed results
    - [ ] SQL results confirm or explicitly contradict the code review hypothesis

---

## Phase 3 – Insight Visualization & Reporting (15 min)

**Agent:** Visualization Architect (select from dropdown)
**Prompt:** `/visualization-architect`

### Actions

1. **Open:** `scenarios/sub-lab-B-rca/starter_notebook.ipynb`

2. **Select agent:** Click Agent Selector Dropdown → **Visualization Architect**

3. **Prompt**

   **Option 1 — Prompt file (recommended):**
   Type `/visualization-architect` in Copilot Chat, then attach `#rca_app_logs_clean.csv`.

   **Option 2 — Custom prompt:**
   ```
   Using data/rca_app_logs_clean.csv, generate 3 interactive charts as Jupyter notebook cells using plotly.express:
   1. ERROR + FATAL count by service_name (horizontal bar chart)
   2. response_time_ms distribution for the top failing service (histogram)
   3. ERROR and FATAL log count over time by hour (line chart — parse timestamp column first)
   Rules: Y-axis starts at 0 (fig.update_yaxes(rangemode='tozero')). No 3D charts.
   No user_id_masked in any chart label, axis, or hover field.
   All axes labeled with units. All charts titled.
   Export each chart: fig.write_html('outputs/B_chart_0N_name.html')
   Follow each chart with a 2-sentence markdown interpretation.
   ```

4. **Review each chart before saving:**
   - [ ] All 3 charts have descriptive titles
   - [ ] All axes labeled with units (e.g., "Number of Errors", "Response Time (ms)", "Hour of Day")
   - [ ] Y-axis starts at 0 (`rangemode='tozero'`) — confirm `fig.update_yaxes` is in the code
   - [ ] `user_id_masked` not visible in chart labels, axis values, or hover tooltips
   - [ ] Each chart followed by a markdown interpretation cell

5. **Export charts as interactive HTML** — confirm each chart cell includes:
   ```python
   fig.write_html('outputs/B_chart_01_errors_by_service.html')
   ```
   Filenames: `B_chart_01_errors_by_service.html`, `B_chart_02_response_time_dist.html`, `B_chart_03_errors_over_time.html`

   Each `.html` is a self-contained interactive file — hover over bars to see exact error counts per service.

6. **Before sharing any exported file:**
   - [ ] No `user_id_masked` values visible in the chart (including hover tooltips)
   - [ ] File reviewed by you — not accepted directly from Copilot output
   - [ ] Sharing destination is within approved internal channels only

7. **Save notebook to:** `outputs/B_visualizations.ipynb`

### Completion Checklist — Scenario B

- [ ] `outputs/B_profile.md` — log dataset profiled, all known quality issues documented
- [ ] `scripts/clean_logs.py` — runs without error; row counts before/after printed
- [ ] `outputs/B_cleaning_decisions.md` — every transformation justified; all 5 critique flaws addressed
- [ ] `outputs/B_visualizations.ipynb` — 3 labeled interactive charts with interpretation cells; HTML exports saved to `outputs/`
- [ ] SQL queries ran; highest-failure service confirmed or contradicted by data
- [ ] No `user_id_masked` visible in any output, chart, or printed DataFrame

**For the debrief:**
1. Which service is the most likely root cause — and what SQL evidence supports it
2. One flaw from the flawed analysis that would have produced a wrong conclusion if repeated
3. One thing Copilot generated that you had to correct

---

## Scenario C — Product Modernization

> You have been given the legacy mainframe source module and 400 rows of feature usage metrics. Using Copilot, examine the code, analyze the usage data, identify high-impact features, and produce a prioritized modernization recommendation.

---

## Pre-Step — Legacy Code Review (5 min)

**Agent:** Exploratory Data Analyst (select from dropdown)

Before touching the usage data, assess the technical complexity of each legacy function. A feature that is heavily used AND technically complex to migrate is your highest priority.

1. **Open:** `data/legacy_mainframe.py`

2. **Select agent:** Click Agent Selector Dropdown → **Exploratory Data Analyst**

3. **Custom prompt:**
   ```
   Review #legacy_mainframe.py. For each function: function name, what it does in plain English,
   which defects (marked BUG) it contains, and why those defects would make migration to a modern
   service more complex or risky. Rate each function: Low / Medium / High migration complexity.
   Do not fix the code — describe only. Plain English.
   ```

4. **Review output for:**
   - All functions assessed — confirm the count matches the file before accepting the output
   - Each function has a migration complexity rating with reasoning
   - At least one function rated High with a clear link to a specific BUG comment
   - BUG comments connected to concrete migration risks (e.g., no idempotency → duplicate records on retry)

5. **Write down your hypothesis:** Which function is the highest-priority modernization candidate based on code complexity? Cross-reference against usage data in Phase 1.

---

## Phase 1 – Data Ingestion & Quality Assessment (15 min)

**Agent:** Data Profiling Analyst (select from dropdown)
**Prompt:** `/data-profiling-analyst`

### Actions

1. **Open and inspect the raw data before prompting:**
   ```
   data/mainframe_usage.xlsx
   data/mainframe_schema.md
   ```
   Read `mainframe_schema.md` — the Known Issues section documents sentinel values and invalid entries.

2. **Select agent:** Click Agent Selector Dropdown → **Data Profiling Analyst**

3. **Prompt**

   **Option 1 — Prompt file (recommended):**
   Type `/data-profiling-analyst` in Copilot Chat, then attach `#mainframe_usage.xlsx` and `#mainframe_schema.md`.

   **Option 2 — Custom prompt:**
   ```
   Profile data/mainframe_usage.xlsx using pandas (pd.read_excel, requires openpyxl).
   Print: row count, null count per column, value_counts for team, legacy_flag,
   and modernization_priority, describe() for numeric columns.
   Flag: negative error_rate_pct values, sentinel 9999 in estimated_migration_effort_days
   (this means "effort not yet assessed" — do not treat as a real value),
   null monthly_active_users (do not treat as zero — telemetry was not collected),
   mixed date formats in last_accessed_date.
   Do not modify the dataframe.
   ```

4. **Run the generated script from the terminal:**
   ```
   python scripts/profile_mainframe.py
   ```
   The script prints results to the terminal **and** automatically saves the quality summary to `outputs/C_profile.md`. Review the actual numbers — confirm row count and sentinel value distribution before proceeding.

   > `outputs/C_profile.md` is the handoff to Phase 2 — attach it with `#C_profile.md` in your next prompt.

5. **Review output for:**
   - [ ] Row count documented (must be 400)
   - [ ] All known data quality issues identified (see `mainframe_schema.md` Known Issues)
   - [ ] Sentinel 9999 in `estimated_migration_effort_days` flagged separately — not treated as a real value
   - [ ] Null `monthly_active_users` flagged — explicitly noted as "telemetry not collected", not zero
   - [ ] Negative `error_rate_pct` values flagged as invalid
   - [ ] `legacy_flag` and `modernization_priority` distributions documented

---

## Phase 2 – Analysis Critique, Cleaning & SQL Prioritization (25 min)

**Agent:** Data Cleaning Engineer (select from dropdown)
**Prompt:** `/data-cleaning-engineer`

### Step 1 — Critique the Flawed Analysis (5 min)

The previous modernization analyst produced a report with embedded errors. Before generating your own script, use Copilot to identify every flaw.

1. **Select agent:** Click Agent Selector Dropdown → **Data Cleaning Engineer**

2. **Custom prompt:**
   ```
   Review #flawed_modernization_analysis.md and #C_profile.md.
   Identify every analytical flaw in the report. For each flaw:
   1. State the claim made in the report
   2. Explain why it is wrong (logical, statistical, or data quality error)
   3. State what the correct approach would be, referencing specific issues from C_profile.md
   ```

3. **Review output for:**
   - [ ] All 5 flaws identified (the document contains exactly 5)
   - [ ] Each flaw linked to a specific data quality issue (sentinel values, causal claims, logical contradictions, or unverified statistics)
   - [ ] Correct approach stated for each — not just "this is wrong"

### Step 2 — Generate the Corrected Cleaning Script (10 min)

4. **Follow-up prompt** (same agent, same session):
   ```
   Now generate scripts/clean_mainframe.py that correctly cleans data/mainframe_usage.xlsx
   (use pd.read_excel), avoiding all the flaws identified above. Every transformation must
   have an inline comment explaining the business justification. Print row count before
   cleaning, after each major step, and at the end. Save cleaned data to
   data/mainframe_usage_clean.csv. pandas only. Do not overwrite the original xlsx.
   ```

5. **Review the code line by line before running.** Verify:
   - Sentinel 9999 in `estimated_migration_effort_days` excluded from calculations — not imputed or dropped
   - Negative `error_rate_pct` handled with business justification
   - Null `monthly_active_users` documented as "telemetry not collected" — NOT imputed as 0
   - Mixed date formats resolved with `pd.to_datetime(errors='coerce')`

6. **Run the script from the terminal:**
   ```
   python scripts/clean_mainframe.py
   ```
   Confirm row counts print at each step and `data/mainframe_usage_clean.csv` is created.

7. **Follow-up prompt:**
   ```
   For null monthly_active_users: what are the business-valid options for handling them?
   Why does imputing 0 introduce bias in a modernization prioritization context?
   ```

8. **Review output for:**
   - [ ] Every transformation has a written justification comment
   - [ ] Row count documented before AND after cleaning
   - [ ] Sentinel 9999 handling explicitly documented — not silently dropped
   - [ ] Null `monthly_active_users` not imputed as 0 — decision documented

9. **Save to:** `scripts/clean_mainframe.py` + `outputs/C_cleaning_decisions.md`
   *(Use template: `templates/cleaning_decisions_template.md`)*

### Step 3 — SQL Prioritization (10 min)

10. **Custom prompt:**
    ```
    Using data/mainframe_usage_clean.csv, generate a Python script that:
    1. Loads the CSV into a pandas DataFrame
    2. Writes it to an in-memory SQLite database using sqlite3 (standard library — no installs)
       conn = sqlite3.connect(':memory:')
       df.to_sql('features', conn, index=False)
    3. Runs these SQL queries and prints results:
       - Count of legacy features (legacy_flag = True) grouped by team
       - Top 5 features by monthly_active_users where legacy_flag = True (exclude null users)
       - Features where modernization_priority = 'High' AND estimated_migration_effort_days != 9999,
         ordered by monthly_active_users descending
       - Average error_rate_pct by team (exclude negative values)
    ```

11. **Follow-up prompt:**
    ```
    Write a SQL query that ranks the top 3 legacy features that are both:
    - modernization_priority = 'High'
    - monthly_active_users in the top 25% of all features
    Order by monthly_active_users descending. Exclude rows where effort = 9999.
    Do the top candidates match your hypothesis from the code review? Explain why or why not.
    ```

12. **Review output for:**
    - [ ] Sentinel 9999 correctly excluded from the ranked list
    - [ ] Results consistent with profiling findings
    - [ ] Top candidates reconciled with code review complexity ratings

---

## Phase 3 – Insight Visualization & Reporting (15 min)

**Agent:** Visualization Architect (select from dropdown)
**Prompt:** `/visualization-architect`

### Actions

1. **Open:** `scenarios/sub-lab-C-modernization/starter_notebook.ipynb`

2. **Select agent:** Click Agent Selector Dropdown → **Visualization Architect**

3. **Prompt**

   **Option 1 — Prompt file (recommended):**
   Type `/visualization-architect` in Copilot Chat, then attach `#mainframe_usage_clean.csv`.

   **Option 2 — Custom prompt:**
   ```
   Using data/mainframe_usage_clean.csv, generate 3 interactive charts as Jupyter notebook cells using plotly.express:
   1. Count of legacy vs modern features by team (grouped bar chart)
   2. monthly_active_users distribution for legacy features only (histogram)
   3. Scatter plot: monthly_active_users (x) vs estimated_migration_effort_days (y),
      colored by modernization_priority — exclude rows where effort = 9999
   Rules: Y-axis starts at 0 for bar and histogram (fig.update_yaxes(rangemode='tozero')).
   No 3D charts. All axes labeled with units. All charts titled.
   Export each chart: fig.write_html('outputs/C_chart_0N_name.html')
   Follow each chart with a 2-sentence markdown interpretation.
   ```

4. **Review each chart before saving:**
   - [ ] All 3 charts have descriptive titles
   - [ ] Axes labeled with units (e.g., "Monthly Active Users", "Migration Effort (days)")
   - [ ] Y-axis starts at 0 on bar chart and histogram — confirm `fig.update_yaxes` is in the code
   - [ ] Scatter plot excludes sentinel 9999 — confirm in the code before accepting output
   - [ ] Each chart followed by a markdown interpretation cell

5. **Export charts as interactive HTML** — confirm each chart cell includes:
   ```python
   fig.write_html('outputs/C_chart_01_legacy_by_team.html')
   ```
   Filenames: `C_chart_01_legacy_by_team.html`, `C_chart_02_user_distribution.html`, `C_chart_03_effort_vs_usage.html`

   The scatter plot is especially useful as HTML — hover over each point to see feature name, team, and exact usage count without any data being obscured.

6. **Before sharing any exported file:**
   - [ ] File reviewed by you — not accepted directly from Copilot output
   - [ ] No internal identifiers visible that should not be shared (check hover tooltips)
   - [ ] Sharing destination is within approved internal channels only

7. **Save notebook to:** `outputs/C_visualizations.ipynb`

### Completion Checklist — Scenario C

- [ ] `outputs/C_profile.md` — usage dataset profiled, all known quality issues documented
- [ ] `scripts/clean_mainframe.py` — runs without error; row counts before/after printed
- [ ] `outputs/C_cleaning_decisions.md` — every transformation justified; all 5 critique flaws addressed; sentinel 9999 and null monthly_active_users decisions documented
- [ ] `outputs/C_visualizations.ipynb` — 3 labeled interactive charts with interpretation cells; HTML exports saved to `outputs/`
- [ ] SQL queries ran and top modernization candidates identified
- [ ] Sentinel 9999 excluded from all calculations and charts

**For the debrief:**
1. Which 2–3 features you recommend for immediate modernization — and why (cite both usage data and code complexity)
2. One flaw from the flawed analysis that would have produced a wrong recommendation if repeated
3. One thing Copilot generated that you had to correct

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

## Reference Files

| File | When to Use |
|---|---|
| `reference/PROMPT_PATTERN.md` | Write better prompts — RIFCC-DA framework and examples |
| `reference/responsible_use.md` | Governance and data handling policy |
| `reference/GLOSSARY.md` | Definitions for terms used throughout the lab |
| `reference/COPILOT_COMMANDS.md` | Keyboard shortcuts and Copilot Chat commands |
| `reference/data_quality_storytelling.md` | How to communicate findings to a business audience |
| `VERIFY_BEFORE_SEND.md` | Privacy preflight checklist — apply before every prompt |

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Agent not in dropdown | Verify `.github/agents/` folder exists at workspace root with `.agent.md` files |
| Copilot Chat not opening | Check extension status bar — sign out and back into GitHub |
| Jupyter kernel not starting | `Ctrl+Shift+P` → "Python: Select Interpreter" → choose Python 3.10+ |
| `import pandas` fails | Run `pip install pandas plotly numpy jupyter openpyxl` in terminal |
| `import plotly` error | Run `pip install plotly` — required for all Stage 3 charts |
| HTML file not opening | Open the `.html` file directly in a browser — no server needed. Right-click → Open With → Browser |
| Hover tooltip shows PII field | Drop the column before passing to Plotly: `df.drop(columns=['counterparty_masked'])` |
| `import openpyxl` error | Run `pip install openpyxl` — required for Scenarios A and C |
| Excel file not loading | Confirm you are using `pd.read_excel('data/filename.xlsx')` from the workspace root |
| Script fails with FileNotFoundError | Run scripts from the workspace root, not from inside a subfolder |
| Output too generic | Attach files explicitly with `#filename` — do not rely on Copilot's general knowledge |
| `pd.to_datetime()` error | Use `errors='coerce'` — some date columns have mixed formats (intentional) |
| SQL returns empty | Confirm `df.to_sql('tablename', conn, index=False)` ran before the SELECT |
| Anomaly rate > 1.0 (Scenario A) | Check you excluded `anomaly_confirmed = 2` before calculating rate |
| Scatter shows 9999 points (Scenario C) | Add `df = df[df['estimated_migration_effort_days'] != 9999]` before plotting |
| PII field in chart output or hover (Scenario A) | Drop before passing to Plotly: `df.drop(columns=['counterparty_masked'])` |
| PII field in chart output or hover (Scenario B) | Drop before passing to Plotly: `df.drop(columns=['user_id_masked'])` |
