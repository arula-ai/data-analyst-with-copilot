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
**Prompt file:** `/code-review`

> Code tells you what *can* go wrong. Logs tell you what *did* go wrong. Read the code first — form a hypothesis, then validate it with data.

1. Open `data/app_service.py` — read it before prompting. Note that `# BUG` comments are hints, not the complete defect list. Some defects are structural with no annotation.

2. Select **Exploratory Data Analyst** from Agent dropdown

3. Type `/code-review` and attach `#data/app_service.py` and `#data/rca_schema.md`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

4. **Review output for:**
   - [ ] Every `# BUG`-annotated line represented in the output table
   - [ ] At least one structural defect identified with no `# BUG` annotation (e.g., `_release_connection` no-op, silent exception swallow in `NotificationService`)
   - [ ] Each defect has a predicted `log_level` (INFO / WARN / ERROR / FATAL)
   - [ ] Each defect classified as intermittent or consistent
   - [ ] A hypothesis statement naming the highest-risk service and mechanism

5. **Write down your hypothesis:** Which service do you expect to have the most ERROR/FATAL entries, and is it resource exhaustion or logic failure? You will validate this against the log data in Phase 2.

---

## Phase 1 — Data Ingestion & Quality Assessment (10 min)

**Agent:** Data Profiling Analyst
**Prompt file:** `/data-profiling`

> **Before prompting:** Read `data/rca_schema.md` — the Known Issues section documents duplicates, expected nulls on FATAL rows, and invalid message fields.

### Steps

1. Select **Data Profiling Analyst** from Agent dropdown

2. **Recommended prompt:**
   Select **Data Profiling Analyst** from the Agent dropdown, then type `/data-profiling` and attach `#data/rca_app_logs.csv` and `#data/rca_schema.md`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

   **Or use this custom prompt:**
   ```
   Profile data/rca_app_logs.csv using pandas only.
   Print: total row count, log_level distribution (value_counts), ERROR and FATAL count
   by service_name, null count per column, duplicate request_id count,
   count of null or empty message values on ERROR and FATAL rows separately.
   Flag any service with more than 5 FATAL log entries.
   Flag columns where null % > 5%.
   Do not modify the dataframe. Do not print user_id_masked values.
   Write the script to scripts/profile_logs.py and run it.
   Save the quality summary to outputs/B_profile.md.
   ```

3. **Confirm the script ran** and check terminal output for:
   - [ ] Total row count = 300
   - [ ] `log_level` distribution documented with counts
   - [ ] ERROR + FATAL count per `service_name`
   - [ ] Null counts documented for all columns
   - [ ] Duplicate `request_id` count documented
   - [ ] Mixed timestamp formats flagged
   - [ ] Null/empty `message` count on ERROR rows documented separately from FATAL rows
   - [ ] `user_id_masked` noted as PII-adjacent
   - [ ] Output saved to `outputs/B_profile.md`

> `outputs/B_profile.md` is your handoff to Phase 2 — attach it with `#outputs/B_profile.md` in your next prompt.

---

## Phase 2 — Analysis Critique, Cleaning & Exploratory Analysis (25 min)

### Part A — Analysis Critique & Data Cleaning (15 min)

**Agent:** Data Cleaning Engineer
**Prompt file:** `/data-cleaning`

> Before generating a cleaning script, critique the previous analyst's flawed report — this prevents you from repeating the same mistakes.

1. Select **Data Cleaning Engineer** from Agent dropdown

2. **Critique prompt** (type directly — the `/data-cleaning` slash command runs cleaning, not critique):
   ```
   Review #scenarios/sub-lab-B-rca/exercises/flawed_rca_analysis.md and #outputs/B_profile.md.
   Identify every analytical flaw in the report. For each flaw:
   1. State the claim made in the report
   2. Explain why it is wrong (logical, statistical, or data quality error)
   3. State what the correct approach would be, referencing specific issues from B_profile.md
   ```

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

3. **Review critique output for:**
   - [ ] All 5 flaws identified (the document contains exactly 5)
   - [ ] Each flaw linked to a specific data quality issue from `outputs/B_profile.md`
   - [ ] Correct approach stated for each — not just "this is wrong"

