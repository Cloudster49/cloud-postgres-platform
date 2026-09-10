# Query Performance Experiment 01

## Objective

Measure PostgreSQL performance when retrieving transactions for a specific account.

## Dataset

- Database: cloud_platform
- Table: transactions
- Rows: [INSERT CURRENT COUNT]
- PostgreSQL: 16.15

## Query

```sql
SELECT *
FROM transactions
WHERE account_id = 500;