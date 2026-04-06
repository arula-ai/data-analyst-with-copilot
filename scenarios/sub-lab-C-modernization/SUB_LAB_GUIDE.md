# Sub-Lab C — Product Modernization
## Scenario Walkthrough (50 min)

**Your Role:** Platform Modernization Analyst — Engineering Strategy Team
**Dataset:** `data/mainframe_usage.xlsx` — 400 mainframe feature usage records
**Source Code:** `data/legacy_mainframe.py` — read this before the usage data
**Sentinel Value:** `9999` in `estimated_migration_effort_days` means "effort not yet assessed" — never treat as a real value

---

## Timing Overview

| Block | Time | What You Do |
|---|---|---|
| **Stage 0** | 5 min | Setup and orientation |
| **Pre-Step** | 5 min | Review legacy code — rate migration complexity before touching the data |
| **Phase 1** | 10 min | Profile the usage dataset — find all quality issues |
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
  mainframe_usage.xlsx          ← your dataset
  mainframe_schema.md           ← read this before Phase 1
  legacy_mainframe.py           ← read this in the Pre-Step
outputs/                        ← all deliverables go here
scripts/                        ← your generated scripts go here
scenarios/sub-lab-C-modernization/
  exercises/
    flawed_modernization_analysis.md  ← used in Phase 2 Step 1
```

---

## Pre-Step — Legacy Code Review (5 min)

**Agent:** Exploratory Data Analyst

> A feature that is heavily used AND technically complex to migrate is your highest priority. Assess the code complexity first — then cross-reference against usage data.

1. Open `data/legacy_mainframe.py`

2. Select **Exploratory Data Analyst** from Agent dropdown

3. **Custom prompt:**
   ```
   Review #data/legacy_mainframe.py. For each function: function name, what it does in plain English,
   which defects (marked BUG) it contains, and why those defects would make migration to a modern
   service more complex or risky. Rate each function: Low / Medium / High migration complexity.
   Do not fix the code — describe only. Plain English.
   ```

4. **Review output for:**
   - [ ] All functions assessed — confirm the count matches the file before accepting the output
   - [ ] Each function has a migration complexity rating with reasoning
   - [ ] At least one function rated High with a clear link to a specific BUG comment
   - [ ] BUG comments connected to concrete migration risks (e.g., no idempotency → duplicate records on retry)

5. **Write down your hypothesis:** Which function is the highest-priority modernization candidate based on code complexity? You will cross-reference against usage data in Phase 2.

---

## Phase 1 — Data Ingestion & Quality Assessment (10 min)

**Agent:** Data Profiling Analyst
**Prompt file:** `/data-profiling-analyst`

> **Before prompting:** Read `data/mainframe_schema.md` — the Known Issues section documents sentinel values and invalid entries.

### Steps

1. Select **Data Profiling Analyst** from Agent dropdown

2. **Recommended prompt:**
   Type `/data-profiling-analyst` then attach `#data/mainframe_usage.xlsx` and `#data/mainframe_schema.md`

   **Or use this custom prompt:**
   ```
   Profile data/mainframe_usage.xlsx using pandas (pd.read_excel, requires openpyxl).
   Print: row count, null count per column, value_counts for team, legacy_flag,
   and modernization_priority, describe() for numeric columns.
   Flag: negative error_rate_pct values, sentinel 9999 in estimated_migration_effort_days
   (this means "effort not yet assessed" — do not treat as a real value),
   null monthly_active_users (do not treat as zero — telemetry was not collected),
   mixed date formats in last_accessed_date.
   Do not modify the dataframe.
   Save the quality summary to outputs/C_profile.md.
   ```

3. **Save the generated code** to `scripts/profile_mainframe.py`, then run:
   ```
   python scripts/profile_mainframe.py
   ```

