# Flawed Modernization Analysis — Exercise File
**Mainframe Feature Assessment**
**Analyst:** P. Okafor, Modernization Planning Team

> **Exercise:** Identify all 5 analytical flaws embedded in this document.
>
> For each flaw, state:
> 1. What the claim is
> 2. Why it is wrong (logical, statistical, or factual error)
> 3. What the correct approach or correct statement would be
>
> Use `data/mainframe_schema.md` as your reference for valid data ranges and business rules.

---

## Executive Summary

This report summarizes findings from the Q4 2024 mainframe feature usage analysis. Analysis was conducted on 400 feature records covering 5 teams across the enterprise platform.

---

## Finding 1: Top Modernization Candidates

A ranked list of modernization candidates was produced by sorting all legacy features by `estimated_migration_effort_days` ascending — lowest effort first — to identify quick wins for the engineering teams.

<!-- FLAW 1: Sentinel value included in ranking. The mainframe_schema.md documents that estimated_migration_effort_days = 9999 means "effort not yet assessed." These 13 rows were not excluded before sorting. Features with 9999 sort near the top of a descending sort or appear as extreme outliers in an ascending sort, making the ranking unreliable. The correct approach excludes 9999 before any ranking or averaging of migration effort. -->

The top 3 quick-win features — those with the lowest assessed migration effort — are: `fx_rate_lookup` (3 days), `settlement_cutoff_check` (9999 days), and `statement_generation` (12 days).

---

## Finding 2: Legacy Infrastructure Risk

The analysis examined which teams carry the most technical debt by counting legacy features per team. The Payments team has the highest count of legacy features, making it the highest-risk team for modernization.

<!-- FLAW 2: Causal claim about risk. Having the most legacy features does not cause the highest operational risk. Risk depends on usage volume, error rates, and business criticality — not just feature count. The correct framing is "The Payments team has the highest count of legacy features, which warrants further investigation into usage and error rates before drawing risk conclusions." -->

This confirms that **legacy feature count directly causes operational risk**, and the Payments team should be deprioritized for new feature work until modernization is complete.

---

## Finding 3: Dataset Completeness

Prior to analysis, the dataset was cleaned to resolve data quality issues including negative error rates, mixed date formats, and missing usage data.

<!-- FLAW 3: Logical contradiction. The mainframe_schema.md documents 27 null monthly_active_users values and states these mean "telemetry was not collected — do not treat as zero." If these nulls were filled with 0 before analysis, features with missing telemetry appear to have zero users, which would incorrectly rank them as low-priority for modernization. The statement below contradicts this. -->

After cleaning, **all 400 features have complete usage data** including monthly active user counts, and no telemetry gaps were identified in the final dataset.

---

## Finding 4: Error Rate Analysis

Error rates were analyzed across all teams to identify which areas have the most unstable legacy implementations. The average error rate per team was calculated from the cleaned dataset.

<!-- FLAW 4: Negative values included in average. The mainframe_schema.md documents 18 negative error_rate_pct values as invalid data pipeline errors. If these were not excluded before calculating the team average, the averages are pulled downward and some teams may appear more stable than they are. Negative error rates must be excluded from all calculations. -->

The **average error rate across all 400 features** (including negative values, which represent reversal corrections) was 2.3%, within acceptable thresholds for a legacy platform.

---

## Finding 5: Modernization Priority Distribution

The analysis found that the majority of legacy features are already flagged for modernization. Features marked High priority across all teams total 312 out of 400 — meaning 78% of the platform has been identified for immediate action.

<!-- FLAW 5: Impossible or unverified statistic. The mainframe_schema.md does not document the distribution of modernization_priority values. A claim that 78% of features are flagged High priority should be validated by running df['modernization_priority'].value_counts() against the actual data. If this number came from Copilot's output rather than verified code execution, it is an unverified assumption — not a fact. The correct approach runs the value_counts check and reports the actual number. -->

Leadership should treat this as a critical situation requiring immediate resource allocation across all 5 teams simultaneously.
