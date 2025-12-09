-- ============================================================
--  CUSTOMER_ADDRESS TABLE (OLTP)
--  Stores multiple address types for each customer.
--  Address history is NOT maintained in OLTP; only current values.
--  Supported types include: RESIDENTIAL, PERMANUAL, WORK, MAILING.
-- ============================================================

CREATE TABLE IF NOT EXISTS customer_address (
    address_id       SERIAL PRIMARY KEY,
    -- NOTE:
    --   Postgres automatically creates a UNIQUE index on address_id
    --   because it is the PRIMARY KEY.

    customer_id      INT NOT NULL REFERENCES customer(customer_id),

    -- Address classification
    address_type     VARCHAR(20) NOT NULL,
    -- Expected values:
    --   'RESIDENTIAL'
    --   'PERMANENT'
    --   'WORK'
    --   'MAILING'

    -- Address lines
    line1            VARCHAR(200) NOT NULL,
    line2            VARCHAR(200),
    landmark         VARCHAR(200),

    -- Location information (Indian format)
    city             VARCHAR(50) NOT NULL,
    state            VARCHAR(50) NOT NULL,
    pincode          VARCHAR(6) NOT NULL,
    country          VARCHAR(50) NOT NULL DEFAULT 'India',

    -- Communication preference
    is_primary       BOOLEAN NOT NULL DEFAULT FALSE,
    -- Indicates the primary address for correspondence.

    -- Audit fields
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Recommended Indexes
-- ============================================================

-- Fast lookup of all addresses for a customer
CREATE INDEX IF NOT EXISTS idx_custaddr_customer
    ON customer_address (customer_id);

-- Quickly fetch the primary address (e.g., for statements)
CREATE INDEX IF NOT EXISTS idx_custaddr_primary
    ON customer_address (customer_id, is_primary)
    WHERE is_primary = TRUE;

-- Useful for regional queries / data quality checks
CREATE INDEX IF NOT EXISTS idx_custaddr_city_state
    ON customer_address (city, state);

-- This will guarantee each customer has at most one primary address.
CREATE UNIQUE INDEX ux_customer_primary_address
ON customer_address (customer_id)
WHERE is_primary = TRUE;
