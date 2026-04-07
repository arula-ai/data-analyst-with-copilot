# Sub-Lab A — Treasury Anomaly Detection
## Scenario Walkthrough (50 min)

**Your Role:** Treasury Data Analyst — Operations Risk Team
**Dataset:** `data/treasury_payments.xlsx` — 500 payment records, Q4 2024
**PII-Adjacent Field:** `counterparty_masked` — never include in any output, chart, or print statement

---

## Timing Overview

| Block | Time | What You Do |
|---|---|---|
| **Stage 0** | 5 min | Setup and orientation |
| **Phase 1** | 10 min | Profile the dataset — find all quality issues |
| **Phase 2** | 25 min | Clean the data and run exploratory analysis |
| **Phase 3** | 15 min | Build 3 charts and export interactive HTML files |

---

## Stage 0 — Setup (5 min)

- [ ] Repository open in VS Code
- [ ] Copilot Chat active (`Ctrl+Shift+I` / `Cmd+Shift+I`)
- [ ] Agent Selector Dropdown visible and populated in Copilot Chat
- [ ] Type `/` in Copilot Chat — confirm prompt files appear
- [ ] Read `VERIFY_BEFORE_SEND.md` before opening any data

**Quick directory check:**
```
data/
  treasury_payments.xlsx    ← your dataset
  treasury_schema.md        ← read this before Phase 1
outputs/                    ← all deliverables go here
scripts/                    ← your generated scripts go here
scenarios/sub-lab-A-treasury/
  exercises/
    flawed_treasury_analysis.md  ← used in Phase 2 Step 1
templates/                  ← copy these to outputs/ for each phase
reference/                  ← RIFCC-DA framework, policy, glossary
```

---

## Phase 1 — Data Ingestion & Quality Assessment (10 min)

**Agent:** Data Profiling Analyst
**Prompt file:** `/data-profiling-analyst`

> **Before prompting:** Read `data/treasury_schema.md` — specifically the Known Issues section. Sentinel values (`999` in `prior_alerts_90d`, `-1` in `analyst_confidence`), invalid flag values (`anomaly_confirmed = 2`), and `counterparty_masked` are all documented there.

### Steps

1. Open Copilot Chat → select **Data Profiling Analyst** from Agent dropdown

2. **Recommended prompt:**
   Select **Data Profiling Analyst** from the Agent dropdown, then type `/data-profiling-analyst` and attach `#data/treasury_payments.xlsx` and `#data/treasury_schema.md`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

   **Or use this custom prompt:**
   ```
   Profile data/treasury_payments.xlsx using pandas (pd.read_excel, requires openpyxl).
   Print: row count, null count per column (count and %), value_counts for payment_type,
   region, client_segment, and review_status, describe() for numeric columns.
   Flag: negative payment_amount values, sentinel 999 in prior_alerts_90d,
   analyst_confidence = -1 (treat as "not rated" — not a real score),
   anomaly_confirmed = 2 (invalid for a binary flag), blank review_status entries,
   duplicate payment_id count, mixed date formats in payment_date.
   Do not modify the dataframe. Do not print counterparty_masked values.
   Write the script to scripts/profile_treasury.py and run it.
   Save the quality summary to outputs/A_profile.md.
   ```

3. **Confirm the script ran** and check terminal output for:
   - [ ] Row count = 500
   - [ ] Sentinel `999` in `prior_alerts_90d` flagged separately from nulls
   - [ ] Sentinel `-1` in `analyst_confidence` flagged as "not rated" — not a real score
   - [ ] `anomaly_confirmed = 2` flagged as invalid for a binary flag
   - [ ] Mixed date formats in `payment_date` flagged
   - [ ] `counterparty_masked` noted as PII-adjacent
   - [ ] Output saved to `outputs/A_profile.md`

> `outputs/A_profile.md` is your handoff to Phase 2 — attach it with `#outputs/A_profile.md` in your next prompt.

---

## Phase 2 — Data Cleaning & Exploratory Analysis (25 min)

