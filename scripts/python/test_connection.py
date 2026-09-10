import os
import psycopg


def get_required_env(name):
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


def get_connection():
    return psycopg.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "5432")),
        dbname=os.getenv("DB_NAME", "cloud_platform"),
        user=os.getenv("DB_USER", "postgres"),
        password=get_required_env("DB_PASSWORD")
    )


def main():
    connection = get_connection()

    try:
        print("Successfully connected to the database!")
    finally:
        connection.close()
        print("Connection closed.")


if __name__ == "__main__":
    main()