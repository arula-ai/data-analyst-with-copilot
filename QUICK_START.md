# Quick Start — Copilot Chat for Data Analysis

**Get operational in under 5 minutes.**

---

## Recommended VS Code Extensions

Install these before starting. They improve the data analysis experience directly in VS Code.

| Extension | What It Does | Install |
|-----------|-------------|---------|
| **Rainbow CSV** | Color-codes CSV columns so you can visually inspect `transaction_alerts.csv` without opening Python | Search "Rainbow CSV" in VS Code Extensions (`Ctrl+Shift+X`) |
| **Data Wrangler** | Opens CSV files as an interactive table — sort, filter, and profile data visually | Search "Data Wrangler" in VS Code Extensions |

**Rainbow CSV:** Open `data/transaction_alerts.csv` in VS Code — each column will be highlighted in a distinct color, making it easy to spot misaligned values and format issues at a glance.

**Data Wrangler:** Right-click `data/transaction_alerts.csv` → "Open in Data Wrangler" to get a visual column summary, null count, and distribution before writing a single line of code.

> These extensions do not send data to external servers. They operate entirely within your local VS Code environment.

---

## Step 1: Open Copilot Chat

- **Windows / Linux:** `Ctrl+Shift+I`
- **Mac:** `Cmd+Shift+I`
- Or click the Copilot icon in the VS Code sidebar (speech bubble icon)

The Copilot Chat panel opens on the right. You type prompts there and Copilot responds inline.

---

## Step 2: Reference a File in Your Prompt

Use `#filename` to attach a file to your prompt. Copilot reads its contents — you do not need to paste the data.

```
Analyze #transaction_alerts.csv for obvious data quality issues.
```

```
Using #schema.md, explain the business rules for the risk_score column.
```

```
Review #clean_alerts.py for any operations that could silently drop rows.
```

> **Note:** Type `#` and VS Code will show a file picker. Select the file from the dropdown, or type the filename to filter. Copilot reads the file content automatically.

---

## Step 3: Activate an Agent Mode

Agent modes constrain how Copilot responds. There are two ways to use them:

**Option A — Agent dropdown (if custom agents are configured):**
1. Open Copilot Chat
2. Click the agent dropdown at the top of the chat panel (shows "Ask" by default)
3. Select the mode for your current stage (e.g., "Data Profiling Analyst")
4. Type your prompt — the mode behavior is now active for the conversation

**Option B — Paste-in method (always works):**
1. Open `.github/agents/[agent-file].agent.md`
2. Copy the role definition and behavioral rules section
3. Paste it at the top of your Copilot Chat message before your actual prompt
4. Copilot will adopt that role for the response

---

## Step 4: Test Your Setup

Paste this prompt into Copilot Chat now:

```
Using #schema.md, list all columns in the transaction_alerts dataset and flag any that might require special handling from a data privacy perspective. Explain your reasoning for each flag.
```

**A good response will:**
- List all 15 columns
- Flag `account_masked` as PII-adjacent and recommend excluding it from outputs
- Note `fraud_confirmed` and `transaction_amount` as financially sensitive
- Recommend not including flagged columns in visualizations or external exports

If you get this, your setup is working correctly.

---

## Step 5: If Copilot Gives an Unhelpful Response

Try these adjustments:

- **Add a Role:** `"You are a Data Profiling Analyst. [your original prompt]"`
- **Add Constraints:** `"Use pandas only. No external libraries. No API calls."`
- **Specify Format:** `"Return as a Python script with inline comments."`
- **Add Checks:** `"Include row count before and after. Document all assumptions."`
- **Narrow the scope:** `"Focus only on the transaction_amount column for now."`
- **Reference the file explicitly:** Make sure you used `#transaction_alerts.csv`, not just described the data

If Copilot still gives a low-quality response, consult `reference/PROMPT_PATTERN.md` for the full RIFCC-DA framework.

---

> **Warning:** Always review generated code before executing it. Copilot can produce plausible-looking code with logic errors, incorrect column references, or operations that silently remove data. Validate everything against the business rules in `data/schema.md`.
