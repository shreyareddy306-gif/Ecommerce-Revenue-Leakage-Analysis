/*
============================================================
Project: E-Commerce Revenue Leakage & Profitability Analysis
File: 02_data_validation.sql
Purpose: Validate imported transaction data in PostgreSQL
Database: ecommerce_revenue_leakage
Dataset: Synthetic E-Commerce Transaction Dataset
============================================================
*/


-- =========================================================
-- 1. Total Row Count
-- Expected: 100,000 rows
-- =========================================================

SELECT
    COUNT(*) AS total_rows
FROM ecommerce_transactions;


-- =========================================================
-- 2. Unique Identifier Validation
-- Expected:
-- Orders    : 100,000
-- Customers : 19,872
-- Products  : 2,500
-- =========================================================

SELECT
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT product_id) AS unique_products
FROM ecommerce_transactions;


-- =========================================================
-- 3. Date Range Validation
-- Expected:
-- Start Date : 2024-01-01
-- End Date   : 2025-12-31
-- =========================================================

SELECT
    MIN(order_date) AS start_date,
    MAX(order_date) AS end_date
FROM ecommerce_transactions;


-- =========================================================
-- 4. Order Status Distribution
-- Expected:
-- Completed : 88,644
-- Returned  : 8,133
-- Cancelled : 3,223
-- =========================================================

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM ecommerce_transactions
GROUP BY order_status
ORDER BY total_orders DESC;


-- =========================================================
-- 5. Critical NULL Value Validation
-- Expected: 0 for all columns below
-- =========================================================

SELECT
    COUNT(*) FILTER (WHERE order_id IS NULL)
        AS missing_order_id,

    COUNT(*) FILTER (WHERE order_date IS NULL)
        AS missing_order_date,

    COUNT(*) FILTER (WHERE customer_id IS NULL)
        AS missing_customer_id,

    COUNT(*) FILTER (WHERE product_id IS NULL)
        AS missing_product_id,

    COUNT(*) FILTER (WHERE return_reason IS NULL)
        AS missing_return_reason

FROM ecommerce_transactions;


-- =========================================================
-- 6. Duplicate Order ID Check
-- Expected: No rows
-- =========================================================

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM ecommerce_transactions
GROUP BY order_id
HAVING COUNT(*) > 1;


-- =========================================================
-- 7. Returned Flag vs Order Status Validation
-- Expected: No inconsistent rows
-- =========================================================

SELECT
    order_status,
    returned,
    COUNT(*) AS total_orders
FROM ecommerce_transactions
GROUP BY order_status, returned
ORDER BY order_status, returned;


-- =========================================================
-- 8. Invalid Numerical Values
-- Expected: 0 for each validation
-- =========================================================

SELECT
    COUNT(*) FILTER (WHERE quantity <= 0)
        AS invalid_quantity,

    COUNT(*) FILTER (WHERE unit_price <= 0)
        AS invalid_unit_price,

    COUNT(*) FILTER (WHERE gross_revenue <= 0)
        AS invalid_gross_revenue,

    COUNT(*) FILTER (
        WHERE discount_pct < 0 OR discount_pct > 100
    ) AS invalid_discount_pct,

    COUNT(*) FILTER (WHERE cogs < 0)
        AS invalid_cogs,

    COUNT(*) FILTER (WHERE shipping_cost < 0)
        AS invalid_shipping_cost,

    COUNT(*) FILTER (WHERE delivery_days < 0)
        AS invalid_delivery_days

FROM ecommerce_transactions;


-- =========================================================
-- 9. Gross Revenue Formula Validation
-- gross_revenue = quantity * unit_price
-- Expected: 0 mismatches
-- =========================================================

SELECT
    COUNT(*) AS gross_revenue_mismatches
FROM ecommerce_transactions
WHERE ABS(
    gross_revenue - (quantity * unit_price)
) > 0.01;


-- =========================================================
-- 10. Discount Formula Validation
-- discount_amount = gross_revenue * discount_pct / 100
-- Small tolerance is used because monetary values are rounded.
-- =========================================================

SELECT
    COUNT(*) AS discount_amount_mismatches
FROM ecommerce_transactions
WHERE ABS(
    discount_amount -
    (gross_revenue * discount_pct / 100.0)
) > 0.05;


-- =========================================================
-- 11. Return Reason Consistency
-- Returned orders should contain an actual return reason.
-- =========================================================

SELECT
    COUNT(*) AS returned_without_reason
FROM ecommerce_transactions
WHERE order_status = 'Returned'
  AND (
      return_reason IS NULL
      OR return_reason = 'Not Applicable'
  );


-- =========================================================
-- 12. Final Validation Summary
-- =========================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT order_id) AS unique_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'Completed'
    ) AS completed_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'Returned'
    ) AS returned_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'Cancelled'
    ) AS cancelled_orders,

    COUNT(*) FILTER (
        WHERE net_profit < 0
    ) AS loss_making_orders

FROM ecommerce_transactions;