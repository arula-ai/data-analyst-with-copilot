# legacy_mainframe.py
# Fictional mainframe feature module — Centrix Financial Systems
# Source: Synthetic code artifact for training purposes only.
#
# This file represents a legacy mainframe feature implementation.
# Participants: Review this code alongside mainframe_usage.xlsx to understand
# which features are still running on this legacy module vs. modernized services.
#
# Features implemented here map to the feature_name column in mainframe_usage.xlsx.
# Legacy flag = True in the dataset means the feature still runs through this module.

import datetime


# ─── GLOBAL CONSTANTS ────────────────────────────────────────────────────────
# BUG: hardcoded business rules — no config file, changes require code redeploy
MAX_WIRE_AMOUNT = 999999.99
BATCH_SIZE = 50  # BUG: fixed batch size, not configurable per environment
SETTLEMENT_CUTOFF_HOUR = 15  # 3:00 PM EST — hardcoded, not timezone-aware


# ─── WIRE TRANSFER PROCESSING ────────────────────────────────────────────────
def process_wire_transfer(account_id, amount, destination):
    """Legacy wire transfer processing. High usage — modernization priority: High."""
    # BUG: no input validation on account_id format
    if amount > MAX_WIRE_AMOUNT:
        # BUG: hard rejection with no logging — operations team cannot audit refusals
        return {"status": "rejected", "reason": "exceeds_limit"}

    record = _write_to_ledger("WIRE", account_id, amount, destination)
    # BUG: no idempotency key — duplicate submissions create duplicate records
    return {"status": "accepted", "ledger_ref": record}


# ─── BATCH ACH PROCESSING ────────────────────────────────────────────────────
def process_ach_batch(transactions):
    """Processes ACH batch payments. High usage — modernization priority: High."""
    results = []
    for i in range(0, len(transactions), BATCH_SIZE):
        chunk = transactions[i:i + BATCH_SIZE]
        for txn in chunk:
            # BUG: each transaction opens/closes its own DB write — no batch commit
            result = _write_to_ledger("ACH", txn["account_id"], txn["amount"], txn["destination"])
            results.append(result)
    return results


# ─── ACCOUNT BALANCE INQUIRY ─────────────────────────────────────────────────
def get_account_balance(account_id):
    """Real-time balance lookup. High usage — modernization priority: Medium."""
    # BUG: no caching — every call is a full ledger scan
    ledger_entries = _scan_ledger(account_id)
    balance = sum(e["amount"] for e in ledger_entries if e["type"] == "credit")
    balance -= sum(e["amount"] for e in ledger_entries if e["type"] == "debit")
    return {"account_id": account_id, "balance": balance}


# ─── FX RATE LOOKUP ──────────────────────────────────────────────────────────
def get_fx_rate(currency_pair):
    """Returns FX rate for a currency pair. Medium usage — modernization priority: Low."""
    # BUG: rates hardcoded — not pulled from live feed, stale after system restart
    RATES = {
        "USD/EUR": 0.92,
        "USD/GBP": 0.79,
        "USD/JPY": 149.5,
    }
    return RATES.get(currency_pair, None)  # BUG: returns None with no error for unknown pairs


# ─── STATEMENT GENERATION ────────────────────────────────────────────────────
def generate_statement(account_id, start_date, end_date):
    """Generates account statement for a date range. Low usage — modernization priority: Low."""
    entries = _scan_ledger(account_id)
    # BUG: date filtering done in Python, not at the data layer — loads full ledger into memory
    filtered = [e for e in entries if start_date <= e["date"] <= end_date]
    return {"account_id": account_id, "entries": filtered, "generated_at": datetime.datetime.now().isoformat()}


# ─── SETTLEMENT CUTOFF CHECK ─────────────────────────────────────────────────
def is_within_settlement_window():
    """Returns True if current time is within same-day settlement window."""
    # BUG: uses local system time — behavior is environment-dependent
    now = datetime.datetime.now()
    return now.hour < SETTLEMENT_CUTOFF_HOUR


# ─── INTERNAL HELPERS ────────────────────────────────────────────────────────
def _write_to_ledger(txn_type, account_id, amount, destination):
    """Stub: writes a ledger record. In production this would be a DB write."""
    return f"REF-{txn_type}-{account_id}-{int(amount)}"


def _scan_ledger(account_id):
    """Stub: returns all ledger entries for an account. In production: full table scan."""
    # BUG: no pagination, no index — performance degrades linearly with ledger size
    return []
