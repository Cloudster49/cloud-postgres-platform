CREATE TABLE customers (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,

    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(25),

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT customers_status_check
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'))
);

CREATE TABLE addresses (
    address_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id BIGINT NOT NULL,

    address_type VARCHAR(20) NOT NULL,

    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country CHAR(2) NOT NULL DEFAULT 'US',

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT addresses_customer_fk
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE,

    CONSTRAINT addresses_type_check
        CHECK (address_type IN ('HOME', 'MAILING', 'WORK'))
);

CREATE TABLE accounts (
    account_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id BIGINT NOT NULL,

    account_number VARCHAR(20) NOT NULL UNIQUE,

    account_type VARCHAR(20) NOT NULL,

    balance NUMERIC(19,4) NOT NULL DEFAULT 0.0000,

    currency CHAR(3) NOT NULL DEFAULT 'USD',

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT accounts_customer_fk
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,

    CONSTRAINT accounts_type_check
        CHECK (account_type IN ('CHECKING', 'SAVINGS', 'CREDIT')),

    CONSTRAINT accounts_status_check
        CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),

    CONSTRAINT accounts_balance_check
        CHECK (balance >= 0)
);

CREATE TABLE merchants (
    merchant_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    merchant_name VARCHAR(255) NOT NULL,

    merchant_category VARCHAR(100),

    country CHAR(2) NOT NULL DEFAULT 'US',

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
    transaction_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    account_id BIGINT NOT NULL,
    merchant_id BIGINT,

    amount NUMERIC(19,4) NOT NULL,

    currency CHAR(3) NOT NULL DEFAULT 'USD',

    transaction_type VARCHAR(20) NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',

    transaction_timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT transactions_account_fk
        FOREIGN KEY (account_id)
        REFERENCES accounts(account_id)
        ON DELETE RESTRICT,

    CONSTRAINT transactions_merchant_fk
        FOREIGN KEY (merchant_id)
        REFERENCES merchants(merchant_id)
        ON DELETE RESTRICT,

    CONSTRAINT transactions_amount_check
        CHECK (amount > 0),

    CONSTRAINT transactions_type_check
        CHECK (
            transaction_type IN (
                'PURCHASE',
                'REFUND',
                'DEPOSIT',
                'WITHDRAWAL',
                'TRANSFER'
            )
        ),

    CONSTRAINT transactions_status_check
        CHECK (
            status IN (
                'PENDING',
                'COMPLETED',
                'FAILED',
                'REVERSED'
            )
        )
);