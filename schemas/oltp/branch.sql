-- ============================================================
--  BRANCH TABLE (OLTP)
--  Represents a physical or digital branch of the bank.
--
--  Includes:
--    - Internal branch code
--    - IFSC code (public identifier)
--    - Optional MICR code
--    - Full postal address (denormalized)
--    - Branch type & region
--    - Lifecycle status
-- ============================================================

CREATE TABLE IF NOT EXISTS branch (
    branch_id        SERIAL PRIMARY KEY,
    -- NOTE:
    --   Postgres automatically creates a UNIQUE index on branch_id
    --   because it is the PRIMARY KEY.

    -- Codes / identifiers
    branch_code      VARCHAR(10) NOT NULL UNIQUE,
    -- Internal identifier used by the bank (e.g. 'BR0012').

    ifsc_code        VARCHAR(20) NOT NULL UNIQUE,
    -- Indian Financial System Code (e.g. 'HDFC0001234').

    micr_code        VARCHAR(15),
    -- Optional: MICR code printed on cheques (e.g. '400240002').

    -- Naming
    branch_name      VARCHAR(100) NOT NULL,
    -- Human-readable branch name, e.g. 'Indore - Vijay Nagar'.

    -- Address (denormalized since branch count is relatively small)
    address_line1    VARCHAR(200) NOT NULL,
    address_line2    VARCHAR(200),
    landmark         VARCHAR(200),

    city             VARCHAR(50) NOT NULL,
    state            VARCHAR(50) NOT NULL,
    pincode          VARCHAR(6) NOT NULL,
    country          VARCHAR(50) NOT NULL DEFAULT 'India',

    -- Classification
    branch_type      VARCHAR(20) NOT NULL,
    -- Suggested values:
    --   'METRO'
    --   'URBAN'
    --   'SEMI_URBAN'
    --   'RURAL'
    --   'DIGITAL_ONLY'

    region_code      VARCHAR(20),
    -- Optional regional grouping, e.g.:
    --   'NORTH', 'SOUTH', 'EAST', 'WEST', 'CENTRAL'
    -- or bank-specific region/zonal codes.

    -- Status
    status           VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    -- Suggested values:
    --   'ACTIVE'
    --   'CLOSED'
    --   'MERGED'

    -- Audit fields
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Recommended Indexes
-- ============================================================

-- Filter and search branches by city/state (ops, dashboards, etc.)
CREATE INDEX IF NOT EXISTS idx_branch_city_state
    ON branch (city, state);

-- Group branches by region for reporting
CREATE INDEX IF NOT EXISTS idx_branch_region
    ON branch (region_code);

-- Quickly filter branches by status
CREATE INDEX IF NOT EXISTS idx_branch_status
    ON branch (status);
