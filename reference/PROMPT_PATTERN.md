# RIFCC-DA Prompt Framework
## For Data Analysis with GitHub Copilot

---

## What is RIFCC-DA?

RIFCC-DA is the data analysis adaptation of the RIFCC prompting framework. It uses the same five fields — Role, Inputs, Format, Constraints, Checks — tuned specifically for analytical tasks involving financial data, data quality, visualization, and responsible use. A well-formed RIFCC-DA prompt produces focused, auditable, policy-compliant output instead of a generic code dump.

Think of it as a pre-flight checklist for your prompt. Each field closes a common failure mode.

---

## The 5 Fields

### R — Role
What analyst role or mindset Copilot should adopt. This constrains the type of response you get.

Setting a role shifts Copilot from "general assistant" to "specialist with domain-specific constraints." A Data Cleaning Engineer will justify transformations. A Responsible Use Auditor will flag risks. Without a role, Copilot defaults to "helpful programmer" and may skip the constraints that matter most.

**Examples:**
- `"Data Profiling Analyst"` — generates structured quality analysis, not just stats
- `"Data Cleaning Engineer"` — generates justified, commented transformations
- `"Visualization Architect"` — enforces chart integrity rules before generating code

---

### I — Inputs
The files, datasets, schema context, and business question you are working from.

Always specify: which file (`#filename`), what the business context is, and any prior findings from earlier stages.

**Examples:**
- `Inputs: #data/treasury_payments.xlsx and #data/treasury_schema.md`
- `Inputs: cleaned dataset from Phase 2 and business question: what regions have the highest anomaly confirmation rate?`
- `Inputs: scripts/clean_treasury.py — the script generated in Phase 2`

---

### F — Format
Exactly what you want back. Be specific — Copilot will fill in your ambiguity with whatever seems easiest.

**Examples:**
- `"Python script with inline comments — one comment per transformation"`
- `"Markdown table — Column | Sensitivity Tier | Risk Notes | Recommended Handling"`
- `"A standalone Python script that exports charts to HTML"`
- `"Plain-English summary — no code, written for a VP of Fraud Operations"`

---

### C — Constraints
What Copilot must not do. Privacy rules, library restrictions, no external calls.

**Always include for this lab:**
- `Use pandas only. No external libraries.`
- `No external API calls or network requests.`
- `Do not include PII fields (counterparty_masked, user_id_masked) in any output, chart, or printed DataFrame.`
- `Handle missing values explicitly — do not silently ignore them.`

---

### C — Checks
Validation logic Copilot must perform or include before finalizing output.

**Always include for this lab:**
- Row counts before and after any transformation
- Null counts per affected column
- Schema compliance check (e.g., `assert df['anomaly_confirmed'].isin([0,1,2]).all()`)
- Sentinel value handling documentation — any sentinel values must be explicitly identified and handled
- Assumption documentation — any assumption made about the data must be explicitly stated

---

## Blank RIFCC-DA Template

```
Role:
Inputs:
Format:
Constraints:
Checks:
```

---

## 6 Example RIFCC-DA Prompts

### Mode 1: Data Risk & Policy Reviewer

```
Role: Data Risk & Policy Reviewer operating under Meridian Asset Management data governance policy
Inputs: #data/treasury_payments.xlsx and #data/treasury_schema.md
Format: Sensitivity classification table — Column | Data Type | Sensitivity Tier | Risk Notes | Recommended Handling — plus a "Must Not Appear in Outputs" section
Constraints: Apply classification tiers: Public / Internal / Confidential / Restricted. Flag counterparty_masked explicitly. Do not assume any field is safe without documented reasoning. No external lookups or API calls.
Checks: Verify all columns are assessed. Confirm counterparty_masked is flagged as requiring special handling. List at least 3 specific actions the analyst must take before beginning analysis.
```

---

### Mode 2: Data Profiling Analyst

```
Role: Data Profiling Analyst generating read-only diagnostic code
Inputs: #data/rca_app_logs.csv and #data/rca_schema.md
Format: Python profiling script (pandas only) that prints: row count, null count per column (as count and %), value_counts for all categoricals, describe() for all numerics, list of schema violations. Followed by a markdown quality issue log.
Constraints: pandas only — no ydata-profiling, no pandas-profiling. Do not modify or save the dataframe. Print all counts as numbers and percentages.
Checks: Flag any column with null % > 5%. Flag numeric columns with values outside schema-defined valid ranges. Flag categorical columns with unexpected values. Generate scripts/profile_logs.py as the output script.
```

---

### Mode 3: Data Cleaning Engineer

