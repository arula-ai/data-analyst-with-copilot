# Data Quality & Analytical Storytelling — Pre-Sharing Checklist

**Use this before saving Stage 3 outputs and before drafting the Stage 6 executive summary.**

Analytical accuracy is not just about clean data and correct code. It is about whether the story you tell from the data is honest, representative, and defensible. This guide provides a framework for validating your findings before sharing them with any audience.

---

## Part 1: The Pre-Sharing Checklist

Run through every item before saving `outputs/03_exploratory_insights.md` or `outputs/06_executive_summary.md`.

### Statistical Accuracy
- [ ] Every percentage is accompanied by the raw count it was calculated from
- [ ] Every average excludes sentinel values and invalid entries (e.g., `analyst_confidence = -1`, `prior_alerts_90d = 999`)
- [ ] Every "X% of alerts" statement specifies: X% of what total? After which filtering steps?
- [ ] Fraud rates are calculated on confirmed alerts only — not on all alerts including nulls or flagged invalids
- [ ] No number in the output contradicts a number in the code output — trace every claim back to a specific cell or script result

### Representativeness
- [ ] Sample sizes are disclosed alongside all comparisons — "Institutional clients had the highest fraud rate" must include the count of Institutional alerts
- [ ] Subgroups with fewer than 20 observations are flagged as unreliable for comparison
- [ ] The time period is explicitly stated — this dataset covers Q4 2024 only
- [ ] Null-excluded analyses note what percentage of rows were excluded and why

### Causal Claims
- [ ] No finding uses the word "causes" — use "correlates with," "is associated with," or "is higher among"
- [ ] No recommendation implies that removing a correlated factor will reduce fraud without additional evidence
- [ ] All regression or trend language is framed as "in this dataset" — not as universal rules

---

## Part 2: Common Analytical Errors to Avoid

| Error | What It Looks Like | The Honest Version |
|-------|-------------------|-------------------|
| **Cherry-picking** | Reporting only the regions with high fraud rates, ignoring regions where the pattern doesn't hold | Report all regions; note where the pattern is and isn't consistent |
| **Misleading % without base rates** | "Fraud rate doubled in the West" (from 1% to 2%) | "Fraud rate in the West increased from 1.2% to 2.4%, based on 48 alerts" |
| **Survivorship bias** | Analyzing only "investigation_complete = Yes" rows as if they represent all fraud | Acknowledge that incomplete investigations may skew confirmed fraud counts |
| **Causation from correlation** | "High prior_alerts_90d causes fraud confirmation" | "Accounts with higher prior_alerts_90d had higher confirmed fraud rates in Q4 2024" |
| **False precision** | "Fraud confirmation rate: 34.7823%" | Round to 1 decimal place unless precision is analytically meaningful |
| **Omitted data disclosure** | Reporting findings without mentioning that 15 null transaction_amounts were excluded | State all exclusions explicitly in an Assumptions section |

---

## Part 3: Audience Calibration

Different audiences need different levels of detail. Tailor your output accordingly.

| Audience | What They Need | What to Avoid |
|----------|---------------|---------------|
| **VP / Executive** | 3 key findings in plain English, 2 actionable recommendations, 1 risk note | Code, column names, pandas syntax, percentages without context |
| **Fraud Operations Manager** | Finding + supporting stat + business implication | Raw DataFrames, statistical jargon, p-values without explanation |
| **Data Analyst Peer** | Methodology, assumptions, code references, limitations | Oversimplification that loses analytical nuance |
| **Compliance / Audit** | Every assumption documented, every exclusion justified, data classification confirmed | Vague summaries, undocumented transformations |

---

## Part 4: Accuracy Review — Traceability Test

Before submitting any output, apply the traceability test to every key claim:

1. Pick any number or finding in your output (e.g., "Velocity Check alerts had a 42% confirmed fraud rate")
2. Open the notebook or script that produced it
3. Run the relevant cell and confirm the number matches
4. If it doesn't match — fix the output, not the code

**If a finding cannot be traced to a specific code output, it must be removed.**

---

## Part 5: The One-Sentence Test

After completing your analysis, read each key finding aloud and apply this test:

> *"Can I say this sentence to a VP of Fraud Operations without qualifying it or walking it back?"*

If you need to add "but it depends on..." or "that's only if you ignore..." — rewrite the finding to include those qualifications upfront. A finding with necessary caveats is stronger than a finding that falls apart under the first question.