4. **Review output for:**
   - [ ] Row count = 400
   - [ ] Sentinel `9999` in `estimated_migration_effort_days` flagged separately — not treated as a real value
   - [ ] Null `monthly_active_users` flagged — explicitly noted as "telemetry not collected", not zero
   - [ ] Negative `error_rate_pct` values flagged as invalid
   - [ ] `legacy_flag` and `modernization_priority` distributions documented
   - [ ] Output saved to `outputs/C_profile.md`

> `outputs/C_profile.md` is your handoff to Phase 2 — attach it with `#outputs/C_profile.md` in your next prompt.

---

## Phase 2 — Analysis Critique, Cleaning & Exploratory Analysis (25 min)

**Agent:** Data Cleaning Engineer
**Prompt file:** `/data-cleaning-engineer`

### Step 1 — Critique the Flawed Analysis (5 min)

> The previous modernization analyst produced a report with embedded errors. Identify every flaw before writing your own script — this prevents you from repeating the same mistakes.

1. Select **Data Cleaning Engineer** from Agent dropdown

2. **Custom prompt:**
   ```
   Review #scenarios/sub-lab-C-modernization/exercises/flawed_modernization_analysis.md and #outputs/C_profile.md.
   Identify every analytical flaw in the report. For each flaw:
   1. State the claim made in the report
   2. Explain why it is wrong (logical, statistical, or data quality error)
   3. State what the correct approach would be, referencing specific issues from C_profile.md
   ```

3. **Review output for:**
   - [ ] All 5 flaws identified (the document contains exactly 5)
   - [ ] Each flaw linked to a specific data quality issue (sentinel values, causal claims, logical contradictions)
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

5. **Review code before running.** Verify:
   - Sentinel `9999` in `estimated_migration_effort_days` excluded from calculations — not imputed or dropped
   - Negative `error_rate_pct` handled with business justification
   - Null `monthly_active_users` documented as "telemetry not collected" — NOT imputed as 0
   - Mixed date formats resolved with `pd.to_datetime(errors='coerce')`

6. **Save the generated code** to `scripts/clean_mainframe.py`, then run:
   ```
   python scripts/clean_mainframe.py
   ```

7. **Follow-up prompt:**
   ```
   For null monthly_active_users: what are the business-valid options for handling them?
   Why does imputing 0 introduce bias in a modernization prioritization context?
   ```

8. **Review output for:**
   - [ ] Every transformation has a written justification comment
   - [ ] Row count documented before AND after cleaning
   - [ ] Sentinel `9999` handling explicitly documented — not silently dropped
   - [ ] Null `monthly_active_users` not imputed as 0 — decision documented

9. Save to: `scripts/clean_mainframe.py` + `outputs/C_cleaning_decisions.md`
   *(Use template: `templates/cleaning_decisions_template.md`)*

> **SQL Reference (Optional — Module 3):** See `scenarios/sub-lab-C-modernization/exercises/sql_cleaning_reference.sql` for equivalent SQL cleaning logic. SQL is not required — Python is the deliverable.

### Step 3 — Exploratory Analysis (5 min)

10. **Custom prompt:**
    ```
    Using data/mainframe_usage_clean.csv, generate a pandas script (scripts/analyze_mainframe.py):
    - Count of legacy features (legacy_flag = True) grouped by team
    - Top 5 features by monthly_active_users where legacy_flag = True (exclude null users)
    - Features where modernization_priority = 'High' AND estimated_migration_effort_days != 9999,
      ordered by monthly_active_users descending
    - Average error_rate_pct by team (exclude negative values)
    ```

    **Save the generated code** to `scripts/analyze_mainframe.py`, then run:
    ```
    python scripts/analyze_mainframe.py
    ```

11. **Follow-up prompt:**
    ```
    Using pandas, rank the top 3 legacy features that are both:
    - modernization_priority = 'High'
    - monthly_active_users in the top 25% of all features
    Order by monthly_active_users descending. Exclude rows where effort = 9999.
    Do the top candidates match your hypothesis from the code review? Explain why or why not.
    ```

