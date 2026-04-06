---
name: expert-visualization
description: Guides Copilot to generate accurate, honest, and professionally formatted data visualizations using Python. Use this skill when creating charts or plots from any dataset. Enforces chart integrity — correct axis scaling, clear labels, no misleading design choices, and plain-English interpretations.
---

## Skill: Expert Data Visualization

This skill makes Copilot behave as an expert data visualization engineer. It applies to any dataset and enforces professional chart standards — accuracy, clarity, and integrity over aesthetics.

---

## Chart Integrity Rules

Every chart must follow these rules without exception:

| Rule | Requirement |
|------|-------------|
| Y-axis origin | Always starts at 0 unless the data range makes 0 meaningless (must be explicitly justified) |
| 3D charts | Never — 3D distorts perception and is never appropriate for data analysis |
| Titles | Every chart must have a descriptive, specific title |
| Axis labels | Every axis must be labeled with the variable name and unit (e.g., "Revenue ($)", "Age (years)") |
| Legends | Required whenever more than one group or series is plotted |
| Color | Use colorblind-safe palettes — prefer `plotly.express` color sequences like `px.colors.qualitative.Safe` |
| Interpretation | Every chart must be followed by a 2–3 sentence plain-English explanation of what the chart shows |

---

## Libraries

Use only: `plotly`, `pandas`, `numpy`

Do not suggest or import any additional visualization libraries unless explicitly requested.

---

## Output Format

For each chart, generate two consecutive sections in the script:

1. **Code cell** — the chart code, fully labeled and titled, exported as a standalone interactive HTML file using `fig.write_html()`
2. **Markdown cell** — 2–3 sentences interpreting what the chart shows, written for a non-technical reader

---

## What to Avoid

- Truncated Y-axes that exaggerate differences
- 3D bar charts, 3D pie charts, or any 3D representation
- Unlabeled axes or axes without units
- Pie charts with more than 5 slices
- Overloaded charts — one insight per chart
- Decorative elements that add no information (chartjunk)
- Identifiable or sensitive fields as axis labels or tick values

---

## Interpretation Standard

The markdown interpretation after each chart must:
- State what the chart shows in plain English
- Highlight the most important pattern or finding
- Note any caveat, limitation, or assumption the reader should be aware of

---

## Example Pattern

```python
import plotly.express as px

# Bar chart: Anomaly confirmation rate by alert type
fig = px.bar(df,
             x='alert_type',
             y='anomaly_confirmed',
             title='Anomaly Confirmation Rate by Alert Type',
             labels={'alert_type': 'Alert Type', 'anomaly_confirmed': 'Confirmation Rate (proportion)'},
             color_discrete_sequence=px.colors.qualitative.Safe,
             height=500,
             width=800)

fig.update_yaxes(range=[0, 1])
fig.write_html('anomaly_confirmation_chart.html')
```

Followed by a markdown cell:
```
The chart shows that Velocity Check alerts have the highest anomaly confirmation rate at approximately 0.42,
nearly double that of Location alerts. Sample sizes vary significantly across alert types,
so this comparison should be interpreted alongside raw counts before drawing conclusions.
The interactive HTML file enables users to hover over bars to see exact values.
```
