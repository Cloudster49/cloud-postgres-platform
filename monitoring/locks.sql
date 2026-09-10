SELECT
    pid,
    usename,
    pg_blocking_pids(pid) AS blocking_pids,
    wait_event_type,
    wait_event,
    state,
    query
FROM pg_stat_activity
WHERE datname = current_database()
  AND (
      cardinality(pg_blocking_pids(pid)) > 0
      OR wait_event_type = 'Lock'
  )
ORDER BY pid;