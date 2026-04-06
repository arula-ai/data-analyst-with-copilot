# Notebooks and Jupyter — Reference Guide

**Module 1: Setting the Stage** — when to use notebooks vs. scripts in VS Code.

---

## Jupyter Notebooks — When to Use Them vs. Python Scripts

The lab uses Python `.py` scripts as the primary deliverable because scripts are reproducible, version-controllable, and CI/CD-friendly. Notebooks are best for exploratory work.

| Scenario | Use Notebooks | Use Python Scripts |
|----------|--------------|-------------------|
| Initial exploration and hypothesis testing | ✅ | |
| Sharing analysis with inline narrative | ✅ | |
| One-off data investigation | ✅ | |
| Lab deliverable (profile, clean, visualize) | | ✅ Required |
| Production pipeline or CI/CD | | ✅ Required |
| Code review by a colleague | | ✅ Preferred |
| Repeatable execution without manual steps | | ✅ Required |

---

## Setting Up Jupyter in This Lab

**Install (already in requirements.txt):**
```bash
pip install -r requirements.txt
```

**Start Jupyter:**
```bash
# From workspace root:
jupyter notebook
# Opens in browser at http://localhost:8888
```

**Or use VS Code's built-in notebook interface:**
1. `Ctrl+Shift+P` → "Create: New Jupyter Notebook"
2. Select your Python interpreter when prompted (Python 3.11)
3. Run cells inline — output appears directly below each cell

---

## Embedding Plotly Charts in Notebooks

Your Phase 3 Plotly visualizations can be embedded in a notebook for a combined analysis document:

```python
import pandas as pd
import plotly.express as px

df = pd.read_csv('data/treasury_payments_clean.csv')

# Chart 1: Confirmed anomaly rate by payment_type
anomaly_rates = (
    df[df['anomaly_confirmed'].isin([0,1])]
    .groupby('payment_type')['anomaly_confirmed']
    .mean()
    .reset_index()
    .rename(columns={'anomaly_confirmed': 'anomaly_rate'})
)

fig = px.bar(
    anomaly_rates,
    x='payment_type',
    y='anomaly_rate',
    title='Confirmed Anomaly Rate by Payment Type',
    labels={'payment_type': 'Payment Type', 'anomaly_rate': 'Confirmed Anomaly Rate'}
)
fig.update_yaxes(rangemode='tozero')
fig.show()  # Renders inline in notebook

# Also export as standalone HTML:
fig.write_html('outputs/A_chart_01_anomaly_by_type.html')
```

---

## Quick Reference: VS Code Keyboard Shortcuts for Data Work

| Action | Windows / Linux | Mac |
|--------|----------------|-----|
| Open Extensions panel | `Ctrl+Shift+X` | `Cmd+Shift+X` |
| Open Copilot Chat | `Ctrl+Shift+I` | `Cmd+Shift+I` |
| New Jupyter Notebook | `Ctrl+Shift+P` → "New Jupyter Notebook" | Same |
| Run notebook cell | `Ctrl+Enter` | `Ctrl+Enter` |
| Run cell + move to next | `Shift+Enter` | `Shift+Enter` |
| Open Command Palette | `Ctrl+Shift+P` | `Cmd+Shift+P` |
