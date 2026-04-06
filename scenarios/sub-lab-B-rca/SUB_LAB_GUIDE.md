# Sub-Lab B — Root Cause Analysis
## Scenario Walkthrough (50 min)

**Your Role:** Platform Reliability Analyst — Engineering Operations Team
**Dataset:** `data/rca_app_logs.csv` — 300 application log entries
**Source Code:** `data/app_service.py` — read this before the log data
**PII-Adjacent Field:** `user_id_masked` — never include in any output, chart, or print statement

---

## Timing Overview

| Block | Time | What You Do |
|---|---|---|
| **Stage 0** | 5 min | Setup and orientation |
| **Pre-Step** | 5 min | Review source code — form a hypothesis before touching the logs |
| **Phase 1** | 10 min | Profile the log dataset — find all quality issues |
| **Phase 2** | 25 min | Critique the flawed analysis, clean the data, run exploratory analysis |
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
  rca_app_logs.csv          ← your dataset
  rca_schema.md             ← read this before Phase 1
  app_service.py            ← read this in the Pre-Step
outputs/                    ← all deliverables go here
scripts/                    ← your generated scripts go here
scenarios/sub-lab-B-rca/
  exercises/
    flawed_rca_analysis.md  ← used in Phase 2 Step 1
```

---

## Pre-Step — Codebase Review (5 min)

**Agent:** Exploratory Data Analyst

> Code tells you what *can* go wrong. Logs tell you what *did* go wrong. Read the code first — form a hypothesis, then validate it with data.

1. Open `data/app_service.py`

2. Select **Exploratory Data Analyst** from Agent dropdown

3. **Custom prompt:**
   ```
   Review #data/app_service.py. Identify every comment marked BUG and explain what failure
   each defect could produce at runtime. For each defect: which class, what the defect is,
   what failure mode it produces, and which log_level you would expect to see in
   rca_app_logs.csv (INFO / WARN / ERROR / FATAL).
   Plain English only. Do not fix the code.
   ```

4. **Review output for:**
   - [ ] Each BUG comment identified and explained
   - [ ] A predicted log_level per defect
   - [ ] At least one defect that explains intermittent vs. consistent failures

5. **Write down your hypothesis:** Which service do you expect to have the most ERROR/FATAL entries? You will validate this against the log data in Phase 2.

---

## Phase 1 — Data Ingestion & Quality Assessment (10 min)

**Agent:** Data Profiling Analyst
**Prompt file:** `/data-profiling-analyst`

> **Before prompting:** Read `data/rca_schema.md` — the Known Issues section documents duplicates, expected nulls on FATAL rows, and invalid message fields.

### Steps

1. Select **Data Profiling Analyst** from Agent dropdown

2. **Recommended prompt:**
   Type `/data-profiling-analyst` then attach `#data/rca_app_logs.csv` and `#data/rca_schema.md`

   **Or use this custom prompt:**
   ```
   Profile data/rca_app_logs.csv using pandas only.
   Print: total row count, log_level distribution (value_counts), ERROR and FATAL count
   by service_name, null count per column, duplicate request_id count.
   Flag any service with more than 5 FATAL log entries.
   Flag columns where null % > 5%.
   Do not modify the dataframe. Do not print user_id_masked values.
   Save the quality summary to outputs/B_profile.md.
   ```

3. **Save the generated code** to `scripts/profile_logs.py`, then run:
   ```
   python scripts/profile_logs.py
   ```

4. **Review output for:**
   - [ ] Total row count = 300
   - [ ] `log_level` distribution documented with counts
   - [ ] ERROR + FATAL count per `service_name`
   - [ ] Null counts documented for all columns
   - [ ] Duplicate `request_id` count documented
   - [ ] Mixed timestamp formats flagged
   - [ ] `user_id_masked` noted as PII-adjacent
   - [ ] Output saved to `outputs/B_profile.md`

> `outputs/B_profile.md` is your handoff to Phase 2 — attach it with `#outputs/B_profile.md` in your next prompt.

---

## Phase 2 — Analysis Critique, Cleaning & Exploratory Analysis (25 min)

**Agent:** Data Cleaning Engineer
**Prompt file:** `/data-cleaning-engineer`

### Step 1 — Critique the Flawed Analysis (5 min)

> The previous RCA analyst produced a report with embedded errors. Identify every flaw before writing your own script — this prevents you from repeating the same mistakes.

1. Select **Data Cleaning Engineer** from Agent dropdown

2. **Custom prompt:**
   ```
   Review #scenarios/sub-lab-B-rca/exercises/flawed_rca_analysis.md and #outputs/B_profile.md.
   Identify every analytical flaw in the report. For each flaw:
   1. State the claim made in the report
   2. Explain why it is wrong (logical, statistical, or data quality error)
   3. State what the correct approach would be, referencing specific issues from B_profile.md
   ```

3. **Review output for:**
   - [ ] All 5 flaws identified (the document contains exactly 5)
   - [ ] Each flaw linked to a specific data quality issue
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

5. **Review code before running.** Verify:
   - Duplicate `request_id` rows removed with justification
   - Mixed timestamp formats resolved using `pd.to_datetime(errors='coerce')`
   - Null `response_time_ms` on FATAL rows retained — schema says these are expected nulls
   - Null `response_time_ms` on ERROR rows documented — not silently dropped
   - `user_id_masked` never printed in row-level output

