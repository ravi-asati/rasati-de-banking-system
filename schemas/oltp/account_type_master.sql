-- ============================================================
--  ACCOUNT_TYPE_MASTER TABLE (OLTP)
--  Reference/master table for all retail banking product types.
--
--  Examples include:
--    - Deposits: SAVINGS, SALARY_SAVINGS, CURRENT, NRE_SAVINGS, NRO_SAVINGS, FD, RD
--    - Loans: HOME_LOAN, AUTO_LOAN, PERSONAL_LOAN, EDUCATION_LOAN, GOLD_LOAN, LAP
--    - Cards / OD: CREDIT_CARD, OVERDRAFT
--    - Investments: PPF, etc.
--
--  The account table will reference this via account_type_code.
-- ============================================================

CREATE TABLE IF NOT EXISTS account_type_master (
    account_type_code   VARCHAR(30) PRIMARY KEY,
    -- NOTE:
    --   Postgres automatically creates a UNIQUE index on account_type_code
    --   because it is the PRIMARY KEY.

    category            VARCHAR(20) NOT NULL,
    -- High-level classification, e.g.:
    --   'DEPOSIT'
    --   'LOAN'
    --   'CREDIT_CARD'
    --   'OVERDRAFT'
    --   'INVESTMENT'

    type_name           VARCHAR(100) NOT NULL,
    -- Human-readable name of the product, e.g.:
    --   'Savings Account'
    --   'Home Loan'
    --   'Credit Card Account'

    description         VARCHAR(255),
    -- Optional longer description of the product.

    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    -- Indicates if the product type is currently offered.

    -- Audit fields
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Recommended Indexes
-- ============================================================

-- Group/filter account types by category (for reporting / UI)
CREATE INDEX IF NOT EXISTS idx_accttype_category
    ON account_type_master (category);

-- Quickly find only currently active product types
CREATE INDEX IF NOT EXISTS idx_accttype_active
    ON account_type_master (is_active);
    

-- ============================================================
-- Optional: Seed Data (COMMENTED OUT)
-- Uncomment and adjust as needed to pre-populate product types.
-- ============================================================
/*
INSERT INTO account_type_master (account_type_code, category, type_name, description)
VALUES
    -- Deposits
    ('SAVINGS',        'DEPOSIT',    'Savings Account',                 'Standard savings account'),
    ('SALARY_SAVINGS', 'DEPOSIT',    'Salary Savings Account',          'Salary-linked savings account'),
    ('CURRENT',        'DEPOSIT',    'Current Account',                 'Business/current account'),
    ('NRE_SAVINGS',    'DEPOSIT',    'NRE Savings Account',             'Non-Resident External savings account'),
    ('NRO_SAVINGS',    'DEPOSIT',    'NRO Savings Account',             'Non-Resident Ordinary savings account'),
    ('FD',             'DEPOSIT',    'Fixed Deposit',                   'Term deposit / fixed deposit'),
    ('RD',             'DEPOSIT',    'Recurring Deposit',               'Recurring deposit account'),

    -- Loans
    ('HOME_LOAN',      'LOAN',       'Home Loan',                       'Housing loan'),
    ('AUTO_LOAN',      'LOAN',       'Auto Loan',                       'Car / vehicle loan'),
    ('PERSONAL_LOAN',  'LOAN',       'Personal Loan',                   'Unsecured personal loan'),
    ('EDUCATION_LOAN', 'LOAN',       'Education Loan',                  'Student / education loan'),
    ('GOLD_LOAN',      'LOAN',       'Gold Loan',                       'Loan against gold'),
    ('LAP',            'LOAN',       'Loan Against Property',           'Secured loan against property'),

    -- Cards / Overdraft / Others
    ('CREDIT_CARD',    'CREDIT_CARD','Credit Card Account',             'Credit card line of credit'),
    ('OVERDRAFT',      'OVERDRAFT',  'Overdraft Account',               'OD facility on account'),

    -- Investments
    ('PPF',            'INVESTMENT', 'Public Provident Fund Account',   'PPF account facilitated by bank');
*/
