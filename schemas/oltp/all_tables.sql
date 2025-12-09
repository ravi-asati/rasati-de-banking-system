-- ===================================================================
--  OLTP TABLE CREATION SCRIPT (PostgreSQL)
--  Schema: bank_oltp
--  Contains:
--      1. customer
--      2. customer_address
--      3. customer_contact
--      4. branch
--      5. account_type_master
--      6. account
--      7. account_transaction
-- ===================================================================

SET search_path TO bank_oltp;

-- ============================================================
-- 1. CUSTOMER
-- ============================================================
CREATE TABLE IF NOT EXISTS customer (
    customer_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    middle_name     VARCHAR(50),
    last_name       VARCHAR(50) NOT NULL,
    date_of_birth   DATE NOT NULL,
    gender          VARCHAR(10),
    pan_number      VARCHAR(10),
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_customer_lastname ON customer(last_name);
CREATE INDEX IF NOT EXISTS idx_customer_pan ON customer(pan_number);
CREATE INDEX IF NOT EXISTS idx_customer_status ON customer(status);


-- ============================================================
-- 2. CUSTOMER_ADDRESS
-- ============================================================
CREATE TABLE IF NOT EXISTS customer_address (
    address_id       SERIAL PRIMARY KEY,
    customer_id      INT NOT NULL REFERENCES customer(customer_id),
    address_type     VARCHAR(20) NOT NULL,
    line1            VARCHAR(200) NOT NULL,
    line2            VARCHAR(200),
    landmark         VARCHAR(200),
    city             VARCHAR(50) NOT NULL,
    state            VARCHAR(50) NOT NULL,
    pincode          VARCHAR(6) NOT NULL,
    country          VARCHAR(50) NOT NULL DEFAULT 'India',
    is_primary       BOOLEAN NOT NULL DEFAULT FALSE,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_custaddr_customer ON customer_address(customer_id);
CREATE INDEX IF NOT EXISTS idx_custaddr_primary ON customer_address(customer_id, is_primary)
    WHERE is_primary = TRUE;
CREATE INDEX IF NOT EXISTS idx_custaddr_city_state ON customer_address(city, state);

-- ============================================================
-- 3. CUSTOMER_CONTACT
-- ============================================================
CREATE TABLE IF NOT EXISTS customer_contact (
    contact_id       SERIAL PRIMARY KEY,
    customer_id      INT NOT NULL REFERENCES customer(customer_id),
    contact_type     VARCHAR(20) NOT NULL,
    contact_category VARCHAR(20),
    contact_value    VARCHAR(255) NOT NULL,
    country_code     VARCHAR(5),
    std_code         VARCHAR(5),
    phone_number     VARCHAR(15),
    is_primary       BOOLEAN NOT NULL DEFAULT FALSE,
    is_verified      BOOLEAN NOT NULL DEFAULT FALSE,
    verified_at      TIMESTAMP,
    status           VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_custcontact_customer ON customer_contact(customer_id);
CREATE INDEX IF NOT EXISTS idx_custcontact_primary_type
    ON customer_contact(customer_id, contact_type, is_primary)
    WHERE is_primary = TRUE;
CREATE INDEX IF NOT EXISTS idx_custcontact_value ON customer_contact(contact_value);
CREATE INDEX IF NOT EXISTS idx_custcontact_status ON customer_contact(status);

CREATE UNIQUE INDEX ux_custcontact_primary_per_type
     ON customer_contact (customer_id, contact_type)
     WHERE is_primary = TRUE;


-- ============================================================
-- 4. BRANCH
-- ============================================================
CREATE TABLE IF NOT EXISTS branch (
    branch_id        SERIAL PRIMARY KEY,
    branch_code      VARCHAR(10) NOT NULL UNIQUE,
    ifsc_code        VARCHAR(20) NOT NULL UNIQUE,
    micr_code        VARCHAR(15),
    branch_name      VARCHAR(100) NOT NULL,
    address_line1    VARCHAR(200) NOT NULL,
    address_line2    VARCHAR(200),
    landmark         VARCHAR(200),
    city             VARCHAR(50) NOT NULL,
    state            VARCHAR(50) NOT NULL,
    pincode          VARCHAR(6) NOT NULL,
    country          VARCHAR(50) NOT NULL DEFAULT 'India',
    branch_type      VARCHAR(20) NOT NULL,
    region_code      VARCHAR(20),
    status           VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_branch_city_state ON branch(city, state);
CREATE INDEX IF NOT EXISTS idx_branch_region ON branch(region_code);
CREATE INDEX IF NOT EXISTS idx_branch_status ON branch(status);


-- ============================================================
-- 5. ACCOUNT_TYPE_MASTER
-- ============================================================
CREATE TABLE IF NOT EXISTS account_type_master (
    account_type_code   VARCHAR(30) PRIMARY KEY,
    category            VARCHAR(20) NOT NULL,
    type_name           VARCHAR(100) NOT NULL,
    description         VARCHAR(255),
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_accttype_category ON account_type_master(category);
CREATE INDEX IF NOT EXISTS idx_accttype_active ON account_type_master(is_active);


-- ============================================================
-- 6. ACCOUNT
-- ============================================================
CREATE TABLE IF NOT EXISTS account (
    account_id          SERIAL PRIMARY KEY,
    account_number      VARCHAR(30) NOT NULL UNIQUE,
    customer_id         INT NOT NULL REFERENCES customer(customer_id),
    branch_id           INT NOT NULL REFERENCES branch(branch_id),
    account_type_code   VARCHAR(30) NOT NULL REFERENCES account_type_master(account_type_code),
    currency            VARCHAR(3) NOT NULL DEFAULT 'INR',
    status              VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    open_date           DATE NOT NULL,
    close_date          DATE,
    current_balance     NUMERIC(18,2) NOT NULL DEFAULT 0.00,
    credit_limit        NUMERIC(18,2),
    overdraft_limit     NUMERIC(18,2),
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Enforce business rule: one ACTIVE account of each type per customer
CREATE UNIQUE INDEX IF NOT EXISTS ux_account_customer_type_active
    ON account(customer_id, account_type_code)
    WHERE status <> 'CLOSED';

CREATE INDEX IF NOT EXISTS idx_account_customer ON account(customer_id);
CREATE INDEX IF NOT EXISTS idx_account_branch ON account(branch_id);
CREATE INDEX IF NOT EXISTS idx_account_type ON account(account_type_code);
CREATE INDEX IF NOT EXISTS idx_account_status ON account(status);


-- ============================================================
-- 7. ACCOUNT_TRANSACTION
-- ============================================================
CREATE TABLE IF NOT EXISTS account_transaction (
    txn_id               BIGSERIAL PRIMARY KEY,
    account_id           INT NOT NULL REFERENCES account(account_id),
    txn_timestamp        TIMESTAMP NOT NULL,
    value_date           DATE NOT NULL,
    txn_type             VARCHAR(10) NOT NULL,
    amount               NUMERIC(18,2) NOT NULL,
    currency             VARCHAR(3) NOT NULL DEFAULT 'INR',
    balance_after_txn    NUMERIC(18,2),
    description          VARCHAR(255),
    narration            VARCHAR(255),
    merchant_name        VARCHAR(100),
    merchant_category    VARCHAR(4),
    channel              VARCHAR(20),
    instrument_type      VARCHAR(20),
    instrument_reference VARCHAR(100),
    rrn                  VARCHAR(50),
    txn_status           VARCHAR(20) NOT NULL DEFAULT 'POSTED',
    txn_status_reason    VARCHAR(255),
    related_txn_id       BIGINT REFERENCES account_transaction(txn_id),
    created_at           TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_txn_account_ts
    ON account_transaction(account_id, txn_timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_txn_account_valuedate
    ON account_transaction(account_id, value_date);

CREATE INDEX IF NOT EXISTS idx_txn_channel_status
    ON account_transaction(channel, txn_status);

CREATE INDEX IF NOT EXISTS idx_txn_reason
    ON account_transaction(txn_status_reason);

-- ===================================================================
-- END OF FILE
-- ===================================================================
