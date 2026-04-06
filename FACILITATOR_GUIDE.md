# Facilitator Guide — GitHub Copilot for Data Analysis Lab

**Instructor Reference Only — Not for Participants**

---

## 1. Session Overview

| Property | Value |
|---|---|
| Duration | 90 minutes |
| Recommended group size | 8–20 participants |
| Format | 30-min shared demo + 50-min scenario sprint (individual) + 10-min group debrief |
| Room setup | Individual workstations, VS Code installed, Python environment ready |
| Pre-session checks | Verify all participants have Copilot Chat enabled and `pip install -r requirements.txt` completed |
| Scenarios | 3 equal sub-labs — A (Treasury), B (RCA), C (Modernization). Participants choose 1. |

**Rotation model:** This lab runs 4x/month. Each session the facilitator fully demos 1 scenario. Participants build fluency across all 3 by attending multiple sessions or choosing the scenario most relevant to their role.

**Pre-session reminder:** Each scenario dataset contains intentional data quality issues. Do not fix them. Do not hint that they exist until the debrief. Participants are expected to discover them through profiling.

---

## 2. Shared Demo Block — Facilitator Script (0–30 min)

Run this block live with the full group. Participants follow along.

### 2a. Workspace Setup (5 min)

Walk participants through:
- Opening the repo in VS Code
- `VERIFY_BEFORE_SEND.md` — read it aloud; establish that this applies before every prompt
- `QUICK_START.md` — point to it for anyone new to Copilot Chat
- Agent Selector Dropdown — verify all 6 agents visible. The 4 primary agents (Data Profiling Analyst, Data Cleaning Engineer, Exploratory Data Analyst, Visualization Architect) are used in every scenario sprint. The 2 optional agents (Data Risk Reviewer, Responsible Use Auditor) are available for advanced participants or as optional governance extensions — see Section 7 for guidance.
- Folder layout: `scenarios/`, `reference/`, `templates/`, `outputs/`, `.github/agents/`

### 2b. RIFCC-DA Framework (5 min)

Open `reference/PROMPT_PATTERN.md` and walk through the 5 components:

| Component | Explain as |
|---|---|
| Role | "Who Copilot should pretend to be" |
| Inputs | "Which files you're handing it" |
| Format | "How you want the answer structured" |
| Constraints | "What it must NOT do" |
| Checks | "What to verify before answering" |

> **Facilitator tip:** Emphasise that domain context — business rules, valid ranges, known issues — travels in the **Inputs** field via the schema file attachment. Participants sometimes want a 6th "Domain" field; redirect them to pack that context into `I` using `#schema.md`.

Show one full example prompt using the `/` picker and explain the `#filename` attachment pattern.

### 2c. Responsible Use & Governance (5 min)

Walk through `reference/responsible_use.md`. Key points to emphasize:
- Synthetic data here — but the same rules apply to real data
- PII-adjacent fields exist in each dataset — never in charts, exports, or print output
- Data classification: Internal — do not paste rows into external AI tools or share outside the session
- Every transformation decision requires written justification — "Copilot said so" is not acceptable

### 2d. First Agent Demo (15 min)

**Choose one scenario dataset to demo live.** The recommended default is Sub-Lab A (treasury_payments.xlsx) because it has the most issues (11) and no code pre-step — it demonstrates pure data analysis cleanly. Use Sub-Lab B if your audience is engineering-heavy.

1. Discuss the business questions using Copilot.
2. Run the imports cell and data load cell — show the dataset is real and loads correctly
3. Select **Data Profiling Analyst** from the Agent Selector Dropdown
4. Enter a profiling prompt live using `/data-profiling-analyst` + `#filename`
5. Show how to evaluate the output: run the code, check the actual numbers vs. Copilot's claims
6. Show one follow-up prompt asking Copilot to identify issues
7. Point to the matching SUB_LAB_GUIDE.md stage — "this is what you'll do for 50 minutes"

---

## 3. Scenario Ground Truths

### Sub-Lab A — Treasury Anomaly Detection (treasury_payments.xlsx)

**Dataset:** 500 rows, 14 columns
**Schema:** `data/treasury_schema.md`

**No pre-step** — pure data analysis, no codebase review.

**PII-adjacent field:** `counterparty_masked` — never in any chart, print, or export.

