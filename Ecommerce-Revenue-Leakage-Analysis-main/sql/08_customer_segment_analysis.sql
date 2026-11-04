/*
============================================================
Project: E-Commerce Revenue Leakage & Profitability Analysis
File: 08_customer_segment_analysis.sql
Purpose: Analyze customer segment performance, profitability,
         returns, cancellations, AOV, and revenue leakage
Database: ecommerce_revenue_leakage
Dataset: Synthetic E-Commerce Transaction Dataset
============================================================
*/


-- =========================================================
-- 1. Customer Segment Performance
-- =========================================================

SELECT
    customer_segment,

    COUNT(*) AS total_orders,

    COUNT(DISTINCT customer_id)
        AS unique_customers,

    ROUND(
        SUM(gross_revenue),
        2
    ) AS gross_revenue,

    ROUND(
        SUM(net_revenue),
        2
    ) AS net_revenue,

    ROUND(
        SUM(net_profit),
        2
    ) AS net_profit,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS revenue_leakage,

    ROUND(
        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin_pct

FROM ecommerce_transactions

GROUP BY customer_segment

ORDER BY net_profit DESC;


-- =========================================================
-- 2. Return Rate by Customer Segment
-- =========================================================

SELECT
    customer_segment,

    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'Returned'
    ) AS returned_orders,

    ROUND(
        COUNT(*) FILTER (
            WHERE order_status = 'Returned'
        ) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS return_rate_pct

FROM ecommerce_transactions

GROUP BY customer_segment

ORDER BY return_rate_pct DESC;


-- =========================================================
-- 3. Cancellation Rate by Customer Segment
-- =========================================================

SELECT
    customer_segment,

    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'Cancelled'
    ) AS cancelled_orders,

    ROUND(
        COUNT(*) FILTER (
            WHERE order_status = 'Cancelled'
        ) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS cancellation_rate_pct

FROM ecommerce_transactions

GROUP BY customer_segment

ORDER BY cancellation_rate_pct DESC;


-- =========================================================
-- 4. Average Order Value by Customer Segment
--
-- Project AOV Definition:
-- Net Revenue / Total Orders
-- =========================================================

SELECT
    customer_segment,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(net_revenue) /
        NULLIF(COUNT(*), 0),
        2
    ) AS average_order_value

FROM ecommerce_transactions

GROUP BY customer_segment

ORDER BY average_order_value DESC;


-- =========================================================
-- 5. Revenue Leakage per Order by Customer Segment
-- =========================================================

SELECT
    customer_segment,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS total_revenue_leakage,

    ROUND(
        SUM(revenue_leakage) /
        NULLIF(COUNT(*), 0),
        2
    ) AS leakage_per_order

FROM ecommerce_transactions

GROUP BY customer_segment

ORDER BY leakage_per_order DESC;


-- =========================================================
-- 6. Combined Customer Segment KPI View
-- Useful for Power BI / business reporting
-- =========================================================

SELECT
    customer_segment,

    COUNT(*) AS total_orders,

    COUNT(DISTINCT customer_id)
        AS unique_customers,

    ROUND(
        SUM(net_revenue),
        2
    ) AS net_revenue,

    ROUND(
        SUM(net_profit),
        2
    ) AS net_profit,

    ROUND(
        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(net_revenue) /
        NULLIF(COUNT(*), 0),
        2
    ) AS average_order_value,

    COUNT(*) FILTER (
        WHERE order_status = 'Returned'
    ) AS returned_orders,

    ROUND(
        COUNT(*) FILTER (
            WHERE order_status = 'Returned'
        ) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS return_rate_pct,

    COUNT(*) FILTER (
        WHERE order_status = 'Cancelled'
    ) AS cancelled_orders,

    ROUND(
        COUNT(*) FILTER (
            WHERE order_status = 'Cancelled'
        ) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS cancellation_rate_pct,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS revenue_leakage,

    ROUND(
        SUM(revenue_leakage) /
        NULLIF(COUNT(*), 0),
        2
    ) AS leakage_per_order

FROM ecommerce_transactions

GROUP BY customer_segment

ORDER BY net_profit DESC;