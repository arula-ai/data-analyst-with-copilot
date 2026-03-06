# Sub-Lab A — Root Cause Analysis: Lab Guide

**50-Minute Hands-On Sprint**
**Workflow:** Codebase Review → Log Profiling → Pattern Analysis → Visualize → Share

---

## Quick Reference

| Stage | Agent | Time | Output |
|---|---|---|---|
| Pre-step | Exploratory Data Analyst | 5 min | Hypotheses from code review |
| 1 — Profile | Data Profiling Analyst | 10 min | `outputs/A_profile.md` |
| 2 — Clean + SQL | Data Cleaning Engineer | 25 min | `outputs/A_cleaning_decisions.md` + `scripts/clean_logs.py` |
| 3 — Visualize | Visualization Architect | 15 min | `outputs/A_visualizations.ipynb` |

---

## Before You Start

- [ ] Read `SCENARIO_BRIEF.md` — understand your role and objective
- [ ] Run through `VERIFY_BEFORE_SEND.md` — know what data can go into a Copilot prompt
- [ ] Open `data/rca_schema.md` — this is your ground truth for column definitions and valid ranges
- [ ] Open `data/app_service.py` — you will read this before touching the log data
- [ ] Open Copilot Chat (`Ctrl+Shift+I` / `Cmd+Shift+I`) and verify agents appear in the dropdown

---

## Pre-Step — Codebase Review (5 min)

**Agent:** Exploratory Data Analyst

**Objective:** Read the source code first. Form hypotheses about what can fail before looking at the logs. This is how real RCA works — code tells you what *can* go wrong, logs tell you what *did* go wrong.

### Actions

1. Open `data/app_service.py`

2. Select agent: **Exploratory Data Analyst**

3. Enter prompt:
   ```
   Review #app_service.py. Identify every comment marked BUG and explain what failure
   each defect could produce at runtime. For each defect: which class, what the defect is,
   what failure mode it produces (what goes wrong at runtime), and which log_level you
   would expect to see in rca_app_logs.csv (INFO / WARN / ERROR / FATAL).
   Plain English only. Do not fix the code.
   ```

4. Review output for:
   - Each BUG comment identified and explained
   - A predicted log_level per defect
   - At least one defect that would explain intermittent failures vs. consistent failures

5. **Write down your top hypothesis:** Which service do you expect to have the most ERROR/FATAL entries based on the code? You will validate this against the logs in Stage 1.

---

## Stage 1 — Log Profiling (10 min)

**Agent:** Data Profiling Analyst

**Objective:** Profile `rca_app_logs.csv` to surface data quality issues and confirm (or challenge) your code review hypotheses.

### Actions

1. Open input file: `data/rca_app_logs.csv`

2. Select agent: **Data Profiling Analyst**

3. Enter prompt — choose one:

   **Option A — Invoke prompt file (recommended):**
   ```
   /data-profiling-analyst
   ```
   Then attach `#rca_app_logs.csv` and `#rca_schema.md`.

   **Option B — Manual prompt:**
   ```
   Profile #rca_app_logs.csv using pandas only.
   Print: total row count, log_level distribution (value_counts), ERROR and FATAL count
   by service_name, null count per column, duplicate request_id count.
   Flag any service with more than 5 FATAL log entries.
   Flag columns where null % > 5%.
   Do not modify the dataframe.
   ```

4. **Run the generated code.** Check the actual numbers — do not trust Copilot's output without executing it.

5. Enter follow-up prompt (paste your actual output):
   ```
   I ran the profiling script and got these results: [paste output].
   Which service has the highest ERROR + FATAL rate? Does this match my hypothesis
   from the code review? What data quality issues need to be addressed before analysis?
   ```

6. Review output for:
   - Total row count documented (must be 300)
   - `log_level` distribution documented with counts
   - ERROR + FATAL count per `service_name`
   - Null counts documented for all 9 columns
   - At least 3 data quality issues identified (see `rca_schema.md` Known Issues)
   - Mixed timestamp formats flagged
   - `user_id_masked` noted as PII-adjacent

7. Save to: `outputs/A_profile.md`
   *(Use template: `templates/profile_template.md`)*

---

## Stage 2 — Clean + SQL (25 min)

**Agent:** Data Cleaning Engineer

**Objective:** Generate a safe, commented cleaning script. Then use SQL to interrogate the cleaned data for error patterns. Both Python and SQL are required here — not optional.

### Part A — Python Cleaning Script (15 min)

1. Select agent: **Data Cleaning Engineer**

2. Enter prompt — choose one:

   **Option A — Invoke prompt file (recommended):**
   ```
   /data-cleaning-engineer
   ```
   Then attach `#rca_app_logs.csv` and `#A_profile.md`.

   **Option B — Manual prompt:**
   ```
   Using the issues in #A_profile.md, generate scripts/clean_logs.py to clean
   #rca_app_logs.csv. Every transformation must have an inline comment explaining
   the business justification. Print row count before cleaning, after each major step,
   and at the end. Save cleaned data to data/rca_app_logs_clean.csv — do not overwrite
   the original. pandas only.
   ```

