-- ============================================================
--  CUSTOMER_CONTACT TABLE (OLTP)
--  Stores multiple contact channels for each customer in a
--  normalized, enterprise-style model.
--
--  Examples:
--    - MOBILE (primary, verified)
--    - LANDLINE (home/office)
--    - EMAIL (personal, work)
--    - WHATSAPP (mobile-linked)
--
--  Phone-like contacts are broken down into:
--    country_code, std_code (for landline), phone_number
-- ============================================================

CREATE TABLE IF NOT EXISTS customer_contact (
    contact_id       SERIAL PRIMARY KEY,
    -- NOTE:
    --   Postgres automatically creates a UNIQUE index on contact_id
    --   because it is the PRIMARY KEY.

    customer_id      INT NOT NULL REFERENCES customer(customer_id),

    -- Contact classification
    contact_type     VARCHAR(20) NOT NULL,
    -- Expected values (not enforced here, but by convention):
    --   'MOBILE'
    --   'LANDLINE'
    --   'EMAIL'
    --   'WHATSAPP'

    contact_category VARCHAR(20),
    -- Optional semantic category, e.g.:
    --   'PERSONAL'
    --   'WORK'

    -- Main value representation used by applications (search/display)
    contact_value    VARCHAR(255) NOT NULL,
    -- Examples:
    --   '+91-9876543210'
    --   '+91-22-23456789'
    --   'user@example.com'

    -- Structured phone information (used for MOBILE / LANDLINE / WHATSAPP)
    country_code     VARCHAR(5),
    -- Example: '+91'

    std_code         VARCHAR(5),
    -- For LANDLINE only: '11' (Delhi), '22' (Mumbai), '80' (Bangalore), etc.
    -- Should be NULL for MOBILE / EMAIL / WHATSAPP.

    phone_number     VARCHAR(15),
    -- For MOBILE/WHATSAPP: 10-digit Indian mobile number (e.g. '9876543210').
    -- For LANDLINE: subscriber number (6–8 digits) without STD code.
    -- Should be NULL for EMAIL.

    -- Flags
    is_primary       BOOLEAN NOT NULL DEFAULT FALSE,
    -- Indicates the primary contact for a given contact_type
    -- e.g. primary MOBILE, primary EMAIL, etc.

    is_verified      BOOLEAN NOT NULL DEFAULT FALSE,
    verified_at      TIMESTAMP,
    -- For phone/email verification via OTP or link.

    status           VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    -- Suggested values:
    --   'ACTIVE'
    --   'INACTIVE'
    --   'BLOCKED'

    -- Audit fields
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Recommended Indexes
-- ============================================================

-- Fetch all contacts for a customer quickly
CREATE INDEX IF NOT EXISTS idx_custcontact_customer
    ON customer_contact (customer_id);

-- Efficient lookup of primary contact per type
CREATE INDEX IF NOT EXISTS idx_custcontact_primary_type
    ON customer_contact (customer_id, contact_type, is_primary)
    WHERE is_primary = TRUE;

-- Fast lookup by contact_value (e.g., login via email/phone)
CREATE INDEX IF NOT EXISTS idx_custcontact_value
    ON customer_contact (contact_value);

-- Optional: index for status-based queries (ops / reporting)
CREATE INDEX IF NOT EXISTS idx_custcontact_status
    ON customer_contact (status);

-- ============================================================
-- Optional Uniqueness Constraints (Business Rules)
-- ============================================================

-- Rule (optional):
--   At most one PRIMARY contact per (customer_id, contact_type).
--   Example: only one primary MOBILE, one primary EMAIL, etc.
--
-- Uncomment if you want this enforced at the DB level:

CREATE UNIQUE INDEX ux_custcontact_primary_per_type
     ON customer_contact (customer_id, contact_type)
     WHERE is_primary = TRUE;
