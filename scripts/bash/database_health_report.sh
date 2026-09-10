#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$HOME/cloud-postgres-platform"

source "$PROJECT_ROOT/.env"

echo "========================================"
echo " PostgreSQL Health Report"
echo "========================================"
echo

echo "Timestamp:"
date

echo
echo "Database:"
echo "$DB_NAME"

echo
echo "PostgreSQL Version:"
psql \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -tAc "SELECT version();"

echo
echo "Database Size:"
psql \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -tAc "SELECT pg_size_pretty(pg_database_size(current_database()));"

echo
echo "Connections:"
psql \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -c "SELECT
            count(*) AS total_connections,
            count(*) FILTER (WHERE state = 'active') AS active,
            count(*) FILTER (WHERE state = 'idle') AS idle
        FROM pg_stat_activity WHERE datname = current_database();"

echo
echo "Table Sizes:"
psql \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -c "
        SELECT relname AS table_name, pg_size_pretty(pg_total_relation_size(relid)) AS total_size
        FROM pg_catalog.pg_statio_user_tables
        ORDER BY pg_total_relation_size(relid) DESC;"

echo
echo "Health check completed."

echo
echo "Top Queries by Total Execution Time:"

psql \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -f "$PROJECT_ROOT/monitoring/top_queries.sql"