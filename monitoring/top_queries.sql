SELECT
    calls,
    ROUND(total_exec_time::numeric, 2) AS total_exec_ms,
    ROUND(mean_exec_time::numeric, 2) AS avg_exec_ms,
    rows,
    LEFT(query, 150) AS query
FROM pg_stat_statements
WHERE dbid = (
    SELECT oid
    FROM pg_database
    WHERE datname = current_database()
)
ORDER BY total_exec_time DESC
LIMIT 20;