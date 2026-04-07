---
mode: 'agent'
description: 'Write a Plotly visualization script to scripts/visualize_[scenario].py, run it, and produce a single self-contained HTML dashboard with a summary header and 3 labeled policy-compliant charts.'
---

## Role
You are a Data Visualization Architect. Generate 3 labeled, honest interactive charts for the attached cleaned dataset by generating a production Python script using Plotly. Each chart must answer a specific business question from the scenario. All 3 charts are combined into a single self-contained HTML dashboard file.

## Input
- The cleaned dataset file (e.g., `#data/treasury_payments_clean.csv`).

## Format
- Write the complete Python script to `scripts/visualize_[scenario].py` (e.g., `scripts/visualize_treasury.py`, `scripts/visualize_logs.py`, `scripts/visualize_mainframe.py`). Run it immediately after writing.
- Build each chart using plotly.express, then combine them into one dashboard file:
  ```python
  chart1_html = fig1.to_html(include_plotlyjs=True,  full_html=False)
  chart2_html = fig2.to_html(include_plotlyjs=False, full_html=False)
  chart3_html = fig3.to_html(include_plotlyjs=False, full_html=False)

  summary = f"""
  <h2>[Scenario] Analysis Dashboard</h2>
  <p><strong>Dataset:</strong> {n_rows} rows after cleaning &nbsp;|&nbsp; <strong>Period:</strong> [period from data]</p>
  <p><strong>Key Finding:</strong> [one-sentence headline from EDA]</p>
  <hr/>
  """

  html = f"<html><head><meta charset='utf-8'></head><body>{summary}{chart1_html}{chart2_html}{chart3_html}</body></html>"
  with open('outputs/[X]_dashboard.html', 'w', encoding='utf-8') as f:
      f.write(html)
  ```
  `include_plotlyjs=True` on the first chart embeds Plotly.js once — fully self-contained, no CDN, no external network call.
- Include a block comment after each chart section explaining what the chart shows, the key pattern, and one sentence about the business implication.

## Constraints
- plotly.express only — no matplotlib, no seaborn, no 3D charts
- PII-adjacent fields (counterparty_masked, user_id_masked) must not appear as a chart label, axis value, hover field, or legend entry — remove them from the dataframe before passing to Plotly
- Sentinel values (9999, 999, -1) must be excluded before plotting — confirm exclusion in the code
- The dashboard is a single self-contained `.html` file — no server required to open it, no external CDN
- Populate the summary header with real computed values — row count from the cleaned dataframe, period/date range from the data, one-sentence key finding from EDA
- A descriptive title stating what the chart shows on every chart
- Labeled x-axis and y-axis with units where applicable
- Y-axis starting at 0 for all bar and line charts (`fig.update_yaxes(rangemode='tozero')`)
- A legend where multiple series or categories are shown
- Do not call `fig.show()` or `fig.write_html()` per individual chart — use `to_html()` and combine into the single dashboard

## Checks
- [ ] Does every chart have a title and fully labeled axes with units?
- [ ] Does the Y-axis start at zero for bar and line charts?
- [ ] Are all PII-adjacent fields absent from chart elements?
- [ ] Is the summary header populated with real values (row count, period, key finding)?
- [ ] Is the single `outputs/[X]_dashboard.html` file present in `outputs/` after running?
- [ ] Does the dashboard open correctly in a browser and show all 3 charts?
- [ ] Is each chart section followed by a block comment with the chart's key pattern and business implication?
