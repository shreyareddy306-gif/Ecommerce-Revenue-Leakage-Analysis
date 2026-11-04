/*
============================================================
Project: E-Commerce Revenue Leakage & Profitability Analysis
File: 01_create_table.sql
Purpose: Create the main PostgreSQL transaction table
Database: ecommerce_revenue_leakage
Dataset: Synthetic E-Commerce Transaction Dataset
============================================================
*/

-- =========================================================
-- 1. Create Main Transaction Table
-- =========================================================

CREATE TABLE ecommerce_transactions (

    -- Order & Customer Information
    order_id VARCHAR(50) PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    customer_segment VARCHAR(50),

    -- Product Information
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(255),
    category VARCHAR(100),
    sub_category VARCHAR(100),

    -- Geographic Information
    region VARCHAR(50),
    state VARCHAR(100),

    -- Order Information
    quantity INTEGER,
    unit_price NUMERIC(12,2),
    gross_revenue NUMERIC(14,2),

    -- Discount Information
    discount_pct NUMERIC(6,2),
    discount_amount NUMERIC(14,2),
    sales NUMERIC(14,2),

    -- Cost Information
    unit_cost NUMERIC(12,2),
    cogs NUMERIC(14,2),
    shipping_cost NUMERIC(12,2),

    -- Delivery Information
    delivery_days INTEGER,

    -- Payment & Order Status
    payment_method VARCHAR(50),
    order_status VARCHAR(50),

    -- Return Information
    returned INTEGER,
    return_reason VARCHAR(100),

    -- Revenue Loss Information
    cancellation_loss NUMERIC(14,2),
    return_loss NUMERIC(14,2),

    -- Final Financial Metrics
    net_revenue NUMERIC(14,2),
    net_profit NUMERIC(14,2),
    profit_margin_pct NUMERIC(10,2),

    -- Revenue Leakage
    revenue_leakage NUMERIC(14,2),
    leakage_reason VARCHAR(100)
);


-- =========================================================
-- 2. Verify Table Creation
-- =========================================================

SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'ecommerce_transactions';


-- =========================================================
-- 3. Verify Number of Columns
-- Expected: 31 columns
-- =========================================================

SELECT
    COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'ecommerce_transactions';


-- =========================================================
-- 4. View Table Structure
-- =========================================================

SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'ecommerce_transactions'
ORDER BY ordinal_position;