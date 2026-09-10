SELECT
    pid,
    usename,
    application_name,
    client_addr,
    state,
    query_start,
    NOW() - query_start AS query_duration,
    query
FROM pg_stat_activity
WHERE datname = current_database()
  AND state <> 'idle'
ORDER BY query_start;