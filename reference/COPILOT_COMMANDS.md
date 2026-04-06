# Copilot Chat Commands — Quick Reference

---

## Section 1: File Attachment Syntax

Use `#filename` to reference a file in your Copilot Chat prompt. Copilot reads the file content automatically — you do not need to paste the data.

**Attaching a single file (Scenario A — Treasury):**
```
Analyze #data/treasury_payments.xlsx for data quality issues.
```

**Attaching multiple files:**
```
Using #data/treasury_payments.xlsx and #data/treasury_schema.md, generate a profiling script.
```

**Attaching a script for review:**
```
Review #scripts/clean_treasury.py for any operations that could expose counterparty_masked.
```

> **Note:** Type `#` in the Copilot Chat input and VS Code will open a file picker. Select the file or type to filter. Copilot reads the file content — do not paste raw rows into the prompt.

---

## Section 2: Agent Mode Activation

The lab uses **3 phases per scenario**, each with its own agent mode:
- **Phase 1 (Profile)** → "Data Profiling Analyst"
- **Phase 2 (Clean)** → "Data Cleaning Engineer"
- **Phase 3 (Visualize)** → "Visualization Architect"
- **Cross-phase support** → "Exploratory Data Analyst"

**Option A — Agent dropdown (if custom agents are configured):**
1. Open Copilot Chat (`Ctrl+Shift+I` / `Cmd+Shift+I`)
2. Click the agent dropdown at the top of the chat panel (shows "Ask" or "Claude" by default)
3. Select the mode for your current phase
4. Type your prompt — the mode behavior is active for this conversation

**Option B — Paste-in method (always works, no configuration required):**
1. Open `.github/agents/[agent-file].agent.md`
2. Copy the "Your Role" and "Behavioral Rules" sections
3. Paste at the top of your Copilot Chat message, before your actual prompt
4. Copilot will adopt that role for the response

---

## Section 3: Prompting Copilot for Exploratory Analysis (Phases 1–2)

> **Note:** The examples below use Scenario A (Treasury) column names. Scenario B participants substitute `service_name`, `log_level`, `error_code`, `response_time_ms`. Scenario C participants substitute `feature_name`, `usage_count`, `last_used_date`, `estimated_migration_effort_days`.

Use `pandas` (already installed via `requirements.txt`) to explore DataFrames directly. The lab works with pandas DataFrames, not SQLite.

**Setup pattern — always start with this:**
```
import pandas as pd
df = pd.read_excel('data/treasury_payments.xlsx')
df.info()
df.head()
```

> **Note:** The `#filename` syntax is for **Copilot Chat prompts only** — it is not a valid Python file path. In Python scripts, always use the actual relative path (e.g., `'data/treasury_payments.xlsx'`).

**Exploration queries:**
```
Write pandas to count rows grouped by region, ordered by count descending.
```

```
Write pandas to find the average risk_score per alert_type, excluding nulls.
```

```
Write pandas to list all rows where anomaly_confirmed = 1 and risk_score > 0.8,
ordered by transaction_amount descending.
```

**Profiling via Pandas:**
```
Write pandas to identify duplicate alert_id values and return their count.
```

```
Write pandas to find all rows where analyst_confidence < 0 (invalid sentinel value).
```

**Grouping & Aggregation:**
```
Write pandas to group by region and count unique payment_id values.
```

```
Write pandas to calculate max(transaction_amount) and mean(risk_score) by region.
```

> **Key approach:** Use pandas DataFrames directly. Chain methods for filtering, grouping, and aggregation. Use plotly.express (NOT matplotlib/seaborn) for visualizations.

---

## Section 4: Slash Commands

Type `/` in Copilot Chat to see all available slash commands. All 6 prompt files are in `.github/prompts/`.

| Slash Command | Agent Mode | What It Does |
|---|---|---|
| `/data-profiling-analyst` | Data Profiling Analyst | Generates profiling code and a numbered data quality issue log; outputs `[X]_profile.md` |
| `/data-cleaning-engineer` | Data Cleaning Engineer | Generates a cleaning script with inline justifications and before/after row counts; outputs `[X]_cleaning_decisions.md` |
| `/exploratory-data-analyst` | Exploratory Data Analyst | Generates hypothesis-driven EDA code with plain-English findings using pandas groupby and aggregation |
| `/visualization-architect` | Visualization Architect | Generates labeled, policy-compliant chart code using plotly.express; outputs `[X]_chart_*.html` |
| `/data-risk-reviewer` | Data Risk Reviewer | Classifies every column by sensitivity tier (Public/Internal/Confidential/Restricted); flags PII-adjacent fields with handling recommendations |
| `/responsible-use-auditor` | Responsible Use Auditor | Reviews all generated scripts and outputs for policy compliance; produces risk findings table and auditor sign-off |

**VS Code Extension Quick Commands:**

| Extension | Command | What It Does |
|-----------|---------|--------------|
| Jupyter | `Ctrl+Shift+P` → "Create New Jupyter Notebook" | New blank notebook for exploratory analysis |

---

## Section 5: Iteration Techniques

When Copilot gives an unhelpful, incomplete, or incorrect response:

**Add a Role:**
```
You are a Data Cleaning Engineer. Every transformation must have a written justification. [your original prompt]
```

**Add Constraints:**
```
Use pandas only. No external libraries. No API calls. Do not include counterparty_masked in any output.
```

**Specify Format:**
```
Return as a Python script with one inline comment per transformation explaining why.
```

**Add Checks:**
```
Print row count before and after. Include an assertion that anomaly_confirmed contains only 0 and 1.
```

**Narrow the scope:**
```
Focus only on the transaction_amount and risk_score columns. Ignore all other columns for now.
```

**Reference the actual schema:**
```
Use #treasury_schema.md to verify the valid range for risk_score before writing the assertion.
```

**Verify PII handling:**
```
Ensure that counterparty_masked is never written to CSV outputs — only use it for analysis.
```

---

## Section 6: Keyboard Shortcuts

| Action | Windows / Linux | Mac |
|---|---|---|
| Open Copilot Chat | `Ctrl+Shift+I` | `Cmd+Shift+I` |
| Accept inline suggestion | `Tab` | `Tab` |
| Dismiss inline suggestion | `Escape` | `Escape` |
| Cycle to next suggestion | `Alt+]` | `Option+]` |
| Cycle to previous suggestion | `Alt+[` | `Option+[` |
| Open Copilot inline chat | `Ctrl+I` | `Cmd+I` |
| New Copilot Chat session | Use the `+` icon in the chat panel | Same |
