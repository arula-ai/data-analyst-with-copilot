# Answer Key — Flawed Treasury Analysis
**Scenario A: Treasury Anomaly Detection**
**Reference document:** `flawed_treasury_analysis.md`

> **For facilitators and self-checking only.** Attempt to identify all 5 flaws independently before reading these answers.

---

## Flaw 1: Impossible Anomaly Rate

**The claim:**
> "Wire Transfer had the highest rate at **134%**"

**Why it is wrong:**
`anomaly_confirmed` is a binary flag: 0 or 1. An anomaly *confirmation rate* is calculated as:

```
confirmed anomalies (anomaly_confirmed = 1) ÷ total rows for that payment_type
```

This ratio can never exceed 100%. A rate of 134% is mathematically impossible.

**What likely went wrong:**
The analyst likely included rows where `anomaly_confirmed = 2` (an invalid flag value) in the numerator but excluded them from the denominator — or calculated on uncleaned data where duplicate `payment_id` rows inflated the confirmed count while the unique count was used as the denominator.

**Correct approach:**
1. Remove duplicate `payment_id` rows first
2. Exclude `anomaly_confirmed = 2` from both numerator AND denominator
3. Calculate: `df[df['anomaly_confirmed'] == 1].groupby('payment_type').size() / df[df['anomaly_confirmed'].isin([0,1])].groupby('payment_type').size()`

---

## Flaw 2: Correlation Stated as Causation

**The claim:**
> "These results prove that **high risk scores directly cause confirmed anomalies**"

**Why it is wrong:**
The `risk_score` column and `anomaly_confirmed` column are both outputs of the same monitoring system that reviews treasury payments. A correlation between high risk scores and confirmed anomalies does not prove causation — it may simply reflect that both are measured by the same review process that tends to flag the same payments.

Stating that risk scores "directly cause" anomalies is a logical error. The data can only show association, not mechanism.

**Correct framing:**
> "Payments with risk scores above 0.8 were **associated with** higher confirmed anomaly rates — 4× more likely than payments with scores below 0.4. The causal mechanism requires further investigation."

---

## Flaw 3: Logical Contradiction on Row Count

**The claim:**
> "After cleaning, **all 500 payment records remain intact** with no rows removed from the dataset."

**Why it is wrong:**
`treasury_schema.md` documents:
- 12 duplicate `payment_id` rows
- 15 null `payment_amount` values
- 34 null `days_since_last_payment` values

If any of these issues were addressed during cleaning (as claimed earlier in the report), the row count cannot still be 500. You cannot both (a) address data quality issues and (b) retain all 500 rows unchanged — unless every fix was a transformation in place, with no rows dropped.

The specific claim of "complete representation of Q4 2024 activity" is also misleading if duplicates were removed, since those duplicate rows are no longer in the dataset.

**Correct approach:**
- Document row count **before** cleaning: 500
- Document row count **after each major cleaning step** with the count and justification
- Final count will be ≤ 500. Report it accurately.

---

## Flaw 4: Sentinel Value Included in Average

**The claim:**
> "The average prior alert count across all 500 payments was 4.7 alerts per account."

**Why it is wrong:**
`treasury_schema.md` documents that `prior_alerts_90d = 999` is a sentinel value meaning "system error or missing data coded as integer." The 6 rows with this value were not excluded before calculating the mean.

Including 999 in the mean calculation:
- Adds 5,994 to the numerator (6 rows × 999)
- Inflates the average significantly above the true mean for valid records

**The correct calculation excludes sentinel values:**
```python
df[df['prior_alerts_90d'] != 999]['prior_alerts_90d'].mean()
```

The correct average (excluding sentinel rows) is substantially lower than 4.7.

---

## Flaw 5: Sentinel Value Included in Average (analyst_confidence)

**The claim:**
> "The average confidence score of 6.8 out of 10 indicates moderate-to-high analyst conviction... calculated across all 500 records including all rating categories."

**Why it is wrong:**
`treasury_schema.md` documents that `analyst_confidence = -1` is a **legacy code** meaning "not rated" — it is not a valid score on the 0–10 scale. The 19 rows with this value were included in the mean calculation.

Including -1 values pulls the average downward, making analysts appear less confident than they actually are on rated cases.

The phrase "including all rating categories" in the report signals this error — -1 is not a "rating category," it is a sentinel code that must be excluded.

**The correct calculation:**
```python
df[df['analyst_confidence'] != -1]['analyst_confidence'].mean()
```

The correct average (excluding -1 rows) will be higher than 6.8.

---

## Summary Table

| Flaw # | Type | Column(s) Involved | Key Rule Violated |
|--------|------|-------------------|-------------------|
| 1 | Impossible statistic | `anomaly_confirmed`, `payment_type` | Rates cannot exceed 100%; `anomaly_confirmed = 2` must be excluded from both numerator and denominator |
| 2 | Causation ≠ correlation | `risk_score`, `anomaly_confirmed` | Observational data shows association, not cause |
| 3 | Logical contradiction | `payment_id`, `payment_amount`, `days_since_last_payment` | Row count after cleaning cannot equal row count before if any rows were dropped |
| 4 | Sentinel in mean | `prior_alerts_90d` | `prior_alerts_90d = 999` must be excluded from all averages |
| 5 | Sentinel in mean | `analyst_confidence` | `analyst_confidence = -1` must be excluded from all averages |
