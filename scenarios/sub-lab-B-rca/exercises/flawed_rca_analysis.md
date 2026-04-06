# Flawed RCA Analysis — Exercise File
**Platform Log Analysis**
**Analyst:** T. Vasquez, Platform Reliability Team

> **Exercise:** Identify all 5 analytical flaws embedded in this document.
>
> For each flaw, state:
> 1. What the claim is
> 2. Why it is wrong (logical, statistical, or factual error)
> 3. What the correct approach or correct statement would be
>
> Use `data/rca_schema.md` as your reference for valid data ranges and business rules.

---

## Executive Summary

This report summarizes findings from the Q4 2024 log analysis for the payments platform. Analysis was conducted on 300 log entries covering all 5 microservices across production and staging environments.

---

## Finding 1: NotificationService is the Root Cause

Log analysis confirmed that NotificationService generated the most failures during the incident window. Its ERROR + FATAL rate as a percentage of its own total log entries was 61%, significantly higher than any other service.

<!-- FLAW 1: Wrong service blamed without evidence. The rca_schema.md Known Issues section documents that 15 duplicate request_ids exist in the dataset. If duplicates were not removed before calculating per-service rates, the counts are inflated and the ranking is unreliable. A correct analysis removes duplicates first, then calculates rates. -->

Based on this finding, we conclude that **NotificationService directly caused all payment transaction failures** observed during the incident window.

---

## Finding 2: Response Time as a Failure Predictor

Rows with null `response_time_ms` were excluded from the average calculation. The average response time for ERROR-level logs across all services was 1,847ms, compared to 312ms for INFO-level logs — a significant difference.

<!-- FLAW 2: Causal claim without evidence. The analysis shows correlation between log_level and response_time_ms, not causation. High response times may be a symptom of failure, not the cause. The correct framing is "ERROR logs are associated with higher average response times" not "slow response times caused the errors." -->

These results confirm that **slow response times cause service errors** and that optimizing query performance will eliminate the failure pattern.

---

## Finding 3: Data Completeness After Cleaning

The log dataset was cleaned prior to analysis. Null values were handled and duplicate entries were addressed using standard cleaning procedures.

<!-- FLAW 3: Logical contradiction. The rca_schema.md Known Issues section documents 15 duplicate request_ids. If duplicates were removed during cleaning, at most 285 rows could remain — not 300. The statement that all 300 log entries were retained is impossible if any deduplication occurred. The correct analysis documents the exact number of rows removed and updates the total count accordingly. -->

After cleaning, **all 300 log entries were retained with no data loss**. The cleaned dataset contains the complete record of platform activity during the incident window.

---

## Finding 4: Average Response Time Calculation

Response time analysis was conducted across all services to identify performance outliers. Services with average response times above 500ms were flagged for investigation.

<!-- FLAW 4: Sentinel value included in calculation. The rca_schema.md notes that response_time_ms is null for FATAL rows (expected behavior — service crashed before timing). If null rows were filled with 0 before averaging (a common Copilot default), the average is pulled downward, making services appear faster than they are. Nulls on FATAL rows should be excluded, not imputed. -->

The **average response time across all 300 log entries** (including FATAL rows where response time was recorded as 0ms due to immediate failure) was 287ms, within acceptable thresholds.

---

## Finding 5: Error Code Distribution

Error codes were analyzed to identify the most common failure types. ERR_001 was the most frequently occurring error code across all services.

<!-- FLAW 5: False completeness claim. The rca_schema.md states that error_code is null for INFO and WARN rows — this is expected behavior, not a data issue. If the analysis counts error codes without filtering to ERROR/FATAL rows first, the null count from INFO/WARN rows inflates the "missing data" figure and the percentage of rows with valid error codes is understated. -->

**Error codes were present in 100% of log entries**, and the distribution reflects complete error capture across the incident window with no gaps in instrumentation.
