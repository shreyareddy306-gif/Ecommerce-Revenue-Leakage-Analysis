/*
============================================================
Project: E-Commerce Revenue Leakage & Profitability Analysis
File: 10_returns_delivery_analysis.sql
Purpose: Analyze product returns, delivery delays,
         return reasons, and financial impact of returns
Database: ecommerce_revenue_leakage
Dataset: Synthetic E-Commerce Transaction Dataset
============================================================
*/


-- =========================================================
-- 1. Return Rate by Delivery Days
-- =========================================================

SELECT
    delivery_days,

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

GROUP BY delivery_days

ORDER BY delivery_days;


-- =========================================================
-- 2. Standard vs Late Delivery
--
-- Project Analytical Definition:
-- Standard Delivery = 1-5 Days
-- Late Delivery     = More Than 5 Days
--
-- This is a project-specific analytical threshold,
-- not a universal industry standard.
-- =========================================================

SELECT
    CASE
        WHEN delivery_days > 5
            THEN 'Late Delivery (>5 Days)'
        ELSE 'Standard Delivery (1-5 Days)'
    END AS delivery_group,

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
    ) AS return_rate_pct,

    ROUND(
        SUM(return_loss),
        2
    ) AS total_return_loss

FROM ecommerce_transactions

GROUP BY delivery_group

ORDER BY return_rate_pct DESC;


-- =========================================================
-- 3. Return Reason Analysis
-- =========================================================

SELECT
    return_reason,

    COUNT(*) AS returned_orders,

    ROUND(
        SUM(return_loss),
        2
    ) AS total_return_loss,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS revenue_leakage,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS return_pct

FROM ecommerce_transactions

WHERE order_status = 'Returned'

GROUP BY return_reason

ORDER BY returned_orders DESC;


-- =========================================================
-- 4. Average Financial Loss per Returned Order
-- =========================================================

SELECT
    COUNT(*) AS returned_orders,

    ROUND(
        SUM(return_loss),
        2
    ) AS total_return_loss,

    ROUND(
        AVG(return_loss),
        2
    ) AS avg_loss_per_returned_order

FROM ecommerce_transactions

WHERE order_status = 'Returned';


-- =========================================================
-- 5. Return Reason Ranked by Financial Loss
-- =========================================================

SELECT
    return_reason,

    COUNT(*) AS returned_orders,

    ROUND(
        SUM(return_loss),
        2
    ) AS total_return_loss,

    ROUND(
        AVG(return_loss),
        2
    ) AS avg_loss_per_return,

    DENSE_RANK() OVER (
        ORDER BY SUM(return_loss) DESC
    ) AS financial_loss_rank

FROM ecommerce_transactions

WHERE order_status = 'Returned'

GROUP BY return_reason

ORDER BY financial_loss_rank;


-- =========================================================
-- 6. Delivery Days and Financial Impact
-- =========================================================

SELECT
    delivery_days,

    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'Returned'
    ) AS returned_orders,

    ROUND(
        SUM(return_loss),
        2
    ) AS return_loss,

    ROUND(
        SUM(net_profit),
        2
    ) AS net_profit,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS revenue_leakage

FROM ecommerce_transactions

GROUP BY delivery_days

ORDER BY delivery_days;


-- =========================================================
-- 7. Validate Total Returned Orders
-- Expected: 8,133
-- =========================================================

SELECT
    COUNT(*) AS total_returned_orders

FROM ecommerce_transactions

WHERE order_status = 'Returned';