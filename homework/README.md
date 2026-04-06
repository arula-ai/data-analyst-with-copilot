# Post-Session Homework

**Complete after the session. No time limit — these are take-home exercises.**

---

## Why Homework?

The 90-minute lab covers one scenario. The other two scenarios use the same framework with different data shapes, analytical goals, and quality issues. Working through a second scenario on your own is the fastest way to build fluency with RIFCC-DA prompting and Copilot-assisted data analysis.

---

## Exercise 1: Complete a Second Scenario (Recommended)

Go back to the lab repo and work through one of the two scenarios you didn't choose in the session. Use the same 3-phase structure:

- **Phase 1** — Profile with the Data Profiling Analyst agent
- **Phase 2** — Clean and explore with the Data Cleaning Engineer agent
- **Phase 3** — Visualize with the Visualization Architect agent

Save your deliverables to `outputs/` using the correct scenario prefix (A, B, or C).

| If you did in session | Try next |
|---|---|
| Scenario A (Treasury) | Scenario B (RCA) — different data shape: logs vs payments |
| Scenario B (RCA) | Scenario C (Modernization) — adds legacy code pre-step |
| Scenario C (Modernization) | Scenario A (Treasury) — largest dataset, most issues |

---

## Exercise 2: Critique the Flawed Analysis

Each scenario has a flawed analysis document in its `exercises/` folder. Go through it carefully and identify all intentional errors. Use Copilot to help:

```
You are a Data Profiling Analyst. Review #flawed_treasury_analysis.md.
Identify every statistical error, logical contradiction, and policy violation.
For each issue, explain what is wrong and what the correct approach would be.
```

Try to find all 5 flaws before reading the inline comments that reveal them.

---

## Exercise 3: Write Your Own RIFCC-DA Prompts From Scratch

Without looking at `reference/PROMPT_PATTERN.md`, write a complete RIFCC-DA prompt for each of the following tasks:

1. Profile `rca_app_logs.csv` to find all data quality issues
2. Generate a cleaning script for `mainframe_usage.xlsx` that handles the `estimated_migration_effort_days = 9999` sentinel value
3. Create a bar chart showing confirmed anomaly rate by `alert_type` for the treasury dataset, excluding `anomaly_confirmed = 2`

After writing your prompts, compare them to the examples in `reference/PROMPT_PATTERN.md`. What did you include? What did you leave out?

---

## Exercise 4: Apply the Framework to Your Own Data (Advanced)

If you have access to a real dataset in your work (ensure it is approved for AI-assisted analysis per your organization's data classification policy), try applying the RIFCC-DA framework:

1. Run VERIFY_BEFORE_SEND.md checklist on your dataset before starting
2. Use the Data Profiling Analyst agent to profile your data
3. Document at least 3 data quality issues in `outputs/` using the profile template
4. Use the Data Cleaning Engineer agent to generate a cleaning script for one issue
5. Use the Visualization Architect agent to create one chart — export as HTML

> **Important:** Only use data approved for AI-assisted analysis under your organization's responsible use policy. Do not send Restricted-tier data to Copilot.

---

## Exercise 5: Governance Extension (Optional)

Use the two optional governance agents that weren't part of the main session:

1. Open any scenario dataset and run the **Data Risk Reviewer** agent before profiling. Compare its output to VERIFY_BEFORE_SEND.md — does it catch the same issues? Anything new?

2. After completing all 3 phases for a scenario, run the **Responsible Use Auditor** agent on your generated scripts and outputs. Does it flag anything you missed?

Document your findings in a markdown file in `outputs/` — name it `[X]_governance_review.md`.

---

## Submitting Your Work

Share your completed `outputs/` folder (or the specific deliverables) with your facilitator or team lead. At minimum, aim for:

- [ ] All 3 required deliverables for at least one additional scenario (`[X]_profile.md`, `[X]_cleaning_decisions.md`, `[X]_chart_*.html`)
- [ ] Exercise 2: Flawed analysis critique notes
