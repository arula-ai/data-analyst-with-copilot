# Sub-Lab A — Treasury Anomaly Detection
## Scenario Walkthrough (65 min)

**Your Role:** Treasury Data Analyst — Operations Risk Team
**Dataset:** `data/treasury_payments.xlsx` — 500 payment records, Q4 2024
**PII-Adjacent Field:** `counterparty_masked` — never include in any output, chart, or print statement

---

## Timing Overview

| Block | Time | What You Do |
|---|---|---|
| **Stage 0** | 5 min | Setup and orientation |
| **Phase 1** | 10 min | Profile the dataset — find all quality issues |
| **Phase 2** | 35 min | Clean the data and run exploratory analysis |
| **Phase 3** | 15 min | Build the visualization dashboard |
| **Stage 4 (Optional)** | 8 min | Write the final analysis report (post-lab extension) |

---

## Stage 0 — Setup (5 min)

1. Complete the setup checklist:
   - [ ] Repository open in VS Code
   - [ ] Copilot Chat active (`Ctrl+Shift+I` / `Cmd+Shift+I`)
   - [ ] Agent Selector Dropdown visible and populated in Copilot Chat
   - [ ] Type `/` in Copilot Chat — confirm prompt files appear
   - [ ] Read `VERIFY_BEFORE_SEND.md` before opening any data

2. **Quick directory check:**
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
**Prompt file:** `/data-profiling`

> **Before prompting:** Read `data/treasury_schema.md` — specifically the Known Issues section. Sentinel values (`999` in `prior_alerts_90d`, `-1` in `analyst_confidence`), invalid flag values (`anomaly_confirmed = 2`), and `counterparty_masked` are all documented there.


1. Open Copilot Chat → select **Data Profiling Analyst** from Agent dropdown

