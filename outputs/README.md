# Lab Outputs — Deliverables Manifest

**This folder is where all your work lives. If it's not here, it doesn't count.**

---

## Required Deliverables

| Filename | Stage | Description | Required? | Template Available? |
|---|---|---|---|---|
| `00_data_risk_review.md` | Stage 0 | Sensitivity classification for all 15 columns + handling restrictions | **YES** | YES — `templates/00_data_risk_review_template.md` |
| `01_data_profile.md` | Stage 1 | Data quality issue log with at least 8 issues, counts, and severity | **YES** | YES — `templates/01_data_profile_template.md` |
| `../scripts/clean_alerts.py` | Stage 2 | Commented cleaning script with row counts before and after | **YES** | No — generate with Copilot |
| `02_cleaning_decisions.md` | Stage 2 | Transformation log with justifications for every action | **YES** | YES — `templates/02_cleaning_decisions_template.md` |
| `03_exploratory_insights.md` | Stage 3 | Business insights in plain English with assumptions and limitations | **YES** | YES — `templates/03_exploratory_insights_template.md` |
| `04_visualizations.ipynb` | Stage 4 | At least 4 labeled charts with interpretation cells | **YES** | YES — `notebooks/starter_analysis.ipynb` as starting point |
| `05_audit_review.md` | Stage 5 | Code and output compliance review with severity-rated findings | **YES** | YES — `templates/05_audit_review_template.md` |
| `06_executive_summary.md` | Stage 6 | 3 insights, 2 recommendations, 1 risk note, 1 data limitation | **YES** | YES — `templates/06_executive_summary_template.md` |
| `[stage]_handoff.md` | Any | Copilot-generated stage summary (3 bullet points) | No (bonus) | No |

---

## Alternative Scenario Deliverables (Optional)

Complete these only if you are working through the alternative scenarios in `LAB_ACTION_GUIDE.md` after finishing the main lab.

| Filename | Scenario | Description | Required? |
|---|---|---|---|
| `rca_findings.md` | Scenario A — Root Cause Analysis | Root cause hypothesis with supporting evidence from `rca_app_logs.csv` | No (optional) |
| `modernization_recommendations.md` | Scenario B — Product Usage & Modernization | Feature prioritization and migration recommendations from `mainframe_usage.xlsx` | No (optional) |
| `treasury_findings.md` | Scenario C — Operational Anomaly Detection | Treasury payment anomaly patterns and trend analysis from `treasury_payments.xlsx` | No (optional) |

---

## End-of-Lab Completion Checklist

Use this to verify your work before the session ends. Go through it with your facilitator.

- [ ] `outputs/00_data_risk_review.md`
- [ ] `outputs/01_data_profile.md`
- [ ] `scripts/clean_alerts.py`
- [ ] `outputs/02_cleaning_decisions.md`
- [ ] `outputs/03_exploratory_insights.md`
- [ ] `outputs/04_visualizations.ipynb`
- [ ] `outputs/05_audit_review.md`
- [ ] `outputs/06_executive_summary.md`

**No artifact = incomplete lab. Check this list with your facilitator before leaving.**

---

## Notes

- All files in this folder (except this README) are excluded from git — your work stays local.
- Use the templates in `/templates/` to structure each artifact. Don't start from a blank page.
- If you generated stage hand-off summaries, save them here as `00_handoff.md`, `01_handoff.md`, etc.
