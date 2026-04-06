# Lab Outputs — Deliverables Manifest

**This folder is where all your work lives. If it's not here, it doesn't count.**

---

## Required Deliverables

Complete 3 artifacts per scenario. All 3 are required to mark the lab complete. File names are prefixed with your scenario letter (A, B, or C).

| Filename | Phase | Description | Template |
|---|---|---|---|
| `[X]_profile.md` | Phase 1 | Data quality issue log — every issue found with count and severity | `templates/profile_template.md` |
| `[X]_cleaning_decisions.md` | Phase 2 | Transformation log — every action justified, row counts before/after | `templates/cleaning_decisions_template.md` |
| `[X]_chart_*.html` | Phase 3 | 3 interactive charts exported as self-contained HTML files | `templates/visualization_notes_template.md` |

**Example for Scenario A (Treasury):**

| Filename |
|---|
| `A_profile.md` |
| `A_cleaning_decisions.md` |
| `A_chart_01_anomaly_by_type.html` |
| `A_chart_02_amount_distribution.html` |
| `A_chart_03_anomaly_trend.html` |

---

## Scripts

Your generated scripts live in `../scripts/`, not in `outputs/`. Name them after your scenario:

| Script | Scenario |
|---|---|
| `scripts/profile_treasury.py` + `scripts/clean_treasury.py` + `scripts/visualize_treasury.py` | Sub-Lab A — Treasury Anomaly Detection |
| `scripts/profile_logs.py` + `scripts/clean_logs.py` + `scripts/visualize_logs.py` | Sub-Lab B — Root Cause Analysis |
| `scripts/profile_mainframe.py` + `scripts/clean_mainframe.py` + `scripts/visualize_mainframe.py` | Sub-Lab C — Product Modernization |

---

## End-of-Lab Completion Checklist

Go through this with your facilitator before the session ends.

- [ ] `outputs/[X]_profile.md` — quality issues documented with counts and severity
- [ ] `outputs/[X]_cleaning_decisions.md` — every transformation justified, row counts before/after
- [ ] `scripts/clean_[scenario].py` — commented cleaning script that runs without errors
- [ ] `scripts/visualize_[scenario].py` — visualization script that generates interactive HTML charts
- [ ] `outputs/[X]_chart_*.html` — 3 exported interactive charts (open in any browser)

**No artifact = incomplete lab. Check this list with your facilitator before leaving.**

---

## Notes

- All files in this folder (except this README) are excluded from git — your work stays local.
- Use the templates in `templates/` to structure each artifact. Don't start from a blank page.
- HTML chart files are self-contained — open them directly in any browser to interact with the data. No server needed.
