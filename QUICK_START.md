# Quick Start — Copilot Chat for Data Analysis

**Get operational in under 5 minutes.**

---

## Step 0: Install Required VS Code Extensions

Open the Extensions panel (`Ctrl+Shift+X` / `Cmd+Shift+X`) and confirm these are installed:

| Extension | Why You Need It | Quick Install |
|-----------|----------------|---------------|
| **GitHub Copilot + Copilot Chat** | AI assistance for all lab phases | Required |
| **Python + Pylance** | Code execution and IntelliSense | Required |
| **Jupyter** | Notebook support | Recommended |

---

## Importing Data Not In Your Repo

If a stakeholder provides a data file outside this repo:

1. **Drag it** into the `data/` folder in VS Code's Explorer panel
2. **Reference it in your prompt:** `Profile #my_file.csv using pandas.`
3. **What Copilot sees:** Only files you explicitly attach with `#filename`. It does not scan your filesystem.

> **In this lab session:** All your data files are already in the `data/` folder — you do not need to import anything. This section applies if you receive a dataset from a stakeholder outside the lab environment.

> **Governance check first:** Before attaching any external file, classify it against `reference/responsible_use.md`. Confidential or Restricted data should NOT be attached to Copilot Chat.

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
Analyze #data/treasury_payments.xlsx for obvious data quality issues.
```

```
Using #data/treasury_schema.md, explain the business rules for the risk_score column.
```

```
Review #scripts/clean_treasury.py for any operations that could silently drop rows.
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

## Step 4: Verify Your Python Environment (Optional but Recommended)

Before testing Copilot, confirm all Python dependencies and lab files are in place:

```bash
python scripts/verify_setup.py
```

All checks should show `[PASS]`. If anything shows `[FAIL]`, fix it before starting.

---

## Step 5: Test Your Setup

Paste this prompt into Copilot Chat now (use the schema file for your scenario):

```
Using #[your-scenario-schema].md, list all columns in the dataset
and flag any that might require special handling from a data privacy perspective.
Explain your reasoning for each flag.
```

Replace `[your-scenario-schema]` with the schema for your assigned scenario:
- **Scenario A:** `#data/treasury_schema.md`
- **Scenario B:** `#data/rca_schema.md`
- **Scenario C:** `#data/mainframe_schema.md`

**A good response will:**
- List all columns from the dataset
- Flag any PII-adjacent fields (e.g., `counterparty_masked` in A, `user_id_masked` in B) and recommend excluding them from outputs
- Note operationally sensitive fields and recommend not including them in visualizations or external exports
- Show that Copilot has read and understood the schema context you provided

If you get this, your setup is working correctly.

---

## Step 6: If Copilot Gives an Unhelpful Response

Try these adjustments:

- **Add a Role:** `"You are a Data Profiling Analyst. [your original prompt]"`
- **Add Constraints:** `"Use pandas only. No external libraries. No API calls."`
- **Specify Format:** `"Return as a Python script with inline comments."`
- **Add Checks:** `"Include row count before and after. Document all assumptions."`
- **Narrow the scope:** `"Focus only on the payment_amount column for now."`
- **Reference the file explicitly:** Make sure you used `#data/treasury_payments.xlsx`, not just described the data

If Copilot still gives a low-quality response, consult `reference/PROMPT_PATTERN.md` for the full RIFCC-DA framework.

---

> **Warning:** Always review generated code before executing it. Copilot can produce plausible-looking code with logic errors, incorrect column references, or operations that silently remove data. Validate everything against the business rules in the scenario's schema file (e.g., `data/treasury_schema.md`, `data/rca_schema.md`, or `data/mainframe_schema.md`).

---

Setup complete. Open `LAB_ACTION_GUIDE.md` and begin with **Stage 0 — Scenario Setup** to start the lab.
