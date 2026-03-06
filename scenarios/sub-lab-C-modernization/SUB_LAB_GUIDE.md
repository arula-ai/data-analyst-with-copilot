# Sub-Lab B — Product Usage & Modernization Analysis: Lab Guide

**50-Minute Hands-On Sprint**
**Workflow:** Code Complexity Review → Usage Profiling → Feature Analysis → Visualize → Share

---

## Quick Reference

| Stage | Agent | Time | Output |
|---|---|---|---|
| Pre-step | Exploratory Data Analyst | 5 min | Migration complexity notes per function |
| 1 — Profile | Data Profiling Analyst | 10 min | `outputs/B_profile.md` |
| 2 — Clean + SQL | Data Cleaning Engineer | 25 min | `outputs/B_cleaning_decisions.md` + `scripts/clean_mainframe.py` |
| 3 — Visualize | Visualization Architect | 15 min | `outputs/B_visualizations.ipynb` |

---

## Before You Start

- [ ] Read `SCENARIO_BRIEF.md` — understand your role and objective
- [ ] Run through `VERIFY_BEFORE_SEND.md` — know what data can go into a Copilot prompt
- [ ] Open `data/mainframe_schema.md` — this is your ground truth for column definitions and valid ranges
- [ ] Open `data/legacy_mainframe.py` — you will read this before touching the usage data
- [ ] Confirm `openpyxl` is installed: `pip install openpyxl`
- [ ] Open Copilot Chat (`Ctrl+Shift+I` / `Cmd+Shift+I`) and verify agents appear in the dropdown

---

## Pre-Step — Legacy Code Review (5 min)

**Agent:** Exploratory Data Analyst

**Objective:** Understand the technical complexity of each legacy function before looking at usage data. A feature that's heavily used AND technically complex to migrate is your highest priority.

### Actions

1. Open `data/legacy_mainframe.py`

2. Select agent: **Exploratory Data Analyst**

3. Enter prompt:
   ```
   Review #legacy_mainframe.py. For each function: function name, what it does in plain English,
   which defects (marked BUG) it contains, and why those defects would make migration to a modern
   service more complex or risky. Rate each function: Low / Medium / High migration complexity.
   Do not fix the code — describe only. Plain English.
   ```

4. Review output for:
   - All 6 functions assessed
   - At least one function rated High migration complexity with clear reasoning
   - BUG comments correctly identified and linked to migration risk (e.g., no idempotency → duplicate records on retry)

5. **Write down your top hypothesis:** Which function do you expect to be the highest-priority modernization candidate based on code complexity alone? You will cross-reference this against usage data in Stage 1.

---

## Stage 1 — Usage Data Profiling (10 min)

**Agent:** Data Profiling Analyst

**Objective:** Profile `mainframe_usage.xlsx` to understand the data quality issues and usage distribution across features.

### Actions

1. Open input file: `data/mainframe_usage.xlsx`

2. Select agent: **Data Profiling Analyst**

3. Enter prompt — choose one:

   **Option A — Invoke prompt file (recommended):**
   ```
   /data-profiling-analyst
   ```
   Then attach `#mainframe_usage.xlsx` and `#mainframe_schema.md`.

   **Option B — Manual prompt:**
   ```
   Profile data/mainframe_usage.xlsx using pandas (pd.read_excel, requires openpyxl).
   Print: row count, null count per column, value_counts for team, legacy_flag,
   and modernization_priority, describe() for numeric columns.
   Flag: negative error_rate_pct values, sentinel 9999 in estimated_migration_effort_days,
   null monthly_active_users, mixed date formats in last_accessed_date.
   Do not modify the dataframe.
   ```

4. **Run the generated code.** Check the actual numbers.

5. Enter follow-up prompt (paste your actual output):
   ```
   I ran the profiling script and got these results: [paste output].
   Which team has the most legacy features? Which features have both high monthly_active_users
   AND are still on legacy infrastructure? What data quality issues need fixing before analysis?
   ```

6. Review output for:
   - Row count documented (must be 400)
   - All 4 known data quality issues identified (see `mainframe_schema.md` Known Issues)
   - Sentinel 9999 in `estimated_migration_effort_days` flagged separately — not treated as a real effort estimate
   - Negative `error_rate_pct` values flagged as invalid
   - `legacy_flag` distribution documented

7. Save to: `outputs/B_profile.md`
   *(Use template: `templates/profile_template.md`)*

---

## Stage 2 — Clean + SQL (25 min)

**Agent:** Data Cleaning Engineer

**Objective:** Generate a safe, commented cleaning script. Then use SQL to rank features by modernization priority. Both Python and SQL are required — not optional.

### Part A — Python Cleaning Script (15 min)

1. Select agent: **Data Cleaning Engineer**

2. Enter prompt — choose one:

   **Option A — Invoke prompt file (recommended):**
   ```
   /data-cleaning-engineer
   ```
   Then attach `#mainframe_usage.xlsx` and `#B_profile.md`.

   **Option B — Manual prompt:**
   ```
   Using the issues in #B_profile.md, generate scripts/clean_mainframe.py to clean
   data/mainframe_usage.xlsx (use pd.read_excel). Every transformation must have an inline
   comment explaining the business justification. Print row count before cleaning, after each
   major step, and at the end. Save cleaned data to data/mainframe_usage_clean.csv.
   pandas only. Do not overwrite the original xlsx.
   ```

