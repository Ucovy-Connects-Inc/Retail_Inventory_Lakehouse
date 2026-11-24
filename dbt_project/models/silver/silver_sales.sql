{{ config(
    materialized='table',
    schema='silver'
) }}

select *
from {{ ref('stg_sales') }}
where date is not null
  and store_id is not null
  and product_id is not null
  and inventory_level is not null
  and inventory_level >= 0
  and units_sold >= 0
  and units_ordered >= 0
  and price is not null
  and price > 0
