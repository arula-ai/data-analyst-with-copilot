# Copilot Chat Commands — Quick Reference

---

## Section 1: File Attachment Syntax

Use `#filename` to reference a file in your Copilot Chat prompt. Copilot reads the file content automatically — you do not need to paste the data.

**Attaching a single file:**
```
Analyze #transaction_alerts.csv for data quality issues.
```

**Attaching multiple files:**
```
Using #transaction_alerts.csv and #schema.md, generate a profiling script.
```

**Attaching a script for review:**
```
Review #clean_alerts.py for any operations that could expose account_masked.
```

> **Note:** Type `#` in the Copilot Chat input and VS Code will open a file picker. Select the file or type to filter. Copilot reads the file content — do not paste raw CSV rows into the prompt.

---

## Section 2: Agent Mode Activation

**Option A — Agent dropdown (if custom agents are configured):**
1. Open Copilot Chat (`Ctrl+Shift+I` / `Cmd+Shift+I`)
2. Click the agent dropdown at the top of the chat panel (shows "Ask" or "Claude" by default)
3. Select the mode for your current stage:
   - Stage 0 → "Data Risk & Policy Reviewer"
   - Stage 1 → "Data Profiling Analyst"
   - Stage 2 → "Data Cleaning Engineer"
   - Stage 3 → "Exploratory Data Analyst"
   - Stage 4 → "Visualization Architect"
   - Stage 5 → "Responsible Use Auditor"
4. Type your prompt — the mode behavior is active for this conversation

**Option B — Paste-in method (always works, no configuration required):**
1. Open `.github/agents/[agent-file].agent.md`
2. Copy the "Your Role" and "Behavioral Rules" sections
3. Paste at the top of your Copilot Chat message, before your actual prompt
4. Copilot will adopt that role for the response

---

## Section 3: Prompting Copilot for SQL (Stage 2B)

Use `sqlite3` from Python's standard library to run SQL against your CSV — no new installs needed.

**Setup pattern — always start with this:**
```
Load #transaction_alerts_clean.csv into an in-memory SQLite database using pandas and sqlite3.
Use conn = sqlite3.connect(':memory:') and df.to_sql('alerts', conn, index=False).
```

**Exploration queries:**
```
Write SQL to count rows grouped by alert_type, ordered by count descending.
```

```
Write SQL to find the average risk_score per region, excluding nulls.
```

```
Write SQL to list all fraud_confirmed = 1 alerts where risk_score > 0.8,
ordered by transaction_amount descending.
```

**Cleaning via SQL:**
```
Write SQL to identify duplicate alert_id values and return their count.
```

```
Write SQL to find all rows where analyst_confidence = -1 (invalid sentinel value).
```

> **Key difference from Python:** SQL is declarative — you describe WHAT you want, not HOW to get it. Use it for filtering, aggregation, and joins. Use Python/pandas for transformations, imputation, and visualization.

---

## Section 4: Suggested Slash Commands (if configured)

| Slash Command | Mode | What It Does |
|---|---|---|
| `/review-data-risk` | Data Risk & Policy Reviewer | Classifies all columns by sensitivity tier and produces handling recommendations |
| `/profile-data` | Data Profiling Analyst | Generates profiling code and a numbered data quality issue log |
| `/clean-data-safely` | Data Cleaning Engineer | Generates a cleaning script with inline justifications and before/after row counts |
| `/eda-hypotheses` | Exploratory Data Analyst | Generates hypothesis-driven EDA code with plain-English findings |
| `/make-visuals` | Visualization Architect | Generates labeled, policy-compliant chart code in Jupyter notebook format |
| `/audit-for-policy` | Responsible Use Auditor | Reviews referenced code and outputs for security and compliance issues |

---

## Section 5: Iteration Techniques

When Copilot gives an unhelpful, incomplete, or incorrect response:

**Add a Role:**
```
You are a Data Cleaning Engineer. Every transformation must have a written justification. [your original prompt]
```

**Add Constraints:**
```
Use pandas only. No external libraries. No API calls. Do not include account_masked in any output.
```

**Specify Format:**
```
Return as a Python script with one inline comment per transformation explaining why.
```

**Add Checks:**
```
Print row count before and after. Include an assertion that fraud_confirmed contains only 0 and 1.
```

**Narrow the scope:**
```
Focus only on the transaction_amount column. Ignore all other columns for now.
```

**Reference the actual file:**
```
Use #schema.md to verify the valid range for risk_score before writing the assertion.
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
