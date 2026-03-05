# Verify Before You Send — Data Privacy Checklist

**Read this before Stage 0. Apply at every stage.**

This checklist exists because errors in financial data analysis — including AI-assisted analysis — can expose sensitive information, produce misleading outputs, or violate internal policy. None of these checklist items are optional.

---

## Section 0: Is Your Copilot Configured Correctly?

Complete this once at the start of the lab. If any item fails, stop and resolve it before opening any data.

- [ ] VS Code shows your **enterprise/work account** in the bottom-left corner — not a personal GitHub account
- [ ] Copilot Chat opens with `Ctrl+Shift+I` and responds to a test message
- [ ] You are working on **approved corporate hardware** — not a personal laptop outside IT management
- [ ] You are **not** in a shared cloud notebook, public Codespace, or any environment outside your local VS Code install
- [ ] **RED FLAG:** Are you unsure whether your Copilot instance is enterprise-managed or personal? If YES → ask your IT administrator before proceeding. Personal Copilot accounts have different data handling rules than enterprise accounts.

> **Why this matters:** When you use `#filename` to attach a file in Copilot Chat, the full file content is sent to GitHub's servers as part of your prompt. Enterprise accounts have organization-managed data residency and content exclusion policies. Personal accounts do not. Using the wrong account is a policy violation.

**Do not attach files from outside this repository.** All data used in this lab lives in `data/`. Do not attach files from network drives, SharePoint, OneDrive, or any external system. If you need to analyze real data, get compliance approval first and use a separate sanitized copy in an approved environment.

---

## Section 1: Before You Open the Dataset

Answer these questions before loading `transaction_alerts.csv`:

- [ ] Have I read `reference/responsible_use.md`? *(Required — do not skip)*
- [ ] Do I know which data classification tier this dataset is? *(Answer: Internal — see schema.md)*
- [ ] Am I working in a local VS Code environment, not a shared cloud notebook or a publicly accessible endpoint?
- [ ] **RED FLAG:** Does this dataset contain unmasked personal identifiers — real names, unmasked account numbers, phone numbers, or social security numbers? If YES → stop, consult your facilitator before proceeding.
- [ ] **RED FLAG:** Are you connected to a corporate network with data loss prevention (DLP) policies that might flag CSV file activity? If YES → confirm with IT or your facilitator before proceeding.

---

## Section 2: Before You Send a Prompt to Copilot

Answer these questions every time you are about to send a prompt:

- [ ] Does my prompt reference only files in this repo? *(No external URLs, no pasted data from outside the lab)*
- [ ] Have I excluded `account_masked` from any output format request? *(e.g., "do not include account_masked in the output" or "exclude PII-adjacent columns from charts")*
- [ ] Am I sending schema context and column names — not raw row-level data — in my prompt whenever possible?
- [ ] **RED FLAG:** Does my prompt include actual row data containing `account_masked` values? If YES → remove those rows from the prompt before sending. Reference the file with `#transaction_alerts.csv` instead of pasting content.

---

## Section 3: After Copilot Responds — Before You Execute

Answer these questions before running any generated code:

- [ ] Did I read the generated code, not just skim it? *(If you can't explain what line 12 does, you haven't read it)*
- [ ] Does the code include any requests to external URLs, APIs, or packages not in the approved list? *(Approved: pandas, matplotlib, seaborn, numpy — nothing else)*
- [ ] Does the code modify or overwrite `data/transaction_alerts.csv` without first saving a backup copy?
- [ ] Does any output file, chart, or printed DataFrame include `account_masked` values?
- [ ] Does the code logic make sense given the business rules in `data/schema.md`? *(e.g., is it treating -1 analyst_confidence correctly? Is it excluding 999 sentinel values from calculations?)*

---

> **If you answer YES to any RED FLAG item, stop. Do not proceed. Raise the issue with your facilitator.**
>
> **If you are unsure about any item: ask. Uncertainty is not a reason to proceed.**

---

*This checklist applies to all generated code, all prompts, and all output artifacts. Complete it at the start of the lab and revisit Sections 2 and 3 before each stage.*