4. **Follow-up prompt** (same agent, same session):
   Select **Data Cleaning Engineer** from the Agent dropdown, then type `/data-cleaning` and attach `#data/rca_app_logs.csv` and `#outputs/B_profile.md`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

   **Or use this custom prompt:**
   ```
   Now generate scripts/clean_logs.py that correctly cleans data/rca_app_logs.csv,
   avoiding all the flaws identified above. Every transformation must have an inline
   comment explaining the business justification. Print row count before cleaning,
   after each major step, and at the end. Save cleaned data to outputs/rca_app_logs_clean.csv.
   Do not overwrite the original. pandas only. Do not print user_id_masked values.
   Write the script to scripts/clean_logs.py and run it.
   ```

5. **Review code before running.** Verify:
   - Duplicate `request_id` rows removed with justification
   - Mixed timestamp formats resolved using `pd.to_datetime(errors='coerce')`
   - Null `response_time_ms` on FATAL rows retained — schema says these are expected nulls
   - Null `response_time_ms` on ERROR rows documented separately — not silently dropped
   - Null/empty `message` on ERROR/FATAL rows retained — they still represent failure events; noted as data gaps
   - `user_id_masked` never printed in row-level output

6. **Confirm the script ran** and review output for:
   - [ ] Every transformation has a written justification comment
   - [ ] Row count documented before AND after cleaning
   - [ ] Duplicate removal documented with count
   - [ ] Null `response_time_ms` on FATAL rows retained with comment
   - [ ] Null/empty `message` on ERROR/FATAL rows retained with comment
   - [ ] `outputs/rca_app_logs_clean.csv` created
   - [ ] `user_id_masked` never printed

7. Cleaning justifications are already documented as inline comments inside `scripts/clean_logs.py` — no separate file needed for this step. Your EDA findings (the business-facing briefing) go into `outputs/B_cleaning_decisions.md` at the end of Part B.

> **SQL Reference (Optional — Module 3):** See `scenarios/sub-lab-B-rca/exercises/sql_cleaning_reference.sql` for equivalent SQL cleaning logic. SQL is not required — Python is the deliverable.

---

### Part B — Exploratory Analysis (10 min)

**Agent:** Exploratory Data Analyst
**Prompt file:** `/rca-analysis`

> **How this works:** You are building a case, not generating a script. Read the output between each prompt and note your finding before moving on. At the end you will have 3 findings to close against your Pre-Step hypothesis.

8. Select **Exploratory Data Analyst** from Agent dropdown

