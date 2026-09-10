import argparse
import os
import random
import time

import psycopg
from dotenv import load_dotenv


PROJECT_ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../..")
)

load_dotenv(os.path.join(PROJECT_ROOT, ".env"))


def get_required_env(name):
    value = os.getenv(name)

    if not value:
        raise ValueError(
            f"Environment variable '{name}' is required but not set."
        )

    return value


def get_connection():
    return psycopg.connect(
        host=get_required_env("DB_HOST"),
        port=get_required_env("DB_PORT"),
        dbname=get_required_env("DB_NAME"),
        user=get_required_env("DB_USER"),
        password=get_required_env("DB_PASSWORD"),
    )


def get_customer_ids(connection):
    """Retrieve all existing customer IDs."""
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT customer_id FROM customers ORDER BY customer_id;"
        )

        return [row[0] for row in cursor.fetchall()]


def generate_account_number():
    """Generate a 10-digit account number."""
    return str(random.randint(1_000_000_000, 9_999_999_999))


def generate_accounts(connection, row_count, batch_size):
    """Generate and insert accounts linked to existing customers."""

    customer_ids = get_customer_ids(connection)

    if not customer_ids:
        raise RuntimeError(
            "No customers exist. Generate customers before generating accounts."
        )

    insert_sql = """
        INSERT INTO accounts (
            customer_id,
            account_number,
            account_type,
            balance,
            currency,
            status
        )
        VALUES (%s, %s, %s, %s, %s, %s)
    """

    account_types = [
        "CHECKING",
        "SAVINGS",
        "CREDIT",
    ]

    inserted = 0

    while inserted < row_count:
        current_batch_size = min(
            batch_size,
            row_count - inserted
        )

        records = []

        for _ in range(current_batch_size):
            customer_id = random.choice(customer_ids)
            account_type = random.choice(account_types)

            # Keep balances realistic for our test environment.
            if account_type == "CHECKING":
                balance = round(random.uniform(100, 10_000), 2)
            elif account_type == "SAVINGS":
                balance = round(random.uniform(500, 50_000), 2)
            else:
                balance = round(random.uniform(100, 5_000), 2)

            records.append(
                (
                    customer_id,
                    generate_account_number(),
                    account_type,
                    balance,
                    "USD",
                    "ACTIVE",
                )
            )

        with connection.cursor() as cursor:
            cursor.executemany(insert_sql, records)

        connection.commit()

        inserted += current_batch_size

        print(
            f"Inserted {inserted:,}/{row_count:,} accounts"
        )


def main():
    parser = argparse.ArgumentParser(
        description="Generate test accounts for the PostgreSQL platform."
    )

    parser.add_argument(
        "--rows",
        type=int,
        default=100,
        help="Number of accounts to generate.",
    )

    parser.add_argument(
        "--batch-size",
        type=int,
        default=1000,
        help="Number of records inserted per database batch.",
    )

    args = parser.parse_args()

    if args.rows <= 0:
        raise ValueError(
            "The number of rows must be greater than zero."
        )

    if args.batch_size <= 0:
        raise ValueError(
            "The batch size must be greater than zero."
        )

    start_time = time.perf_counter()

    connection = get_connection()

    try:
        print(f"Connected to database: {connection.info.dbname}")

        customer_count = len(get_customer_ids(connection))

        print(f"Available customers: {customer_count:,}")
        print(f"Generating {args.rows:,} accounts...")

        generate_accounts(
            connection,
            args.rows,
            args.batch_size,
        )

    except Exception:
        connection.rollback()
        raise

    finally:
        connection.close()

    elapsed = time.perf_counter() - start_time

    rows_per_second = (
        args.rows / elapsed
        if elapsed > 0
        else 0
    )

    print()
    print("Generation complete.")
    print(f"Accounts inserted: {args.rows:,}")
    print(f"Elapsed time: {elapsed:.2f} seconds")
    print(f"Throughput: {rows_per_second:,.0f} rows/second")


if __name__ == "__main__":
    main()