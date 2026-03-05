# Schema: rca_app_logs.csv

**Use Case:** Root Cause Analysis (RCA) — Application Log Analysis
**Rows:** 300 | **Columns:** 9
**Source:** Synthetic application logs from a fictional microservices platform

---

## Column Reference

| # | Column | Type | Valid Values | Notes |
|---|--------|------|-------------|-------|
| 1 | `timestamp` | string | `YYYY-MM-DD HH:MM:SS` | **Issue: 12 rows in MM/DD/YYYY HH:MM format** |
| 2 | `service_name` | string | auth-service, payment-gateway, user-api, transaction-processor, notification-service | None |
| 3 | `environment` | string | prod, staging | None |
| 4 | `log_level` | string | INFO, WARN, ERROR, FATAL | None |
| 5 | `error_code` | string | ERR_001–ERR_500, ERR_DB_001 | Null for INFO/WARN rows |
| 6 | `message` | string | Free text | **Issue: 27 ERROR/FATAL rows have null or empty message** |
| 7 | `request_id` | string | REQ-XXXXX | **Issue: 8 duplicate request_ids** |
| 8 | `response_time_ms` | integer | > 0 | **Issue: 33 nulls (mostly FATAL rows)** |
| 9 | `user_id_masked` | string | u***XXX | PII-adjacent — do not expose in outputs |

---

## Known Data Quality Issues (4 total)

| # | Issue | Column | Count | Discovery Method |
|---|-------|--------|-------|-----------------|
| 1 | Mixed timestamp formats | `timestamp` | 12 | `df['timestamp'].str.match(r'^\d{2}/\d{2}')` |
| 2 | Null/empty message on ERROR/FATAL | `message` | 27 | `df[(df['log_level'].isin(['ERROR','FATAL'])) & (df['message'].isna() \| (df['message']==''))]` |
| 3 | Duplicate request_ids | `request_id` | 8 | `df['request_id'].duplicated().sum()` |
| 4 | Null response_time_ms | `response_time_ms` | 33 | `df['response_time_ms'].isnull().sum()` |

---

## Privacy Notes

- `user_id_masked` is a masked identifier — treat as PII-adjacent. Do not use as a chart label, export value, or print output.
- `service_name` and `environment` are safe for aggregation and visualization.

---

## Business Rules

- `log_level` severity order: INFO < WARN < ERROR < FATAL
- A `request_id` should be unique — duplicates indicate log pipeline errors or retry storms
- `response_time_ms` null on FATAL rows is expected (service crashed before timing out)
- `error_code` null on INFO/WARN rows is expected behavior, not a data issue
