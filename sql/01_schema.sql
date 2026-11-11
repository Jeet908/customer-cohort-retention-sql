-- DDL Schema definition for Retail Customer Analytics Pipeline
-- Compatible with PostgreSQL 13+ and MySQL 8+

DROP TABLE IF EXISTS retail_transactions CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    signup_date TIMESTAMP NOT NULL,
    country VARCHAR(50) DEFAULT 'India',
    customer_segment VARCHAR(30) DEFAULT 'Retail'
);

CREATE TABLE retail_transactions (
    transaction_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) REFERENCES customers(customer_id),
    order_date TIMESTAMP NOT NULL,
    sku VARCHAR(30) NOT NULL,
    category VARCHAR(50) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL
);

CREATE INDEX idx_retail_cust_date ON retail_transactions(customer_id, order_date);
CREATE INDEX idx_retail_status ON retail_transactions(status);