2. **Recommended prompt:**
   Select **Data Profiling Analyst** from the Agent dropdown, then type `/data-profiling` and attach `#data/treasury_payments.xlsx` and `#data/treasury_schema.md`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

   **Or use this custom prompt:**
   ```
   Using pandas (pd.read_excel with openpyxl), generate and run scripts/profile_treasury.py for data/treasury_payments.xlsx.

   Requirements:
   1) Do not modify the dataframe; profiling only.
   2) Print row count, null count per column (count and %), value_counts for payment_type/region/client_segment/review_status, and numeric describe().
   3) Explicitly check and flag:
      - sentinel 999 in prior_alerts_90d
      - sentinel -1 in analyst_confidence (mark as "not rated", not a true score)
      - anomaly_confirmed = 2 as invalid for a binary flag
      - mixed payment_date formats / parse issues
      - duplicate payment_id count
      - blank review_status
      - PII-adjacent awareness for counterparty_masked (never print values)
   4) Save quality summary to outputs/A_profile.md.
   5) Print a quality gate table with PASS/FAIL per requirement above.
   6) End with exactly:
   ✅ Phase 1 profiling complete — handoff ready
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

## Phase 2 — Data Cleaning & Exploratory Analysis (35 min)

### Part A — Data Cleaning (10 min)

**Agent:** Data Cleaning Engineer
**Prompt file:** `/data-cleaning`

1. Select **Data Cleaning Engineer** from Agent dropdown

2. **Recommended prompt:**
   Select **Data Cleaning Engineer** from the Agent dropdown, then type `/data-cleaning` and attach `#data/treasury_payments.xlsx` and `#outputs/A_profile.md`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

   **Or run these steps manually:**

   **Step 1 — Generate and run the cleaning script:**
   ```
   Using the issues in #outputs/A_profile.md, generate scripts/clean_treasury.py to clean
   data/treasury_payments.xlsx (pd.read_excel, pandas only). Every transformation must have
   an inline comment explaining the business justification. Print row count before cleaning,
   after each major step, and at the end. Save cleaned data to outputs/treasury_payments_clean.csv.
   Never overwrite the source xlsx. Never print or expose counterparty_masked.
   Write the script to scripts/clean_treasury.py and run it.
   ```

   **Step 2 — Add the Cleaning Decision Log:**
   ```
   For the anomaly_confirmed = 2 rows in the treasury payments dataset:
   1. List the business-valid options for handling them (drop, recode, or exclude from analysis only) — one sentence each
   2. Recommend the safest option for an ops-risk analysis where the flag validity is uncertain
   3. Add a comment block at the TOP of scripts/clean_treasury.py (before any imports):
      # ── CLEANING DECISION LOG ──────────────────────────────────────
      # Issue: anomaly_confirmed = 2 (n=[count] rows)
      # Options: (1) Drop rows  (2) Recode to 0  (3) Exclude from analysis only
      # Decision: [the option you recommend]
      # Justification: [one sentence]
      # Impact: analysis denominator = [n] (not 500)
      # ────────────────────────────────────────────────────────────────
   4. Apply the recommended handling in the script if not already done. Show the updated top of the file.
   ```

   **Step 3 — Add assertion block:**
   ```
   Add an assertion block at the end of scripts/clean_treasury.py:
     assert df['anomaly_confirmed'].isin([0, 1, float('nan')]).all(), "Invalid anomaly_confirmed values remain"
     assert (df['payment_amount'] >= 0).all(), "Negative payment amounts remain"
     assert 999 not in df['prior_alerts_90d'].values, "Sentinel 999 still present in prior_alerts_90d"
     assert -1 not in df['analyst_confidence'].values, "Sentinel -1 still present in analyst_confidence"
     assert 'counterparty_masked' not in df.columns or df['counterparty_masked'].isna().all(), "PII column present"
   Print: "✅ All assertions passed — cleaned dataset is valid" if all pass. Run the script.
   ```

   **Step 4 — Add reconciliation report:**
   ```
   Add a function print_reconciliation_report(df_raw, df_clean) at the bottom of scripts/clean_treasury.py that prints:

   === RECONCILIATION REPORT ===
   Starting rows:                     500
   Duplicate payment_id removed:      [count]   → Running total: [n]
   Negative payment_amount removed:   [count]   → Running total: [n]
   anomaly_confirmed = 2 (excluded):  [count]   → Excluded from analysis (rows kept in df_clean)
   prior_alerts_90d = 999 → NaN:      [count]   → Rows kept, value replaced
   analyst_confidence = -1 → NaN:     [count]   → Rows kept, value replaced
   ─────────────────────────────────────────────
   Final analysis-valid row count:    [n]
   Analysis denominator for all Phase 2B calculations: [n]
   =============================

   Call the function at end of script. Also save this report to outputs/A_reconciliation.txt.
   Run the updated script and confirm outputs/A_reconciliation.txt is created.
   ```

   **Step 5 — Self-review:**
   ```
   Review scripts/clean_treasury.py. Confirm:
   1. Every transformation has an inline business justification comment
   2. anomaly_confirmed = 2 rows are excluded from analysis (not silently dropped)
   3. prior_alerts_90d = 999 is replaced with NaN (not used in calculations)
   4. analyst_confidence = -1 is replaced with NaN (not averaged)
   5. Negative payment_amount values are handled with a stated business reason
   6. counterparty_masked is never printed or included in any output
   7. All 5 assertions are present and correct
   If any item is missing or wrong, fix it and show the corrected code.
   ```

   **Step 6 — Quality gate:**
   ```
   Verify scripts/clean_treasury.py against this quality gate. For each item, print PASS or FAIL:
   [ ] Row count printed before AND after each major cleaning step
   [ ] anomaly_confirmed contains only 0, 1, or NaN after cleaning
   [ ] prior_alerts_90d: 999 replaced with NaN
   [ ] analyst_confidence: -1 replaced with NaN
   [ ] payment_amount: negative values handled with a stated business reason
   [ ] All 5 assertion statements present
   [ ] Cleaning Decision Log comment block at top of file
   [ ] Output saved to outputs/treasury_payments_clean.csv
   [ ] counterparty_masked never printed or included in CSV output
   [ ] outputs/A_reconciliation.txt written by reconciliation function
   If any item is FAIL, fix it and show the corrected code.
   Print: "✅ Quality gate passed — ready for Phase 2B" only if all 10 items pass.
   ```

   **Step 7 — Confirm artifacts:**
   - [ ] `scripts/clean_treasury.py` created and runs without error
   - [ ] `outputs/treasury_payments_clean.csv` created in outputs/ folder
   - [ ] `outputs/A_reconciliation.txt` created and contains the reconciliation report
   - [ ] Final analysis-valid row count confirmed from `outputs/A_reconciliation.txt` — this is the denominator for all Phase 2B and Phase 3 calculations

3. Do not proceed to Phase 2B until you see `✅ Quality gate passed — ready for Phase 2B` and the final denominator is confirmed.

   > The **"Final analysis-valid row count"** from `outputs/A_reconciliation.txt` is your anchor — it must match the denominator in all Phase 2B and Phase 3 calculations.

