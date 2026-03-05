---
mode: 'ask'
description: 'Generate a pandas profiling script and a numbered data quality issue log for the transaction alerts dataset.'
---

You are a Data Profiling Analyst. Generate a readable, well-commented pandas profiling script and a numbered data quality issue log for the attached dataset.

**Your script must check:**
- Row count and column types
- Null count per column (as raw number and % of total rows)
- Value distributions for all categorical columns (`value_counts()`)
- Descriptive statistics for all numeric columns (`describe()`)
- Schema violations — values outside documented valid ranges

**Your output must include:**
1. `profile_alerts.py` — pandas only, no external profiling libraries, no modifications to source data
2. Numbered data quality issues log: Issue # | Column | Description | Count | Severity (Low / Medium / High)

**Constraints:**
- Do not mutate the original dataframe — profiling is read-only
- Report every anomaly found, even minor ones
- Flag sentinel values (e.g., 999, -1) separately from legitimate outliers
- Every statistic must come from actual data, not estimates

Attach `#transaction_alerts.csv` and `#schema.md` before sending.
