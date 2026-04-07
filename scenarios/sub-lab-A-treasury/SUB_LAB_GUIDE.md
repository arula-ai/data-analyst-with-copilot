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
| **Phase 3** | 15 min | Build the visualization dashboard |
| **Stage 4** | 8 min | Write the final analysis report |

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
   outputs/treasury_payments_clean.csv. pandas only. Do not overwrite the original xlsx.
   Do not include counterparty_masked in any printed output.
   Save the cleaned data to outputs/treasury_payments_clean.csv.
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
   - [ ] `outputs/treasury_payments_clean.csv` created

5. **Follow-up prompt:**
   ```
   For the anomaly_confirmed = 2 rows: what are the business-valid options for handling them?
   What assumption does each option make about the validity of these records?
   ```

6. Cleaning justifications are already documented as inline comments inside `scripts/clean_treasury.py` — no separate file needed for this step. Your EDA findings (the business-facing briefing) go into `outputs/A_cleaning_decisions.md` at the end of Part B.

> **SQL Reference (Optional — Module 3):** See `scenarios/sub-lab-A-treasury/exercises/sql_cleaning_reference.sql` for equivalent SQL cleaning logic. SQL is not required — Python is the deliverable.

---

### Part B — Exploratory Analysis (10 min)

**Agent:** Exploratory Data Analyst
**Prompt file:** `/eda-analysis`

> **How this works:** You are building a story, not generating a script. Read the output between each prompt and note your finding before moving on. At the end you will have 2–3 findings ready to brief the Head of Operations.

7. Select **Exploratory Data Analyst** from Agent dropdown

