# Hartwell Financial Services — Responsible Use Policy for AI-Assisted Data Analysis

**Version 2.1 | Effective: Q1 2025 | Owner: Data Governance Office**

---

## 1. Purpose and Scope

This policy governs the use of AI-assisted tools, including GitHub Copilot, in data analysis workflows at Hartwell Financial Services. It applies to all employees, contractors, and partners who use AI tools to interact with internal data assets, generate analytical code, or produce outputs derived from Hartwell data systems.

The purpose of this policy is to ensure that AI-assisted analysis is conducted in a manner consistent with Hartwell's data classification standards, applicable financial regulations, and internal security requirements. AI tools augment analyst judgment — they do not replace analyst accountability. Compliance with this policy is a condition of continued access to analytical tooling and data systems.

---

## 2. Approved Use Cases for GitHub Copilot in Data Analysis

The following uses of GitHub Copilot are approved for data analysis work at Hartwell Financial Services:

- Generating Python scripts for data profiling, cleaning, and transformation using approved libraries (pandas, matplotlib, seaborn, numpy)
- Creating visualizations of anonymized or synthetic datasets within a local VS Code environment
- Drafting markdown documentation for analysis decisions, data quality findings, and executive summaries
- Generating unit tests or validation assertions for data pipelines
- Interpreting statistical outputs and drafting plain-English explanations for non-technical stakeholders
- Reviewing generated code for logic errors, schema compliance, and data quality issues

---

## 3. Prohibited Actions

The following actions are prohibited when using AI tools for data analysis:

- **Sending raw transaction data, customer records, or account identifiers to external AI endpoints.** GitHub Copilot processes your prompt in context — do not paste row-level data containing account_masked values, transaction amounts linked to identifiable accounts, or any Restricted-tier data.
- **Including PII or PII-adjacent data in prompts without masking.** Even masked fields (such as account_masked) must be referenced by name and schema context only — not pasted as raw values.
- **Auto-deploying AI-generated code without human review.** All generated scripts must be read, understood, and validated against business rules before execution or deployment.
- **Using AI tools to generate insights from Restricted-tier data without prior approval from the Data Governance Office.** Restricted data requires a documented approval before any AI-assisted analysis begins.
- **Sharing AI-generated outputs externally without a compliance review.** Reports, charts, and summaries derived from Internal or higher-tier data must be reviewed before distribution outside Hartwell.
- **Using AI tools to circumvent data access controls** — including generating code that reads from data sources your role does not have approved access to.
- **Accepting AI output as fact without validation.** AI tools can produce plausible but incorrect statistics, fabricated column names, and logic errors that violate business rules. Validation is the analyst's responsibility.
- **Hard-coding credentials, account numbers, or API keys in generated scripts**, regardless of whether those values appear synthetic.

---

## 4. Data Classification Tiers

| Tier | Description | Examples | AI Analysis Allowed? |
|---|---|---|---|
| **Public** | Freely shareable outside Hartwell | Published reports, press releases, marketing materials | Yes |
| **Internal** | For Hartwell use only — not for external distribution | Operational metrics, anonymized aggregates, synthetic training data | Yes, with activity logging |
| **Confidential** | Sensitive business data requiring restricted handling | Customer transaction records, financial risk models, masked account identifiers | Yes, with manager approval and documented justification |
| **Restricted** | Highest sensitivity — requires formal review before any processing | Unmasked PII, full account numbers, fraud investigation case files, regulatory submissions | No — requires Data Governance Office review before AI-assisted analysis |

The `transaction_alerts.csv` dataset used in this training lab is classified as **Internal (Synthetic)**. It may be analyzed using approved AI tools without additional approval. However, the handling requirements for `account_masked` follow Confidential-tier protocols as a training exercise in appropriate caution.

---

## 5. Analyst Accountability

**You are responsible for reviewing all AI-generated code before execution.** The fact that Copilot generated a script does not transfer liability for its correctness, compliance, or safety. If a script drops data without justification, exposes a sensitive column, or produces misleading output, the analyst who ran it is accountable.

