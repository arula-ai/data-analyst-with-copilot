# Schema: treasury_payments.xlsx

**Use Case:** Operational Anomaly Detection & Trend Analysis — Treasury Payment Monitoring
**Rows:** 500 | **Columns:** 14
**Source:** Synthetic Treasury payment records from a fictional institutional asset manager
**Company:** Meridian Asset Management (fictional)
**Format:** Excel (.xlsx) — load with `pd.read_excel('data/treasury_payments.xlsx')` (requires `openpyxl`)

---

## Business Context

Meridian Asset Management is a fictional institutional asset manager. The Treasury Operations team monitors large-value payment flows to detect anomalies — payments that deviate from established patterns in amount, timing, counterparty behavior, or risk scoring. This dataset contains one row per flagged payment and covers Q4 2024 (October–December).

Anomaly detection is defined as: a payment flagged by the monitoring system and reviewed by a Treasury analyst within 5 business days of the payment date.

---

## Column Reference

| # | Column | Type | Valid Range / Values | Nullable | Business Description |
|---|--------|------|---------------------|----------|----------------------|
| 1 | `payment_id` | string | PAY-XXXXXXXX (8-digit suffix) | No | Unique identifier for each flagged payment |
| 2 | `counterparty_masked` | string | Pattern: `c***@domain.tld` | No | Masked counterparty identifier. PII-adjacent — do not include in any output or visualization. |
| 3 | `region` | string | Northeast, Southeast, Midwest, West, International | No | Geographic region where the payment originated |
| 4 | `payment_type` | string | Wire Transfer, ACH Batch, SWIFT, Internal Transfer, FX Settlement | No | Classification of the payment instrument |
| 5 | `payment_amount` | float | $500.00–$5,000,000.00 | Yes | Dollar value of the flagged payment |
| 6 | `prior_alerts_90d` | integer | 0–20 | No | Count of prior alerts for the same counterparty in the 90 days preceding this payment |
| 7 | `days_since_last_payment` | integer | 1–180 | Yes | Days since the counterparty's last completed payment before this alert |
| 8 | `risk_score` | float | 0.0–1.0 | No | Normalized risk signal score (0.0 = no signal, 1.0 = maximum risk) |
| 9 | `analyst_confidence` | integer | 0–10 | No | Analyst's self-rated confidence that the payment is a genuine anomaly (0–10). -1 is a legacy code meaning "not rated". |
| 10 | `anomaly_confirmed` | integer | 0 or 1 | No | Final disposition: 0 = not confirmed anomaly, 1 = confirmed anomaly |
| 11 | `analyst_id` | string | ANL-XXX (3-digit suffix) | No | Identifier of the analyst who reviewed the payment |
| 12 | `review_status` | string | Complete, Pending, Escalated | No | Whether the review workflow was completed |
| 13 | `payment_date` | string | YYYY-MM-DD | No | Date the payment was flagged for review |
| 14 | `client_segment` | string | Pension Fund, Sovereign Wealth, Family Office, Endowment | No | Client segment classification of the counterparty |

---

## Known Data Quality Issues (11 total)

> **Note:** The following issues are intentional and embedded for training purposes. Participants are expected to discover these during profiling and address them during cleaning.

| Issue # | Column | Description | Count | Expected Discovery Method |
|---------|--------|-------------|-------|--------------------------|
| 1 | `payment_id` | Duplicate IDs — same payment_id appears more than once | 12 | `df.duplicated(subset=['payment_id']).sum()` |
| 2 | `payment_type` | Value "TRF" used instead of "Wire Transfer" — encoding inconsistency | 23 | `df['payment_type'].value_counts()` |
| 3 | `payment_amount` | Negative values — invalid for a payment amount | 8 | `df[pd.to_numeric(df['payment_amount'], errors='coerce') < 0]` |
| 4 | `payment_amount` | Null/missing values | 15 | `df['payment_amount'].isnull().sum()` |
| 5 | `prior_alerts_90d` | Sentinel value 999 — system error coded as integer | 6 | `df[df['prior_alerts_90d'] > 20]` |
| 6 | `days_since_last_payment` | Null/missing values | 34 | `df['days_since_last_payment'].isnull().sum()` |
| 7 | `risk_score` | Values > 1.0 — outside valid normalized range | 11 | `df[df['risk_score'] > 1.0]` |
| 8 | `analyst_confidence` | Value -1 — legacy code for "not rated"; not valid on 0–10 scale | 19 | `df['analyst_confidence'].value_counts()` |
| 9 | `anomaly_confirmed` | Value 2 — invalid for a binary flag | 4 | `df['anomaly_confirmed'].value_counts()` |
| 10 | `review_status` | Blank entries — appear as NaN in pandas with default read | 7 | `df['review_status'].isnull().sum()` |
| 11 | `payment_date` | Five rows use MM/DD/YYYY format instead of YYYY-MM-DD | 5 | Visual inspection or `pd.to_datetime()` parse errors |

---

## Privacy and Handling Notes

- **`counterparty_masked`** is a masked representation of a counterparty identifier. It is not directly identifiable but must be treated as PII-adjacent.
- **Do not include `counterparty_masked` in any visualization, chart, or exported output.**
- **Do not paste rows containing `counterparty_masked` into any AI prompt interface.**
- This is fully synthetic data generated for training purposes only.
- Treat this dataset as Internal tier under Meridian's data classification policy.

---

## Business Rules

| Rule | Definition |
|------|-----------|
| `anomaly_confirmed` | 0 = not confirmed anomaly, 1 = confirmed anomaly. No other values are valid. |
| `analyst_confidence` | Scale 0–10. 9–10 = high confidence, 5–8 = moderate, 0–4 = low. -1 is an invalid legacy code — exclude from all calculations. |
| `risk_score` | 0.0 = no detectable risk signal, 1.0 = maximum risk signal. Values above 1.0 are data entry errors. |
| `prior_alerts_90d` | Valid range is 0–20. Values of 999 are sentinel errors — do not include in statistical summaries. |
| `payment_amount` | Must be > 0. Negative values indicate a data entry or system error. |
| `review_status` | Valid values are Complete, Pending, Escalated only. Blank entries are invalid. |
