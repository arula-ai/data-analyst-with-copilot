-- SQL Cleaning Reference: treasury_payments
-- Scenario A — Treasury Anomaly Detection
-- This script mirrors the Python cleaning logic in scripts/clean_treasury.py
-- Use this if your production pipeline is SQL-based (PostgreSQL / SQL Server / Snowflake syntax shown)
--
-- NOTE: SQL is NOT required to complete the lab.
-- The Python script (scripts/clean_treasury.py) is the primary deliverable.
-- This reference is for participants whose production workflows use database pipelines.
--
-- Source schema: data/treasury_schema.md
-- Python equivalent: scripts/clean_treasury.py (generated during Phase 2)

-- ============================================================
-- STEP 0: Count rows before cleaning
-- ============================================================
SELECT COUNT(*) AS rows_before_cleaning FROM treasury_payments;
-- Expected: 500


-- ============================================================
-- STEP 1: Remove duplicate payment_ids (keep first occurrence)
-- Business justification: payment_id is a unique identifier per payment record.
-- 12 duplicates are data entry or ETL pipeline errors.
-- We retain the first occurrence by earliest row position.
-- ============================================================
WITH deduped AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY payment_id ORDER BY rowid) AS rn
    FROM treasury_payments
)
SELECT * INTO treasury_payments_step1
FROM deduped
WHERE rn = 1;

SELECT COUNT(*) AS rows_after_dedup FROM treasury_payments_step1;
-- Expected: ~488 (500 - 12 duplicates)


-- ============================================================
-- STEP 2: Standardize payment_type — replace 'TRF' with 'Wire Transfer'
-- Business justification: 'TRF' is a legacy encoding inconsistency.
-- Valid payment types per schema: Wire Transfer, ACH Batch, SWIFT, Internal Transfer, FX Settlement.
-- ============================================================
UPDATE treasury_payments_step1
SET payment_type = 'Wire Transfer'
WHERE payment_type = 'TRF';

-- Verify: no remaining 'TRF' values
SELECT payment_type, COUNT(*) FROM treasury_payments_step1 GROUP BY payment_type;


-- ============================================================
-- STEP 3: Flag and exclude negative payment_amount values
-- Business justification: Negative payment amounts are invalid for treasury payment records.
-- Per schema: valid range is $500.00–$5,000,000.00.
-- Document count before excluding.
-- ============================================================
SELECT COUNT(*) AS negative_payment_count
FROM treasury_payments_step1
WHERE payment_amount < 0;
-- Expected: ~8

SELECT * INTO treasury_payments_step2
FROM treasury_payments_step1
WHERE payment_amount >= 0 OR payment_amount IS NULL;
-- NOTE: Null payment_amount rows (15) are retained here — handled in next step.

SELECT COUNT(*) AS rows_after_negative_removal FROM treasury_payments_step2;


-- ============================================================
-- STEP 4: Document null payment_amount rows — do NOT silently drop
-- Business justification: Null amounts may represent incomplete records still under review.
-- Decision: exclude from amount-based calculations but retain rows with review_status.
-- ============================================================
SELECT COUNT(*) AS null_payment_amount_count
FROM treasury_payments_step2
WHERE payment_amount IS NULL;
-- Expected: ~15
-- These rows are retained in the dataset but excluded from payment_amount aggregations:
-- Use: WHERE payment_amount IS NOT NULL in any averaging or sum


-- ============================================================
-- STEP 5: Exclude sentinel 999 in prior_alerts_90d from calculations
-- Business justification: per schema, 999 = "system error or missing data coded as integer"
-- NOT a real alert count. Must never be included in averages or thresholds.
-- DO NOT DROP THESE ROWS — document and exclude from calculations.
-- ============================================================
SELECT COUNT(*) AS sentinel_999_count
FROM treasury_payments_step2
WHERE prior_alerts_90d = 999;
-- Expected: ~6

-- Use this filter in any prior_alerts_90d calculation:
-- WHERE prior_alerts_90d != 999 AND prior_alerts_90d IS NOT NULL

