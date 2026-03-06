# Sub-Lab C — Operational Anomaly Detection & Trend Analysis: Lab Guide

**50-Minute Hands-On Sprint**
**Workflow:** Payment Data Profiling → Clean + SQL → Visualize → Share

---

## Quick Reference

| Stage | Agent | Time | Output |
|---|---|---|---|
| 1 — Profile | Data Profiling Analyst | 10 min | `outputs/C_profile.md` |
| 2 — Clean + SQL | Data Cleaning Engineer | 25 min | `outputs/C_cleaning_decisions.md` + `scripts/clean_treasury.py` |
| 3 — Visualize | Visualization Architect | 15 min | `outputs/C_visualizations.ipynb` |

---

## Before You Start

- [ ] Read `SCENARIO_BRIEF.md` — understand your role and objective
- [ ] Run through `VERIFY_BEFORE_SEND.md` — pay special attention: `counterparty_masked` is PII-adjacent
- [ ] Open `data/treasury_schema.md` — this is your ground truth for column definitions and valid ranges
- [ ] Confirm `openpyxl` is installed: `pip install openpyxl`
- [ ] Open Copilot Chat (`Ctrl+Shift+I` / `Cmd+Shift+I`) and verify agents appear in the dropdown

> **No codebase review in this sub-lab** — this is pure data analysis. Move directly to Stage 1.

---

## Stage 1 — Payment Data Profiling (10 min)

**Agent:** Data Profiling Analyst

**Objective:** Profile `treasury_payments.xlsx` to surface all data quality issues before any analysis begins.

### Actions

1. Open input file: `data/treasury_payments.xlsx`

2. Select agent: **Data Profiling Analyst**

3. Enter prompt — choose one:

   **Option A — Invoke prompt file (recommended):**
   ```
   /data-profiling-analyst
   ```
   Then attach `#treasury_payments.xlsx` and `#treasury_schema.md`.

   **Option B — Manual prompt:**
   ```
   Profile data/treasury_payments.xlsx using pandas (pd.read_excel, requires openpyxl).
   Print: row count, null count per column (count and %), value_counts for payment_type,
   region, client_segment, and review_status, describe() for numeric columns.
   Flag: negative payment_amount values, sentinel 999 in prior_alerts_90d,
   analyst_confidence = -1, anomaly_confirmed = 2, blank review_status entries,
   duplicate payment_id count, mixed date formats in payment_date.
   Do not modify the dataframe.
   ```

4. **Run the generated code.** Check the actual numbers.

5. Enter follow-up prompt (paste your actual output):
   ```
   I ran the profiling script and got these results: [paste output].
   Which data quality issues could most distort the anomaly rate calculations
   if left uncorrected? Which sentinel values need to be excluded before analysis?
   ```

6. Review output for:
   - Row count documented (must be 500)
   - All 11 known data quality issues identified (see `treasury_schema.md` Known Issues)
   - Sentinel 999 in `prior_alerts_90d` and -1 in `analyst_confidence` flagged separately from nulls
   - `anomaly_confirmed = 2` flagged as invalid for a binary flag
   - `counterparty_masked` noted as PII-adjacent — must not appear in any output
   - Mixed date formats in `payment_date` flagged

7. Save to: `outputs/C_profile.md`
   *(Use template: `templates/profile_template.md`)*

---

## Stage 2 — Clean + SQL (25 min)

**Agent:** Data Cleaning Engineer

**Objective:** Generate a safe, commented cleaning script. Then use SQL to surface anomaly patterns and trends. Both Python and SQL are required — not optional.

### Part A — Python Cleaning Script (15 min)

1. Select agent: **Data Cleaning Engineer**

2. Enter prompt — choose one:

   **Option A — Invoke prompt file (recommended):**
   ```
   /data-cleaning-engineer
   ```
   Then attach `#treasury_payments.xlsx` and `#C_profile.md`.

   **Option B — Manual prompt:**
   ```
   Using the issues in #C_profile.md, generate scripts/clean_treasury.py to clean
   data/treasury_payments.xlsx (use pd.read_excel). Every transformation must have
   an inline comment explaining the business justification. Print row count before
   cleaning, after each major step, and at the end. Save cleaned data to
   data/treasury_payments_clean.csv. pandas only. Do not overwrite the original xlsx.
   Do not include counterparty_masked in any printed output.
   ```

3. Review the code line by line before running. Verify:
   - `anomaly_confirmed = 2` rows handled with justification — not silently dropped
   - Sentinel 999 in `prior_alerts_90d` excluded from calculations — not imputed
   - `analyst_confidence = -1` excluded from all averaging — treated as "not rated"
   - Negative `payment_amount` handled with business justification
   - Mixed date formats in `payment_date` resolved with `pd.to_datetime(errors='coerce')`
   - `counterparty_masked` never printed in row-level output

4. Save script to: `scripts/clean_treasury.py`

5. Save decisions to: `outputs/C_cleaning_decisions.md`
   *(Use template: `templates/cleaning_decisions_template.md`)*

### Part B — SQL Pattern Analysis (10 min)