```
Role: Data Cleaning Engineer writing production-safe Python with full transformation justification
Inputs: #data/mainframe_usage.xlsx and profiling findings from outputs/C_profile.md
Format: Python script scripts/clean_mainframe.py — every transformation has an inline comment explaining the business justification. Print row count before cleaning, after each major operation, and at end. Save cleaned data to data/mainframe_usage_clean.xlsx (do not overwrite original).
Constraints: pandas only. No silent row drops — every removal must be printed and commented. No imputation without stating the assumption. Do not modify data/mainframe_usage.xlsx. Handle sentinel value 9999 in estimated_migration_effort_days explicitly.
Checks: Print row count before and after every major step. Document all sentinel values detected and how they are handled. Document total rows removed and reason.
```

---

### Mode 4: Exploratory Data Analyst

```
Role: Senior Data Analyst answering treasury operations business questions
Inputs: data/treasury_payments_clean.csv and #data/treasury_schema.md. Business question: Which regions have the highest anomaly rates, and how does analyst_confidence correlate with risk_score?
Format: Python EDA code (pandas and numpy only) followed by a plain-English findings narrative: Business Question | Methodology (2 sentences) | Key Finding | Supporting Evidence (counts and %) | Assumptions | Limitations
Constraints: pandas and numpy only. Do not include counterparty_masked in any output. Do not claim causation from correlation. State all excluded rows explicitly. Handle sentinel values -1 in analyst_confidence and 2 in anomaly_confirmed as specified in schema.
Checks: Exclude rows with sentinel values from calculations. Cross-check all percentages against raw counts. List all assumptions made about the cleaned dataset.
```

---

### Mode 5: Visualization Architect

```
Role: Visualization Architect building honest, labeled charts for RCA reporting
Inputs: data/rca_app_logs_clean.csv and #data/rca_schema.md
Format: A standalone Python script scripts/visualize_logs.py exporting interactive plotly charts to HTML files, followed by markdown interpretation. Generate: (1) error_code distribution, (2) response_time_ms by service_name, (3) log_level counts, (4) response_time_ms vs error_code scatter.
Constraints: plotly.express only. Y-axis must start at 0 for bar charts. No 3D charts. No user_id_masked in any chart label, axis, or legend. All axes labeled with units. All charts must have titles. Export charts via fig.write_html().
Checks: Verify Y-axis starts at 0 for bar charts. Verify user_id_masked is absent. Verify each chart is exported to a separate HTML file. Verify chart type is appropriate for the data relationship shown.
```

---

### Mode 6: Responsible Use Auditor

```
Role: Responsible Use Auditor applying Centrix Financial Systems enterprise security and data governance standards
Inputs: all scripts in scripts/ directory and all files in outputs/
Format: Structured audit report — Files Reviewed checklist, Risk Findings table (Finding # | File | Line | Description | Severity: Low/Med/High/Critical | Recommendation), Policy Compliance Assessment (3 yes/no questions with evidence), Required Corrective Actions
Constraints: Review every file in full — no skipping. Rate every finding with a specific severity. Recommendations must be specific and actionable, not generic. Do not approve any file you haven't fully reviewed.
Checks: Confirm no urllib, requests, or http library calls anywhere. Confirm all PII fields (counterparty_masked, user_id_masked) are absent from all output files and print statements. Confirm all transformations have written justification comments.
```

---

## Common Prompt Failure Patterns

| Failure Pattern | What Goes Wrong | How to Fix It |
|---|---|---|
| Prompt too vague — no Role specified | Copilot responds as a general assistant, skipping domain-specific constraints (e.g., justifying row drops, flagging sensitive columns) | Add `Role:` field explicitly. Use the mode names from `.github/agents/`. |
| No Constraints block | Copilot may use external libraries (requests, sklearn), expose PII fields in outputs, or generate code that modifies the source file | Add `Constraints: pandas only (or plotly.express). No external calls. Do not include PII fields.` |
| Missing Checks block | Output has no validation logic, row counts are missing, and assumptions are unstated | Add `Checks: Print row count before/after. Document all excluded rows. State all assumptions and sentinel values.` |
| Asking for insight without business context | Copilot runs generic EDA instead of answering the specific question you need — results are technically valid but not useful | Add the specific business question to the Inputs field: `Business question: which regions have the highest anomaly rates?` |
| Format specified too loosely | "Give me some code" produces a wall of undocumented code with no structure | Specify exactly: `Format: Python script with one comment per transformation + markdown table showing rows affected` |
| Not referencing the actual file | Copilot invents column names or makes up distributions | Always include `#data/treasury_payments.xlsx` in the prompt — use the `#` file picker |
