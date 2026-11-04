/*
============================================================
Project: E-Commerce Revenue Leakage & Profitability Analysis
File: 03_core_kpis.sql
Purpose: Calculate core business and profitability KPIs
Database: ecommerce_revenue_leakage
Dataset: Synthetic E-Commerce Transaction Dataset
============================================================
*/


-- =========================================================
-- 1. Core Financial KPIs
-- =========================================================

SELECT
    COUNT(*) AS total_orders,

    ROUND(SUM(gross_revenue), 2)
        AS gross_revenue,

    ROUND(SUM(net_revenue), 2)
        AS net_revenue,

    ROUND(SUM(net_profit), 2)
        AS net_profit,

    ROUND(SUM(revenue_leakage), 2)
        AS total_revenue_leakage

FROM ecommerce_transactions;


-- =========================================================
-- 2. Revenue Leakage Components
-- =========================================================

SELECT
    ROUND(SUM(discount_amount), 2)
        AS total_discount_amount,

    ROUND(SUM(return_loss), 2)
        AS total_return_loss,

    ROUND(SUM(cancellation_loss), 2)
        AS total_cancellation_loss,

    ROUND(SUM(shipping_cost), 2)
        AS total_shipping_cost

FROM ecommerce_transactions;


-- =========================================================
-- 3. Overall Profit Margin
-- Weighted business-level margin:
-- Total Net Profit / Total Net Revenue
-- =========================================================

SELECT
    ROUND(
        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS overall_profit_margin_pct

FROM ecommerce_transactions;


-- =========================================================
-- 4. Return Rate
-- =========================================================

SELECT
    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'Returned'
    ) AS returned_orders,

    ROUND(
        COUNT(*) FILTER (
            WHERE order_status = 'Returned'
        ) * 100.0 / COUNT(*),
        2
    ) AS return_rate_pct

FROM ecommerce_transactions;


-- =========================================================
-- 5. Cancellation Rate
-- =========================================================

SELECT
    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'Cancelled'
    ) AS cancelled_orders,

    ROUND(
        COUNT(*) FILTER (
            WHERE order_status = 'Cancelled'
        ) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate_pct

FROM ecommerce_transactions;


-- =========================================================
-- 6. Average Order Value (AOV)
-- Project Definition:
-- Net Revenue / Total Orders
-- =========================================================

SELECT
    ROUND(
        SUM(net_revenue) / NULLIF(COUNT(*), 0),
        2
    ) AS average_order_value

FROM ecommerce_transactions;


-- =========================================================
-- 7. Loss-Making Orders
-- =========================================================

SELECT
    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE net_profit < 0
    ) AS loss_making_orders,

    ROUND(
        COUNT(*) FILTER (
            WHERE net_profit < 0
        ) * 100.0 / COUNT(*),
        2
    ) AS loss_making_order_rate_pct

FROM ecommerce_transactions;


-- =========================================================
-- 8. Order Status Summary
-- =========================================================

SELECT
    order_status,
    COUNT(*) AS total_orders,

    ROUND(SUM(gross_revenue), 2)
        AS gross_revenue,

    ROUND(SUM(net_revenue), 2)
        AS net_revenue,

    ROUND(SUM(net_profit), 2)
        AS net_profit,

    ROUND(SUM(revenue_leakage), 2)
        AS revenue_leakage

FROM ecommerce_transactions

GROUP BY order_status

ORDER BY total_orders DESC;


-- =========================================================
-- 9. Executive KPI Summary
-- Single-row output useful for reporting / dashboard checks
-- =========================================================

SELECT
    COUNT(*) AS total_orders,

    ROUND(SUM(gross_revenue), 2)
        AS gross_revenue,

    ROUND(SUM(net_revenue), 2)
        AS net_revenue,

    ROUND(SUM(net_profit), 2)
        AS net_profit,

    ROUND(
        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(SUM(revenue_leakage), 2)
        AS revenue_leakage,

    ROUND(SUM(discount_amount), 2)
        AS discount_amount,

    ROUND(SUM(return_loss), 2)
        AS return_loss,

    ROUND(SUM(cancellation_loss), 2)
        AS cancellation_loss,

    ROUND(SUM(shipping_cost), 2)
        AS shipping_cost,

    ROUND(
        SUM(net_revenue) /
        NULLIF(COUNT(*), 0),
        2
    ) AS average_order_value,

    ROUND(
        COUNT(*) FILTER (
            WHERE order_status = 'Returned'
        ) * 100.0 / COUNT(*),
        2
    ) AS return_rate_pct,

    ROUND(
        COUNT(*) FILTER (
            WHERE order_status = 'Cancelled'
        ) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate_pct,

    ROUND(
        COUNT(*) FILTER (
            WHERE net_profit < 0
        ) * 100.0 / COUNT(*),
        2
    ) AS loss_making_order_rate_pct

FROM ecommerce_transactions;