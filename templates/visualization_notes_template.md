# Visualization Notes
**Phase:** 3 | **Agent Mode:** Visualization Architect | **Time Budget:** 15 min
**Save to:** `outputs/[X]_chart_*.html` *(replace [X] with your scenario letter: A, B, or C)*

---

## Purpose
This document records chart design decisions, Copilot corrections, and sharing checklist compliance. One entry per chart produced. Required as the Phase 3 deliverable alongside your exported interactive HTML charts.

---

## Charts Produced

### Chart 1

| Property | Value |
|---|---|
| Chart Type | *(bar / histogram / line / scatter)* |
| Title | |
| X-axis label | |
| Y-axis label | |
| Y-axis starts at 0 | [ ] Yes |
| Data filtered/excluded before plotting | *(describe any pre-filter, e.g., excluded sentinel values)* |
| Copilot prompt used | *(paste abbreviated prompt or reference)* |
| Exported as | *(filename.html)* |

**Finding this chart shows:**
*(1–2 sentences describing what the chart communicates)*

**Corrections made to Copilot output:**
*(What did you change, and why?)*

---

### Chart 2

| Property | Value |
|---|---|
| Chart Type | |
| Title | |
| X-axis label | |
| Y-axis label | |
| Y-axis starts at 0 | [ ] Yes |
| Data filtered/excluded before plotting | |
| Copilot prompt used | |
| Exported as | |

**Finding this chart shows:**

**Corrections made to Copilot output:**

---

### Chart 3

| Property | Value |
|---|---|
| Chart Type | |
| Title | |
| X-axis label | |
| Y-axis label | |
| Y-axis starts at 0 | [ ] Yes |
| Data filtered/excluded before plotting | |
| Copilot prompt used | |
| Exported as | |

**Finding this chart shows:**

**Corrections made to Copilot output:**

---

## Sharing Checklist

> Complete before sharing any chart or exporting any output.

- [ ] No PII or PII-adjacent fields appear in any chart (check axis labels, titles, hover text, legends)
- [ ] No sentinel values included in plotted data (e.g., 999, -1, 9999 excluded before plotting)
- [ ] All axes labeled with units where applicable
- [ ] Y-axis starts at 0 for all bar and line charts
- [ ] Chart titles accurately describe what is shown (no overstated causal claims)
- [ ] Charts reviewed for misleading visual patterns (truncated axes, misleading color scales)
- [ ] Exported files saved to `outputs/` folder

---

## Export Options — Module 4: Sharing Visuals

Your Plotly charts are exported as self-contained interactive HTML. Choose the format that fits your recipient:

| Format | How to Export | Best For |
|--------|--------------|---------|
| **Interactive HTML** | Already done — `.html` file in `outputs/` | Internal stakeholders who open files locally |
| **Static PNG** | Open `.html` in Chrome → click Hamburger icon (top-right of chart) → **Download plot as PNG** | Slide decks, email, tools that don't render HTML |
| **Clipboard screenshot** | `Windows+Shift+S` (Windows) / `Cmd+Shift+4` (Mac) — capture chart area | Quick Teams/Slack/chat sharing |
| **Notebook embed** | Copy Plotly code into a Jupyter notebook cell → run inline → save `.ipynb` | Reproducible analysis documents |
| **Reporting pipeline** | Export cleaned `.csv` from `data/` → import into Power BI / Tableau / Looker as data source | Production reporting dashboards |

### Reporting Integration Notes

> Fill in during or after the lab session.

**If connecting to Power BI:**
- Data source: `data/[scenario]_[clean].csv`
- Recommended chart type mapping: bar → Clustered Bar, histogram → Histogram visual, line → Line chart

**If connecting to Tableau:**
- Import as Text File (CSV) or Excel
- Date columns: confirm format after `pd.to_datetime()` normalization

**If using Jupyter notebook:**
- Install: `pip install jupyter` (included in requirements.txt)
- Run: `jupyter notebook` from workspace root
- Reference: `reference/notebooks_and_data_wrangler.md`

---

## Debrief Preparation

Answer these before the group debrief (8 min):

1. **Key finding** (one sentence, VP-level framing):
   > *"The data shows that..."*

2. **Data quality risk you caught:**
   > *"If we had not excluded [issue], the chart would have shown..."*

3. **One Copilot correction you made:**
   > *"Copilot initially... I corrected it because..."*
