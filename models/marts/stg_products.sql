SELECT 
    sku AS product_id, 
    name AS product_name, 
    type AS product_type, 
    price AS product_price 
FROM {{ ref('raw_products') }}
