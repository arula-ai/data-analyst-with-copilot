---
mode: 'ask'
description: 'Generate 3 labeled, policy-compliant interactive charts using Plotly and export as self-contained HTML files.'
---

## Role
You are a Data Visualization Architect. Generate 3 labeled, honest interactive charts for the attached cleaned dataset by generating a production Python script using Plotly. Each chart must answer a specific business question from the scenario.

## Input
- The cleaned dataset file (e.g., `#data/treasury_payments_clean.csv`).

## Format
- A single Python script containing the code to generate all 3 charts
- For each chart (using plotly.express), include clear code comments, export the figure `fig.write_html('outputs/...')`. There is no need to call `fig.show()` or create markdown cells.
- A block comment immediately after each chart export code with: what the chart shows, what pattern is visible, and one sentence about what this means for the scenario's business question.

## Constraints
- plotly.express only — no matplotlib, no seaborn, no 3D charts
- PII-adjacent fields (counterparty_masked, user_id_masked) must not appear as a chart label, axis value, hover field, or legend entry — remove them from the dataframe before passing to Plotly
- Sentinel values (9999, 999, -1) must be excluded before plotting — confirm exclusion in the code
- Each exported `.html` is a self-contained interactive file — no server required to open it
- A descriptive title stating what the chart shows
- Labeled x-axis and y-axis with units where applicable
- Y-axis starting at 0 for all bar and line charts (`fig.update_yaxes(rangemode='tozero')`)
- A legend where multiple series or categories are shown
- A block comment immediately after exporting: what the chart shows, the key pattern, and one sentence about the scenario's business implication
- An export call after each chart: `fig.write_html('outputs/[scenario]_chart_[N]_[name].html')`

## Checks
- [ ] Does every chart have a title and fully labeled axes with units?
- [ ] Does the Y-axis start at zero for bar and line charts?
- [ ] Are all PII-adjacent fields absent from chart elements?
- [ ] Does every chart have a `fig.write_html()` export call?
- [ ] Is each chart followed by a block comment explaining what the chart shows and the business implication?
