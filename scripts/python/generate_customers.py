import argparse
import os
import time

import psycopg
from dotenv import load_dotenv
from faker import Faker


# Load .env from the project root
PROJECT_ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../..")
)
load_dotenv(os.path.join(PROJECT_ROOT, ".env"))

fake = Faker()


def get_required_env(name):
    """Return a required environment variable or raise an error."""
    value = os.getenv(name)

    if not value:
        raise ValueError(
            f"Environment variable '{name}' is required but not set."
        )

    return value


def get_connection():
    """Create and return a PostgreSQL connection."""
    return psycopg.connect(
        host=get_required_env("DB_HOST"),
        port=get_required_env("DB_PORT"),
        dbname=get_required_env("DB_NAME"),
        user=get_required_env("DB_USER"),
        password=get_required_env("DB_PASSWORD"),
    )


def generate_customers(connection, row_count, batch_size):
    """Generate and insert customers in batches."""
    insert_sql = """
        INSERT INTO customers (
            first_name,
            last_name,
            email,
            phone_number,
            status
        )
        VALUES (%s, %s, %s, %s, %s)
    """

    inserted = 0

    while inserted < row_count:
        current_batch_size = min(batch_size, row_count - inserted)

        records = []

        for _ in range(current_batch_size):
            first_name = fake.first_name()
            last_name = fake.last_name()

            records.append(
                (
                    first_name,
                    last_name,
                    fake.unique.email(),
                    fake.phone_number()[:25],
                    "ACTIVE",
                )
            )

        with connection.cursor() as cursor:
            cursor.executemany(insert_sql, records)

        connection.commit()

        inserted += current_batch_size

        print(
            f"Inserted {inserted:,}/{row_count:,} customers"
        )


def main():
    parser = argparse.ArgumentParser(
        description="Generate test customers for the PostgreSQL platform."
    )

    parser.add_argument(
        "--rows",
        type=int,
        default=10,
        help="Number of customers to generate.",
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
        print(f"Connected as: {connection.info.user}")
        print(f"Connected to host: {connection.info.host}")
        print()
        print(f"Generating {args.rows:,} customers...")

        generate_customers(
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

    rows_per_second = args.rows / elapsed if elapsed > 0 else 0

    print()
    print("Generation complete.")
    print(f"Customers inserted: {args.rows:,}")
    print(f"Elapsed time: {elapsed:.2f} seconds")
    print(f"Throughput: {rows_per_second:,.0f} rows/second")


if __name__ == "__main__":
    main()