### Part A — Data Cleaning (10 min)

**Agent:** Data Cleaning Engineer
**Prompt file:** `/data-cleaning-engineer`

1. Select **Data Cleaning Engineer** from Agent dropdown

2. **Recommended prompt:**
   Select **Data Cleaning Engineer** from the Agent dropdown, then type `/data-cleaning-engineer` and attach `#data/treasury_payments.xlsx` and `#outputs/A_profile.md`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

   **Or use this custom prompt:**
   ```
   Using the issues in #outputs/A_profile.md, generate scripts/clean_treasury.py to clean
   data/treasury_payments.xlsx (use pd.read_excel). Every transformation must have
   an inline comment explaining the business justification. Print row count before
   cleaning, after each major step, and at the end. Save cleaned data to
   data/treasury_payments_clean.csv. pandas only. Do not overwrite the original xlsx.
   Do not include counterparty_masked in any printed output.
   Write the script to scripts/clean_treasury.py and run it.
   ```

3. **Review code before running.** Verify:
   - `anomaly_confirmed = 2` handled with explicit justification — not silently dropped
   - `prior_alerts_90d = 999` excluded from calculations — not treated as a real value
   - `analyst_confidence = -1` excluded from all averaging — noted as "not rated"
   - Negative `payment_amount` handled with business reasoning
   - Mixed date formats resolved using `pd.to_datetime(errors='coerce')`
   - `counterparty_masked` never printed

4. **Confirm the script ran** and review output for:
   - [ ] Every transformation has a written justification comment
   - [ ] Row count printed before AND after cleaning
   - [ ] All three sentinel exclusions documented
   - [ ] `counterparty_masked` absent from all printed output
   - [ ] `data/treasury_payments_clean.csv` created

5. **Follow-up prompt:**
   ```
   For the anomaly_confirmed = 2 rows: what are the business-valid options for handling them?
   What assumption does each option make about the validity of these records?
   ```

6. Save to: `outputs/A_cleaning_decisions.md`
   *(Use template: `templates/cleaning_decisions_template.md`)*

> **SQL Reference (Optional — Module 3):** See `scenarios/sub-lab-A-treasury/exercises/sql_cleaning_reference.sql` for equivalent SQL cleaning logic. SQL is not required — Python is the deliverable.

---

### Part B — Exploratory Analysis (10 min)

**Agent:** Exploratory Data Analyst
**Prompt file:** `/eda-analysis`

> **How this works:** You are building a story, not generating a script. Read the output between each prompt and note your finding before moving on. At the end you will have 2–3 findings ready to brief the Head of Operations.

8. Select **Exploratory Data Analyst** from Agent dropdown