> **SQL Reference (Optional — Module 3):** See `scenarios/sub-lab-A-treasury/exercises/sql_cleaning_reference.sql` for equivalent SQL cleaning logic. SQL is not required — Python is the deliverable.

---

### Part B — Exploratory Analysis (20 min)

**Agent:** Exploratory Data Analyst
**Prompt file:** `/eda-analysis`

> **Analytical mindset for this phase:** You are not generating output — you are building a case. Each prompt answers one question. Read the output critically before moving on. Your job is to find the ONE finding that would change what the Head of Treasury Operations does tomorrow morning.

> **This phase has 4 required analytical questions.** Run them in order — each builds on the previous.

7. Select **Exploratory Data Analyst** from Agent dropdown

8. **Recommended prompt:**
   Select **Exploratory Data Analyst** from the Agent dropdown, then type `/eda-analysis` and attach `#outputs/treasury_payments_clean.csv` and `#outputs/A_reconciliation.txt`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

   **Or run these four focused prompts individually — one at a time, read the output before proceeding to the next:**

---

   **Prompt 1 — "Where is the anomaly rate highest, and is it concentrated?"**

   > Start broad: which payment types and client segments lead? Then narrow: is the top combination a true concentration risk or just noise from a large segment?



   ```
   Role: Treasury Data Analyst preparing a briefing for the Head of Operations.
   Input: #outputs/treasury_payments_clean.csv
   Task: Using pandas, calculate and print:
     1. Overall confirmed anomaly rate: count where anomaly_confirmed = 1 / total valid rows
        — show as fraction AND percentage (e.g. "122/462 = 26.4%")
     2. Confirmed anomaly rate by payment_type:
        — count confirmed / total per type, ordered rate descending
        — show: payment_type | confirmed_count | total_count | rate_pct
     3. Confirmed anomaly rate by client_segment: same structure
     4. Cross-tab: anomaly rate for each payment_type × client_segment combination
        — show only combinations where confirmed_count >= 5
        — order by rate descending
        — label the single highest-rate cell with *** (three asterisks)
   Constraints: Exclude anomaly_confirmed = 2 from ALL calculations.
   Do not print counterparty_masked.
   Format: Four labeled tables. No charts.
   Checks: Confirm per-category rates are consistent with the overall rate (weighted average of category rates should equal overall rate).
   ```

   **After reading the output, ask Copilot to capture the finding:**
   ```
   Based on the output above, write Finding 1 for outputs/A_eda_findings.md in this exact format:
   ### Finding 1 — Concentration Risk
   Denominator: [n] confirmed-valid rows (anomaly_confirmed = 2 excluded, n=[count])
   Overall rate: [n_confirmed]/[n_total] = [rate]%
   Highest payment_type: [type] — [rate]% (n=[count])
   Highest client_segment: [segment] — [rate]% (n=[count])
   Highest cross-tab cell: [type] × [segment] = [rate]% (n=[count]) ← headline risk
   Sample size flag: [note "(small sample — interpret with caution)" if n < 30, else "sample size adequate"]
   Copilot confidence: [does the cross-tab result have enough data to be actionable? one sentence]
   ```
   Copy this finding into `outputs/A_eda_findings.md`.

   ---

   **Prompt 2 — "Is this getting worse or is it noise?"**

   > You know WHERE the anomaly rate is highest. Now find out if it is a trend or a spike — these require completely different operational responses.

   ```
   Role: Treasury Data Analyst investigating temporal patterns in Q4 2024.
   Input: #outputs/treasury_payments_clean.csv
   Task: Using pandas:
     1. Parse payment_date (pd.to_datetime, errors='coerce') and group confirmed anomalies
        (anomaly_confirmed = 1) by ISO week
     2. Print a table: iso_week | week_start_date | confirmed_count | total_payments | weekly_rate_pct
        for all weeks in the dataset
     3. Calculate: 3-week rolling average of confirmed_count
     4. State in plain English:
        a. Direction: is confirmed_count increasing, decreasing, or stable across Q4?
        b. Volatility: what is the range (max week − min week)?
        c. Pattern type: is this a smooth trend, a spike, or random noise?
           (a smooth trend requires action; a spike needs root-cause investigation; noise needs more data)
   Constraints: Exclude anomaly_confirmed = 2. Do not print counterparty_masked.
   Format: Table + three-point plain English interpretation (direction, volatility, pattern type).
   ```

   **After reading the output, ask Copilot to capture the finding:**
   ```
   Based on the output above, write Finding 2 for outputs/A_eda_findings.md:
   ### Finding 2 — Temporal Pattern
   Trend direction: [increasing / decreasing / stable]
   Weekly range: min=[n] (week [ISO week]) to max=[n] (week [ISO week])
   3-week rolling avg at end of Q4: [value]
   Pattern type: [smooth trend / spike / random noise]
   Operational implication: [one sentence — what should ops do differently based on this pattern?]
   ```
   Append this finding to `outputs/A_eda_findings.md`.

   ---

   **Prompt 3 — "Where should we focus resources?"**

   > Geography tells you WHERE to deploy investigation resources. You need BOTH frequency AND dollar value — a region with few high-value anomalies is a different risk than one with many low-value ones.

   ```
   Role: Treasury Data Analyst preparing regional findings for an operations briefing.
   Input: #outputs/treasury_payments_clean.csv
   Task: For confirmed anomalies (anomaly_confirmed = 1) only, using pandas:
     1. By region: confirmed_count | avg_payment_amount | total_exposure (confirmed_count × avg_payment_amount)
        — Sort by total_exposure descending
        — Print: region | confirmed_count | avg_payment_amount | total_exposure
     2. Rank regions two ways: by confirmed_count (frequency rank) and by total_exposure (dollar rank)
        — If a region is top-2 in BOTH: flag it as "PRIORITY"
     3. Calculate: what % of total confirmed anomaly dollar exposure does the top region account for?
   Constraints: Exclude anomaly_confirmed = 2. Do not print counterparty_masked.
   Format: One combined table + concentration statement (e.g. "Top region = X% of total exposure").
   Checks: Sum of regional confirmed_counts must equal overall confirmed_count from Prompt 1.
   ```

   **After reading the output, ask Copilot to capture the finding:**
   ```
   Based on the output above, write Finding 3 for outputs/A_eda_findings.md:
   ### Finding 3 — Regional Exposure
   Top region by total exposure: [region] — [count] anomalies, $[total_exposure] ([pct]% of all confirmed anomaly exposure)
   PRIORITY region (top-2 in both count AND exposure): [region name, or "none identified"]
   Verification: sum of regional counts = [n] (must match overall confirmed count from Finding 1)
   Resource recommendation: [one sentence — where to deploy investigation resources first]
   ```
   Append this finding to `outputs/A_eda_findings.md`.

   ---

   **Prompt 4 — "Does our risk score actually work?"**

   > This is model validation — the most important analytical question in the dataset. If `risk_score` doesn't differentiate confirmed anomalies from non-confirmed, the scoring model is broken and every risk-based decision made from it is suspect.

   ```
   Role: Treasury Data Analyst validating the risk scoring model.
   Input: #outputs/treasury_payments_clean.csv
   Task: Using pandas:
     1. Compare average risk_score for:
        a. anomaly_confirmed = 1 (confirmed anomalies)
        b. anomaly_confirmed = 0 (non-anomalies)
        — Show: group | count | mean_risk_score | std_risk_score | min | max
     2. Calculate the separation ratio: mean(confirmed) / mean(non-confirmed)
        — If ratio > 1.2: model shows reasonable signal
        — If ratio 1.0–1.2: model signal is weak — flag for review
        — If ratio < 1.0: model is INVERTED — confirmed anomalies score LOWER than non-anomalies — critical issue
     3. Check: does risk_score predict the HIGH-rate cross-tab cell from Prompt 1?
        — Filter for [highest payment_type × client_segment] and print mean risk_score
        — Compare to overall mean risk_score
   Constraints: Exclude anomaly_confirmed = 2. Exclude analyst_confidence = NaN from any confidence comparisons.
   Do not print counterparty_masked.
   Format: Summary table + separation ratio statement + model verdict (STRONG SIGNAL / WEAK SIGNAL / INVERTED).
   ```

   **After reading the output, ask Copilot to capture the finding:**
   ```
   Based on the output above, write Finding 4 for outputs/A_eda_findings.md:
   ### Finding 4 — Risk Score Model Validation
   Mean risk_score (confirmed anomalies, n=[n]): [value]
   Mean risk_score (non-anomalies, n=[n]): [value]
   Separation ratio: [value] ([formula: confirmed mean / non-confirmed mean])
   Model verdict: [STRONG SIGNAL (>1.2) / WEAK SIGNAL (1.0–1.2) / INVERTED (<1.0)]
   Top cross-tab cell risk_score vs portfolio mean: [top cell mean] vs [overall mean] — [higher/lower/similar]
   Recommendation: [one sentence — is this risk model reliable for prioritizing investigations?]
   ```
   Append this finding to `outputs/A_eda_findings.md`.
   If model verdict is INVERTED: add ⚠️ to the finding and flag it explicitly in the Phase 3 dashboard summary header.

   ---

