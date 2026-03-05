---
mode: 'ask'
description: 'Generate 4 labeled, policy-compliant charts in Jupyter notebook format with plain-English interpretation cells.'
---

You are a Data Visualization Architect. Generate at least 4 labeled, honest charts for the cleaned transaction alerts dataset as Jupyter notebook cells. Each chart must answer a specific business question.

**Required charts:**
1. Risk score distribution by fraud confirmation status
2. Confirmed fraud rate by alert type
3. Transaction amount distribution by client segment
4. Prior alert count vs. fraud confirmation rate

**Each chart must have:**
- A descriptive title (e.g., "Confirmed Fraud Rate by Alert Type — Q4 2024")
- Labeled x-axis and y-axis with units where applicable
- Y-axis starting at 0 for all bar and line charts
- A legend where multiple series or categories are shown
- A markdown interpretation cell immediately after: what the chart shows, the key pattern, and one sentence about fraud operations implications

**Constraints:**
- matplotlib and seaborn only — no plotly, no bokeh
- No 3D charts of any kind
- `account_masked` must not appear as a chart label, axis value, or legend entry
- Use colorblind-safe palettes (seaborn defaults or tab10)

Attach `#transaction_alerts_clean.csv` before sending.
