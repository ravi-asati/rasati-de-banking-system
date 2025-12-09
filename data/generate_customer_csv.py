###############################################################
# generate_customer_csv.py
# -------------------------------------------------------------
# Generates synthetic customer data for the OLTP "customer" table.
# Customer IDs follow a realistic bank-style 12-digit pattern:
#   <3-digit bank prefix><9-digit sequence number>
# Example:
#   301000000001
#   301000000002
#   ...
# This script writes output to:
#   data/oltp_raw/customer.csv
###############################################################

# ----------------------------
# IMPORTS (explained)
# ----------------------------

import os                      # Used for directory creation & path handling
import random                  # Used for randomness (middle names, statuses)
from datetime import date      # Represents date objects (used indirectly)

import pandas as pd            # Used to create DataFrames & write CSVs
from faker import Faker        # Library that generates realistic fake data


# ----------------------------
# DIRECTORY CONFIGURATION
# ----------------------------

# Get absolute path of this file (__file__ is this script’s path)
# Then dirname() moves one folder up (etl → project-root).
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Build output folder path: project-root/data/oltp_raw
DATA_DIR = os.path.join(BASE_DIR, "data", "oltp_raw")

# Create folder if it doesn't already exist (otherwise do nothing)
os.makedirs(DATA_DIR, exist_ok=True)


# ----------------------------
# RANDOM GENERATORS
# ----------------------------

# Initialize Faker with Indian locale (names, addresses resemble Indian data)
fake = Faker("en_IN")

# Seed ensures script produces SAME random data every run (reproducible)
random.seed(42)

# Number of customer records to generate (change anytime)
N_CUSTOMERS = 10_000


# ----------------------------
# CUSTOMER ID FORMAT (IMPORTANT)
# ----------------------------
# We construct a 12-digit customer_id:
#   <3-digit bank prefix> + <9-digit zero-padded sequence>
#
# Example:
#   Prefix = 301
#   Sequence 1  → ID = 301000000001
#   Sequence 2  → ID = 301000000002
#   ...
# Capable of supporting up to 999,999,999 customers.
#
# >>> Make sure "customer.customer_id" column is BIGINT in Postgres.
# -------------------------------------------------------------

BANK_PREFIX = 301      # You can use 101, 201, 501 etc. This simulates bank-specific CIF pattern.
SEQUENCE_START = 1     # Starting sequence number for synthetic customers
SEQUENCE_DIGITS = 9    # Number of digits allocated to sequence part (→ supports millions)


# ----------------------------
# CUSTOMER GENERATION FUNCTION
# ----------------------------

def generate_customers():
    """
    Generates N synthetic customers and writes them to customer.csv.
    Every row matches the columns of the OLTP customer table.
    """
    rows = []  # This list will accumulate row dictionaries

    # Loop from sequence 1 to sequence N_CUSTOMERS
    for seq in range(SEQUENCE_START, SEQUENCE_START + N_CUSTOMERS):

        # Build the string version of the 12-digit customer_id
        #  - f"{seq:09d}" zero-pads the sequence to 9 digits
        #  - bank prefix is concatenated in front
        customer_id_str = f"{BANK_PREFIX}{seq:0{SEQUENCE_DIGITS}d}"

        # Convert string to integer for storing as BIGINT in PostgreSQL
        customer_id = int(customer_id_str)

        # Generate customer’s first name (Faker "en_IN")
        first_name = fake.first_name()

        # Generate customer’s last name
        last_name = fake.last_name()

        # Optional middle name: 20% chance
        middle_name = ""
        if random.random() < 0.2:
            middle_name = fake.first_name()

        # Date of birth: realistic age range (18–75)
        dob = fake.date_of_birth(minimum_age=18, maximum_age=75)

        # Randomly pick gender
        gender = random.choice(["MALE", "FEMALE", "OTHER"])

        # Generate PAN-like synthetic number (not real PANs)
        # Using modulo gives nice variation for last 4 digits
        pan_number = f"ABCDE{customer_id % 10000:04d}F"

        # Weighted random selection of customer status
        status = random.choices(
            population=["ACTIVE", "INACTIVE", "BLOCKED", "CLOSED"],
            weights=[0.8, 0.1, 0.05, 0.05],  # 80% ACTIVE, 10% INACTIVE etc.
        )[0]  # random.choices returns list → take element 0

        # Build dictionary representing one row in customer table
        rows.append(
            {
                "customer_id": customer_id,
                "first_name": first_name,
                "middle_name": middle_name,
                "last_name": last_name,
                "date_of_birth": dob,
                "gender": gender,
                "pan_number": pan_number,
                "status": status,
            }
        )

    # Convert list of customer records → Pandas DataFrame (tabular structure)
    df = pd.DataFrame(rows)

    # Build CSV output path
    output_path = os.path.join(DATA_DIR, "customer.csv")

    # Write the DataFrame to CSV without index column
    df.to_csv(output_path, index=False)

    print(f"Generated {len(df)} customers → {output_path}")


# ----------------------------
# SCRIPT ENTRY POINT
# ----------------------------

# When this script is executed directly (not imported), run generation
if __name__ == "__main__":
    print("Generating synthetic customer data...")
    generate_customers()
    print("Done.")
