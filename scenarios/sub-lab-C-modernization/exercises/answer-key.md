# Answer Key — Flawed Modernization Analysis
**Scenario C: Product Modernization**
**Reference document:** `flawed_modernization_analysis.md`

> **For facilitators and self-checking only.** Attempt to identify all 5 flaws independently before reading these answers.

---

## Flaw 1: Sentinel Value Included in Ranking

**The claim:**
> "The top 3 quick-win features — those with the lowest assessed migration effort — are: `fx_rate_lookup` (3 days), `settlement_cutoff_check` (**9999 days**), and `statement_generation` (12 days)."

**Why it is wrong:**
`mainframe_schema.md` documents that `estimated_migration_effort_days = 9999` is a sentinel value meaning "effort not yet assessed." A feature with `9999` has an **unknown** migration effort — it has not been evaluated, not a "9,999 day" project.

Including 9999 in a ranked sort means:
- In ascending sort: 9999 appears near the top (or as an outlier) depending on other values
- The feature is presented as a candidate when its effort is completely unknown

The report lists `settlement_cutoff_check` at 9999 days as a top-3 candidate, which is directly wrong — an unassessed feature cannot be a "quick win."

**Correct approach:**
```python
# Exclude sentinel before ranking
df[df['estimated_migration_effort_days'] != 9999].sort_values('estimated_migration_effort_days')
```

---

## Flaw 2: Correlation Stated as Causation (Feature Count ≠ Risk)

**The claim:**
> "This confirms that **legacy feature count directly causes operational risk**"

**Why it is wrong:**
Having the most legacy features does not cause operational risk. A team with many low-usage, stable legacy features may carry less operational risk than a team with a few high-traffic, error-prone features.

Operational risk depends on usage volume (`monthly_active_users`), error rates (`error_rate_pct`), and business criticality — not just legacy feature count.

The word "directly causes" is a causal claim that cannot be supported by a count-based comparison. The data shows a *count correlation* at best.

**Correct framing:**
> "The Payments team has the highest count of legacy features (N). Whether this translates to the highest operational risk requires cross-referencing usage volume and error rates."

---

## Flaw 3: Logical Contradiction on Dataset Completeness

**The claim:**
> "After cleaning, **all 400 features have complete usage data** including monthly active user counts, and no telemetry gaps were identified."

**Why it is wrong:**
`mainframe_schema.md` documents 27 null `monthly_active_users` values. These nulls represent features where telemetry was not collected during the period — they are documented as a known data quality issue.

The claim that all 400 features have "complete usage data" directly contradicts the schema. The 27 features with null user counts have unknown usage — this is not a cleaning artifact that can be resolved. Filling these with 0 (a common Copilot default) would make those features appear to have zero users, incorrectly ranking them as low-priority candidates for modernization.

**Correct approach:**
- Document: "27 features have null monthly_active_users — telemetry not collected. These rows are retained but excluded from user-count aggregations."
- Do NOT impute nulls as 0.

---

## Flaw 4: Negative Values Included in Average

**The claim:**
> "The **average error rate across all 400 features** (including negative values, which represent reversal corrections) was 2.3%"

**Why it is wrong:**
`mainframe_schema.md` explicitly states: "error_rate_pct must be ≥ 0 — negative values are **data pipeline errors**, not valid readings."

Negative error rates are not "reversal corrections" — they are invalid data produced by a broken pipeline. The analyst's reinterpretation ("reversal corrections") is a fabricated business justification not supported by the schema.

Including negative values in the average pulls team-level means downward, making some teams appear more stable than they actually are. The 18 negative rows must be excluded from all calculations.

**Correct approach:**
```python
df[df['error_rate_pct'] >= 0]['error_rate_pct'].mean()
# Or by team:
df[df['error_rate_pct'] >= 0].groupby('team')['error_rate_pct'].mean()
```

---

## Flaw 5: Unverified Statistic (Not Validated from Data)

**The claim:**
> "Features marked High priority across all teams total **312 out of 400 — meaning 78%** of the platform has been identified for immediate action."

**Why it is wrong:**
`mainframe_schema.md` does not document the distribution of `modernization_priority` values. The claim that 78% of features are High priority is presented as a fact, but there is no evidence it was validated by running `value_counts()` on the actual data.

If this number came from Copilot's output rather than executed code, it is an unverified assumption. Copilot can confidently generate plausible-sounding statistics that are not grounded in the actual dataset.

**How to verify:**
```python
print(df['modernization_priority'].value_counts())
print(df['modernization_priority'].value_counts(normalize=True).round(3))
```

Run this and report the actual numbers. "Copilot said so" is not a valid source.

---

## Summary Table

| Flaw # | Type | Column(s) Involved | Key Rule Violated |
|--------|------|-------------------|-------------------|
| 1 | Sentinel in ranking | `estimated_migration_effort_days` | 9999 = "effort unknown" — must be excluded from all sorting and averaging |
| 2 | Causation ≠ correlation | `legacy_flag`, team groupings | Feature count does not determine risk — requires cross-referencing with usage and error data |
| 3 | Logical contradiction | `monthly_active_users` | 27 null telemetry rows cannot become "complete data" — do not impute as 0 |
| 4 | Invalid values in average | `error_rate_pct` | Negative values are data pipeline errors, not "reversal corrections" — must be excluded |
| 5 | Unverified statistic | `modernization_priority` | All statistics must be validated from executed code, not Copilot output |