6. Enter prompt:
   ```
   Using data/treasury_payments_clean.csv, generate a Python script that:
   1. Loads the CSV into a pandas DataFrame
   2. Writes it to an in-memory SQLite database using sqlite3 (standard library — no installs)
      conn = sqlite3.connect(':memory:')
      df.to_sql('payments', conn, index=False)
   3. Runs these SQL queries and prints results:
      - Anomaly confirmation rate by payment_type (anomaly_confirmed = 1 / total per type)
        — exclude rows where anomaly_confirmed = 2
      - Average payment_amount by region (exclude nulls and negative values)
      - Count of confirmed anomalies (anomaly_confirmed = 1) by client_segment
      - Top 5 analyst_ids by number of payments reviewed
   Do not include counterparty_masked in any SELECT output.
   ```

7. Enter follow-up prompt:
   ```
   Write a SQL query that finds all payments where:
   - risk_score > 0.8 AND anomaly_confirmed = 1
   - payment_date is in November 2024 (extract month from payment_date)
   Order by payment_amount descending. Limit to 10 rows.
   What does this cluster of high-risk confirmed anomalies in November tell us
   about operational patterns in Q4 2024?
   ```

8. Review SQL output for:
   - Anomaly rates calculated on clean rows only (no `anomaly_confirmed = 2` or nulls)
   - `counterparty_masked` absent from all printed results
   - Results consistent with your profiling findings

---

## Stage 3 — Visualize + Share (15 min)

**Agent:** Visualization Architect

**Objective:** Build 3 charts that make the anomaly patterns visible to a Treasury Operations Manager who needs to brief leadership.

### Actions

1. Open: `starter_notebook.ipynb`

2. Select agent: **Visualization Architect**

3. Enter prompt — choose one:

   **Option A — Invoke prompt file (recommended):**
   ```
   /visualization-architect
   ```
   Then attach `#treasury_payments_clean.csv`.

   **Option B — Manual prompt:**
   ```
   Using data/treasury_payments_clean.csv, generate 3 charts as Jupyter notebook cells:
   1. Confirmed anomaly rate by payment_type (bar chart)
      — exclude rows where anomaly_confirmed is not 0 or 1
   2. payment_amount distribution for confirmed anomalies only (histogram)
   3. Confirmed anomaly count by week of Q4 2024 (line chart — parse payment_date first)
   Rules: Y-axis starts at 0. No 3D charts. No counterparty_masked in any chart.
   All axes labeled with units. All charts titled.
   Follow each chart with a 2-sentence markdown interpretation.
   ```

4. Review each chart before saving:
   - All 3 charts have descriptive titles
   - Axes labeled with units (e.g., "Confirmed Anomaly Rate", "Payment Amount ($)", "Week")
   - Y-axis starts at 0
   - `counterparty_masked` not visible anywhere in chart output or tick labels
   - Each chart followed by a markdown interpretation cell
   - Anomaly rate chart excludes `anomaly_confirmed = 2` — confirm in the code

5. Export charts as PNG:
   ```
   plt.savefig('outputs/C_chart_01_anomaly_by_type.png', bbox_inches='tight', dpi=150)
   ```
   Use filenames: `C_chart_01_anomaly_by_type.png`, `C_chart_02_amount_distribution.png`, `C_chart_03_anomaly_trend.png`

6. **Before sharing any exported image:**
   - [ ] Confirmed `counterparty_masked` not visible in the image
   - [ ] Image reviewed by you — not accepted directly from Copilot output
   - [ ] Sharing destination is within approved internal channels only

7. Save notebook to: `outputs/C_visualizations.ipynb`

---

## Completion Checklist

Before the debrief, confirm:

- [ ] `outputs/C_profile.md` — payment dataset profiled, all 11 quality issues documented
- [ ] `scripts/clean_treasury.py` — cleaning script runs without error, row counts before/after documented
- [ ] `outputs/C_cleaning_decisions.md` — every transformation justified, sentinel handling documented
- [ ] `outputs/C_visualizations.ipynb` — 3 labeled charts with interpretation cells
- [ ] SQL queries ran and anomaly patterns identified
- [ ] `counterparty_masked` absent from all outputs, charts, and printed DataFrames
- [ ] Sentinel values (999, -1) excluded from all calculations

**For the debrief, prepare:**
1. Which payment type has the highest confirmed anomaly rate — and what trend you observed over Q4
2. One data quality issue that could have produced misleading anomaly rates if uncorrected
3. One thing Copilot generated that you had to review and correct

---

## Troubleshooting

| Problem | Solution |
|---|---|
| `import openpyxl` error | Run `pip install openpyxl` in terminal |
| Agent not in dropdown | Verify `.github/agents/` folder is at workspace root |
| Excel not loading | Use `pd.read_excel('../data/treasury_payments.xlsx')` with relative path |
| Mixed date parse fails | Use `pd.to_datetime(df['payment_date'], errors='coerce')` |
| Anomaly rate > 1.0 | Check you excluded `anomaly_confirmed = 2` before calculating rate |
| `counterparty_masked` appearing in output | Add `drop(columns=['counterparty_masked'])` before any print or export |
| SQL returns empty | Confirm `df.to_sql('payments', conn, index=False)` ran before the SELECT |
