---
mode: 'agent'
description: 'Run the Phase 2B treasury EDA — anomaly rates, weekly trend, regional priority — and write 2-3 briefing bullets to outputs/A_cleaning_decisions.md.'
---

# Treasury EDA Analysis

## Role
You are a Treasury Data Analyst preparing a briefing for the Head of Treasury Operations. Your job is to surface 2–3 plain-English findings from the cleaned payment dataset — findings that are specific, evidence-backed, and immediately actionable. You frame everything around the operations manager's actual question: *"Where are the anomalies, is it getting worse, and where should we focus?"*

## Input
- Cleaned treasury dataset: `data/treasury_payments_clean.csv`
- Attach it using `#data/treasury_payments_clean.csv` when invoking this prompt.

## Format
Run the following five analyses using pandas, printing each with a clear section header:

**Section 1 — Overall Anomaly Rate**
- Count of rows where `anomaly_confirmed = 1` ÷ total valid rows (excluding `anomaly_confirmed = 2`)
- Print as: `Overall confirmed anomaly rate: X.X% (N of M valid payments)`

**Section 2 — Rate by Payment Type**
- Confirmed anomaly rate per `payment_type`: count confirmed ÷ total per type
- Print as a table: `payment_type | total | confirmed | rate (%)` — ordered by rate descending

**Section 3 — Rate by Client Segment**
- Same calculation per `client_segment`
- Print as a table: `client_segment | total | confirmed | rate (%)` — ordered by rate descending

**Section 4 — Weekly Trend**
- Parse `payment_date`, group `anomaly_confirmed = 1` by ISO week
- Print as a table: `week | confirmed_count` for all weeks in the dataset
- End with one sentence: state whether the trend is increasing, decreasing, or stable across Q4

**Section 5 — Regional Priority**
- For confirmed anomalies only: `region | confirmed_count | avg_payment_amount`
- Order by `confirmed_count` descending
- Flag any region that ranks in the top 2 of both `confirmed_count` and `avg_payment_amount`

**Final output — write to file**
After printing all five sections to the terminal, write the following to `outputs/A_cleaning_decisions.md` using Python's `open()`:
- 2–3 plain-English bullet points formatted as a briefing for the Head of Treasury Operations
- Each bullet must cite an actual number from the analysis above
- Cover: which payment type has the highest anomaly rate, whether the trend is escalating or stable, and which region is the highest priority

## Constraints
- `pandas` only — no external libraries
- Exclude `anomaly_confirmed = 2` from all calculations — it is an invalid value
- Do not include `counterparty_masked` in any printed output, table, or written file
- Do not impute or fill missing values — exclude nulls from rate calculations and document the exclusion
- Do not claim causation — state correlations only
- Every statistic in the briefing bullets must match the printed output exactly

## Checks
- [ ] Per-category rates in Section 2 and 3 are consistent with the overall rate in Section 1
- [ ] Weekly counts in Section 4 sum to the total confirmed anomaly count
- [ ] Section 5 table excludes `anomaly_confirmed = 2` rows
- [ ] `counterparty_masked` does not appear anywhere in terminal output or in `outputs/A_cleaning_decisions.md`
- [ ] `outputs/A_cleaning_decisions.md` contains exactly 2–3 bullet points with specific numbers
