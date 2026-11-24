{{ config(
    materialized='table',
    schema='silver'
) }}

select *
from {{ ref('stg_inventory') }}
where inventory_id is not null
  and available_stock is not null
  and available_stock >= 0
  and inventory_status in ('In Stock', 'Low Stock', 'Out of Stock', 'Overstock')
