{{ config(
    materialized='table',
    schema='silver'
) }}

select *
from {{ ref('stg_orders') }}
where order_id is not null
  and order_status in ('Cancelled', 'Delivered', 'Pending', 'Processing', 'Returned', 'Shipped')