9. **Recommended prompt:**
   Select **Exploratory Data Analyst** from the Agent dropdown, then type `/rca-analysis` and attach `#outputs/rca_app_logs_clean.csv` and `#data/rca_schema.md`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

   **Or run these three focused prompts one at a time:**

   > Ask each question separately — read the output before moving to the next. Each prompt builds on the previous answer.

   **Prompt 1 — "Which service is failing most, and is it across both environments?"**

   > Start with failure rate per service — not raw counts. notification-service has more total log rows than other services, so raw counts alone mislead. Then immediately split by environment — staging failures are a different incident from prod failures and should not be combined.

   ```
   Role: Platform Reliability Analyst preparing an RCA briefing for Engineering Operations.
   Input: #outputs/rca_app_logs_clean.csv
   Task: Using pandas, calculate and print:
     1. Failure rate per service: (ERROR+FATAL count) / total rows per service
        Show: service_name | total_rows | error_fatal_count | failure_rate_pct
        Ordered by failure_rate_pct descending.
     2. ERROR+FATAL count split by environment (prod vs staging) — one row per environment
        Show: environment | total_rows | error_fatal_count | failure_rate_pct
   Constraints: Do not print user_id_masked.
   Format: Two labeled tables.
   ```

   **Read the output.** Which service has the highest failure rate? Does the environment split show prod and staging failing at similar rates, or is one environment driving the pattern? A higher failure rate in staging than prod suggests configuration or resource capacity differences — not a code-only problem.

   > **Follow-up (if rates differ significantly across environments):** Ask Copilot: *"For the highest-failure service only, split ERROR and FATAL rows by environment and show the count and rate per environment."* This reveals whether the failure is platform-wide or environment-specific — which changes the remediation path entirely.

   **Prompt 2 — "Is response time correlated with failure, and which log_level is slowest?"**

   > The hypothesis from the code review predicted that resource exhaustion (DB pool, session TTL) would show up as elevated response times on failure rows. Test it directly by comparing response times across log levels — not just by service.

   ```
   Role: Platform Reliability Analyst testing whether failure events are correlated with
   higher response times.
   Input: #outputs/rca_app_logs_clean.csv
   Task: Using pandas:
     1. Average response_time_ms by log_level (INFO, WARN, ERROR, FATAL)
        Exclude all null response_time_ms. Do NOT fill nulls with 0.
        Show: log_level | avg_response_time_ms | row_count (with valid response times)
        Ordered by avg_response_time_ms descending.
     2. Average response_time_ms by service_name (exclude nulls)
        Show: service_name | avg_response_time_ms, ordered descending
     3. State in one sentence: are ERROR rows significantly slower than INFO rows on average?
   Constraints: Do not print user_id_masked.
   Format: Two tables + one-sentence interpretation.
   ```

   **Read the output.** If ERROR rows have materially higher average response times than INFO rows: resource contention (DB pool exhaustion, session TTL under load) is the likely failure chain. If ERROR rows are NOT slower than INFO rows: the failures are logic-driven — exceptions swallowed silently, no retries, auth failures that terminate fast.

   > **Hypothesis check:** Does the service with the highest failure rate (from Prompt 1) also have the highest average response time? If yes — supports resource exhaustion. If no — supports silent logic failure. Note whether this confirms or contradicts what you wrote in the Pre-Step.

   **Prompt 3 — "Which error codes are driving failures — and do they map to the BUGs in the code?"**

   > This is the hypothesis closure step. The Pre-Step identified specific defect signatures (ERR_001 from AuthService session expiry, ERR_DB_001 from TransactionProcessor pool exhaustion). Now check whether those codes appear most in the actual log data — closing the loop from code review to evidence.

   ```
   Role: Platform Reliability Analyst closing the loop between code defects and log evidence.
   Input: #outputs/rca_app_logs_clean.csv
   Task: Using pandas, filter to ERROR + FATAL rows only, then:
     1. Count value_counts of error_code (include NaN separately as "null — missing diagnostic")
        Show: error_code | count | pct_of_error_fatal_rows, ordered by count descending
     2. For the top 2 most frequent error codes: show which service_name rows have that code
        (service_name | count) — one sub-table per top error code
     3. State in one sentence: do the most frequent error codes match the failure modes
        predicted by the BUGs in app_service.py?
   Constraints: Do not print user_id_masked.
   Format: One main table + two sub-tables + one-sentence interpretation.
   Note: error_code is null for 12 ERROR/FATAL rows — this is a data gap, not expected behavior.
   ```

   **Read the output.** ERR_001 maps to `AuthService` session expiry (SESSION_TTL = 30s, no caching). ERR_DB_001 maps to `TransactionProcessor` pool exhaustion (DB_POOL_SIZE = 3, no fallback). If these two codes dominate the error distribution — the code review hypothesis is confirmed by the data. Note which BUG in `app_service.py` each top error code traces back to.

10. **Review output for:**
    - [ ] Service failure rate table printed (rate as %, ordered descending, with base-n per service)
    - [ ] Environment split table printed (prod vs staging failure rate)
    - [ ] Response time by log_level table printed (nulls excluded, not filled with 0)
    - [ ] Cross-service avg response_time_ms table printed
    - [ ] Error code frequency table printed (ERROR/FATAL rows only, nulls counted separately)
    - [ ] Hypothesis closure sentence states confirmed or contradicted with evidence
    - [ ] `user_id_masked` absent from all printed output

11. **Document your findings** in `outputs/B_cleaning_decisions.md` as 2–3 plain-English briefing bullets — which service leads and at what rate, whether response time implicates resource exhaustion, and which error codes confirm or contradict the code review hypothesis. Write them as if briefing the Engineering Operations lead right now.

**Bonus (if time permits):**
- Ask Copilot: *"For ERR_001 rows (AuthService session expiry): what is the average response_time_ms compared to ERR_DB_001 rows (DB pool exhaustion)? Which defect is producing the slower failures?"* — This distinguishes between an auth bottleneck and a DB bottleneck, which have different remediation paths.
- Ask Copilot to generate `scripts/analyze_logs.py` that runs all three analyses in sequence with labeled output — a reproducible record of the exact numbers that informed your Phase 3 charts.

---

