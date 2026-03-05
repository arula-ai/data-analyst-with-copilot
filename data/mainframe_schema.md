# Schema: mainframe_usage.xlsx

**Use Case:** Product Usage & Modernization Analysis — Mainframe Feature Assessment
**Rows:** 400 | **Columns:** 10
**Source:** Synthetic mainframe feature usage metrics from a fictional enterprise platform
**Format:** Excel (.xlsx) — load with `pd.read_excel('data/mainframe_usage.xlsx')` (requires `openpyxl`)

---

## Column Reference

| # | Column | Type | Valid Values | Notes |
|---|--------|------|-------------|-------|
| 1 | `feature_id` | string | FEAT-XXXX | Unique identifier |
| 2 | `feature_name` | string | Free text | Name of the mainframe feature or module |
| 3 | `team` | string | Core Banking, Payments, Reporting, Risk & Compliance, Customer Portal | Owning team |
| 4 | `monthly_active_users` | integer | ≥ 0 | **Issue: 27 nulls** |
| 5 | `avg_response_ms` | float | > 0 | Average response time in milliseconds |
| 6 | `error_rate_pct` | float | 0.0–100.0 | **Issue: 18 negative values (invalid)** |
| 7 | `last_accessed_date` | string | `YYYY-MM-DD` | **Issue: 14 rows in MM/DD/YYYY format** |
| 8 | `legacy_flag` | boolean | True, False | True = running on mainframe |
| 9 | `modernization_priority` | string | High, Medium, Low | Team-assigned migration priority |
| 10 | `estimated_migration_effort_days` | integer | 5–365 | **Issue: 13 sentinel 9999 values (effort unknown)** |

---

## Known Data Quality Issues (4 total)

| # | Issue | Column | Count | Discovery Method |
|---|-------|--------|-------|-----------------|
| 1 | Null monthly_active_users | `monthly_active_users` | 27 | `df['monthly_active_users'].isnull().sum()` |
| 2 | Negative error_rate_pct | `error_rate_pct` | 18 | `(df['error_rate_pct'] < 0).sum()` |
| 3 | Mixed date formats | `last_accessed_date` | 14 | `df['last_accessed_date'].str.match(r'^\d{2}/\d{2}')` |
| 4 | Sentinel 9999 in migration effort | `estimated_migration_effort_days` | 13 | `(df['estimated_migration_effort_days'] == 9999).sum()` |

---

## Privacy Notes

- No direct PII in this dataset. `feature_id` and `feature_name` are internal product data — treat as Internal classification.
- Do not share team-level usage metrics externally without a compliance review.

---

## Business Rules

- `error_rate_pct` must be ≥ 0 — negative values are data pipeline errors, not valid readings
- `estimated_migration_effort_days = 9999` is a sentinel value meaning "effort not yet assessed" — exclude from any average or distribution calculation
- `legacy_flag = True` features are candidates for modernization; `False` features are already on modern infrastructure
- `monthly_active_users` null means telemetry was not collected for that feature in the period — do not treat as zero