9. **Recommended prompt:**
   Select **Exploratory Data Analyst** from the Agent dropdown, then type `/eda-analysis` and attach `#data/treasury_payments_clean.csv`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

   **Or use these three focused prompts one at a time:**

   > Ask each question separately — read the output before moving to the next. Each prompt builds on the previous answer.

   **Prompt 1 — "Where is the anomaly rate highest?"**

   > Get the overall picture first. Which payment types and client segments drive the most confirmed anomalies? This is your headline finding.

   ```
   Role: Treasury Data Analyst preparing a briefing for the Head of Operations.
   Input: #data/treasury_payments_clean.csv
   Task: Using pandas, calculate and print:
     1. Overall confirmed anomaly rate: count where anomaly_confirmed = 1 / total valid rows
     2. Confirmed anomaly rate by payment_type — count confirmed / total per type,
        ordered by rate descending, show both count and rate (%)
     3. Confirmed anomaly rate by client_segment — same calculation, ordered descending
   Constraints: Exclude anomaly_confirmed = 2 from all calculations.
   Do not print counterparty_masked.
   Format: Labeled plain-text tables for each result.
   Checks: Confirm per-category rates are consistent with the overall rate.
   ```

   **Read the output.** Which `payment_type` has the highest rate? Which `client_segment`? Write these down — you will reference them in Prompt 2.

   **Prompt 2 — "Is this getting worse?"**

   > You know WHAT has the highest rate. Now find out whether it is escalating — critical context for any operations briefing.

   ```
   Role: Treasury Data Analyst investigating temporal patterns in Q4 2024.
   Input: #data/treasury_payments_clean.csv
   Task: Using pandas:
     1. Parse payment_date and group confirmed anomalies (anomaly_confirmed = 1) by ISO week
     2. Print a table: week | confirmed_anomaly_count for all weeks in the dataset
     3. State in one sentence: is the count increasing, decreasing, or stable across Q4?
   Constraints: Exclude anomaly_confirmed = 2. Do not print counterparty_masked.
   Format: Table + one-sentence trend interpretation.
   ```

   **Read the output.** Note the trend direction — this is your time-based finding.

   **Prompt 3 — "Where should we focus?"**

   > Synthesize geography. You need BOTH frequency AND dollar value — a region with few high-value anomalies is a different risk than one with many low-value ones.

   ```
   Role: Treasury Data Analyst preparing regional findings for an operations briefing.
   Input: #data/treasury_payments_clean.csv
   Task: For confirmed anomalies (anomaly_confirmed = 1) only, using pandas:
     1. Count of confirmed anomalies by region, ordered by count descending
     2. Average payment_amount by region for confirmed anomalies, ordered descending
     3. Print both side by side: region | confirmed_count | avg_payment_amount
   Constraints: Exclude anomaly_confirmed = 2. Do not print counterparty_masked.
   Format: One combined table.
   Checks: Note any region that ranks in the top 2 of BOTH columns — that is your
   highest-priority regional finding.
   ```

   **Read the output.** Any region in the top 2 of both columns = highest-priority risk concentration.

10. **Review output for:**
    - [ ] **Section 1: Data Cleaning Audit Log** present with row reconciliation table
    - [ ] Table shows **Raw Data** count vs. **Final Dataset** count with all exclusion steps
    - [ ] **Section 2: Evidence-Based Findings** present with numbered headers
    - [ ] Each finding follows: **Question | Methodology | Finding | Evidence | Assumptions**
    - [ ] Overall confirmed anomaly rate calculated and noted
    - [ ] Highest-rate `payment_type` identified with actual rate (%)
    - [ ] Highest-rate `client_segment` identified with actual rate (%)
    - [ ] Week-by-week trend table printed; trend direction stated in one sentence
    - [ ] Regional table shows both confirmed count and average amount side by side
    - [ ] `counterparty_masked` absent from all printed output

11. **Save your findings** — use this prompt to write structured output to the file:

    ```
    Based on the analysis results above, save findings to outputs/A_cleaning_decisions.md
    structured as follows:

    Section 1: Data Cleaning Audit Log
    - Row reconciliation table: Raw Data row count → each exclusion step → Final Dataset row count
    - Each transformation listed with written justification

    Section 2: Evidence-Based Findings
    For each of the 3 business questions, one entry with these fields:
    Business Question | Methodology | Finding | Evidence | Assumptions | Limitations

    Do not include counterparty_masked in any output.
    ```

**Bonus (if time permits):** Ask Copilot to generate `scripts/eda_treasury.py` that runs all three analyses in sequence with labeled output — a reproducible record of the exact numbers that informed your Phase 3 charts.

---

## Phase 3 — Insight Visualization & Reporting (15 min)

**Agent:** Visualization Architect
**Prompt file:** `/visualization-architect`

1. Select **Visualization Architect** from Agent dropdown