12. **Review output for:**
    - [ ] Sentinel `9999` correctly excluded from the ranked list
    - [ ] Results consistent with profiling findings
    - [ ] Top candidates reconciled with code review complexity ratings

---

## Phase 3 — Insight Visualization & Reporting (15 min)

**Agent:** Visualization Architect
**Prompt file:** `/visualization-architect`

1. Select **Visualization Architect** from Agent dropdown

2. **Recommended prompt:**
   Type `/visualization-architect` then attach `#data/mainframe_usage_clean.csv`

   **Or use this custom prompt:**
   ```
   Using data/mainframe_usage_clean.csv, generate scripts/visualize_mainframe.py with
   3 interactive charts using plotly.express:
   1. Count of legacy vs modern features by team (grouped bar chart)
   2. monthly_active_users distribution for legacy features only (histogram)
   3. Scatter plot: monthly_active_users (x) vs estimated_migration_effort_days (y),
      colored by modernization_priority — exclude rows where effort = 9999
   Rules: Y-axis starts at 0 for bar and histogram (fig.update_yaxes(rangemode='tozero')).
   Do NOT apply rangemode='tozero' to the scatter plot — let the axis scale to the data.
   No 3D charts.
   All axes labeled with units. All charts titled.
   Export each chart: fig.write_html('outputs/C_chart_0N_name.html')
   Include a comment block evaluating the charts for the business.
   ```

3. **Save the generated code** to `scripts/visualize_mainframe.py`, then run:
   ```
   python scripts/visualize_mainframe.py
   ```

4. **Review each HTML file in your browser:**
   - [ ] All 3 charts open correctly in a browser
   - [ ] All 3 charts have descriptive titles
   - [ ] Axes labeled with units (e.g., "Monthly Active Users", "Migration Effort (days)")
   - [ ] Y-axis starts at 0 on bar chart and histogram
   - [ ] Scatter plot excludes sentinel `9999` — verify in the code before accepting output

5. **Sharing and Exporting Visuals**

   | Format | How | When to Use |
   |--------|-----|-------------|
   | **Interactive HTML** | Share `.html` directly — opens in any browser | Default for internal stakeholders |
   | **Static PNG** | Open HTML in Chrome → download chart image | For slide decks or email |
   | **Clipboard screenshot** | `Windows + Shift + S` | Quick sharing in Teams/Slack |

   > **Before sharing:** Run the `VERIFY_BEFORE_SEND.md` checklist. Confirm no internal identifiers are visible in labels, axes, or hover tooltips.

---

## Completion Checklist

- [ ] `scripts/profile_mainframe.py` — runs without error; output matches 400-row count
- [ ] `outputs/C_profile.md` — usage dataset profiled, all known quality issues documented
- [ ] `scripts/clean_mainframe.py` — runs without error; row counts before/after printed
- [ ] `scripts/analyze_mainframe.py` — runs without error; top modernization candidates identified with supporting data
- [ ] `scripts/visualize_mainframe.py` — runs without error and generates HTML outputs
- [ ] `outputs/C_cleaning_decisions.md` — every transformation justified; all 5 critique flaws addressed; sentinel `9999` and null `monthly_active_users` decisions documented
- [ ] `outputs/C_chart_*.html` — 3 labeled interactive charts saved to outputs folder
- [ ] Pandas analysis ran and top modernization candidates identified
- [ ] Sentinel `9999` excluded from all calculations and charts

---

## Debrief — Prepare These 3 Points

1. Which 2–3 features you recommend for immediate modernization — and why (cite both usage data and code complexity)
2. One flaw from the flawed analysis that would have produced a wrong recommendation if repeated
3. One thing Copilot generated that you had to correct

> **Full reference:** `LAB_ACTION_GUIDE.md` contains additional context, troubleshooting, and all three scenarios if you want to compare approaches.
