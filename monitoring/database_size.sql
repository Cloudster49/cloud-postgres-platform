SELECT current_database() AS database_name,
       pg_size_pretty(pg_database_size(current_database())) AS database_size;

-- Check individual tables

SELECT
    relname AS table_name,
    pg_size_pretty(
        pg_total_relation_size(relid)
    ) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;