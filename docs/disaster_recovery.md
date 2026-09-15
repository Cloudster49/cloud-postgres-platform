# Disaster Recovery Procedure

## System

The primary PostgreSQL database is:


cloud_platform

The database contains the project's production-style schema and transaction workload.

## Backup Method

Backups are created using PostgreSQL `pg_dump` in custom format:

pg_dump -F c


The custom format allows the backup to be inspected and restored using PostgreSQL's `pg_restore` utility.

## Restore Method

Restoration is performed using:

pg_restore

The recovery workflow was validated using a separate test database:

cloud_platform_restore_test


## Disaster Scenario

The recovery process simulated loss or corruption of database objects by restoring the backup into a separate recovery environment rather than overwriting the primary database.

This provided a safe way to validate that the backup could recreate the database independently.

## Recovery Procedure

1. Identify the latest valid backup.
2. Inspect the backup using `pg_restore -l`.
3. Create or reinitialize the recovery database.
4. Restore the backup using `pg_restore`.
5. Verify restored database objects.
6. Compare expected row counts.
7. Execute relational validation queries.
8. Confirm that the recovered database is usable.

## Recovery Validation

The restore test successfully recreated the database in:

```
cloud_platform_restore_test
```

The restored database was validated against the source database using object and row-count checks.

The successful restore demonstrated that the backup was usable for database recovery rather than merely producing a backup file.

## Recovery Objectives

### RTO

A formal Recovery Time Objective was **not established** for this project.

The recovery exercise focused on validating the technical backup and restore procedure rather than defining a production service-level agreement.

### RPO

A formal Recovery Point Objective was **not established** for this project.

The project demonstrated point-in-time recovery from the available PostgreSQL backup rather than implementing a production continuous-backup or replication architecture.

## Recovery Architecture

```
cloud_platform
      │
      │ pg_dump
      ▼
Custom-format backup
      │
      │ pg_restore
      ▼
cloud_platform_restore_test
      │
      ▼
Object + row-count validation
```

## Result

The disaster-recovery restore test was successful.

The recovered database was created separately from the source database and validated through database-object and row-count checks.

This confirmed that the project has a repeatable PostgreSQL backup and restoration procedure.

## Limitations

This project demonstrates logical PostgreSQL backup and recovery using `pg_dump` and `pg_restore`.

It does not attempt to reproduce a full enterprise disaster-recovery architecture involving:

* Cross-region database replication
* Continuous physical backups
* Automated failover
* Multi-region application deployment
* Formal RTO/RPO service-level agreements

Those capabilities would be appropriate extensions for a production-scale implementation.
