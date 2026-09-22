SELECT 
    id AS item_id, 
    order_id, 
    sku AS product_id 
FROM {{ ref('raw_items') }}