-- Example correct average:
SELECT AVG(CAST(prior_alerts_90d AS FLOAT)) AS avg_prior_alerts
FROM treasury_payments_step2
WHERE prior_alerts_90d != 999;


-- ============================================================
-- STEP 6: Exclude sentinel -1 in analyst_confidence from calculations
-- Business justification: per schema, -1 = legacy "not rated" code, NOT a valid 0-10 score.
-- Including -1 in averages pulls the mean downward artificially.
-- DO NOT DROP THESE ROWS.
-- ============================================================
SELECT COUNT(*) AS sentinel_neg1_count
FROM treasury_payments_step2
WHERE analyst_confidence = -1;
-- Expected: ~19

-- Use this filter in any analyst_confidence calculation:
-- WHERE analyst_confidence != -1 AND analyst_confidence >= 0

-- Example correct average:
SELECT AVG(CAST(analyst_confidence AS FLOAT)) AS avg_analyst_confidence
FROM treasury_payments_step2
WHERE analyst_confidence != -1;


-- ============================================================
-- STEP 7: Handle risk_score values > 1.0
-- Business justification: per schema, valid range is 0.0-1.0 (normalized score).
-- Values above 1.0 are data entry errors.
-- Decision: flag and exclude from risk_score calculations.
-- ============================================================
SELECT COUNT(*) AS invalid_risk_score_count
FROM treasury_payments_step2
WHERE risk_score > 1.0;
-- Expected: ~11


-- ============================================================
-- STEP 8: Handle anomaly_confirmed = 2
-- Business justification: per schema, valid values are 0 (not confirmed) and 1 (confirmed).
-- Value 2 is invalid for a binary flag.
-- Decision: exclude from anomaly rate calculations. Document count.
-- ============================================================
SELECT COUNT(*) AS invalid_anomaly_confirmed_count
FROM treasury_payments_step2
WHERE anomaly_confirmed = 2;
-- Expected: ~4

-- All anomaly rate queries must use:
-- WHERE anomaly_confirmed IN (0, 1)


-- ============================================================
-- STEP 9: Handle blank review_status
-- Business justification: valid values are Complete, Pending, Escalated.
-- Blank entries are incomplete records.
-- ============================================================
SELECT COUNT(*) AS blank_review_status_count
FROM treasury_payments_step2
WHERE review_status IS NULL OR review_status = '';
-- Expected: ~7


-- ============================================================
-- STEP 10: Normalize payment_date format
-- Business justification: 5 rows use MM/DD/YYYY instead of YYYY-MM-DD.
-- Mixed formats prevent correct date-based aggregations.
-- SQL Server example:
-- ============================================================

-- PostgreSQL example:
-- UPDATE treasury_payments_step2
-- SET payment_date = TO_DATE(payment_date, 'MM/DD/YYYY')
-- WHERE payment_date ~ '^\d{2}/\d{2}/\d{4}$';

-- SQL Server example:
-- UPDATE treasury_payments_step2
-- SET payment_date = CONVERT(DATE, payment_date, 101)
-- WHERE payment_date LIKE '__/__/____';

SELECT COUNT(*) AS rows_final FROM treasury_payments_step2;


-- ============================================================
-- GOVERNANCE: counterparty_masked is PII-adjacent
-- Business rule: this column must NEVER appear in any output, chart, or export.
-- All queries and views that expose this data should exclude it explicitly.
-- ============================================================

-- Safe view example (excludes PII-adjacent field):
CREATE VIEW treasury_payments_clean_safe AS
SELECT
    payment_id,
    -- counterparty_masked excluded intentionally — PII-adjacent field
    region,
    payment_type,
    payment_amount,
    prior_alerts_90d,
    days_since_last_payment,
    risk_score,
    analyst_confidence,
    anomaly_confirmed,
    analyst_id,
    review_status,
    payment_date,
    client_segment
FROM treasury_payments_step2;
