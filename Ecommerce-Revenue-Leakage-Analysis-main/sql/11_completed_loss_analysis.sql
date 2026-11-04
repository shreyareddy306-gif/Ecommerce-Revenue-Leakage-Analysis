/*
============================================================
Project: E-Commerce Revenue Leakage & Profitability Analysis
File: 11_completed_loss_analysis.sql
Purpose: Analyze completed orders that still generate losses
         and identify associated leakage patterns
Database: ecommerce_revenue_leakage
Dataset: Synthetic E-Commerce Transaction Dataset
============================================================
*/


-- =========================================================
-- 1. Completed Orders: Profitable vs Loss-Making
-- =========================================================

SELECT
    CASE
        WHEN net_profit < 0
            THEN 'Loss-Making'
        ELSE 'Profitable'
    END AS profit_status,

    COUNT(*) AS total_orders,

    ROUND(AVG(gross_revenue), 2)
        AS avg_gross_revenue,

    ROUND(AVG(discount_pct), 2)
        AS avg_discount_pct,

    ROUND(AVG(discount_amount), 2)
        AS avg_discount_amount,

    ROUND(AVG(shipping_cost), 2)
        AS avg_shipping_cost,

    ROUND(AVG(cogs), 2)
        AS avg_cogs,

    ROUND(AVG(net_revenue), 2)
        AS avg_net_revenue,

    ROUND(AVG(net_profit), 2)
        AS avg_net_profit,

    ROUND(AVG(revenue_leakage), 2)
        AS avg_revenue_leakage

FROM ecommerce_transactions

WHERE order_status = 'Completed'

GROUP BY profit_status

ORDER BY avg_net_profit;


-- =========================================================
-- 2. Leakage Reasons in Loss-Making Completed Orders
-- =========================================================

SELECT
    leakage_reason,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(net_profit),
        2
    ) AS total_net_profit,

    ROUND(
        ABS(SUM(net_profit)),
        2
    ) AS total_loss,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS revenue_leakage,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS order_pct

FROM ecommerce_transactions

WHERE order_status = 'Completed'
  AND net_profit < 0

GROUP BY leakage_reason

ORDER BY total_loss DESC;


-- =========================================================
-- 3. Category-Level Completed Losses
-- =========================================================

SELECT
    category,

    COUNT(*) AS loss_making_orders,

    ROUND(
        SUM(net_revenue),
        2
    ) AS net_revenue,

    ROUND(
        SUM(net_profit),
        2
    ) AS net_profit,

    ROUND(
        ABS(SUM(net_profit)),
        2
    ) AS total_loss,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS revenue_leakage

FROM ecommerce_transactions

WHERE order_status = 'Completed'
  AND net_profit < 0

GROUP BY category

ORDER BY total_loss DESC;


-- =========================================================
-- 4. Discount Level in Completed Loss-Making Orders
-- =========================================================

SELECT
    discount_pct,

    COUNT(*) AS loss_making_orders,

    ROUND(
        AVG(discount_amount),
        2
    ) AS avg_discount_amount,

    ROUND(
        AVG(shipping_cost),
        2
    ) AS avg_shipping_cost,

    ROUND(
        SUM(net_profit),
        2
    ) AS net_profit,

    ROUND(
        ABS(SUM(net_profit)),
        2
    ) AS total_loss,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS revenue_leakage

FROM ecommerce_transactions

WHERE order_status = 'Completed'
  AND net_profit < 0

GROUP BY discount_pct

ORDER BY total_loss DESC;


-- =========================================================
-- 5. Products Creating the Largest Completed-Order Losses
-- =========================================================

SELECT
    product_id,
    product_name,
    category,
    sub_category,

    COUNT(*) AS loss_making_orders,

    ROUND(
        SUM(net_revenue),
        2
    ) AS net_revenue,

    ROUND(
        SUM(net_profit),
        2
    ) AS net_profit,

    ROUND(
        ABS(SUM(net_profit)),
        2
    ) AS total_loss,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS revenue_leakage

FROM ecommerce_transactions

WHERE order_status = 'Completed'
  AND net_profit < 0

GROUP BY
    product_id,
    product_name,
    category,
    sub_category

ORDER BY total_loss DESC

LIMIT 10;


-- =========================================================
-- 6. Regional Distribution of Completed Loss-Making Orders
-- =========================================================

SELECT
    region,

    COUNT(*) AS loss_making_orders,

    ROUND(
        SUM(net_profit),
        2
    ) AS net_profit,

    ROUND(
        ABS(SUM(net_profit)),
        2
    ) AS total_loss,

    ROUND(
        AVG(shipping_cost),
        2
    ) AS avg_shipping_cost,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS revenue_leakage

FROM ecommerce_transactions

WHERE order_status = 'Completed'
  AND net_profit < 0

GROUP BY region

ORDER BY total_loss DESC;


-- =========================================================
-- 7. Verify Completed Loss-Making Orders
-- Expected: 8,405
-- =========================================================

SELECT
    COUNT(*) AS completed_loss_making_orders,

    ROUND(
        COUNT(*) * 100.0 /
        NULLIF(
            (
                SELECT COUNT(*)
                FROM ecommerce_transactions
                WHERE order_status = 'Completed'
            ),
            0
        ),
        2
    ) AS pct_of_completed_orders

FROM ecommerce_transactions

WHERE order_status = 'Completed'
  AND net_profit < 0;


-- =========================================================
-- 8. Completed Orders Final Profitability Summary
-- =========================================================

SELECT
    COUNT(*) AS completed_orders,

    COUNT(*) FILTER (
        WHERE net_profit < 0
    ) AS loss_making_orders,

    COUNT(*) FILTER (
        WHERE net_profit >= 0
    ) AS profitable_orders,

    ROUND(
        COUNT(*) FILTER (WHERE net_profit < 0)
        * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS loss_making_rate_pct,

    ROUND(
        SUM(net_revenue),
        2
    ) AS total_net_revenue,

    ROUND(
        SUM(net_profit),
        2
    ) AS total_net_profit,

    ROUND(
        SUM(net_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS total_revenue_leakage

FROM ecommerce_transactions

WHERE order_status = 'Completed';