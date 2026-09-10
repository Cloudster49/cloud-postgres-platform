CREATE INDEX idx_transactions_account_status
ON transactions(account_id, status);