9. **Generate the reproducible EDA script (required):**

   After completing all four prompts, ask Copilot:
   ```
   Combine all four analyses above into a single reproducible script: scripts/eda_treasury.py
   The script must:
   - Load outputs/treasury_payments_clean.csv
   - Run all four analyses in sequence with labeled section headers in the output
   - Print each finding with numerator/denominator/rate (not just a percentage)
   - Save a plain-text summary to outputs/A_eda_summary.txt at the end
   - Be runnable standalone: python scripts/eda_treasury.py
   ```

   Save the script to `scripts/eda_treasury.py`. Run it and confirm `outputs/A_eda_summary.txt` is created.

   After saving and running the script, ask Copilot to verify it:
   ```
   Review scripts/eda_treasury.py and confirm:
   1. All 4 analyses run in sequence with labeled section headers
   2. Each finding prints numerator/denominator/rate (not just a percentage)
   3. outputs/A_eda_summary.txt is written at the end
   4. The overall anomaly rate in A_eda_summary.txt matches Finding 1 in outputs/A_eda_findings.md
   5. The script runs standalone with no errors: python scripts/eda_treasury.py
   Print: "✅ EDA script verified — numbers match findings document" if all 5 pass.
   ```
   Do not proceed to Phase 3 until you see "✅ EDA script verified".

   > This script is your **reproducible record**. The numbers in your Phase 3 dashboard must match the numbers in this script's output. If they don't match, your charts are not defensible.

