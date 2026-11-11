-- =====================================================================
-- Repeat Purchase Frequency & Intersite Lag Analysis
-- Uses: ROW_NUMBER(), DENSE_RANK(), LAG() Window Functions
-- =====================================================================

WITH ordered_transactions AS (
    SELECT 
        transaction_id,
        customer_id,
        order_date,
        amount,
        -- Rank each order sequence per user
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date ASC) AS order_sequence,
        -- Fetch timestamp of preceding transaction
        LAG(order_date, 1) OVER(PARTITION BY customer_id ORDER BY order_date ASC) AS previous_order_date
    FROM retail_transactions
    WHERE status = 'COMPLETED'
),

intervals AS (
    SELECT 
        transaction_id,
        customer_id,
        order_date,
        previous_order_date,
        order_sequence,
        amount,
        EXTRACT(EPOCH FROM (order_date - previous_order_date)) / 86400.0 AS days_since_last_order
    FROM ordered_transactions
)

-- Summary of customer churn velocity & repeat patterns
SELECT 
    CASE 
        WHEN order_sequence = 1 THEN 'First-Time Buyer'
        WHEN order_sequence BETWEEN 2 AND 4 THEN 'Returning Customer'
        ELSE 'Loyal High-Frequency Customer'
    END AS customer_tier,
    COUNT(transaction_id) AS total_orders,
    ROUND(AVG(amount), 2) AS avg_ticket_size,
    ROUND(AVG(days_since_last_order)::NUMERIC, 1) AS avg_days_to_repurchase
FROM intervals
GROUP BY 1
ORDER BY total_orders DESC;