## Phase 3 — Insight Visualization & Reporting (15 min)

**Agent:** Visualization Architect
**Prompt file:** `/data-visualization`

1. Select **Visualization Architect** from Agent dropdown

2. **Recommended prompt:**
   Select **Visualization Architect** from the Agent dropdown, then type `/data-visualization` and attach `#outputs/rca_app_logs_clean.csv`

   > **Tip:** Always use the Agent dropdown first, then type your prompt. Do not type `/` and browse the slash command list — built-in commands like `/tests` appear in the same list and will produce an error if selected by mistake.

   **Or use this custom prompt:**
   ```
   Using outputs/rca_app_logs_clean.csv (pd.read_csv), generate
   scripts/visualize_logs.py with 3 interactive Plotly charts.
   Drop user_id_masked immediately on load.

   Chart 1 — Horizontal bar: ERROR + FATAL count by service_name
     - Ordered by count descending
     - Label each bar with its count
     - X-axis: "Number of ERROR + FATAL Events". Y-axis: service names. Title the chart.

   Chart 2 — Grouped bar: Average response_time_ms by log_level
     - Filter to rows where response_time_ms is NOT null. Do NOT fill nulls with 0.
     - Calculate mean response_time_ms for each log_level (INFO, WARN, ERROR, FATAL)
     - Show one bar per log_level, ordered by severity (INFO, WARN, ERROR, FATAL)
     - Label each bar with the average value (e.g. "842ms")
     - X-axis: "Log Level". Y-axis: "Average Response Time (ms)". Y-axis from 0. Title the chart.
     - Include a comment: "This chart tests whether ERROR/FATAL rows have higher response
       times than INFO rows — confirming or disproving the resource-exhaustion hypothesis."

   Chart 3 — Bar: ERROR + FATAL count by hour (chronological timeline)
     - Parse timestamp column as datetime
     - Group ERROR + FATAL rows by hour — use the actual datetime hour (e.g. 2024-11-01 08:00,
       2024-11-01 09:00, ...) not aggregated hour-of-day
     - X-axis: datetime hour (show as "YYYY-MM-DD HH:MM"). X-axis labels at 45°.
     - Y-axis: "Number of ERROR + FATAL Events". Y-axis from 0. Title the chart.

   Combine all 3 into outputs/B_dashboard.html (single self-contained file,
   include_plotlyjs=True on Chart 1 only). Add a summary header with row count,
   date range from data, and a one-sentence key finding from the EDA.
   Include a comment block per chart evaluating the business insight.
   Write the script to scripts/visualize_logs.py and run it.
   ```

3. **Save the generated script** before running: hover over the code block in Copilot Chat → click **Insert into New File** → save as `scripts/visualize_logs.py`. Alternatively, copy the code → `Ctrl+N` → paste → `Ctrl+S` → name it.

4. **Open the dashboard in your browser:**
   ```
   start outputs\B_dashboard.html        ← Windows
   open outputs/B_dashboard.html         ← Mac
   ```

5. **Confirm the script ran** and review the dashboard:
   - [ ] Dashboard opens in browser showing all 3 charts with the summary header
   - [ ] Summary header shows correct row count, date range, and a key finding sentence
   - [ ] Chart 1 (horizontal bar): bars ordered by count descending, each labelled
   - [ ] Chart 2 (grouped bar): one bar per log_level ordered INFO→FATAL, avg response time labelled; ERROR bars visibly higher than INFO if resource exhaustion is present
   - [ ] Chart 3 (bar): chronological timeline — x-axis shows actual datetime hours in order, not hour-of-day aggregated
   - [ ] All 3 charts have descriptive titles and labeled axes with units
   - [ ] Y-axes start at 0 on all charts
   - [ ] `user_id_masked` not visible in labels, axis values, or hover tooltips

6. **Sharing the dashboard**

   | Format | How | When to Use |
   |--------|-----|-------------|
   | **Interactive HTML** | Attach `outputs/B_dashboard.html` directly | Teams, email, internal review — opens in any browser, no install needed |
   | **Screenshot** | `Windows + Shift + S` over the open dashboard | Quick Teams/Slack paste |

   > **Before sharing:** Run the `VERIFY_BEFORE_SEND.md` checklist. Confirm `user_id_masked` is not visible in any label, axis, or hover tooltip.

