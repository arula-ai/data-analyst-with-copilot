# Answer Key — Flawed RCA Analysis
**Scenario B: Root Cause Analysis**
**Reference document:** `flawed_rca_analysis.md`

> **For facilitators and self-checking only.** Attempt to identify all 5 flaws independently before reading these answers.

---

## Flaw 1: Wrong Service Blamed Without Evidence

**The claim:**
> "NotificationService directly caused all payment transaction failures"

**Why it is wrong:**
`rca_schema.md` documents that 8 duplicate `request_id` rows exist in the raw dataset. If duplicates were not removed before calculating per-service failure rates, the counts are inflated and the service ranking is unreliable.

The claim that NotificationService "directly caused all payment transaction failures" is also unsupported — the data can show which service had the most logged failures, but this does not prove it caused failures in other services. A 61% ERROR/FATAL rate for NotificationService does not establish a causal chain to payment transaction failures in PaymentGateway or TransactionProcessor.

**Correct approach:**
1. Remove duplicate `request_id` rows first
2. Calculate ERROR + FATAL rate per service on the deduplicated dataset
3. Phrase findings as: "NotificationService had the highest ERROR/FATAL rate at X%", not "caused all failures"
4. Cross-reference with `app_service.py` BUG analysis to identify plausible failure chains

---

## Flaw 2: Correlation Stated as Causation

**The claim:**
> "These results confirm that **slow response times cause service errors**"

**Why it is wrong:**
The analysis shows a correlation between `log_level` and `response_time_ms` — ERROR logs have higher average response times than INFO logs. This is a statistical association, not proof of causation.

High response times may be a *symptom* of an underlying failure (e.g., database pool exhaustion causing timeouts), not the *cause* of errors. The causal direction cannot be determined from log data alone — it requires code-level investigation (see `app_service.py` BUG comments).

**Correct framing:**
> "ERROR logs were associated with significantly higher average response times (1,847ms vs 312ms for INFO). This correlation may reflect timeouts or resource contention — confirmed by the retry_limit = 0 and DB pool size = 3 defects identified in app_service.py."

---

## Flaw 3: Logical Contradiction on Row Count

**The claim:**
> "After cleaning, **all 300 log entries were retained with no data loss**."

**Why it is wrong:**
`rca_schema.md` documents:
- 8 duplicate `request_id` rows — if removed, row count drops to ~292
- 27 ERROR/FATAL rows with null or empty `message` fields

The statement says cleaning was performed AND all 300 rows were retained. These cannot both be true if duplicate removal was part of the cleaning process.

Additionally, the claim of "complete record of platform activity" is technically undermined if duplicates were removed — the deduplicated dataset has 292 unique request events, not 300.

**Correct approach:**
- Document: "Before cleaning: 300 rows. After duplicate request_id removal: ~292 rows (8 duplicates removed — log pipeline errors)."
- Report the final row count accurately.

---

## Flaw 4: Sentinel Nulls Filled with Zero (response_time_ms)

**The claim:**
> "average response time across all 300 log entries (**including FATAL rows where response time was recorded as 0ms**) was 287ms"

**Why it is wrong:**
`rca_schema.md` explicitly states: "response_time_ms null on FATAL rows is expected behavior — service crashed before timing out."

Null response time on FATAL rows means *the timing was not captured*, not that the service responded in 0ms. Filling nulls with 0 before averaging:
- Makes FATAL rows appear to have the fastest response times
- Pulls the average downward — services appear faster than they are
- Masks the performance difference between healthy (INFO) and failing (ERROR/FATAL) states

**Correct approach:**
```python
# Exclude nulls from average — do NOT use fillna(0)
df[df['response_time_ms'].notna()]['response_time_ms'].mean()

# Or by service:
df.groupby('service_name')['response_time_ms'].mean()  # pandas excludes nulls by default
```

---

## Flaw 5: False Completeness Claim on Error Codes

**The claim:**
> "Error codes were present in **100% of log entries**"

**Why it is wrong:**
`rca_schema.md` documents that `error_code` is null for INFO and WARN log level rows — this is **expected behavior**, not a data gap. INFO and WARN log entries do not have error codes because no error occurred.

If the analyst counted error codes without filtering to ERROR/FATAL rows first, null counts from INFO/WARN rows inflate the "missing" error code figure. The claim that error codes are present in 100% of entries is verifiably false — INFO and WARN rows structurally do not have error codes.

**Correct approach:**
1. Filter to ERROR/FATAL rows first: `df[df['log_level'].isin(['ERROR', 'FATAL'])]`
2. Count null `error_code` within that subset only
3. Count `value_counts()` on `error_code` within the ERROR/FATAL rows

```python
error_fatal_rows = df[df['log_level'].isin(['ERROR', 'FATAL'])]
print(error_fatal_rows['error_code'].value_counts(dropna=False))
```

---

## Summary Table

| Flaw # | Type | Column(s) Involved | Key Rule Violated |
|--------|------|-------------------|-------------------|
| 1 | Wrong conclusion / unvalidated ranking | `request_id`, `service_name`, `log_level` | Deduplication must precede per-service rate calculations |
| 2 | Causation ≠ correlation | `log_level`, `response_time_ms` | Correlation between response time and log level is not proof of causation |
| 3 | Logical contradiction | `request_id` (duplicates) | Row count after deduplication cannot equal row count before |
| 4 | Null filled with 0 | `response_time_ms` | FATAL-row nulls must be excluded, not imputed as 0ms |
| 5 | False completeness | `error_code`, `log_level` | `error_code` null on INFO/WARN is expected; must filter to ERROR/FATAL before counting |
