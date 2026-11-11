-- =====================================================================
-- 30-Day Cohort Retention Matrix via PostgreSQL CTEs & Window Functions
-- =====================================================================

WITH first_purchase_cohort AS (
    -- Identify the month of initial purchase for each customer
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(order_date))::DATE AS cohort_month
    FROM retail_transactions
    WHERE status = 'COMPLETED'
    GROUP BY customer_id
),

customer_activities AS (
    -- Extract all distinct activity months per customer
    SELECT DISTINCT
        t.customer_id,
        fpc.cohort_month,
        DATE_TRUNC('month', t.order_date)::DATE AS activity_month,
        -- Calculate index difference in months between activity and cohort
        (EXTRACT(YEAR FROM t.order_date) - EXTRACT(YEAR FROM fpc.cohort_month)) * 12 +
        (EXTRACT(MONTH FROM t.order_date) - EXTRACT(MONTH FROM fpc.cohort_month)) AS cohort_index
    FROM retail_transactions t
    INNER JOIN first_purchase_cohort fpc 
        ON t.customer_id = fpc.customer_id
    WHERE t.status = 'COMPLETED'
),

cohort_sizes AS (
    -- Total count of distinct users in original cohort month (Month 0)
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) AS total_users
    FROM first_purchase_cohort
    GROUP BY cohort_month
),

retention_counts AS (
    -- Aggregate active user counts by cohort and retention interval
    SELECT 
        ca.cohort_month,
        ca.cohort_index,
        COUNT(DISTINCT ca.customer_id) AS active_users
    FROM customer_activities ca
    GROUP BY ca.cohort_month, ca.cohort_index
)

-- Final Output: Cohort Retention Matrix with Retention Percentages
SELECT 
    rc.cohort_month,
    cs.total_users AS cohort_size,
    rc.cohort_index AS month_number,
    rc.active_users,
    ROUND((rc.active_users::NUMERIC / cs.total_users::NUMERIC) * 100.0, 2) AS retention_percentage
FROM retention_counts rc
JOIN cohort_sizes cs 
    ON rc.cohort_month = cs.cohort_month
ORDER BY rc.cohort_month ASC, rc.cohort_index ASC;