**You must document your assumptions and validation steps.** When Copilot makes an assumption about the data — an imputation method, a date format, an outlier threshold — that assumption must be reviewed and explicitly documented in your output artifacts. Undocumented assumptions are policy violations in regulated analytical environments.

**You cannot claim AI error as a defense for policy violations.** "Copilot generated it" does not satisfy compliance requirements. If a generated output would fail an internal review, it must be corrected before use — regardless of its source.

---

## 6. Incident Reporting

If you believe you have sent sensitive data to an AI system in violation of this policy, or if an AI-generated output contains identifiable information that should not have been included, you must report the incident within **24 hours** to:

**Data Governance Office:** datagovernance@hartwellfinancial.com *(fictional — for training purposes only)*

Include in your report: the tool used, the nature of the data involved, the approximate time of the incident, and any outputs generated. Do not attempt to delete evidence of the incident before reporting.

---

## 7. Questions

For questions about this policy or requests for Restricted-tier analysis approval, contact the Data Governance Office at the address above or through the internal governance portal.

---

## 8. Copilot IDE Data Governance — What Gets Sent and What Doesn't

Understanding what GitHub Copilot transmits is a prerequisite for responsible use. This section answers the most common employee questions about data exposure in the IDE.

### What GitHub Copilot sends to servers

When you use Copilot Chat in VS Code, the following is sent to GitHub's servers for each request:

| What | Sent? | Notes |
|------|-------|-------|
| Your typed prompt | Yes | Always |
| Files you attach with `#filename` | Yes | The full file content is included in the prompt context |
| Your open editor tab (sometimes) | Yes | Copilot may include the currently active file as context |
| Your entire repository | No | Copilot does not scan or upload your full repo |
| Files not referenced in the prompt | No | Only explicitly referenced files are sent |
| Your terminal output | No | Unless you paste it into the chat |

**Key rule:** Copilot sees what you put in front of it. If you attach `#transaction_alerts.csv`, all 500 rows are sent. If you attach `#schema.md`, only the schema is sent. Reference schema and column names — not raw data rows — whenever possible.

### Dos and Don'ts in the IDE

| Do | Don't |
|----|-------|
| Reference files by name using `#filename` syntax | Paste raw CSV rows or transaction values into the prompt |
| Use schema context (`#schema.md`) instead of raw data | Attach files containing Restricted-tier data (unmasked PII, full account numbers) |
| Work in a local VS Code environment on approved hardware | Use personal GitHub accounts for enterprise data work |
| Use enterprise-configured Copilot (signed in with your work account) | Use Copilot on a personal laptop outside corporate security controls |
| Keep outputs in the local `outputs/` folder | Upload AI-generated outputs to external services without compliance review |
| Report accidental data exposure within 24 hours | Attempt to delete evidence of a policy violation before reporting |

### Verifying your Copilot configuration

Before starting any data analysis session, confirm:

1. **You are signed into VS Code with your enterprise account** — check the bottom-left corner of VS Code. It should show your work email, not a personal account.
2. **Copilot is enterprise-managed** — your organization's IT policy determines content exclusions and data residency settings. If you are unsure whether your Copilot instance is enterprise-configured, ask your IT administrator before proceeding.
3. **Content exclusions are active** — enterprise Copilot can be configured to prevent specific files or directories from being sent as context. Confirm with IT that production data paths are excluded if you work near production systems.

### What this means for this lab

The `transaction_alerts.csv` dataset is **synthetic** — no real customers, no real transactions. However, the lab is intentionally designed to treat it as if it were real Confidential-tier data, so participants practice the correct habits. The governance rules above apply throughout all lab stages regardless of dataset sensitivity.

---

*This is a fictional policy document created for training purposes. It does not represent the actual policies of Fidelity Investments, Hartwell Financial Services (a fictional entity), or any real financial institution.*