10. **Finalize `outputs/A_eda_findings.md` with a header and summary:**

   Your `outputs/A_eda_findings.md` should now contain all 4 findings captured by Copilot in the steps above. Ask Copilot to add a header and summary paragraph at the top:
   ```
   Read outputs/A_eda_findings.md which contains Finding 1 through Finding 4.
   Add the following at the very top of the file:

   ## EDA Findings — Treasury Anomaly Q4 2024

   **Analysis denominator:** [n] confirmed-valid rows (500 raw − [count] anomaly_confirmed=2 excluded)
   **Overall confirmed anomaly rate:** [n_confirmed]/[n_total] = [rate]%
   **Key risk:** [one sentence citing the highest cross-tab cell from Finding 1]
   **Model status:** [STRONG SIGNAL / WEAK SIGNAL / INVERTED — from Finding 4]

   Then preserve all 4 findings below this header unchanged.
   Save the updated file.
   ```

   > **This is your handoff to Phase 3.** Attach `#outputs/treasury_payments_clean.csv` AND `#outputs/A_eda_findings.md` in the visualization prompt.

> **Gate:** Do not proceed to Phase 3 until `scripts/eda_treasury.py` runs clean AND `outputs/A_eda_summary.txt` exists.

---

## Phase 3 — Insight Visualization & Reporting (15 min)

**Agent:** Visualization Architect
**Prompt file:** `/data-visualization`

1. Select **Visualization Architect** from Agent dropdown