---

## Stage 4 — Final Analysis Report (8 min)

**Goal:** Synthesize findings from all prior stages into a structured written deliverable for the Engineering Operations lead.

### 4.1 — Generate the Report

Open Copilot Chat (`Ctrl + Alt + I`). Select the **Report Writer** agent from the dropdown if available — or paste the prompt below directly.

**Attach these files before prompting:**
- `#outputs/B_profile.md`
- `#outputs/B_cleaning_decisions.md`
- `#scripts/clean_logs.py`

**Custom Prompt:**
```
You are a senior data analyst writing a structured RCA report for the Engineering Operations lead.
Using the attached profiling output, cleaning decisions, and EDA results from this session,
write a 6-section analysis report and save it to outputs/B_analysis_report.md:

**Section 1 — Executive Summary**
2–3 sentences. State: the most likely root cause service, the data quality issue that most
threatened analysis integrity, and the recommended action. No field names or technical jargon.

**Section 2 — Data Quality Issues Found**
| Issue | Rows Affected | Action Taken |
One table row per sentinel value or quality issue identified in profiling.

**Section 3 — EDA Findings**
| Finding | Metric | Evidence |
Three rows:
- Highest-failure service and confirmed average response time for that service
- Hourly failure distribution: which hours have elevated failure counts
- Evidence of failure concentration vs broad distribution across services

**Section 4 — Visualization Insights**
2–3 sentences on what the dashboard makes immediately visible that the raw data did not.

**Section 5 — Recommended Action**
One specific, actionable recommendation for the Engineering Operations lead.
Must cite: the specific service, the failure metric, and the next monitoring step.

**Section 6 — Limitations**
Bullet list. Include: row exclusion counts and why, whether the log sample covers all
failure modes, and what additional data would confirm the root cause.

Rules:
- Use actual numbers from prior stage outputs — do not estimate or round arbitrarily
- user_id_masked must not appear anywhere in the report
- No Python code blocks
- Output as clean Markdown ready to save to outputs/B_analysis_report.md
```

### 4.2 — Review Before Saving

1. Read **Section 3** — verify every number matches your actual EDA outputs; reject any estimates
2. Check **Section 5** — must name a specific service, not a general failure category
3. Save the output to `outputs/B_analysis_report.md`

### 4.3 — Stage 4 Review Checklist

- [ ] `outputs/B_analysis_report.md` created
- [ ] Executive Summary is 2–3 sentences with no field names
- [ ] Section 2 covers every data quality issue found in profiling
- [ ] Section 3 has actual numbers from EDA — not estimates
- [ ] Section 5 names a specific service with a failure metric and evidence
- [ ] Section 6 references specific row exclusion counts
- [ ] `user_id_masked` absent from the entire report

---

## Completion Checklist

- [ ] `scripts/profile_logs.py` — runs without error; output matches 300-row count
- [ ] `outputs/B_profile.md` — log dataset profiled, all known quality issues documented
- [ ] `scripts/clean_logs.py` — runs without error; row counts before/after printed
- [ ] `scripts/analyze_logs.py` — runs without error; failure rate per service calculated; hypothesis confirmed or contradicted
- [ ] `scripts/visualize_logs.py` — runs without error and generates the dashboard
- [ ] `outputs/B_cleaning_decisions.md` — every transformation justified; all 5 critique flaws addressed
- [ ] `outputs/B_dashboard.html` — single dashboard file with summary header and all 3 labeled interactive charts
- [ ] Pandas analysis ran; highest-failure service confirmed or contradicted by data
- [ ] No `user_id_masked` visible in any output, chart, or printed DataFrame
- [ ] `outputs/B_analysis_report.md` — 6-section structured report; Section 3 figures sourced from EDA outputs

---

## Debrief — Discussion Points

Your `outputs/B_analysis_report.md` is your prepared position. Use it to ground your answers.

1. **The root cause service named in Section 5 — is the evidence conclusive, or circumstantial? What would make it conclusive?**
2. **One flaw from the flawed analysis that would have produced the wrong escalation decision if you had repeated it.**
3. **One thing Copilot generated across any stage that required your correction — and what that says about where human judgment is still essential.**

> **Full reference:** `LAB_ACTION_GUIDE.md` contains additional context, troubleshooting, and all three scenarios if you want to compare approaches.