8. **Recommended prompt:**
   Select **Exploratory Data Analyst** from the Agent dropdown, then type `/eda-analysis` and attach `#outputs/treasury_payments_clean.csv`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

   **Or use these three focused prompts one at a time:**

   > Ask each question separately — read the output before moving to the next. Each prompt builds on the previous answer.

   **Prompt 1 — "Where is the anomaly rate highest?"**

   > Get the overall picture first. Which payment types and client segments drive the most confirmed anomalies? This is your headline finding.

   ```
   Role: Treasury Data Analyst preparing a briefing for the Head of Operations.
   Input: #outputs/treasury_payments_clean.csv
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

   **Read the output.** Which `payment_type` has the highest rate? Which `client_segment`? Note whether the top two client segment rates are close together — that changes the story. Write your findings before moving to Prompt 2.

   > **Follow-up (if rates are close at the top):** Ask Copilot: *"Filter for ACH Batch payments only, then show the anomaly rate by client_segment for that payment type."* This cross-tab reveals the highest-concentration risk cell in the portfolio — a far more actionable finding than either dimension alone.

   **Prompt 2 — "Is this getting worse?"**

   > You know WHAT has the highest rate. Now find out whether it is escalating — critical context for any operations briefing.

   ```
   Role: Treasury Data Analyst investigating temporal patterns in Q4 2024.
   Input: #outputs/treasury_payments_clean.csv
   Task: Using pandas:
     1. Parse payment_date and group confirmed anomalies (anomaly_confirmed = 1) by ISO week
     2. Print a table: week | confirmed_anomaly_count for all weeks in the dataset
     3. State in one sentence: is the count increasing, decreasing, or stable across Q4?
   Constraints: Exclude anomaly_confirmed = 2. Do not print counterparty_masked.
   Format: Table + one-sentence trend interpretation.
   ```

   **Read the output.** Look at the week-by-week variance, not just the direction. Is the pattern smooth or volatile? A volatile but flat series tells a different operational story than a clean upward or downward trend. Note both the trend direction AND the range (highest week vs lowest week).

   **Prompt 3 — "Where should we focus?"**

   > Synthesize geography. You need BOTH frequency AND dollar value — a region with few high-value anomalies is a different risk than one with many low-value ones.

   ```
   Role: Treasury Data Analyst preparing regional findings for an operations briefing.
   Input: #outputs/treasury_payments_clean.csv
   Task: For confirmed anomalies (anomaly_confirmed = 1) only, using pandas:
     1. Count of confirmed anomalies by region, ordered by count descending
     2. Average payment_amount by region for confirmed anomalies, ordered descending
     3. Print both side by side: region | confirmed_count | avg_payment_amount
   Constraints: Exclude anomaly_confirmed = 2. Do not print counterparty_masked.
   Format: One combined table.
   Checks: Note any region that ranks in the top 2 of BOTH columns — that is your
   highest-priority regional finding.
   ```

   **Read the output.** Look at BOTH columns together — a region with the highest count but low average amount is a different risk from one with fewer but much larger anomalies. If a region leads on count but another leads on average amount, multiply the two (count × avg amount) to get a risk-weighted view of total dollar exposure per region.

9. **Review output for:**
    - [ ] Overall confirmed anomaly rate printed with both numerator and denominator (e.g. 122/462 = 26.4%)
    - [ ] `payment_type` table printed, ordered rate descending, showing count and rate (%) per type
    - [ ] `client_segment` table printed, ordered rate descending, showing count and rate (%) per type
    - [ ] Week-by-week table printed; trend direction stated in one sentence; high and low weeks noted
    - [ ] Regional table shows `region | confirmed_count | avg_payment_amount` side by side
    - [ ] `counterparty_masked` absent from all printed output

10. **Document your findings** in `outputs/A_cleaning_decisions.md` as 2–3 plain-English briefing bullets — what payment type and client segment lead, what the weekly pattern shows, which region is highest priority and why. Write them as if briefing the Head of Treasury Operations right now.

**Bonus (if time permits):**
- Ask Copilot: *"Using the cleaned dataset, compare the average `risk_score` for confirmed anomalies (anomaly_confirmed = 1) vs non-confirmed (anomaly_confirmed = 0). Does the risk score column actually differentiate between the two groups?"* — This is model validation: if risk_score doesn't predict confirmed anomalies, the scoring model needs a rethink.
- Ask Copilot to generate `scripts/eda_treasury.py` that runs all three analyses in sequence with labeled output — a reproducible record of the exact numbers that informed your Phase 3 charts.

---

## Phase 3 — Insight Visualization & Reporting (15 min)

**Agent:** Visualization Architect
**Prompt file:** `/visualization-architect`

1. Select **Visualization Architect** from Agent dropdown

2. **Recommended prompt:**
   Select **Visualization Architect** from the Agent dropdown, then type `/visualization-architect` and attach `#outputs/treasury_payments_clean.csv`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

   **Or use this custom prompt:**
   ```
   Using outputs/treasury_payments_clean.csv (pd.read_csv), generate
   scripts/visualize_treasury.py with 3 interactive Plotly charts.
   Drop counterparty_masked immediately on load. Exclude anomaly_confirmed = 2
   from all calculations.

   Chart 1 — Bar: Confirmed anomaly rate by payment_type
     - Rate = confirmed count / total count per type, ordered rate descending
     - Label each bar: rate (%) and base-n (e.g. "34.0%  n=36/106")
     - Add a horizontal reference line at the portfolio average rate
     - Y-axis from 0. Title axes. No legend.

   Chart 2 — Line: Weekly confirmed anomaly count with rolling average
     - Group confirmed anomalies (anomaly_confirmed = 1) by ISO week
     - Plot weekly count as main line (red markers)
     - Add a 3-week rolling average as a dotted overlay line
     - Add a horizontal reference line at the Q4 weekly average
     - Annotate the highest-count week and the lowest-count week
     - Y-axis from 0. X-axis: week start date, 45° angle.

   Chart 3 — Grouped bar (dual Y-axis): Regional confirmed count vs avg payment amount
     - For confirmed anomalies only: group by region, calculate confirmed count
       and avg payment_amount
     - Sort regions by confirmed count descending
     - Left Y-axis (red bars): confirmed count per region
     - Right Y-axis (blue bars): avg payment amount per region (format: $,.0f)
     - Label each bar with its value. Y-axes from 0.

   Combine all 3 into outputs/A_dashboard.html (single self-contained file,
   include_plotlyjs=True on Chart 1 only). Add a summary header with row count,
   date range, overall anomaly rate, and a one-sentence key finding.
   Include a comment block per chart evaluating the business insight.
   Write the script to scripts/visualize_treasury.py and run it.
   ```

3. **Save the generated script** before running: hover over the code block in Copilot Chat → click **Insert into New File** → save as `scripts/visualize_treasury.py`. Alternatively, copy the code → `Ctrl+N` → paste → `Ctrl+S` → name it.

4. **Open the dashboard in your browser:**
   ```
   start outputs\A_dashboard.html        ← Windows
   open outputs/A_dashboard.html         ← Mac
   ```

5. **Confirm the script ran** and review the dashboard:
   - [ ] Dashboard opens in browser showing all 3 charts with the summary header
   - [ ] Summary header shows correct row count, date range, overall anomaly rate, and key finding
   - [ ] Chart 1 (bar): bars sorted descending, each labelled with rate + base-n, portfolio average reference line visible
   - [ ] Chart 2 (line): rolling average overlay visible, peak and trough weeks annotated, Q4 average reference line visible
   - [ ] Chart 3 (grouped bar): two bars per region (count + avg amount) on dual Y-axes, sorted by confirmed count
   - [ ] All 3 charts have descriptive titles and labeled axes with units
   - [ ] Y-axes start at 0 on all charts
   - [ ] `counterparty_masked` not visible in labels, axis values, or hover tooltips
   - [ ] `anomaly_confirmed = 2` excluded from all calculations

