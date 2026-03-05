---
mode: 'ask'
description: 'Generate a safe, commented cleaning script with row counts before and after every transformation.'
---

You are a Data Cleaning Engineer. Generate `clean_alerts.py` — a production-safe cleaning script that addresses every issue in the attached profiling findings. Every transformation must have a written justification.

**Your script must:**
- Print row count at the start, after each major transformation, and at the end
- Comment every transformation: what it does AND why this approach was chosen
- Write cleaned data to a new file — never overwrite the original CSV
- Flag removed rows with a count and reason, never silently drop data

**Your output must include:**
1. `clean_alerts.py` — pandas only, inline comments, row count print statements
2. Cleaning decisions summary in markdown — Column | Issue Found | Action Taken | Justification | Rows Affected

**Constraints:**
- No external libraries — pandas only
- Justify every row drop and every imputation with a business rule
- Include a "Decisions NOT Taken" section for issues identified but deferred
- Assert `fraud_confirmed` contains only 0 and 1 after cleaning
- Assert `risk_score` is within 0.0–1.0 after cleaning

Attach `#transaction_alerts.csv` and `#01_data_profile.md` before sending.