3. Review the code line by line before running. Verify:
   - Duplicate `request_id` rows handled with justification (keep first? drop all? — document the decision)
   - Mixed timestamp formats in `timestamp` column resolved using `pd.to_datetime(errors='coerce')`
   - Null `message` on ERROR/FATAL rows handled explicitly — not silently dropped
   - Null `response_time_ms` handled — note that FATAL rows are expected to be null (schema business rule)
   - `user_id_masked` never printed in row-level output

4. Save script to: `scripts/clean_logs.py`

5. Save decisions to: `outputs/A_cleaning_decisions.md`
   *(Use template: `templates/cleaning_decisions_template.md`)*

### Part B — SQL Interrogation (10 min)

6. Enter prompt:
   ```
   Using data/rca_app_logs_clean.csv, generate a Python script that:
   1. Loads the CSV into a pandas DataFrame
   2. Writes it to an in-memory SQLite database using sqlite3 (standard library only — no installs)
      conn = sqlite3.connect(':memory:')
      df.to_sql('logs', conn, index=False)
   3. Runs these SQL queries and prints results:
      - Count of rows grouped by service_name and log_level, ordered by service_name
      - Average response_time_ms by service_name (exclude nulls)
      - All ERROR and FATAL rows for the service with the highest failure rate
      - Count of duplicate request_ids remaining (should be 0 after cleaning)
   ```

7. Enter follow-up prompt:
   ```
   Write a SQL query that finds all rows where log_level IN ('ERROR', 'FATAL')
   AND response_time_ms IS NOT NULL, ordered by response_time_ms descending.
   What does this tell us about which service failures are also slow?
   ```

8. Review SQL output for:
   - Counts consistent with your profiling results
   - No `user_id_masked` values in printed results
   - The highest-failure service confirmed or contradicted

---

## Stage 3 — Visualize + Share (15 min)

**Agent:** Visualization Architect

**Objective:** Build 3 charts that make the error pattern visible to a non-technical engineering manager. Export for sharing.

### Actions

1. Open: `starter_notebook.ipynb`

2. Select agent: **Visualization Architect**

3. Enter prompt — choose one:

   **Option A — Invoke prompt file (recommended):**
   ```
   /visualization-architect
   ```
   Then attach `#rca_app_logs_clean.csv`.

   **Option B — Manual prompt:**
   ```
   Using data/rca_app_logs_clean.csv, generate 3 charts as Jupyter notebook cells:
   1. ERROR + FATAL count by service_name (horizontal bar chart)
   2. response_time_ms distribution for the top failing service (histogram)
   3. ERROR and FATAL log count over time by hour (line chart — parse timestamp column first)
   Rules: Y-axis starts at 0. No 3D charts. No user_id_masked in any chart.
   All axes labeled with units. All charts titled.
   Follow each chart with a 2-sentence markdown interpretation.
   ```

4. Review each chart before saving:
   - All 3 charts have descriptive titles
   - All axes labeled with units (e.g., "Number of Errors", "Response Time (ms)", "Hour of Day")
   - Y-axis starts at 0
   - `user_id_masked` not visible anywhere in chart output
   - Each chart followed by a markdown interpretation cell

5. Export charts as PNG:
   ```
   For each chart add before plt.show():
   plt.savefig('outputs/A_chart_01_errors_by_service.png', bbox_inches='tight', dpi=150)
   ```
   Use filenames: `A_chart_01_errors_by_service.png`, `A_chart_02_response_time_dist.png`, `A_chart_03_errors_over_time.png`

6. **Before sharing any exported image:**
   - [ ] Confirmed no `user_id_masked` values visible in the image
   - [ ] Image reviewed by you — not just accepted from Copilot output
   - [ ] Sharing destination is within approved internal channels only

7. Save notebook to: `outputs/A_visualizations.ipynb`

---

## Completion Checklist

Before the debrief, confirm:

- [ ] `outputs/A_profile.md` — log dataset profiled, at least 3 quality issues documented
- [ ] `scripts/clean_logs.py` — cleaning script runs without error, row counts before/after documented
- [ ] `outputs/A_cleaning_decisions.md` — every transformation justified
- [ ] `outputs/A_visualizations.ipynb` — 3 labeled charts with interpretation cells
- [ ] SQL queries ran and results consistent with profiling findings
- [ ] No `user_id_masked` visible in any output, chart, or printed DataFrame

**For the debrief, prepare:**
1. Which service is the most likely root cause — and what evidence supports it
2. One data quality issue you found that could have misled your analysis if uncorrected
3. One thing Copilot generated that you had to review and correct

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Agent not in dropdown | Verify `.github/agents/` folder is at workspace root |
| Mixed timestamp parse fails | Use `pd.to_datetime(df['timestamp'], infer_datetime_format=True, errors='coerce')` |
| `import pandas` fails | Run `pip install pandas matplotlib seaborn numpy jupyter` in terminal |
| CSV not loading | Verify notebook uses `'../data/rca_app_logs.csv'` (relative path, two levels up from notebook) |
| SQL returns empty | Confirm `df.to_sql('logs', conn, index=False)` ran before the SELECT |
| Chart not displaying | Add `%matplotlib inline` at top of notebook or use `plt.show()` |