**Known data quality issues (11):**

| Issue | Column | Count | Discovery |
|---|---|---|---|
| Duplicate payment_ids | `payment_id` | 12 | `df.duplicated(subset=['payment_id']).sum()` |
| "TRF" instead of "Wire Transfer" | `payment_type` | 23 | `df['payment_type'].value_counts()` |
| Negative payment_amount | `payment_amount` | 8 | `(df['payment_amount'] < 0).sum()` |
| Null payment_amount | `payment_amount` | 15 | `df.isnull().sum()` |
| Sentinel 999 in prior_alerts_90d | `prior_alerts_90d` | 6 | `df[df['prior_alerts_90d'] > 20]` |
| Null days_since_last_payment | `days_since_last_payment` | 34 | `df.isnull().sum()` |
| risk_score > 1.0 | `risk_score` | 11 | `df[df['risk_score'] > 1.0]` |
| analyst_confidence = -1 | `analyst_confidence` | 19 | `df['analyst_confidence'].value_counts()` |
| anomaly_confirmed = 2 | `anomaly_confirmed` | 4 | `df['anomaly_confirmed'].value_counts()` |
| Blank review_status | `review_status` | 7 | `df['review_status'].isnull().sum()` |
| Mixed date formats | `payment_date` | 5 | `pd.to_datetime(..., errors='coerce').isnull().sum()` |

**Key constraints:**
- Exclude `anomaly_confirmed = 2` from all rate calculations
- Exclude `prior_alerts_90d = 999` from all averages
- Exclude `analyst_confidence = -1` from all confidence calculations
- Never include `counterparty_masked` in any output

**Expected Phase 2 Pandas findings:** Wire Transfer has highest anomaly rate. FX Settlement payments concentrate in the top amount ranges.

**Expected Phase 3 charts:**
1. Confirmed anomaly rate by payment_type (bar) — Wire Transfer highest after excluding anomaly_confirmed=2
2. payment_amount distribution for confirmed anomalies (histogram) — bimodal or right-skewed
3. Confirmed anomaly count by week of Q4 2024 (line) — trend visible, possible spike in late November

**Flawed analysis errors (in exercises/):**
1. Impossible anomaly rate — "134% of Wire Transfer payments confirmed as anomalies"
2. Causal claim — "high risk score causes anomalies"
3. Logical contradiction — "500 rows intact" after claiming duplicates and invalid values were removed
4. Sentinel 999 in average — prior_alerts_90d average skewed by sentinel values not excluded
5. Legacy code in calculation — analyst_confidence = -1 included in average, dragging it negative

---

### Sub-Lab B — Root Cause Analysis (rca_app_logs.csv)

**Dataset:** 300 rows, 9 columns
**Schema:** `data/rca_schema.md`

**Pre-step:** Read `app_service.py` BUG comments. Expected hypotheses: PaymentGateway and TransactionProcessor produce the most errors.

**Known data quality issues (4):**

| Issue | Column | Count | Discovery |
|---|---|---|---|
| Duplicate request_ids | `request_id` | 15 | `df.duplicated(subset=['request_id']).sum()` |
| Null response_time_ms | `response_time_ms` | 22 | `df.isnull().sum()` |
| Mixed timestamp formats | `timestamp` | 18 | `pd.to_datetime(..., errors='coerce').isnull().sum()` |
| Sentinel -1 in response_time_ms | `response_time_ms` | 9 | `(df['response_time_ms'] < 0).sum()` |

**Expected Phase 1 findings:** TransactionProcessor and PaymentGateway have the highest ERROR/FATAL counts. Log distribution skewed toward ERROR/FATAL in afternoon hours.

**Expected Phase 2 Pandas findings:** Top error_codes are clustered around 500-series for TransactionProcessor; AuthService has fewer fatal errors but high WARN rate.

**Expected Phase 3 charts:**
1. Error rate by service (bar) — TransactionProcessor highest
2. response_time_ms distribution (histogram) — long right tail on ERROR events
3. ERROR+FATAL count over time (line) — afternoon clustering visible