3. Review the code line by line before running. Verify:
   - Sentinel 9999 in `estimated_migration_effort_days` excluded from calculations — not imputed or dropped
   - Negative `error_rate_pct` handled with business justification (are they data errors or reversals?)
   - Null `monthly_active_users` documented as "telemetry not collected" — NOT imputed as 0
   - Mixed date formats in `last_accessed_date` resolved with `pd.to_datetime(errors='coerce')`

4. Save script to: `scripts/clean_mainframe.py`

5. Save decisions to: `outputs/B_cleaning_decisions.md`
   *(Use template: `templates/cleaning_decisions_template.md`)*

### Part B — SQL Prioritization (10 min)

6. Enter prompt:
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
        ordered by monthly_active_users descending — these are high-impact, assessable candidates
      - Average error_rate_pct by team (exclude negative values)
   ```

7. Enter follow-up prompt:
   ```
   Write a SQL query that ranks the top 3 legacy features that are both:
   - modernization_priority = 'High'
   - monthly_active_users in the top 25% of all features
   Order by monthly_active_users descending. Exclude rows where effort = 9999.
   Explain why these 3 are the strongest modernization candidates.
   ```

8. Review SQL output for:
   - Results consistent with profiling findings
   - Sentinel 9999 correctly excluded from the ranked list
   - The recommended features are explainable in plain English

---

## Stage 3 — Visualize + Share (15 min)

**Agent:** Visualization Architect

**Objective:** Build 3 charts that make the modernization case visible to an engineering manager who hasn't seen the data.

### Actions

1. Open: `starter_notebook.ipynb`

2. Select agent: **Visualization Architect**

3. Enter prompt — choose one:

   **Option A — Invoke prompt file (recommended):**
   ```
   /visualization-architect
   ```
   Then attach `#mainframe_usage_clean.csv`.

   **Option B — Manual prompt:**
   ```
   Using data/mainframe_usage_clean.csv, generate 3 charts as Jupyter notebook cells:
   1. Count of legacy vs modern features by team (grouped bar chart)
   2. monthly_active_users distribution for legacy features only (histogram)
   3. Scatter plot: monthly_active_users (x) vs estimated_migration_effort_days (y),
      colored by modernization_priority — exclude rows where effort = 9999
   Rules: Y-axis starts at 0 (except scatter). No 3D charts. All axes labeled with units.
   All charts titled. Follow each chart with a 2-sentence markdown interpretation.
   ```

4. Review each chart before saving:
   - All 3 charts have descriptive titles
   - Axes labeled with units (e.g., "Monthly Active Users", "Migration Effort (days)")
   - Scatter excludes 9999 sentinel — confirm in the code
   - No internal or sensitive column values exposed as tick labels
   - Each chart followed by a markdown interpretation cell

5. Export charts as PNG:
   ```
   plt.savefig('outputs/B_chart_01_legacy_by_team.png', bbox_inches='tight', dpi=150)
   ```
   Use filenames: `B_chart_01_legacy_by_team.png`, `B_chart_02_user_distribution.png`, `B_chart_03_effort_vs_usage.png`

6. **Before sharing any exported image:**
   - [ ] Image reviewed by you — not accepted directly from Copilot output
   - [ ] No internal account or team identifiers visible that should not be shared
   - [ ] Sharing destination is within approved internal channels only

7. Save notebook to: `outputs/B_visualizations.ipynb`

---

## Completion Checklist

Before the debrief, confirm:

- [ ] `outputs/B_profile.md` — usage dataset profiled, all 4 quality issues documented
- [ ] `scripts/clean_mainframe.py` — cleaning script runs without error, row counts before/after documented
- [ ] `outputs/B_cleaning_decisions.md` — every transformation justified, sentinel 9999 handling documented
- [ ] `outputs/B_visualizations.ipynb` — 3 labeled charts with interpretation cells
- [ ] SQL queries ran and top modernization candidates identified
- [ ] Sentinel 9999 excluded from all calculations and charts

**For the debrief, prepare:**
1. Which 2–3 features you recommend for immediate modernization — and why
2. One data quality issue that could have produced a wrong recommendation if uncorrected
3. One thing Copilot generated that you had to review and correct

---

## Troubleshooting

| Problem | Solution |
|---|---|
| `import openpyxl` error | Run `pip install openpyxl` in terminal |
| Agent not in dropdown | Verify `.github/agents/` folder is at workspace root |
| Excel not loading | Use `pd.read_excel('../data/mainframe_usage.xlsx')` with relative path |
| Mixed date parse fails | Use `pd.to_datetime(df['last_accessed_date'], errors='coerce')` |
| Scatter shows 9999 points | Add `df = df[df['estimated_migration_effort_days'] != 9999]` before plotting |
| SQL returns empty | Confirm `df.to_sql('features', conn, index=False)` ran before the SELECT |
