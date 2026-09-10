# Phase 4 Performance Engineering Report

## Dataset

- PostgreSQL version:
- Customers:
- Accounts:
- Merchants:
- Transactions:

## Experiment 1: Account Lookup

Before:
- Scan:
- Execution time:

After:
- Index:
- Scan:
- Execution time:

## Experiment 2: Account + Status

Before:
- Plan:
- Execution time:

After:
- Composite index:
- Plan:
- Execution time:

## Experiment 3: Date Range

Before:
- Plan:
- Execution time:

After:
- Index:
- Plan:
- Execution time:

## Experiment 4: Join Performance

- Query:
- Execution plan:
- Execution time:

## Experiment 5: Aggregation

- Query:
- Execution plan:
- Execution time:

## Key Findings

- Which indexes materially improved reads?
- Which indexes were unnecessary?
- How did dataset size affect performance?
- What tradeoffs did the indexes introduce?
- How did PostgreSQL's planner choose between scans?

## Conclusion

Summarize the final indexing strategy and performance findings.