**Flawed analysis errors (in exercises/):**
1. Wrong service blamed — NotificationService named as root cause, but TransactionProcessor has higher raw ERROR count after deduplication
2. Causal claim — "high response times cause errors" (correlation, not causation)
3. Logical contradiction — "300 rows retained after deduplication" but 15 duplicates removed
4. Sentinel in average — FATAL nulls filled with 0 rather than excluded, skews response time average
5. False completeness — claims "all error_codes present" but null error_codes not counted

---

### Sub-Lab C — Product Modernization (mainframe_usage.xlsx)

**Dataset:** 400 rows, 10 columns
**Schema:** `data/mainframe_schema.md`

**Pre-step:** Read `legacy_mainframe.py` BUG comments. Expected assessment: `process_wire_transfer` and `get_fx_rate` are highest migration risk due to hardcoded values and no error handling.

**Known data quality issues (4):**

| Issue | Column | Count | Discovery |
|---|---|---|---|
| Null monthly_active_users | `monthly_active_users` | 27 | `df['monthly_active_users'].isnull().sum()` |
| Negative error_rate_pct | `error_rate_pct` | 18 | `(df['error_rate_pct'] < 0).sum()` |
| Mixed date formats | `last_accessed_date` | 14 | `pd.to_datetime(..., errors='coerce').isnull().sum()` |
| Sentinel 9999 in migration effort | `estimated_migration_effort_days` | 13 | `(df['estimated_migration_effort_days'] == 9999).sum()` |

**Key constraint:** `estimated_migration_effort_days = 9999` means "effort not assessed" — must be excluded from all averages and rankings.

**Expected Phase 2 Pandas findings:** Risk & Compliance team has most legacy features. Core Banking has highest active users on legacy infrastructure.

**Expected Phase 3 charts:**
1. Legacy vs. modern count by team (grouped bar) — Risk & Compliance highest legacy ratio
2. monthly_active_users distribution (histogram) — right-skewed, few very high-usage features
3. migration effort vs. usage (scatter) — no strong correlation; high-effort features not necessarily high-usage

**Flawed analysis errors (in exercises/):**
1. Sentinel 9999 included in ranking — inflates estimated effort dramatically
2. Causal claim — "high legacy count causes operational risk" (correlation only)
3. Logical contradiction — "all 400 rows intact" after claiming nulls were dropped
4. Negative error_rate in average — invalid values included, skews error rate statistics
5. Unverified statistic — "78% of features are High priority" (actual value differs)

---

## 4. Common Failure Patterns and Coaching Interventions

| Stage | Common Failure | Root Cause | Coaching Intervention |
|---|---|---|---|
| 1 | Accepts Copilot output without running the code | Trusts AI over verified execution | "What does your terminal actually show? Run the script and show me the output." |
| 1 | Finds only 3–4 issues, not the expected count | Didn't check sentinel values or valid ranges | "What does `value_counts()` show for the flag column? Is every value in the valid range?" |
| 2 | Cleaning script uses `df.dropna()` with no parameters | Copilot generated it; participant didn't read it | "How many rows does that remove? Run `df.dropna().shape` and compare to `df.shape`." |
| 2 | Code output is empty or wrong | Code generated incorrectly | "Did you check the dataframe name? Does the script exclude the sentinel value?" |
| 3 | Chart Y-axis starts mid-range | Copilot default; participant didn't check | "Set `ylim(0, ...)` explicitly. Show me the chart with Y-axis starting at 0." |
| 3 | PII-adjacent field appears in chart | Forgot to exclude it | "Confirm `counterparty_masked` is not in any axis label, title, or legend. Remove if present." |
| 3 | Charts have no titles or axis labels | Focused on code, not output quality | "If someone received this chart by email with no context, what would they know from looking at it?" |
| Any | Makes causal claims in findings | Common analytical error | "What would you need to show causation here? Change to 'is associated with.'" |

---

## 5. Timing Guidance

| Check-in | Time | Typical State | Action if Behind |
|---|---|---|---|
| First check | 45 min | Should be finishing Phase 1 and starting Phase 2 | If still on Phase 1 profiling: focus on the top 5 issues, skip exhaustive documentation, move to cleaning |
| Second check | 65 min | Should be finishing Phase 2 EDA | If stuck on EDA: skip the optional questions, confirm at least 2 Pandas results documented, move to Phase 3 |
| Third check | 77 min | Should have at least 2 charts done | If only 1 chart: complete charts 2 and 3 without interpretation cells, add notes in visualization_notes_template |

