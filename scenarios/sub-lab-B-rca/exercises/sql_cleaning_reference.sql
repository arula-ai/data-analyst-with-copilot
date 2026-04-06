-- SQL Cleaning Reference: rca_app_logs
-- Scenario B — Root Cause Analysis
-- This script mirrors the Python cleaning logic in scripts/clean_logs.py
-- Use this if your production pipeline is SQL-based (PostgreSQL / SQL Server syntax shown)
--
-- NOTE: SQL is NOT required to complete the lab.
-- The Python script (scripts/clean_logs.py) is the primary deliverable.
--
-- Source schema: data/rca_schema.md
-- Python equivalent: scripts/clean_logs.py (generated during Phase 2)

-- ============================================================
-- STEP 0: Count rows before cleaning
-- ============================================================
SELECT COUNT(*) AS rows_before_cleaning FROM rca_app_logs;
-- Expected: 300


-- ============================================================
-- STEP 1: Remove duplicate request_ids (keep first occurrence)
-- Business justification: request_id should be unique — duplicates indicate
-- log pipeline errors or retry storms per rca_schema.md.
-- Retaining duplicates inflates per-service failure counts.
-- ============================================================
WITH deduped AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY request_id ORDER BY timestamp) AS rn
    FROM rca_app_logs
)
SELECT * INTO rca_app_logs_step1
FROM deduped
WHERE rn = 1;

SELECT COUNT(*) AS rows_after_dedup FROM rca_app_logs_step1;
-- Expected: ~292 (300 - 8 duplicates)


-- ============================================================
-- STEP 2: Normalize timestamp format
-- Business justification: 12 rows use MM/DD/YYYY HH:MM format instead of YYYY-MM-DD HH:MM:SS.
-- Mixed formats prevent correct time-series grouping and hour-level analysis.
-- ============================================================

-- PostgreSQL example:
-- UPDATE rca_app_logs_step1
-- SET timestamp = TO_TIMESTAMP(timestamp, 'MM/DD/YYYY HH24:MI')
-- WHERE timestamp ~ '^\d{2}/\d{2}/\d{4}';

-- SQL Server example:
-- UPDATE rca_app_logs_step1
-- SET timestamp = CONVERT(DATETIME, timestamp, 101)
-- WHERE timestamp LIKE '__/__/____ __%';

-- Verify: all timestamps parseable
SELECT COUNT(*) AS unparseable_timestamps
FROM rca_app_logs_step1
WHERE TRY_CAST(timestamp AS DATETIME) IS NULL;
-- Expected: 0 after normalization


-- ============================================================
-- STEP 3: Handle null/empty message on ERROR and FATAL rows
-- Business justification: 27 ERROR/FATAL rows have null or empty message fields.
-- These are data gaps — the log pipeline failed to capture the message.
-- Decision: RETAIN these rows (they still represent failure events).
-- DO NOT drop them — a FATAL event without a message is still a FATAL event.
-- ============================================================
SELECT log_level, COUNT(*) AS null_message_count
FROM rca_app_logs_step1
WHERE (message IS NULL OR message = '') AND log_level IN ('ERROR', 'FATAL')
GROUP BY log_level;
-- Expected: ~27 combined ERROR + FATAL

-- Document these rows in B_cleaning_decisions.md.
-- They are retained in the cleaned dataset.


-- ============================================================
-- STEP 4: Handle null response_time_ms
-- Business justification: response_time_ms is null for FATAL rows — expected behavior.
-- Service crashed before timing could be recorded.
-- CRITICAL: DO NOT fill nulls with 0. Null ≠ 0ms response time.
-- Using COALESCE(response_time_ms, 0) is INCORRECT and will skew averages downward.
-- ============================================================
SELECT log_level, COUNT(*) AS null_response_time_count
FROM rca_app_logs_step1
WHERE response_time_ms IS NULL
GROUP BY log_level;
-- FATAL rows: nulls expected. ERROR rows: nulls are data gaps, not expected.

-- WRONG (produces misleading low average):
-- SELECT AVG(COALESCE(CAST(response_time_ms AS FLOAT), 0)) FROM rca_app_logs_step1;

-- CORRECT (excludes nulls from average):
SELECT service_name, AVG(CAST(response_time_ms AS FLOAT)) AS avg_response_ms
FROM rca_app_logs_step1
WHERE response_time_ms IS NOT NULL
GROUP BY service_name
ORDER BY avg_response_ms DESC;


-- ============================================================
-- STEP 5: error_code null on INFO/WARN rows — EXPECTED, not a data issue
-- Business justification: per rca_schema.md, error_code is null for INFO and WARN log levels.
-- This is expected behavior, not a data quality problem.
-- If you count error codes without filtering to ERROR/FATAL, null counts are inflated.
-- ============================================================

-- WRONG (counts INFO/WARN nulls as "missing" error codes):
-- SELECT COUNT(*) FROM rca_app_logs_step1 WHERE error_code IS NULL;

-- CORRECT (filter to ERROR/FATAL first, then count):
SELECT COUNT(*) AS error_fatal_without_error_code
FROM rca_app_logs_step1
WHERE log_level IN ('ERROR', 'FATAL') AND error_code IS NULL;


-- ============================================================
-- STEP 6: Row count after cleaning
-- ============================================================
SELECT COUNT(*) AS rows_final FROM rca_app_logs_step1;


-- ============================================================
-- GOVERNANCE: user_id_masked is PII-adjacent
-- Business rule: this column must NEVER appear in any output, chart, query result, or export.
-- ============================================================

-- Safe view example (excludes PII-adjacent field):
CREATE VIEW rca_app_logs_clean_safe AS
SELECT
    timestamp,
    service_name,
    environment,
    log_level,
    error_code,
    message,
    request_id,
    response_time_ms
    -- user_id_masked excluded intentionally — PII-adjacent field
FROM rca_app_logs_step1;
