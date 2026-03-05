# Visualization Notes
**Stage:** 4 | **Agent Mode:** Visualization Architect | **Time Budget:** 15 min
**Save to:** `outputs/04_visualizations.ipynb` + this notes file

---

## Purpose
This document records the visualization artifacts produced in Stage 4, validates that each chart meets integrity and privacy requirements, and captures the plain-English interpretation of what the charts show collectively.

---

## Visualization Inventory

> Complete after generating all charts. Minimum 4 charts required.

| Chart # | Chart Type | Business Question It Answers | Data Used | Cell Location in Notebook |
|---|---|---|---|---|
| 1 | Distribution | | risk_score by fraud_confirmed | |
| 2 | Bar/Comparison | | fraud rate by alert_type | |
| 3 | Box/Distribution | | transaction_amount by client_segment | |
| 4 | Bar/Relationship | | prior_alerts_90d vs fraud rate | |
| 5 *(optional)* | | | | |

---

## Axes and Labels Validation

> Check each item before saving the notebook. All must be true.

- [ ] All charts have a descriptive title (e.g., "Confirmed Fraud Rate by Alert Type — Q4 2024")
- [ ] All x-axes have a labeled axis title with units where applicable
- [ ] All y-axes have a labeled axis title with units where applicable (e.g., "Fraud Confirmation Rate (%)")
- [ ] Y-axis starts at 0 for all bar and line charts — no truncated baselines
- [ ] No 3D charts of any kind
- [ ] Legends are present where multiple series or categories are shown, and legend labels match the data

---

## Sensitive Data Check

> Confirm before saving the notebook. All must be checked.

- [ ] `account_masked` does not appear as a chart label, axis value, legend entry, or in any plot title
- [ ] No other PII-adjacent column is visible in any chart output
- [ ] Printed DataFrame previews in notebook do not show `account_masked` values
- [ ] Chart output images do not display identifiable account information

---

## Interpretation Summary

> Write 2–4 sentences summarizing what the charts collectively show for a non-technical reader — a fraud operations manager who will use this to brief leadership.

*What do these four charts tell us about fraud patterns in Q4 2024? What should a manager take away?*

Your interpretation:

---

## Chart-by-Chart Interpretation Reference

> Paste the interpretation markdown from each chart cell here for easy reference.

**Chart 1:**

**Chart 2:**

**Chart 3:**

**Chart 4:**

---

## Export Log

> Complete after exporting charts as `.png` files using `plt.savefig()`.

| Chart # | Exported Filename | Contains account_masked? | Approved to Share? |
|---------|------------------|--------------------------|-------------------|
| 1 | `outputs/chart_01_risk_score_distribution.png` | No / Yes | |
| 2 | `outputs/chart_02_fraud_rate_by_alert_type.png` | No / Yes | |
| 3 | `outputs/chart_03_transaction_amount_by_segment.png` | No / Yes | |
| 4 | `outputs/chart_04_prior_alerts_vs_fraud_rate.png` | No / Yes | |

**Before sharing any exported image:**
- [ ] Confirmed no `account_masked` values visible in the image
- [ ] Image reviewed by analyst (you) — not just accepted from Copilot output
- [ ] Sharing destination is within approved internal channels only
