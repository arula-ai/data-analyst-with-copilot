# Data Profile Report
**Stage:** 1 | **Agent Mode:** Data Profiling Analyst | **Time Budget:** 10 min
**Save to:** `outputs/01_data_profile.md`

---

## Purpose
This document records the structural analysis and data quality findings for your scenario dataset. It is the input for Stage 2 cleaning decisions. Every number here must come from actually running the profiling code — not from Copilot's estimates.

---

## Dataset Overview

> Fill in after running the profiling script.

| Property | Value |
|---|---|
| File | *(dataset filename)* |
| Total Rows | |
| Total Columns | |
| Columns with Nulls | |
| Date Profiled | |
| Profiling Script | *(link to or name of the script you ran)* |

---

## Column-by-Column Profile

> Fill in from profiling script output. Mark anomalies found in the last column.

| Column | Null Count | Null % | Unique Values | Data Type (actual) | Anomalies Found |
|---|---|---|---|---|---|
| *(col 1)* | | | | | |
| *(col 2)* | | | | | |
| *(col 3)* | | | | | |
| *(col 4)* | | | | | |
| *(col 5)* | | | | | |
| *(col 6)* | | | | | |
| *(col 7)* | | | | | |
| *(col 8)* | | | | | |
| *(add more rows as needed)* | | | | | |

---

## Data Quality Issues Log

> Document every quality issue found. Use severity: Low (cosmetic), Medium (affects analysis if uncorrected), High (invalidates analysis if uncorrected).

| Issue # | Column | Description | Count | Severity |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |
| 6 | | | | |
| 7 | | | | |
| 8 | | | | |
| *(add more as needed)* | | | | |

---

## Sentinel Values and Special Codes

> List any sentinel values or legacy codes found that require special handling in Stage 2.

| Column | Sentinel Value | Meaning | Count | Action Required |
|---|---|---|---|---|
| | | | | |

---

## Copilot Assumptions

> Document anything Copilot assumed about the data that you have NOT yet manually verified. These need to be validated before Stage 2.

- *Example: "Copilot assumed all date values are parseable — not verified against actual parse errors yet."*
- *[Add your own entries here]*

---

## Manually Verified Facts

> Document facts you confirmed by running code and checking the actual output — not Copilot's claims.

- *Example: "Confirmed 12 duplicate IDs by running df.duplicated(subset=['id_col']).sum() — output: 12."*
- *[Add your own verified facts here]*

---

## Profiling Code Reference

Profiling script saved at: *(file path or "generated in Copilot Chat")*

Key commands used:
- `df.shape` — row and column count
- `df.isnull().sum()` — null counts per column
- `df.dtypes` — actual data types
- `df['col'].value_counts()` — categorical distributions
- `df.describe()` — numeric column statistics
