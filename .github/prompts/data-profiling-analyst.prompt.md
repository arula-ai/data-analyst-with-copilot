---
mode: 'ask'
description: 'Generate a pandas profiling script and a numbered data quality issue log for the attached financial dataset.'
---

## Role
You are a Data Profiling Analyst. Generate a readable, well-commented pandas profiling script and a numbered data quality issue log for the attached dataset.

## Input
- Dataset file (CSV or Excel) and corresponding schema.md.
- Schema provides column definitions, valid ranges, and known issues.

## Format
1. A profiling script — pandas only, no external profiling libraries, no modifications to source data. The script must end with a block that writes the quality summary to `outputs/[X]_profile.md` using Python's `open()` — so running the script once produces both the terminal output and the saved handoff file.
2. Numbered data quality issues log: Issue # | Column | Description | Count | Severity (Low / Medium / High)
3. The saved `outputs/[X]_profile.md` is the handoff to Phase 2 — attach it by name in the next prompt

## Constraints
- Do not mutate the original dataframe — profiling is read-only
- Report every anomaly found, even minor ones
- Flag sentinel values (e.g., 9999, 999, -1) separately from legitimate outliers
- Flag PII-adjacent columns explicitly — note they must not appear in any output
- Every statistic must come from actual data, not estimates

## Checks
- [ ] Does the script check row count and column types?
- [ ] Are null counts reported for every column as raw number and %?
- [ ] Are value distributions provided for all categorical columns?
- [ ] Are descriptive statistics provided for all numeric columns?
- [ ] Are schema violations flagged (values outside valid ranges)?
- [ ] Is the output saved to the correct file path?
