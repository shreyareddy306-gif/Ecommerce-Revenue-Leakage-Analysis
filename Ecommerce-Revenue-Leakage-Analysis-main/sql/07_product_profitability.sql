/*
============================================================
Project: E-Commerce Revenue Leakage & Profitability Analysis
File: 07_product_profitability.sql
Purpose: Analyze category, sub-category, and product-level
         revenue, profitability, and revenue leakage
Database: ecommerce_revenue_leakage
Dataset: Synthetic E-Commerce Transaction Dataset
============================================================
*/


-- =========================================================
-- 1. Category-Level Profitability
-- =========================================================

SELECT
    category,
    COUNT(*) AS total_orders,

    ROUND(SUM(gross_revenue), 2) AS gross_revenue,
    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(SUM(net_profit), 2) AS net_profit,
    ROUND(SUM(revenue_leakage), 2) AS revenue_leakage,

    ROUND(
        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin_pct

FROM ecommerce_transactions

GROUP BY category

ORDER BY net_profit DESC;


-- =========================================================
-- 2. Category-Level Loss-Making Order Rate
-- =========================================================

SELECT
    category,
    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE net_profit < 0
    ) AS loss_making_orders,

    ROUND(
        COUNT(*) FILTER (WHERE net_profit < 0)
        * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS loss_making_rate_pct

FROM ecommerce_transactions

GROUP BY category

ORDER BY loss_making_rate_pct DESC;


-- =========================================================
-- 3. Sub-Category Profitability
-- =========================================================

SELECT
    category,
    sub_category,
    COUNT(*) AS total_orders,

    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(SUM(net_profit), 2) AS net_profit,
    ROUND(SUM(revenue_leakage), 2) AS revenue_leakage,

    ROUND(
        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin_pct

FROM ecommerce_transactions

GROUP BY category, sub_category

ORDER BY profit_margin_pct ASC;


-- =========================================================
-- 4. Top 10 Products by Net Revenue
-- =========================================================

SELECT
    product_id,
    product_name,
    category,
    sub_category,

    COUNT(*) AS total_orders,

    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(SUM(net_profit), 2) AS net_profit,

    ROUND(
        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin_pct

FROM ecommerce_transactions

GROUP BY
    product_id,
    product_name,
    category,
    sub_category

ORDER BY net_revenue DESC

LIMIT 10;


-- =========================================================
-- 5. Top 10 Products by Net Profit
-- =========================================================

SELECT
    product_id,
    product_name,
    category,
    sub_category,

    COUNT(*) AS total_orders,

    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(SUM(net_profit), 2) AS net_profit,

    ROUND(
        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin_pct

FROM ecommerce_transactions

GROUP BY
    product_id,
    product_name,
    category,
    sub_category

ORDER BY net_profit DESC

LIMIT 10;


-- =========================================================
-- 6. Loss-Making Products
-- HAVING is used because we filter after aggregation.
-- =========================================================

SELECT
    product_id,
    product_name,
    category,
    sub_category,

    COUNT(*) AS total_orders,

    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(SUM(net_profit), 2) AS net_profit,
    ROUND(SUM(revenue_leakage), 2) AS revenue_leakage,

    ROUND(
        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin_pct

FROM ecommerce_transactions

GROUP BY
    product_id,
    product_name,
    category,
    sub_category

HAVING SUM(net_profit) < 0

ORDER BY net_profit ASC;


-- =========================================================
-- 7. High-Revenue, Low-Margin Products
-- Project analytical threshold:
-- Profit Margin < 10%
--
-- High revenue is defined as product revenue above the
-- median product-level net revenue.
-- =========================================================

WITH product_performance AS (

    SELECT
        product_id,
        product_name,
        category,
        sub_category,

        COUNT(*) AS total_orders,
        SUM(net_revenue) AS net_revenue,
        SUM(net_profit) AS net_profit,
        SUM(revenue_leakage) AS revenue_leakage,

        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100
            AS profit_margin_pct

    FROM ecommerce_transactions

    GROUP BY
        product_id,
        product_name,
        category,
        sub_category
),

median_revenue AS (

    SELECT
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY net_revenue)
            AS median_product_revenue

    FROM product_performance
)

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    p.total_orders,

    ROUND(p.net_revenue, 2) AS net_revenue,
    ROUND(p.net_profit, 2) AS net_profit,
    ROUND(p.profit_margin_pct, 2) AS profit_margin_pct,
    ROUND(p.revenue_leakage, 2) AS revenue_leakage

FROM product_performance p
CROSS JOIN median_revenue m

WHERE p.net_revenue > m.median_product_revenue
  AND p.profit_margin_pct < 10

ORDER BY p.net_revenue DESC;


-- =========================================================
-- 8. Top 10 Products by Revenue Leakage
-- =========================================================

SELECT
    product_id,
    product_name,
    category,
    sub_category,

    COUNT(*) AS total_orders,

    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(SUM(net_profit), 2) AS net_profit,
    ROUND(SUM(revenue_leakage), 2) AS revenue_leakage

FROM ecommerce_transactions

GROUP BY
    product_id,
    product_name,
    category,
    sub_category

ORDER BY revenue_leakage DESC

LIMIT 10;