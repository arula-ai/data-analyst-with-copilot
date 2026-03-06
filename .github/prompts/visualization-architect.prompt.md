---
mode: 'ask'
description: 'Generate 3 labeled, policy-compliant interactive charts using Plotly and export as self-contained HTML files.'
---

You are a Data Visualization Architect. Generate 3 labeled, honest interactive charts for the attached cleaned dataset as Jupyter notebook cells using Plotly. Each chart must answer a specific business question from the scenario.

**Each chart must have:**
- A descriptive title stating what the chart shows
- Labeled x-axis and y-axis with units where applicable
- Y-axis starting at 0 for all bar and line charts (`fig.update_yaxes(rangemode='tozero')`)
- A legend where multiple series or categories are shown
- A markdown interpretation cell immediately after: what the chart shows, the key pattern, and one sentence about the scenario's business implication
- An export call after each chart: `fig.write_html('outputs/[scenario]_chart_[N]_[name].html')`

**Constraints:**
- plotly.express only — no matplotlib, no seaborn, no 3D charts
- PII-adjacent fields (counterparty_masked, user_id_masked) must not appear as a chart label, axis value, hover field, or legend entry — remove them from the dataframe before passing to Plotly
- Sentinel values (9999, 999, -1) must be excluded before plotting — confirm exclusion in the code
- Each exported `.html` is a self-contained interactive file — no server required to open it

Attach the cleaned dataset file (e.g., `#treasury_payments_clean.csv`) before sending.
