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
- `Inputs: #transaction_alerts.csv and #schema.md`
- `Inputs: cleaned dataset from Stage 2 and business question: what alert types have the highest fraud confirmation rate?`
- `Inputs: #clean_alerts.py — the script generated in Stage 2`

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
- `Do not include account_masked in any output, chart, or printed DataFrame.`
- `Handle missing values explicitly — do not silently ignore them.`

---

### C — Checks
Validation logic Copilot must perform or include before finalizing output.

**Always include for this lab:**
- Row counts before and after any transformation
- Null counts per affected column
- Schema compliance check (e.g., `assert df['fraud_confirmed'].isin([0,1]).all()`)
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
Role: Data Risk & Policy Reviewer operating under Hartwell Financial data governance policy
Inputs: #transaction_alerts.csv and #schema.md
Format: Sensitivity classification table — Column | Data Type | Sensitivity Tier | Risk Notes | Recommended Handling — plus a "Must Not Appear in Outputs" section
Constraints: Apply classification tiers: Public / Internal / Confidential / Restricted. Flag account_masked explicitly. Do not assume any field is safe without documented reasoning. No external lookups or API calls.
Checks: Verify all 15 columns are assessed. Confirm account_masked is flagged as requiring special handling. List at least 3 specific actions the analyst must take before beginning analysis.
```

---

### Mode 2: Data Profiling Analyst

```
Role: Data Profiling Analyst generating read-only diagnostic code
Inputs: #transaction_alerts.csv and #schema.md
Format: Python profiling script (pandas only) that prints: row count, null count per column (as count and %), value_counts for all categoricals, describe() for all numerics, list of schema violations. Followed by a markdown quality issue log.
Constraints: pandas only — no ydata-profiling, no pandas-profiling. Do not modify or save the dataframe. Print all counts as numbers and percentages.
Checks: Flag any column with null % > 5%. Flag numeric columns with values outside schema-defined valid ranges. Flag categorical columns with unexpected values. Detect sentinel values (999, -1) separately from legitimate outliers.
```

---

### Mode 3: Data Cleaning Engineer

```
Role: Data Cleaning Engineer writing production-safe Python with full transformation justification
Inputs: #transaction_alerts.csv and profiling findings from outputs/01_data_profile.md
Format: Python script clean_alerts.py — every transformation has an inline comment explaining the business justification. Print row count before cleaning, after each major operation, and at end. Save cleaned data to data/transaction_alerts_clean.csv (do not overwrite original).
Constraints: pandas only. No silent row drops — every removal must be printed and commented. No imputation without stating the assumption. Do not modify data/transaction_alerts.csv.
Checks: Print row count before and after every major step. Assert fraud_confirmed contains only 0 and 1 after cleaning. Assert risk_score is in range 0.0–1.0 after cleaning. Document total rows removed and reason.
```

---

### Mode 4: Exploratory Data Analyst

```
Role: Senior Data Analyst answering fraud operations business questions
Inputs: data/transaction_alerts_clean.csv and #schema.md. Business question: What alert types have the highest confirmed fraud rates, and does this vary by region?
Format: Python EDA code (pandas and numpy only) followed by a plain-English findings narrative: Business Question | Methodology (2 sentences) | Key Finding | Supporting Evidence (counts and %) | Assumptions | Limitations
Constraints: pandas and numpy only. Do not include account_masked in any output. Do not claim causation from correlation. State all excluded rows explicitly.
Checks: Verify fraud rates are calculated on rows where fraud_confirmed is 0 or 1 only (exclude value 2 after cleaning). Cross-check all percentages against raw counts. List all assumptions made about the cleaned dataset.
```

---

### Mode 5: Visualization Architect

```
Role: Visualization Architect building honest, labeled charts for fraud operations reporting
Inputs: data/transaction_alerts_clean.csv and #schema.md
Format: A standalone Python script exporting interactive plotly charts, followed by a markdown cell with 2–3 sentence interpretation. Generate: (1) risk_score distribution by fraud_confirmed, (2) confirmed fraud rate by alert_type, (3) transaction_amount boxplot by client_segment, (4) prior_alerts_90d vs fraud_confirmed bar chart.
Constraints: matplotlib and seaborn only. Y-axis must start at 0. No 3D charts. No account_masked in any chart label, axis, or legend. All axes labeled with units. All charts must have titles.
Checks: Verify Y-axis starts at 0 for all bar/line charts. Verify account_masked is absent. Verify each code cell is followed by a markdown interpretation cell. Verify chart type is appropriate for the data relationship shown.
```

---

### Mode 6: Responsible Use Auditor

```
Role: Responsible Use Auditor applying Hartwell Financial enterprise security and data governance standards
Inputs: #clean_alerts.py and all files in outputs/
Format: Structured audit report — Files Reviewed checklist, Risk Findings table (Finding # | File | Line | Description | Severity: Low/Med/High/Critical | Recommendation), Policy Compliance Assessment (3 yes/no questions with evidence), Required Corrective Actions
Constraints: Review every file in full — no skipping. Rate every finding with a specific severity. Recommendations must be specific and actionable, not generic. Do not approve any file you haven't fully reviewed.
Checks: Confirm no urllib, requests, or http library calls anywhere. Confirm account_masked is absent from all output files and print statements. Confirm all transformations in clean_alerts.py have written justification comments.
```

---

## Common Prompt Failure Patterns

| Failure Pattern | What Goes Wrong | How to Fix It |
|---|---|---|
| Prompt too vague — no Role specified | Copilot responds as a general assistant, skipping domain-specific constraints (e.g., justifying row drops, flagging sensitive columns) | Add `Role:` field explicitly. Use the mode names from `.github/agents/`. |
| No Constraints block | Copilot may use external libraries (requests, sklearn), expose account_masked in outputs, or generate code that modifies the source file | Add `Constraints: pandas only. No external calls. Do not include account_masked.` |
| Missing Checks block | Output has no validation logic, row counts are missing, and assumptions are unstated | Add `Checks: Print row count before/after. Document all excluded rows. State all assumptions.` |
| Asking for insight without business context | Copilot runs generic EDA instead of answering the specific question you need — results are technically valid but not useful | Add the specific business question to the Inputs field: `Business question: which alert type has the highest fraud rate?` |
| Format specified too loosely | "Give me some code" produces a wall of undocumented code with no structure | Specify exactly: `Format: Python script with one comment per transformation + markdown table showing rows affected` |
| Not referencing the actual file | Copilot invents column names or makes up distributions | Always include `#transaction_alerts.csv` in the prompt — use the `#` file picker |