2. **Recommended prompt:**
   Select **Visualization Architect** from the Agent dropdown, then type `/visualization-architect` and attach `#data/treasury_payments_clean.csv`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

   **Or use this custom prompt:**
   ```
   Using data/treasury_payments_clean.csv, generate scripts/visualize_treasury.py with
   3 interactive charts using plotly.express:
   1. Confirmed anomaly rate by payment_type (bar chart)
      — exclude rows where anomaly_confirmed is not 0 or 1
   2. payment_amount distribution for confirmed anomalies only (histogram)
   3. Confirmed anomaly count by week (line chart — parse payment_date, group by week)
   Rules: Y-axis starts at 0. No 3D charts. No counterparty_masked in any label, axis,
   or hover. All axes labeled with units. All charts titled.
   Combine all 3 charts into a single dashboard file:
     chart1_html = fig1.to_html(include_plotlyjs=True,  full_html=False)
     chart2_html = fig2.to_html(include_plotlyjs=False, full_html=False)
     chart3_html = fig3.to_html(include_plotlyjs=False, full_html=False)
     summary = f'<h2>Treasury Analysis Dashboard</h2><p><strong>Dataset:</strong> {n_rows} rows after cleaning | <strong>Period:</strong> Q4 2024</p><p><strong>Key Finding:</strong> [one-sentence headline from EDA]</p><hr/>'
     html = f'<html><head><meta charset="utf-8"></head><body>{summary}{chart1_html}{chart2_html}{chart3_html}</body></html>'
     with open('outputs/A_dashboard.html', 'w', encoding='utf-8') as f: f.write(html)
   Include a comment block evaluating each chart for the business.
   Write the script to scripts/visualize_treasury.py and run it.
   ```

3. **Open the dashboard in your browser:**
   ```
   start outputs\A_dashboard.html
   ```

4. **Confirm the script ran** and review the dashboard:
   - [ ] Dashboard opens in browser showing all 3 charts with the summary header
   - [ ] Summary header shows correct row count, period, and a key finding sentence
   - [ ] All 3 charts have descriptive titles
   - [ ] Axes labeled with units (e.g., "Confirmed Anomaly Rate", "Payment Amount ($)", "Week")
   - [ ] Y-axis starts at 0 (`rangemode='tozero'`)
   - [ ] `counterparty_masked` not visible in labels, axis values, or hover tooltips
   - [ ] `anomaly_confirmed = 2` excluded from anomaly rate chart

5. **Sharing the dashboard**

   | Format | How | When to Use |
   |--------|-----|-------------|
   | **Interactive HTML** | Attach `outputs/A_dashboard.html` directly | Teams, email, internal review — opens in any browser, no install needed |
   | **Screenshot** | `Windows + Shift + S` over the open dashboard | Quick Teams/Slack paste |

   > **Before sharing:** Run the `VERIFY_BEFORE_SEND.md` checklist. Confirm `counterparty_masked` is not visible in any label, axis, or hover tooltip.

---

## Completion Checklist

- [ ] `scripts/profile_treasury.py` — runs without error; output matches 500-row count
- [ ] `outputs/A_profile.md` — dataset profiled, all known quality issues documented
- [ ] `scripts/clean_treasury.py` — runs without error; row counts before/after printed
- [ ] `outputs/A_cleaning_decisions.md` — 2–3 plain-English findings documented (anomaly rate by payment type, trend direction, regional priority)
- [ ] `scripts/visualize_treasury.py` — runs without error and generates the dashboard
- [ ] `outputs/A_cleaning_decisions.md` — every transformation justified; sentinel handling for `prior_alerts_90d = 999`, `analyst_confidence = -1`, and `anomaly_confirmed = 2` documented; answers to 3 business questions recorded
- [ ] `outputs/A_dashboard.html` — single dashboard file with summary header and all 3 labeled interactive charts
- [ ] `counterparty_masked` absent from all outputs, charts, and printed DataFrames
- [ ] Sentinel values excluded from all calculations

**Bonus (if time permits):** Open `exercises/flawed_treasury_analysis.md`. Now that you have done the analysis yourself — can you spot what the previous analyst got wrong?

---

## Debrief — Prepare These 3 Points

1. Which payment type has the highest confirmed anomaly rate — and what trend you observed week over week
2. One data quality issue that could have produced misleading anomaly rates if uncorrected
3. One thing Copilot generated that you had to correct

> **Full reference:** `LAB_ACTION_GUIDE.md` contains additional context, troubleshooting, and all three scenarios if you want to compare approaches.
