-- ============================================================
--  ACCOUNT TABLE (OLTP)
--  Represents financial accounts owned by customers.
--
--  Includes:
--    - Deposit accounts (Savings, Current, Salary, NRE/NRO, FD/RD)
--    - Loan accounts (Home Loan, Auto Loan, Personal Loan, etc.)
--    - Credit Card accounts
--    - Overdraft accounts
--
--  Business Rule:
--    A customer CANNOT have more than ONE ACTIVE account of the
--    same account_type_code (e.g., only one active Savings account).
--
--    This is enforced via a partial UNIQUE INDEX.
-- ============================================================

CREATE TABLE IF NOT EXISTS account (
    account_id          SERIAL PRIMARY KEY,
    -- NOTE:
    --   Postgres automatically creates a UNIQUE index on account_id
    --   because it is the PRIMARY KEY.

    account_number      VARCHAR(30) NOT NULL UNIQUE,
    -- Core banking account number (must be globally unique)

    customer_id         INT NOT NULL REFERENCES customer(customer_id),
    branch_id           INT NOT NULL REFERENCES branch(branch_id),

    account_type_code   VARCHAR(30) NOT NULL
                        REFERENCES account_type_master(account_type_code),

    currency            VARCHAR(3) NOT NULL DEFAULT 'INR',

    status              VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    -- Suggested values:
    --   'ACTIVE'
    --   'DORMANT'
    --   'CLOSED'
    --   'BLOCKED'

    open_date           DATE NOT NULL,
    close_date          DATE,

    current_balance     NUMERIC(18,2) NOT NULL DEFAULT 0.00,
    -- For DEPOSIT accounts: ledger balance
    -- For LOAN / CREDIT_CARD: outstanding principal or dues

    credit_limit        NUMERIC(18,2),
    -- For CREDIT_CARD, OVERDRAFT

    overdraft_limit     NUMERIC(18,2),
    -- For Current + OD accounts (optional)

    -- Audit fields
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Business Rule: Only one ACTIVE account per (customer_id, account_type_code)
-- Enforced using a partial UNIQUE INDEX.
--
-- Allows multiple accounts over time, as long as only one is ACTIVE:
--   - CLOSED accounts DO NOT violate the rule.
--   - ACTIVE + CLOSED is allowed.
--   - ACTIVE + ACTIVE is NOT allowed.
-- ============================================================

CREATE UNIQUE INDEX IF NOT EXISTS ux_account_customer_type_active
    ON account (customer_id, account_type_code)
    WHERE status <> 'CLOSED';

-- ============================================================
-- Recommended Indexes
-- ============================================================

-- List all accounts for a customer efficiently
CREATE INDEX IF NOT EXISTS idx_account_customer
    ON account (customer_id);

-- Lookup accounts by branch
CREATE INDEX IF NOT EXISTS idx_account_branch
    ON account (branch_id);

-- Filter by account type (useful for dashboards)
CREATE INDEX IF NOT EXISTS idx_account_type
    ON account (account_type_code);

-- Filter by status (ACTIVE/DORMANT/CLOSED)
CREATE INDEX IF NOT EXISTS idx_account_status
    ON account (status);
