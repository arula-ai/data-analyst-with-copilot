-- SQL Cleaning Reference: mainframe_usage
-- Scenario C — Product Modernization
-- This script mirrors the Python cleaning logic in scripts/clean_mainframe.py
-- Use this if your production pipeline is SQL-based (PostgreSQL / SQL Server syntax shown)
--
-- NOTE: SQL is NOT required to complete the lab.
-- The Python script (scripts/clean_mainframe.py) is the primary deliverable.
--
-- Source schema: data/mainframe_schema.md
-- Python equivalent: scripts/clean_mainframe.py (generated during Phase 2)

-- ============================================================
-- STEP 0: Count rows before cleaning
-- ============================================================
SELECT COUNT(*) AS rows_before_cleaning FROM mainframe_usage;
-- Expected: 400


-- ============================================================
-- STEP 1: Flag sentinel 9999 in estimated_migration_effort_days
-- Business justification: 9999 = "effort not yet assessed" per mainframe_schema.md.
-- This is NOT a real effort estimate. Including it inflates averages and distorts rankings.
-- Decision: RETAIN these rows (they represent real features) but EXCLUDE from effort calculations.
-- DO NOT drop or impute — document and exclude.
-- ============================================================
SELECT COUNT(*) AS sentinel_9999_count
FROM mainframe_usage
WHERE estimated_migration_effort_days = 9999;
-- Expected: ~13

-- WRONG (includes 9999 in ranking — these features appear as extreme outliers):
-- SELECT feature_name, estimated_migration_effort_days FROM mainframe_usage ORDER BY estimated_migration_effort_days;

-- CORRECT (exclude sentinel before any effort analysis):
SELECT feature_name, modernization_priority, estimated_migration_effort_days
FROM mainframe_usage
WHERE estimated_migration_effort_days != 9999
  AND legacy_flag = TRUE
  AND modernization_priority = 'High'
ORDER BY estimated_migration_effort_days ASC;


-- ============================================================
-- STEP 2: Handle null monthly_active_users
-- Business justification: nulls mean "telemetry was not collected" per mainframe_schema.md.
-- Null ≠ 0 active users. COALESCE(monthly_active_users, 0) is INCORRECT.
-- Using 0 makes unused features appear to have zero users — not the same as unknown.
-- Decision: retain null rows, exclude from user-count calculations, flag in documentation.
-- ============================================================
SELECT COUNT(*) AS null_monthly_active_users
FROM mainframe_usage
WHERE monthly_active_users IS NULL;
-- Expected: ~27

-- WRONG (treats missing telemetry as zero users, skews priority ranking):
-- SELECT feature_name, COALESCE(monthly_active_users, 0) AS users FROM mainframe_usage;

-- CORRECT (exclude nulls from aggregation, document separately):
SELECT team, AVG(CAST(monthly_active_users AS FLOAT)) AS avg_active_users
FROM mainframe_usage
WHERE monthly_active_users IS NOT NULL
  AND legacy_flag = TRUE
GROUP BY team
ORDER BY avg_active_users DESC;


-- ============================================================
-- STEP 3: Exclude negative error_rate_pct values from calculations
-- Business justification: negative error rates are data pipeline errors per mainframe_schema.md.
-- Valid range is 0.0-100.0. Negative values skew team-level averages downward.
-- Decision: exclude from calculations, document count.
-- ============================================================
SELECT COUNT(*) AS negative_error_rate_count
FROM mainframe_usage
WHERE error_rate_pct < 0;
-- Expected: ~18

-- WRONG (negative values pull average down — some teams appear more stable than they are):
-- SELECT team, AVG(error_rate_pct) AS avg_error_rate FROM mainframe_usage GROUP BY team;

-- CORRECT:
SELECT team, AVG(error_rate_pct) AS avg_error_rate
FROM mainframe_usage
WHERE error_rate_pct >= 0
GROUP BY team
ORDER BY avg_error_rate DESC;


-- ============================================================
-- STEP 4: Normalize last_accessed_date format
-- Business justification: 14 rows use MM/DD/YYYY format instead of YYYY-MM-DD.
-- Mixed formats prevent correct date-based sorting and recency analysis.
-- ============================================================

-- PostgreSQL example:
-- UPDATE mainframe_usage
-- SET last_accessed_date = TO_DATE(last_accessed_date, 'MM/DD/YYYY')
-- WHERE last_accessed_date ~ '^\d{2}/\d{2}/\d{4}$';

-- SQL Server example:
-- UPDATE mainframe_usage
-- SET last_accessed_date = CONVERT(DATE, last_accessed_date, 101)
-- WHERE last_accessed_date LIKE '__/__/____';

-- Verify: all dates parseable
SELECT COUNT(*) AS unparseable_dates
FROM mainframe_usage
WHERE TRY_CAST(last_accessed_date AS DATE) IS NULL;
-- Expected: 0 after normalization


-- ============================================================
-- STEP 5: Verify modernization_priority distribution
-- Business justification: before reporting a "78% High priority" claim,
-- validate the actual distribution from data — never from Copilot output alone.
-- ============================================================
SELECT modernization_priority, COUNT(*) AS count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 1) AS pct
FROM mainframe_usage
GROUP BY modernization_priority;
-- Verify: does the actual % High match any claims in flawed_modernization_analysis.md?


-- ============================================================
-- STEP 6: Row count after cleaning
-- ============================================================
SELECT COUNT(*) AS rows_final FROM mainframe_usage;
-- Note: Row count should be same as before (400) — no rows dropped, only calculated exclusions


-- ============================================================
-- EXAMPLE: Correct high-priority candidate ranking
-- Combines usage data + effort data, excludes all invalid values
-- ============================================================
SELECT
    feature_name,
    team,
    monthly_active_users,
    estimated_migration_effort_days,
    modernization_priority,
    error_rate_pct
FROM mainframe_usage
WHERE
    legacy_flag = TRUE
    AND modernization_priority = 'High'
    AND monthly_active_users IS NOT NULL          -- excludes unknown telemetry
    AND estimated_migration_effort_days != 9999   -- excludes unassessed effort
    AND error_rate_pct >= 0                       -- excludes invalid negative rates
ORDER BY monthly_active_users DESC;
