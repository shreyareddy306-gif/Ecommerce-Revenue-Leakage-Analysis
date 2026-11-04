/*
============================================================
Project: E-Commerce Revenue Leakage & Profitability Analysis
File: 09_monthly_trend_analysis.sql
Purpose: Analyze monthly revenue, profit, leakage,
         growth, returns, and cancellations
Database: ecommerce_revenue_leakage
Dataset: Synthetic E-Commerce Transaction Dataset
============================================================
*/


-- =========================================================
-- 1. Monthly Business Performance
-- =========================================================

SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,

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

GROUP BY DATE_TRUNC('month', order_date)

ORDER BY month;


-- =========================================================
-- 2. Best and Worst Profit Months
-- =========================================================

WITH monthly_profit AS (

    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(net_profit) AS net_profit

    FROM ecommerce_transactions

    GROUP BY DATE_TRUNC('month', order_date)
)

SELECT
    month,
    ROUND(net_profit, 2) AS net_profit

FROM monthly_profit

ORDER BY net_profit DESC;


-- =========================================================
-- 3. Month-over-Month Revenue Growth
-- LAG() retrieves revenue from the previous month.
-- =========================================================

WITH monthly_revenue AS (

    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(net_revenue) AS net_revenue

    FROM ecommerce_transactions

    GROUP BY DATE_TRUNC('month', order_date)
),

revenue_growth AS (

    SELECT
        month,
        net_revenue,

        LAG(net_revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue

    FROM monthly_revenue
)

SELECT
    month,

    ROUND(
        net_revenue,
        2
    ) AS net_revenue,

    ROUND(
        previous_month_revenue,
        2
    ) AS previous_month_revenue,

    ROUND(
        (
            net_revenue - previous_month_revenue
        ) /
        NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS mom_revenue_growth_pct

FROM revenue_growth

ORDER BY month;


-- =========================================================
-- 4. Monthly Return and Cancellation Trends
-- =========================================================

SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,

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

GROUP BY DATE_TRUNC('month', order_date)

ORDER BY month;


-- =========================================================
-- 5. Monthly Leakage Trend
-- =========================================================

SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,

    ROUND(
        SUM(revenue_leakage),
        2
    ) AS revenue_leakage,

    ROUND(
        SUM(discount_amount),
        2
    ) AS discount_amount,

    ROUND(
        SUM(return_loss),
        2
    ) AS return_loss,

    ROUND(
        SUM(cancellation_loss),
        2
    ) AS cancellation_loss,

    ROUND(
        SUM(shipping_cost),
        2
    ) AS shipping_cost

FROM ecommerce_transactions

GROUP BY DATE_TRUNC('month', order_date)

ORDER BY month;


-- =========================================================
-- 6. Monthly Profit Ranking
-- =========================================================

WITH monthly_performance AS (

    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(net_revenue) AS net_revenue,
        SUM(net_profit) AS net_profit,
        SUM(revenue_leakage) AS revenue_leakage

    FROM ecommerce_transactions

    GROUP BY DATE_TRUNC('month', order_date)
)

SELECT
    month,

    ROUND(net_revenue, 2)
        AS net_revenue,

    ROUND(net_profit, 2)
        AS net_profit,

    ROUND(revenue_leakage, 2)
        AS revenue_leakage,

    DENSE_RANK() OVER (
        ORDER BY net_profit DESC
    ) AS profit_rank

FROM monthly_performance

ORDER BY profit_rank;