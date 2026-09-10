SELECT
    current_database() AS database_name,
    current_timestamp AS checked_at,
    version() AS postgres_version;