-- ============================================================
--  ACCOUNT_TRANSACTION TABLE (OLTP)
--  Stores posted ledger transactions for each financial account.
--
--  Supports:
--    - UPI / IMPS / NEFT / RTGS payments
--    - ATM / POS / Card transactions
--    - Loan EMI debits
--    - Internal bank transfers
--    - Reversals, cancellations, failures
--
--  Includes:
--    - Transaction value & timestamp
--    - DEBIT / CREDIT indicator
--    - Channels and instrument info
--    - Optional running balance
--    - Status lifecycle (PENDING, POSTED, FAILED, REVERSED, CANCELLED)
--    - Status reason codes/messages (txn_status_reason)
-- ============================================================

CREATE TABLE IF NOT EXISTS account_transaction (
    txn_id               BIGSERIAL PRIMARY KEY,
    -- NOTE:
    --   Postgres automatically creates a UNIQUE index on txn_id
    --   because it is the PRIMARY KEY.

    -- Reference to account
    account_id           INT NOT NULL REFERENCES account(account_id),

    -- Timing
    txn_timestamp        TIMESTAMP NOT NULL,
    -- When the transaction entered the ledger / CBS.

    value_date           DATE NOT NULL,
    -- Date affecting interest/charges.

    -- Financial direction
    txn_type             VARCHAR(10) NOT NULL,
    --   'DEBIT'  -> Money out
    --   'CREDIT' -> Money in

    amount               NUMERIC(18,2) NOT NULL,
    currency             VARCHAR(3) NOT NULL DEFAULT 'INR',

    -- Running balance after this transaction (optional)
    balance_after_txn    NUMERIC(18,2),

    -- User-visible text
    description          VARCHAR(255),
    narration            VARCHAR(255),

    -- Merchant info (for UPI, POS, eCom)
    merchant_name        VARCHAR(100),
    merchant_category    VARCHAR(4),
    -- Example MCC: 5411 = Grocery; 5812 = Restaurants

    -- Channel information
    channel              VARCHAR(20),
    -- E.g. 'UPI', 'IMPS', 'NEFT', 'RTGS', 'ATM', 'POS', 'NETBANKING', 'BRANCH'

    instrument_type      VARCHAR(20),
    -- E.g. 'UPI_ID', 'CARD', 'CHEQUE', 'ACCOUNT_TRANSFER'

    instrument_reference VARCHAR(100),
    -- E.g. UTR, cheque no., masked card number, ATM reference

    rrn                  VARCHAR(50),
    -- Retrieval Reference Number (POS/ATM/UPI)

    -- Transaction state
    txn_status           VARCHAR(20) NOT NULL DEFAULT 'POSTED',
    -- Possible values:
    --   'PENDING'    -> Initiated but not finalized
    --   'POSTED'     -> Final, reflected in balance
    --   'FAILED'     -> Could not complete; no posting
    --   'REVERSED'   -> Posted earlier but reversed
    --   'CANCELLED'  -> Cancelled before posting; no money movement

    txn_status_reason    VARCHAR(255),
    -- Why transaction failed/cancelled/reversed.
    -- Examples:
    --   'ISSUER_BANK_NOT_AVAILABLE'
    --   'INSUFFICIENT_FUNDS'
    --   'UPI_TIMEOUT'
    --   'CUSTOMER_CANCELLED'
    --   'CASH_NOT_DISPENSED'
    --   'CHEQUE_RETURNED - INSUFFICIENT FUNDS'
    --   'REVERSAL_PROCESSED'

    -- Relation to another transaction (reversal, chargeback, correction)
    related_txn_id       BIGINT REFERENCES account_transaction(txn_id),

    -- Audit
    created_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Recommended Indexes
-- ============================================================

-- Main access pattern: fetch transactions for an account over time
CREATE INDEX IF NOT EXISTS idx_txn_account_ts
    ON account_transaction (account_id, txn_timestamp DESC);

-- Value-date-based searches (statements, interest calc)
CREATE INDEX IF NOT EXISTS idx_txn_account_valuedate
    ON account_transaction (account_id, value_date);

-- Operational analytics by channel and status
CREATE INDEX IF NOT EXISTS idx_txn_channel_status
    ON account_transaction (channel, txn_status);

-- Lookups by reason (disputes, failures, audits)
CREATE INDEX IF NOT EXISTS idx_txn_reason
    ON account_transaction (txn_status_reason);