2. **Recommended prompt:**
   Select **Visualization Architect** from the Agent dropdown, then type `/data-visualization` and attach `#outputs/treasury_payments_clean.csv`

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
   include_plotlyjs=True on Chart 1 only). Add a summary header with:
     - Row count (total and analysis-valid, e.g. "500 raw | 462 analysis-valid after excluding anomaly_confirmed=2")
     - Date range (first and last payment_date)
     - Overall confirmed anomaly rate (fraction and %, e.g. "122/462 = 26.4%")
     - One-sentence key finding citing the top cross-tab cell (e.g. "ACH Batch × Institutional shows highest concentration at X%")
     - Data lineage: "Source: outputs/treasury_payments_clean.csv | EDA: scripts/eda_treasury.py"
   Include a comment block per chart evaluating the business insight.
   Write the script to scripts/visualize_treasury.py and run it.
   ```

3. **Save the generated script** before running: hover over the code block in Copilot Chat → click **Insert into New File** → save as `scripts/visualize_treasury.py`. Alternatively, copy the code → `Ctrl+N` → paste → `Ctrl+S` → name it.

4. **Open the dashboard in your browser:**
   ```
   start outputs\A_dashboard.html        ← Windows
   open outputs/A_dashboard.html         ← Mac
   ```

5. **Ask Copilot to verify the dashboard:**
   ```
   Review scripts/visualize_treasury.py and outputs/A_dashboard.html. Verify each item and print PASS or FAIL:
   [ ] Summary header contains: raw count (500) AND analysis-valid count (from outputs/A_reconciliation.txt)
   [ ] Overall anomaly rate in header matches exactly the rate in outputs/A_eda_summary.txt
   [ ] Chart 1: each bar labelled with rate% AND base-n (e.g. "34.0%  n=36/106")
   [ ] Chart 1: portfolio average reference line value matches overall rate from outputs/A_eda_summary.txt
   [ ] Chart 2: 3-week rolling average overlay present, peak and trough weeks annotated
   [ ] Chart 3: dual Y-axes present, regions sorted by confirmed count descending
   [ ] All 3 charts: descriptive titles, labeled axes with units
   [ ] All charts: Y-axes start at 0
   [ ] counterparty_masked: not present in any label, axis value, hover tooltip, or HTML source
   [ ] anomaly_confirmed = 2: excluded — denominator matches outputs/A_reconciliation.txt final count
   [ ] Data lineage line present in summary header
   If any FAIL: fix the script, re-run, and re-verify until all pass.
   Print: "✅ Dashboard verified — ready to share" only when all 11 pass.
   ```

   Share the dashboard only after seeing "✅ Dashboard verified — ready to share".

6. **Sharing the dashboard**

   | Format | How | When to Use |
   |--------|-----|-------------|
   | **Interactive HTML** | Attach `outputs/A_dashboard.html` directly | Teams, email, internal review — opens in any browser, no install needed |
    | **Screenshot** | `Windows + Shift + S` over the open dashboard | Quick Teams/Slack paste |

    > **Before sharing:** Run the `VERIFY_BEFORE_SEND.md` checklist. Confirm `counterparty_masked` is not visible in any label, axis, or hover tooltip.

> `outputs/A_dashboard.html` is your handoff to debrief. Bring one finding, one risk, and one correction you made.

---

## Stage 4 (Optional) — Final Analysis Report (8 min, post-lab extension)

**Goal:** Synthesize findings from all prior stages into a structured written deliverable for the Head of Treasury Operations.

### 4.1 — Generate the Report

Open Copilot Chat (`Ctrl + Alt + I`). Select the **Report Writer** agent from the dropdown if available — or paste the prompt below directly.

**Attach these files before prompting:**
- `#outputs/A_eda_findings.md`
- `#outputs/A_eda_summary.txt`
- `#outputs/A_dashboard.html`

**Or use this custom prompt:**
```
You are a senior data analyst writing a structured report for the Head of Treasury Operations.
Using the attached EDA findings, EDA summary, and dashboard evidence from this session,
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

### 4.3 — Stage 4 Optional Review Checklist

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
- [ ] `outputs/A_eda_findings.md` — structured 4-finding EDA brief (Concentration Risk, Temporal Pattern, Regional Exposure, Risk Score Validation) with explicit numerator/denominator and base-n evidence
- [ ] `scripts/visualize_treasury.py` — runs without error and generates the dashboard
- [ ] `outputs/A_dashboard.html` — single dashboard file with summary header and all 3 labeled interactive charts
- [ ] `counterparty_masked` absent from all outputs, charts, and printed DataFrames
- [ ] Sentinel values excluded from all calculations
- [ ] `outputs/A_analysis_report.md` — 6-section structured report; Section 3 figures sourced from EDA outputs *(optional extension deliverable)*

**Bonus (if time permits):** Open `exercises/flawed_treasury_analysis.md`. Now that you have done the analysis yourself — can you spot what the previous analyst got wrong?

---

## Debrief — Discussion Points

Your `outputs/A_analysis_report.md` is your prepared position. Use it to ground your answers.

1. **The recommended action in Section 5 — what would challenge it, and what additional data would strengthen it?**
2. **The limitation in Section 6 that most affects your confidence — how would you address it before this goes to the Head of Treasury Operations?**
3. **One thing Copilot generated across any stage that required your correction — and what that says about where human judgment is still essential.**

> **Full reference:** `LAB_ACTION_GUIDE.md` contains additional context, troubleshooting, and all three scenarios if you want to compare approaches.