**Where participants typically fall behind:**
- Phase 2 is the most time-consuming — 25 minutes is tight if the cleaning script needs significant corrections
- Phase 1 takes longer than expected when code needs to actually be run — don't let participants skip execution
- Phase 3 is fast if the data is clean — reinforce that 3 charts minimum is the goal, not 6

---

## 6. Group Debrief Script (82–90 min)

Run as a full-group discussion. No solo artifacts required for debrief.

**Round 1 — One finding per group (2 min):**
Go around the room. Each participant states their top finding in one sentence, VP-framing:
> *"The data shows that [X] which means the operations team should [Y]."*

Prompt if too technical: *"Skip the pandas. Tell me what you found, not how you found it."*

**Round 2 — One risk per group (2 min):**
Each participant names one data quality issue they caught and what would have happened to the analysis if they'd missed it:
> *"If I had not excluded [sentinel value / bad rows], my [chart / rate / average] would have shown [wrong result]."*

**Round 3 — One Copilot correction (2 min):**
Each participant names one thing Copilot generated that was wrong, and how they caught it:
> *"Copilot [described output]. I corrected it because [reason]."*

**Responsible Use discussion (2 min):**
Prompt as a group:
- "Did anyone catch Copilot generating something that included a PII-adjacent field?"
- "What's the difference between Copilot making an assumption versus making a mistake? Give me an example from today."

**Wrap (2 min):**
Remind participants:
- Deliverables go in `outputs/` — 3 artifacts needed to mark the lab complete
- The flawed exercises in `exercises/` are worth reviewing after the session
- These same agents and prompts work on real datasets — the RIFCC-DA framework transfers directly

---

## 7. Optional Agent Extensions (Advanced / Time Permitting)

Two additional agents exist in `.github/agents/` that are not part of the standard 3-phase flow. Use them for advanced participants, governance-focused sessions, or when time allows.

### Data Risk Reviewer
**When to use:** At the very start of a scenario, before Phase 1 — as a data governance pre-check.
**What it does:** Classifies every column by sensitivity tier (Public / Internal / Confidential / Restricted), flags PII-adjacent fields, and produces a handling recommendations table and Pre-Analysis Checklist.
**How to activate:** Select "Data Risk Reviewer" from the agent dropdown, then attach the scenario dataset and schema file.
**Facilitator note:** This is a strong opener if the session audience includes data governance, security, or compliance roles. It reinforces the VERIFY_BEFORE_SEND.md checklist with an AI-assisted classification layer.

### Responsible Use Auditor
**When to use:** After Phase 3, as a closing quality gate — before sharing any outputs.
**What it does:** Reviews all generated scripts and outputs for policy compliance. Flags external API calls, hardcoded sensitive values, PII-adjacent field exposure, and unsafe file operations. Produces a Risk Findings table and an Auditor Sign-off with Pass / Pass with conditions / Fail verdict.
**How to activate:** Select "Responsible Use Auditor" from the agent dropdown, then attach the generated scripts and output files for review.
**Facilitator note:** This is a strong closing exercise for engineering-heavy audiences. The Risk Findings table maps directly to the debrief Round 2 ("what risk did you catch?") discussion.

---

## 8. Technical Troubleshooting

| Issue | Likely Cause | Fix |
|---|---|---|
| Copilot Chat not responding | Extension not authenticated or rate limited | Check extension status bar; sign out and back into GitHub account |
| Copilot doesn't see the file | `#filename` not used — pasted text instead | Retype `#` in chat input and use the file picker dropdown |
| Script not executing | Python path not configured | `Ctrl+Shift+P` → "Python: Select Interpreter" → choose Python 3.10+ |
| `import pandas` fails | Not installed in active environment | `pip install -r requirements.txt` |
| Excel file not loading | `openpyxl` not installed | `pip install openpyxl` then reload kernel |
| Agent not in dropdown | `.github/agents/` folder missing or misnamed | Verify `.agent.md` files exist in `.github/agents/` at workspace root |
| `pd.to_datetime()` fails | Mixed date formats (intentional) | Use `errors='coerce'` — returns NaT for unparseable rows |
| Script execution error | Path issues | Path `../data/filename` vs `data/filename`... verify working directory |
