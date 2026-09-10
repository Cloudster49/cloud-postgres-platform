# PostgreSQL Monitoring

## Health Monitoring

The database health report checks:

- PostgreSQL availability
- PostgreSQL version
- Database size
- Connection counts
- Table sizes
- Top query execution statistics

## Query Monitoring

PostgreSQL `pg_stat_statements` is enabled to track query execution statistics.

Tracked metrics include:

- Query execution count
- Total execution time
- Average execution time
- Rows processed

## Lock Monitoring

Active lock and blocking sessions can be inspected using:

`monitoring/locks.sql`

## Table Activity

PostgreSQL table statistics are monitored using `pg_stat_user_tables`.

## Operational Workflow

1. Run the health report.
2. Review connection usage.
3. Review table growth.
4. Review top queries.
5. Investigate expensive queries with `EXPLAIN ANALYZE`.
6. Check locks when queries appear blocked.