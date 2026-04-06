# Verify Before You Send — Data Privacy Checklist

**Read this before Stage 0. Apply at every phase.**

This checklist exists because errors in financial data analysis — including AI-assisted analysis — can expose sensitive information, produce misleading outputs, or violate internal policy. None of these checklist items are optional.

---

## Section 0: Is Your Copilot Configured Correctly?

Complete this once at the start of the lab. If any item fails, stop and resolve it before opening any data.

- [ ] VS Code shows your **enterprise/work account** in the bottom-left corner — not a personal GitHub account
- [ ] Copilot Chat opens with `Ctrl+Shift+I` and responds to a test message
- [ ] You are working on **approved corporate hardware** — not a personal laptop outside IT management
- [ ] You are **not** in a shared cloud environment, public Codespace, or any environment outside your local VS Code install
- [ ] **RED FLAG:** Are you unsure whether your Copilot instance is enterprise-managed or personal? If YES → ask your IT administrator before proceeding. Personal Copilot accounts have different data handling rules than enterprise accounts.

> **Why this matters:** When you use `#filename` to attach a file in Copilot Chat, the full file content is sent to GitHub's servers as part of your prompt. Enterprise accounts have organization-managed data residency and content exclusion policies. Personal accounts do not. Using the wrong account is a policy violation.

**Do not attach files from outside this repository.** All data used in this lab lives in `data/`. Do not attach files from network drives, SharePoint, OneDrive, or any external system. If you need to analyze real data, get compliance approval first and use a separate sanitized copy in an approved environment.

---

## Section 1: Before You Open the Dataset

Answer these questions before loading your scenario dataset:

- [ ] Have I read `reference/responsible_use.md`? *(Required — do not skip)*
- [ ] Do I know which data classification tier this dataset is? *(Answer: Internal — see the schema file for your scenario)*
- [ ] Am I working in a local VS Code environment, not a shared cloud environment or a publicly accessible endpoint?
- [ ] **RED FLAG:** Does this dataset contain unmasked personal identifiers — real names, unmasked account numbers, phone numbers, or social security numbers? If YES → stop, consult your facilitator before proceeding.
- [ ] **RED FLAG:** Are you connected to a corporate network with data loss prevention (DLP) policies that might flag CSV or Excel file activity? If YES → confirm with IT or your facilitator before proceeding.

**Your scenario's dataset, schema, and PII-adjacent fields:**

| Scenario | Dataset | Schema | PII-Adjacent Field |
|---|---|---|---|
| A — Treasury | `data/treasury_payments.xlsx` | `data/treasury_schema.md` | `counterparty_masked` |
| B — RCA | `data/rca_app_logs.csv` | `data/rca_schema.md` | `user_id_masked` |
| C — Modernization | `data/mainframe_usage.xlsx` | `data/mainframe_schema.md` | *(none)* |

---

## Section 2: Before You Send a Prompt to Copilot

Answer these questions every time you are about to send a prompt:

- [ ] Does my prompt reference only files in this repo? *(No external URLs, no pasted data from outside the lab)*
- [ ] Have I excluded PII-adjacent fields from any output format request?
  - Scenario A: exclude `counterparty_masked` from all outputs, charts, and print statements
  - Scenario B: exclude `user_id_masked` from all outputs, charts, and print statements
- [ ] Am I sending schema context and column names — not raw row-level data — in my prompt whenever possible?
- [ ] **RED FLAG:** Does my prompt include actual row data containing PII-adjacent values (`counterparty_masked` or `user_id_masked`)? If YES → remove those rows from the prompt before sending. Reference the file with `#filename` instead of pasting content.

---

## Section 3: After Copilot Responds — Before You Execute

Answer these questions before running any generated code:

- [ ] Did I read the generated code, not just skim it? *(If you can't explain what line 12 does, you haven't read it)*
- [ ] Does the code include any requests to external URLs, APIs, or packages not in the approved list? *(Approved: pandas, plotly, numpy, openpyxl — nothing else unless explicitly approved by the facilitator)*
- [ ] Does the code modify or overwrite the original dataset file without first saving a backup copy?
- [ ] Does any output file, chart, or printed DataFrame include PII-adjacent field values (`counterparty_masked` or `user_id_masked`)?
- [ ] Does the code logic make sense given the business rules in the scenario's schema file? *(e.g., is it treating sentinel values correctly? Is it excluding 999, -1, or 9999 from calculations?)*

---

> **If you answer YES to any RED FLAG item, stop. Do not proceed. Raise the issue with your facilitator.**
>
> **If you are unsure about any item: ask. Uncertainty is not a reason to proceed.**

---

*This checklist applies to all generated code, all prompts, and all output artifacts. Complete it at the start of the lab and revisit Sections 2 and 3 before each phase.*
