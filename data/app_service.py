# app_service.py
# Fictional microservices platform — Orion Payments Inc.
# Source: Synthetic code artifact for training purposes only.
#
# This file contains intentional defects embedded for RCA lab exercises.
# Participants: Review this code alongside rca_app_logs.csv to hypothesize
# root causes for the error patterns you discover during log analysis.

import time
import random
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DB_POOL_SIZE = 3  # BUG: pool size too small for concurrent transaction load


class PaymentGateway:
    """Processes payment transactions. Calls AuthService and TransactionProcessor."""

    def __init__(self):
        self.timeout_ms = 5000
        self.retry_limit = 0  # BUG: retries disabled — any transient failure becomes a hard failure

    def process_payment(self, transaction_id, amount):
        logger.info(f"Processing payment {transaction_id} amount={amount}")
        try:
            auth_result = AuthService().authenticate(transaction_id)
            if not auth_result:
                raise ValueError("Auth failed")
            result = TransactionProcessor().submit(transaction_id, amount)
            return result
        except Exception as e:
            logger.error(f"Payment failed for {transaction_id}: {e}")
            # BUG: exception swallowed — error_code not set, upstream caller gets None
            return None


class AuthService:
    """Authenticates requests before payment processing."""

    SESSION_TTL = 30  # seconds — BUG: TTL too short, sessions expire under normal load

    def authenticate(self, request_id):
        # Simulates session lookup
        session_valid = self._lookup_session(request_id)
        if not session_valid:
            logger.error(f"ERR_001 Session expired or not found for request {request_id}")
            raise ConnectionError("ERR_001: Session not found")
        return True

    def _lookup_session(self, request_id):
        # BUG: no caching — every request hits the session store directly
        time.sleep(random.uniform(0.01, 0.15))  # simulates latency spike under load
        return random.random() > 0.15  # 15% failure rate under normal conditions


class TransactionProcessor:
    """Submits validated transactions to the settlement backend."""

    def submit(self, transaction_id, amount):
        conn = self._get_db_connection()
        if conn is None:
            # BUG: no fallback queue — transaction lost if DB pool exhausted
            logger.error(f"ERR_DB_001 DB connection pool exhausted for {transaction_id}")
            raise RuntimeError("ERR_DB_001: No available DB connections")
        try:
            # Simulates DB write
            time.sleep(random.uniform(0.05, 2.5))  # BUG: no query timeout set
            return {"status": "submitted", "transaction_id": transaction_id}
        finally:
            self._release_connection(conn)

    def _get_db_connection(self):
        # BUG: pool_size=3 means more than 3 concurrent transactions exhaust the pool
        if random.random() > (1 / DB_POOL_SIZE):
            return None
        return object()  # placeholder connection

    def _release_connection(self, conn):
        pass


class NotificationService:
    """Sends payment confirmation notifications."""

    def notify(self, user_id, message):
        # BUG: no retry logic — notification silently dropped if downstream is unavailable
        try:
            self._send(user_id, message)
        except Exception:
            pass  # BUG: silent swallow — no log, no dead-letter queue

    def _send(self, user_id, message):
        if random.random() > 0.9:
            raise TimeoutError("Notification service unavailable")
        logger.info(f"Notification sent to {user_id}")


class UserAPI:
    """Handles user profile and account lookups."""

    def get_user(self, user_id):
        # BUG: no input validation — invalid user_id reaches DB layer
        return {"user_id": user_id, "status": "active"}
