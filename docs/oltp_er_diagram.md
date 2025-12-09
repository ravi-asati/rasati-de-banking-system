# OLTP ER Diagram — Retail Banking System (India)

This document contains the Entity–Relationship Diagram for the OLTP system of our retail banking project.  
The diagram is written using **Mermaid**, which GitHub renders natively.

---

## ER Diagram

```mermaid
erDiagram
    CUSTOMER {
        int customer_id PK
        string first_name
        string middle_name
        string last_name
        date date_of_birth
        string gender
        string pan_number
        string status
        timestamp created_at
        timestamp updated_at
    }

    CUSTOMER_ADDRESS {
        int address_id PK
        int customer_id FK
        string address_type
        string line1
        string line2
        string landmark
        string city
        string state
        string pincode
        string country
        bool is_primary
        timestamp created_at
        timestamp updated_at
    }

    CUSTOMER_CONTACT {
        int contact_id PK
        int customer_id FK
        string contact_type
        string contact_category
        string contact_value
        string country_code
        string std_code
        string phone_number
        bool is_primary
        bool is_verified
        timestamp verified_at
        string status
        timestamp created_at
        timestamp updated_at
    }

    BRANCH {
        int branch_id PK
        string branch_code
        string ifsc_code
        string micr_code
        string branch_name
        string address_line1
        string address_line2
        string landmark
        string city
        string state
        string pincode
        string country
        string branch_type
        string region_code
        string status
        timestamp created_at
        timestamp updated_at
    }

    ACCOUNT_TYPE_MASTER {
        string account_type_code PK
        string category
        string type_name
        string description
        bool is_active
        timestamp created_at
        timestamp updated_at
    }

    ACCOUNT {
        int account_id PK
        string account_number
        int customer_id FK
        int branch_id FK
        string account_type_code FK
        string currency
        string status
        date open_date
        date close_date
        numeric current_balance
        numeric credit_limit
        numeric overdraft_limit
        timestamp created_at
        timestamp updated_at
    }

    ACCOUNT_TRANSACTION {
        bigint txn_id PK
        int account_id FK
        timestamp txn_timestamp
        date value_date
        string txn_type
        numeric amount
        string currency
        numeric balance_after_txn
        string description
        string narration
        string merchant_name
        string merchant_category
        string channel
        string instrument_type
        string instrument_reference
        string rrn
        string txn_status
        bigint related_txn_id FK
        timestamp created_at
        timestamp updated_at
    }

    CUSTOMER ||--o{ CUSTOMER_ADDRESS : "has"
    CUSTOMER ||--o{ CUSTOMER_CONTACT : "has"
    CUSTOMER ||--o{ ACCOUNT : "owns"
    BRANCH ||--o{ ACCOUNT : "services"
    ACCOUNT_TYPE_MASTER ||--o{ ACCOUNT : "typed as"
    ACCOUNT ||--o{ ACCOUNT_TRANSACTION : "has"
    ACCOUNT_TRANSACTION ||--o| ACCOUNT_TRANSACTION : "related to"
