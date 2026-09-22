SELECT 
    id AS customer_id,
    name AS customer_name
FROM {{ ref('raw_customers') }}
