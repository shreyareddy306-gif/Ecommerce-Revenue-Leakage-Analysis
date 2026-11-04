/*
============================================================
Project: E-Commerce Revenue Leakage & Profitability Analysis
File: 04_revenue_leakage_analysis.sql
Purpose: Analyze revenue leakage by leakage reason
Database: ecommerce_revenue_leakage
Dataset: Synthetic E-Commerce Transaction Dataset
============================================================
*/


-- =========================================================
-- 1. Revenue Leakage by Reason
-- =========================================================

SELECT
    leakage_reason,
    COUNT(*) AS total_orders,
    ROUND(SUM(revenue_leakage), 2) AS total_leakage,
    ROUND(SUM(net_profit), 2) AS total_net_profit

FROM ecommerce_transactions

GROUP BY leakage_reason

ORDER BY total_leakage DESC;


-- =========================================================
-- 2. Leakage Contribution Percentage
-- Shows:
-- - Share of orders
-- - Share of total revenue leakage
-- =========================================================

SELECT
    leakage_reason,

    COUNT(*) AS total_orders,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS order_pct,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS total_leakage,

    ROUND(
        SUM(revenue_leakage) * 100.0 /
        NULLIF(
            SUM(SUM(revenue_leakage)) OVER (),
            0
        ),
        2
    ) AS leakage_pct,

    ROUND(
        SUM(net_profit),
        2
    ) AS total_net_profit

FROM ecommerce_transactions

GROUP BY leakage_reason

ORDER BY total_leakage DESC;


-- =========================================================
-- 3. Validate Leakage Percentage
-- Expected total: approximately 100%
-- =========================================================

WITH leakage_analysis AS (

    SELECT
        leakage_reason,

        SUM(revenue_leakage) * 100.0 /
        NULLIF(
            SUM(SUM(revenue_leakage)) OVER (),
            0
        ) AS leakage_pct

    FROM ecommerce_transactions

    GROUP BY leakage_reason
)

SELECT
    ROUND(
        SUM(leakage_pct),
        2
    ) AS total_percentage

FROM leakage_analysis;


-- =========================================================
-- 4. Rank Leakage Reasons
-- DENSE_RANK assigns ranking based on total leakage.
-- =========================================================

SELECT
    leakage_reason,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS total_leakage,

    DENSE_RANK() OVER (
        ORDER BY SUM(revenue_leakage) DESC
    ) AS leakage_rank

FROM ecommerce_transactions

GROUP BY leakage_reason

ORDER BY leakage_rank;


-- =========================================================
-- 5. Leakage Reason with Order Count and Average Leakage
-- =========================================================

SELECT
    leakage_reason,

    COUNT(*) AS total_orders,

    ROUND(
        AVG(revenue_leakage),
        2
    ) AS avg_leakage_per_order,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS total_leakage,

    ROUND(
        AVG(net_profit),
        2
    ) AS avg_net_profit

FROM ecommerce_transactions

GROUP BY leakage_reason

ORDER BY total_leakage DESC;


-- =========================================================
-- 6. Highest Leakage Reason
-- Returns the leakage reason contributing the largest
-- absolute amount of revenue leakage.
-- =========================================================

SELECT
    leakage_reason,
    COUNT(*) AS total_orders,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS total_leakage

FROM ecommerce_transactions

GROUP BY leakage_reason

ORDER BY total_leakage DESC

LIMIT 1;