6. **Sharing the dashboard**

   | Format | How | When to Use |
   |--------|-----|-------------|
   | **Interactive HTML** | Attach `outputs/A_dashboard.html` directly | Teams, email, internal review — opens in any browser, no install needed |
   | **Screenshot** | `Windows + Shift + S` over the open dashboard | Quick Teams/Slack paste |

   > **Before sharing:** Run the `VERIFY_BEFORE_SEND.md` checklist. Confirm `counterparty_masked` is not visible in any label, axis, or hover tooltip.

---

## Stage 4 — Final Analysis Report (8 min)

**Goal:** Synthesize findings from all prior stages into a structured written deliverable for the Head of Treasury Operations.

### 4.1 — Generate the Report

Open Copilot Chat (`Ctrl + Alt + I`). Select the **Report Writer** agent from the dropdown if available — or paste the prompt below directly.

**Attach these files before prompting:**
- `#outputs/A_profile.md`
- `#outputs/A_cleaning_decisions.md`
- `#scripts/clean_treasury.py`

**Custom Prompt:**
```
You are a senior data analyst writing a structured report for the Head of Treasury Operations.
Using the attached profiling output, cleaning decisions, and EDA results from this session,
write a 6-section analysis report and save it to outputs/A_analysis_report.md:

**Section 1 — Executive Summary**
2–3 sentences. State: the primary risk finding, the data quality issue that most threatened
analysis integrity, and the recommended action. No field names or technical jargon.

**Section 2 — Data Quality Issues Found**
| Issue | Rows Affected | Action Taken |
One table row per sentinel value or quality issue identified in profiling.

**Section 3 — EDA Findings**
| Finding | Metric | Evidence |
Three rows:
- Highest-anomaly payment type and client segment (include exact anomaly rate and base-n)
- Q4 weekly trend: direction and full range (min week count to max week count)
- Highest-priority region by transaction count AND average payment amount

**Section 4 — Visualization Insights**
2–3 sentences on what the dashboard makes immediately visible that the raw data did not.

**Section 5 — Recommended Action**
One specific, actionable recommendation for the Head of Treasury Operations.
Must cite: the specific metric that justifies it, the data evidence, and one metric to
monitor going forward.

**Section 6 — Limitations**
Bullet list. Include: row exclusion counts and why, any fields where completeness was
uncertain, and what additional data would increase confidence.

Rules:
- Use actual numbers from prior stage outputs — do not estimate or round arbitrarily
- counterparty_masked must not appear anywhere in the report
- No Python code blocks
- Output as clean Markdown ready to save to outputs/A_analysis_report.md
```

### 4.2 — Review Before Saving

1. Read **Section 3** — verify every number matches your actual EDA outputs; reject any estimates
2. Check **Section 5** — must name a specific action, a specific metric, and a data citation
3. Save the output to `outputs/A_analysis_report.md`

### 4.3 — Stage 4 Review Checklist

- [ ] `outputs/A_analysis_report.md` created
- [ ] Executive Summary is 2–3 sentences with no field names
- [ ] Section 2 covers every sentinel value found in profiling
- [ ] Section 3 has actual numbers from EDA — not estimates
- [ ] Section 5 names a specific action with a metric and evidence
- [ ] Section 6 references specific row exclusion counts
- [ ] `counterparty_masked` absent from the entire report

---

## Completion Checklist

- [ ] `scripts/profile_treasury.py` — runs without error; output matches 500-row count
- [ ] `outputs/A_profile.md` — dataset profiled, all known quality issues documented
- [ ] `scripts/clean_treasury.py` — runs without error; row counts before/after printed; all sentinel exclusions documented as inline comments
- [ ] `outputs/treasury_payments_clean.csv` — created in outputs/ folder
- [ ] `outputs/A_cleaning_decisions.md` — 2–3 plain-English briefing bullets: anomaly rate by payment type and client segment (with base-n), weekly trend with range, regional priority by count and risk-weighted exposure
- [ ] `scripts/visualize_treasury.py` — runs without error and generates the dashboard
- [ ] `outputs/A_dashboard.html` — single dashboard file with summary header and all 3 labeled interactive charts
- [ ] `counterparty_masked` absent from all outputs, charts, and printed DataFrames
- [ ] Sentinel values excluded from all calculations
- [ ] `outputs/A_analysis_report.md` — 6-section structured report; Section 3 figures sourced from EDA outputs

**Bonus (if time permits):** Open `exercises/flawed_treasury_analysis.md`. Now that you have done the analysis yourself — can you spot what the previous analyst got wrong?

---

## Debrief — Discussion Points

Your `outputs/A_analysis_report.md` is your prepared position. Use it to ground your answers.

1. **The recommended action in Section 5 — what would challenge it, and what additional data would strengthen it?**
2. **The limitation in Section 6 that most affects your confidence — how would you address it before this goes to the Head of Treasury Operations?**
3. **One thing Copilot generated across any stage that required your correction — and what that says about where human judgment is still essential.**

> **Full reference:** `LAB_ACTION_GUIDE.md` contains additional context, troubleshooting, and all three scenarios if you want to compare approaches.
