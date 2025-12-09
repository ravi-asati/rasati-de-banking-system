-- ============================================================
--  CUSTOMER TABLE (OLTP)
--  Stores identity & KYC-level customer information.
--  Contact information is normalized into customer_contact.
--  Address information is normalized into customer_address.
-- ============================================================

CREATE TABLE IF NOT EXISTS customer (
    customer_id     SERIAL PRIMARY KEY,
    -- NOTE:
    --   Postgres automatically creates a UNIQUE btree index on
    --   customer_id because it is the PRIMARY KEY.
    --   No separate index creation is required.
    --   Other DBs like MySQL, Oracle, SQL Server etc. does something similar.

    -- Identity
    first_name      VARCHAR(50) NOT NULL,
    middle_name     VARCHAR(50),
    last_name       VARCHAR(50) NOT NULL,
    date_of_birth   DATE NOT NULL,
    gender          VARCHAR(10),   -- 'MALE', 'FEMALE', 'OTHER'

    -- KYC Identifiers
    pan_number      VARCHAR(10),   -- Example: ABCDE1234F

    -- Lifecycle status of customer relationship
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    -- Possible values:
    --   ACTIVE    -> Customer is active
    --   INACTIVE  -> No recent activity
    --   BLOCKED   -> Compliance / fraud block
    --   CLOSED    -> Relationship terminated

    -- Audit fields
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Recommended Indexes
-- ============================================================

-- Fast lookup by last name (CRM use cases)
CREATE INDEX IF NOT EXISTS idx_customer_lastname
    ON customer (last_name);

-- Fast lookup by PAN (KYC checks)
CREATE INDEX IF NOT EXISTS idx_customer_pan
    ON customer (pan_number);

-- Useful for ops dashboards & status-based filtering
CREATE INDEX IF NOT EXISTS idx_customer_status
    ON customer (status);
