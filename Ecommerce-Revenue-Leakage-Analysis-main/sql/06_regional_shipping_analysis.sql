/*
============================================================
Project: E-Commerce Revenue Leakage & Profitability Analysis
File: 06_regional_shipping_analysis.sql
Purpose: Analyze regional profitability, shipping costs,
         and geographic revenue leakage
Database: ecommerce_revenue_leakage
Dataset: Synthetic E-Commerce Transaction Dataset
============================================================
*/


-- =========================================================
-- 1. Regional Business Performance
-- =========================================================

SELECT
    region,
    COUNT(*) AS total_orders,

    ROUND(SUM(net_revenue), 2)
        AS net_revenue,

    ROUND(SUM(net_profit), 2)
        AS net_profit,

    ROUND(SUM(shipping_cost), 2)
        AS total_shipping_cost,

    ROUND(SUM(revenue_leakage), 2)
        AS revenue_leakage,

    ROUND(
        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin_pct

FROM ecommerce_transactions

GROUP BY region

ORDER BY net_profit DESC;


-- =========================================================
-- 2. Average Shipping Cost by Region
-- =========================================================

SELECT
    region,

    COUNT(*) AS total_orders,

    ROUND(
        AVG(shipping_cost),
        2
    ) AS avg_shipping_cost,

    ROUND(
        SUM(shipping_cost),
        2
    ) AS total_shipping_cost,

    ROUND(
        SUM(shipping_cost) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS shipping_cost_pct_revenue

FROM ecommerce_transactions

GROUP BY region

ORDER BY avg_shipping_cost DESC;


-- =========================================================
-- 3. Loss-Making Orders by Region
-- =========================================================

SELECT
    region,

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
    ) AS loss_making_rate_pct,

    ROUND(
        SUM(net_profit),
        2
    ) AS net_profit

FROM ecommerce_transactions

GROUP BY region

ORDER BY loss_making_rate_pct DESC;


-- =========================================================
-- 4. State-Level Profitability Analysis
-- =========================================================

SELECT
    region,
    state,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(net_revenue),
        2
    ) AS net_revenue,

    ROUND(
        SUM(net_profit),
        2
    ) AS net_profit,

    ROUND(
        AVG(shipping_cost),
        2
    ) AS avg_shipping_cost,

    ROUND(
        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS revenue_leakage

FROM ecommerce_transactions

GROUP BY region, state

ORDER BY profit_margin_pct ASC;


-- =========================================================
-- 5. Regional Shipping Cost per Order
-- =========================================================

SELECT
    region,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(shipping_cost) /
        NULLIF(COUNT(*), 0),
        2
    ) AS shipping_cost_per_order,

    ROUND(
        SUM(revenue_leakage) /
        NULLIF(COUNT(*), 0),
        2
    ) AS leakage_per_order

FROM ecommerce_transactions

GROUP BY region

ORDER BY shipping_cost_per_order DESC;


-- =========================================================
-- 6. Rank Regions by Profitability
-- =========================================================

SELECT
    region,

    ROUND(
        SUM(net_profit),
        2
    ) AS net_profit,

    ROUND(
        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin_pct,

    DENSE_RANK() OVER (
        ORDER BY
            SUM(net_profit) /
            NULLIF(SUM(net_revenue), 0) DESC
    ) AS profitability_rank

FROM ecommerce_transactions

GROUP BY region

ORDER BY profitability_rank;