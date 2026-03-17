# Lab Outputs — Deliverables Manifest

**This folder is where all your work lives. If it's not here, it doesn't count.**

---

## Required Deliverables

Complete 3 artifacts per scenario sprint. All 3 are required to mark the lab complete.

| Filename | Stage | Description | Template |
|---|---|---|---|
| `01_data_profile.md` | Stage 1 | Data quality issue log — every issue found with count and severity | `templates/profile_template.md` |
| `02_cleaning_decisions.md` | Stage 2 | Transformation log — every action justified, row counts before/after | `templates/cleaning_decisions_template.md` |
| `03_visualization_notes.md` | Stage 3 | Chart design log + sharing checklist — one entry per chart | `templates/visualization_notes_template.md` |

In addition to `03_visualization_notes.md`, export each chart as a PNG:

| Filename | Chart |
|---|---|
| `chart_01_[description].png` | Chart 1 from Stage 3 |
| `chart_02_[description].png` | Chart 2 from Stage 3 |
| `chart_03_[description].png` | Chart 3 from Stage 3 |

---

## Cleaning Scripts

Your generated cleaning script lives in `../scripts/`, not in `outputs/`. Name it after your scenario:

| Script | Scenario |
|---|---|
| `scripts/clean_rca.py` | Sub-Lab A — Root Cause Analysis |
| `scripts/clean_mainframe.py` | Sub-Lab B — Product Modernization |
| `scripts/clean_treasury.py` | Sub-Lab C — Treasury Anomaly Detection |

---

## End-of-Lab Completion Checklist

Go through this with your facilitator before the session ends.

- [ ] `outputs/01_data_profile.md` — quality issues documented with counts and severity
- [ ] `outputs/02_cleaning_decisions.md` — every transformation justified, row counts before/after
- [ ] `scripts/clean_[scenario].py` — commented cleaning script that runs without errors
- [ ] `outputs/03_visualization_notes.md` — chart log with sharing checklist marked complete
- [ ] `outputs/chart_01_[...].png`, `chart_02_[...].png`, `chart_03_[...].png` — 3 exported charts

**No artifact = incomplete lab. Check this list with your facilitator before leaving.**

---

## Notes

- All files in this folder (except this README) are excluded from git — your work stays local.
- Use the templates in `templates/` to structure each artifact. Don't start from a blank page.
- The starter script for your scenario is at `scenarios/sub-lab-[X]-[name]/explore_data.py`. Save it back to `outputs/` as `explore_data.py` when done if you want it tracked.
