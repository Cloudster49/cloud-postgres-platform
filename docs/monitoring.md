# PostgreSQL Monitoring

## Health Monitoring

The database health report checks:

* PostgreSQL availability
* PostgreSQL version
* Database size
* Connection counts
* Table sizes
* Top query execution statistics

## Query Monitoring

PostgreSQL `pg_stat_statements` is enabled to track query execution statistics.

Tracked metrics include:

* Query execution count
* Total execution time
* Average execution time
* Rows processed

These metrics support identification of frequently executed or expensive queries for further investigation.

## Lock Monitoring

Active locks and blocking sessions can be inspected using:

```
monitoring/locks.sql
```

This supports troubleshooting when transactions or queries appear blocked.

## Table Activity

PostgreSQL table statistics are monitored using:

```
pg_stat_user_tables
```

These statistics help identify table activity, growth, and maintenance conditions.

## Performance Investigation

Monitoring is combined with PostgreSQL execution-plan analysis.

When a query appears inefficient:

1. Identify the query using monitoring statistics.
2. Review execution frequency and execution time.
3. Run `EXPLAIN ANALYZE`.
4. Inspect index usage and scan methods.
5. Evaluate whether query or index changes improve execution.
6. Re-test after optimization.

## Operational Workflow

1. Run the health report.
2. Review connection usage.
3. Review table growth.
4. Review top queries.
5. Investigate expensive queries with `EXPLAIN ANALYZE`.
6. Check locks when queries appear blocked.
7. Record meaningful performance or operational findings.

## Monitoring Scope

The monitoring work in this project focuses primarily on PostgreSQL database health and query behavior.

Azure infrastructure monitoring was used during deployment and cost-management activities, but the project does not claim a full Azure Monitor/Log Analytics implementation.
