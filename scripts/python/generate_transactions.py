import argparse
import os
import random
import time
from datetime import datetime, timedelta, timezone

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


def get_ids(connection):
    """Load valid account and merchant IDs from PostgreSQL."""

    with connection.cursor() as cursor:
        cursor.execute("SELECT account_id FROM accounts;")
        account_ids = [row[0] for row in cursor.fetchall()]

        cursor.execute("SELECT merchant_id FROM merchants;")
        merchant_ids = [row[0] for row in cursor.fetchall()]

    if not account_ids:
        raise RuntimeError(
            "No accounts exist. Generate accounts before transactions."
        )

    if not merchant_ids:
        raise RuntimeError(
            "No merchants exist. Generate merchants before transactions."
        )

    return account_ids, merchant_ids


def generate_timestamp():
    """Generate a timestamp within the last year."""
    now = datetime.now(timezone.utc)
    random_days = random.randint(0, 365)
    random_seconds = random.randint(0, 86_399)

    return now - timedelta(
        days=random_days,
        seconds=random_seconds,
    )


def generate_transaction():
    """Generate one realistic transaction."""

    transaction_type = random.choices(
        [
            "PURCHASE",
            "REFUND",
            "DEPOSIT",
            "WITHDRAWAL",
            "TRANSFER",
        ],
        weights=[
            65,
            5,
            10,
            10,
            10,
        ],
        k=1,
    )[0]

    if transaction_type == "DEPOSIT":
        amount = round(random.uniform(50, 5_000), 2)

    elif transaction_type == "TRANSFER":
        amount = round(random.uniform(25, 10_000), 2)

    elif transaction_type == "WITHDRAWAL":
        amount = round(random.uniform(20, 1_000), 2)

    elif transaction_type == "REFUND":
        amount = round(random.uniform(5, 500), 2)

    else:
        amount = round(random.uniform(1, 500), 2)

    status = random.choices(
        [
            "COMPLETED",
            "PENDING",
            "FAILED",
            "REVERSED",
        ],
        weights=[
            92,
            4,
            3,
            1,
        ],
        k=1,
    )[0]

    return amount, transaction_type, status, generate_timestamp()


def generate_transactions(connection, row_count, batch_size):
    account_ids, merchant_ids = get_ids(connection)

    insert_sql = """
        INSERT INTO transactions (
            account_id,
            merchant_id,
            amount,
            currency,
            transaction_type,
            status,
            transaction_timestamp
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """

    inserted = 0

    while inserted < row_count:
        current_batch_size = min(
            batch_size,
            row_count - inserted,
        )

        records = []

        for _ in range(current_batch_size):
            amount, transaction_type, status, timestamp = (
                generate_transaction()
            )

            records.append(
                (
                    random.choice(account_ids),
                    random.choice(merchant_ids),
                    amount,
                    "USD",
                    transaction_type,
                    status,
                    timestamp,
                )
            )

        with connection.cursor() as cursor:
            cursor.executemany(insert_sql, records)

        connection.commit()

        inserted += current_batch_size

        print(
            f"Inserted {inserted:,}/{row_count:,} transactions"
        )


def main():
    parser = argparse.ArgumentParser(
        description="Generate test transactions."
    )

    parser.add_argument(
        "--rows",
        type=int,
        default=1000,
        help="Number of transactions to generate.",
    )

    parser.add_argument(
        "--batch-size",
        type=int,
        default=1000,
        help="Number of records inserted per batch.",
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
        print(
            f"Connected to database: {connection.info.dbname}"
        )

        account_ids, merchant_ids = get_ids(connection)

        print(f"Available accounts: {len(account_ids):,}")
        print(f"Available merchants: {len(merchant_ids):,}")
        print(f"Generating {args.rows:,} transactions...")

        generate_transactions(
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
    print(f"Transactions inserted: {args.rows:,}")
    print(f"Elapsed time: {elapsed:.2f} seconds")
    print(
        f"Throughput: {rows_per_second:,.0f} rows/second"
    )


if __name__ == "__main__":
    main()