# Disaster Recovery Procedure

## System

cloud_platform PostgreSQL database

## Backup Method

PostgreSQL `pg_dump` using custom format.

## Restore Method

PostgreSQL `pg_restore`.

## Disaster Scenario

Simulated loss of the `transactions` table in a separate
disaster-recovery test database.

## Recovery Procedure

1. Identify the latest valid backup.
2. Verify the backup with `pg_restore -l`.
3. Create/reinitialize the recovery database.
4. Restore the backup with `pg_restore`.
5. Verify database objects.
6. Verify row counts.
7. Validate relational queries.
8. Record recovery duration.

## RTO

Record measured recovery time here.

## RPO

Record the backup interval here.

## Validation

Document the queries used to confirm the recovered system is usable.

## Result

Document whether recovery was successful.