6. **Save the generated code** to `scripts/clean_logs.py`, then run:
   ```
   python scripts/clean_logs.py
   ```

7. **Review output for:**
   - [ ] Every transformation has a written justification comment
   - [ ] Row count documented before AND after cleaning
   - [ ] Duplicate removal documented with count
   - [ ] Null `response_time_ms` on FATAL rows retained with comment
   - [ ] `user_id_masked` never printed

8. Save to: `scripts/clean_logs.py` + `outputs/B_cleaning_decisions.md`
   *(Use template: `templates/cleaning_decisions_template.md`)*

> **SQL Reference (Optional — Module 3):** See `scenarios/sub-lab-B-rca/exercises/sql_cleaning_reference.sql` for equivalent SQL cleaning logic. SQL is not required — Python is the deliverable.

### Step 3 — Exploratory Analysis (5 min)

9. **Custom prompt:**
   ```
   Using data/rca_app_logs_clean.csv, generate a Python pandas script (scripts/analyze_logs.py):
   - Count of rows grouped by service_name and log_level, ordered by service_name
   - Average response_time_ms by service_name (exclude nulls)
   - All ERROR and FATAL rows for the service with the highest failure rate
   Do not include user_id_masked in any output.
   ```

   **Save the generated code** to `scripts/analyze_logs.py`, then run:
   ```
   python scripts/analyze_logs.py
   ```

10. **Follow-up prompt:**
    ```
    Using pandas, find all rows where log_level IN ('ERROR', 'FATAL')
    AND response_time_ms is not null, ordered by response_time_ms descending.
    Does the service with the most failures also have the highest response times?
    Does this confirm or contradict your original hypothesis from the code review?
    ```

11. **Review output for:**
    - [ ] Counts consistent with profiling results
    - [ ] No `user_id_masked` in printed results
    - [ ] Pandas results confirm or explicitly contradict the code review hypothesis

---

## Phase 3 — Insight Visualization & Reporting (15 min)

**Agent:** Visualization Architect
**Prompt file:** `/visualization-architect`

1. Select **Visualization Architect** from Agent dropdown

2. **Recommended prompt:**
   Type `/visualization-architect` then attach `#data/rca_app_logs_clean.csv`

   **Or use this custom prompt:**
   ```
   Using data/rca_app_logs_clean.csv, generate scripts/visualize_logs.py with
   3 interactive charts using plotly.express:
   1. ERROR + FATAL count by service_name (horizontal bar chart)
   2. response_time_ms distribution for the top failing service (histogram)
   3. ERROR and FATAL log count over time by hour (line chart — parse timestamp first)
   Rules: Y-axis starts at 0. No 3D charts. No user_id_masked in any label, axis, or hover.
   All axes labeled with units. All charts titled.
   Export each chart: fig.write_html('outputs/B_chart_0N_name.html')
   Include a comment block evaluating the charts for the business.
   ```

3. **Save the generated code** to `scripts/visualize_logs.py`, then run:
   ```
   python scripts/visualize_logs.py
   ```

4. **Review each HTML file before sharing:**
   - [ ] All 3 charts open correctly in a browser
   - [ ] All 3 charts have descriptive titles
   - [ ] All axes labeled with units (e.g., "Number of Errors", "Response Time (ms)", "Hour of Day")
   - [ ] Y-axis starts at 0 (`rangemode='tozero'`)
   - [ ] `user_id_masked` not visible in labels, axis values, or hover tooltips

5. **Sharing and Exporting Visuals**

   | Format | How | When to Use |
   |--------|-----|-------------|
   | **Interactive HTML** | Share `.html` directly — opens in any browser | Default for internal stakeholders |
   | **Static PNG** | Open HTML in Chrome → download chart image | For slide decks or email |
   | **Clipboard screenshot** | `Windows + Shift + S` | Quick sharing in Teams/Slack |

   > **Before sharing:** Run the `VERIFY_BEFORE_SEND.md` checklist. Confirm `user_id_masked` is not visible in any label, axis, or hover tooltip.

---

## Completion Checklist

- [ ] `scripts/profile_logs.py` — runs without error; output matches 300-row count
- [ ] `outputs/B_profile.md` — log dataset profiled, all known quality issues documented
- [ ] `scripts/clean_logs.py` — runs without error; row counts before/after printed
- [ ] `scripts/analyze_logs.py` — runs without error; highest-failure service identified with supporting counts
- [ ] `scripts/visualize_logs.py` — runs without error and generates HTML outputs
- [ ] `outputs/B_cleaning_decisions.md` — every transformation justified; all 5 critique flaws addressed
- [ ] `outputs/B_chart_*.html` — 3 labeled interactive charts saved to outputs folder
- [ ] Pandas analysis ran; highest-failure service confirmed or contradicted by data
- [ ] No `user_id_masked` visible in any output, chart, or printed DataFrame

---

## Debrief — Prepare These 3 Points

1. Which service is the most likely root cause — and what data evidence supports it
2. One flaw from the flawed analysis that would have produced a wrong conclusion if repeated
3. One thing Copilot generated that you had to correct

> **Full reference:** `LAB_ACTION_GUIDE.md` contains additional context, troubleshooting, and all three scenarios if you want to compare approaches.
