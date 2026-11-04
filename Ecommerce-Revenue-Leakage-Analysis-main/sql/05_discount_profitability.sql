/*
============================================================
Project: E-Commerce Revenue Leakage & Profitability Analysis
File: 05_discount_profitability.sql
Purpose: Analyze the relationship between discounts,
         profitability, leakage, and loss-making orders
Database: ecommerce_revenue_leakage
Dataset: Synthetic E-Commerce Transaction Dataset
============================================================
*/


-- =========================================================
-- 1. Profitability by Discount Percentage
-- =========================================================

SELECT
    discount_pct,
    COUNT(*) AS total_orders,

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

GROUP BY discount_pct

ORDER BY discount_pct;


-- =========================================================
-- 2. Loss-Making Rate by Discount Percentage
-- =========================================================

SELECT
    discount_pct,

    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE net_profit < 0
    ) AS loss_making_orders,

    ROUND(
        COUNT(*) FILTER (
            WHERE net_profit < 0
        ) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS loss_making_rate_pct

FROM ecommerce_transactions

GROUP BY discount_pct

ORDER BY discount_pct;


-- =========================================================
-- 3. Completed Orders Only:
-- Discount vs Profitability
-- Removes returned/cancelled orders from this comparison.
-- =========================================================

SELECT
    discount_pct,

    COUNT(*) AS completed_orders,

    COUNT(*) FILTER (
        WHERE net_profit < 0
    ) AS loss_making_orders,

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
        COUNT(*) FILTER (
            WHERE net_profit < 0
        ) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS loss_making_rate_pct

FROM ecommerce_transactions

WHERE order_status = 'Completed'

GROUP BY discount_pct

ORDER BY discount_pct;


-- =========================================================
-- 4. Discount Level Ranked by Revenue Leakage
-- =========================================================

SELECT
    discount_pct,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(discount_amount),
        2
    ) AS total_discount_amount,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS total_revenue_leakage,

    DENSE_RANK() OVER (
        ORDER BY SUM(revenue_leakage) DESC
    ) AS leakage_rank

FROM ecommerce_transactions

GROUP BY discount_pct

ORDER BY leakage_rank;


-- =========================================================
-- 5. Average Profit and Leakage by Discount Level
-- =========================================================

SELECT
    discount_pct,

    COUNT(*) AS total_orders,

    ROUND(
        AVG(discount_amount),
        2
    ) AS avg_discount_amount,

    ROUND(
        AVG(net_profit),
        2
    ) AS avg_net_profit,

    ROUND(
        AVG(revenue_leakage),
        2
    ) AS avg_revenue_leakage

FROM ecommerce_transactions

GROUP BY discount_pct

ORDER BY discount_pct;


-- =========================================================
-- 6. Discount Distribution
-- Shows how many orders fall under each discount level.
-- =========================================================

SELECT
    discount_pct,

    COUNT(*) AS total_orders,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS order_pct

FROM ecommerce_transactions

GROUP BY discount_pct

ORDER BY discount_pct;