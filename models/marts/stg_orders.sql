SELECT 
    id AS order_id, 
    customer AS customer_id, 
    CAST(ordered_at AS TIMESTAMP) AS order_date,
    order_total 
FROM {{ ref('raw_orders') }}
