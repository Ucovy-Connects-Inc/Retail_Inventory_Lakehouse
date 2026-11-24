{{ config(
    materialized='table',
    schema='silver'
) }}

select *
from {{ ref('stg_shipments') }}
where shipment_id is not null
  and shipment_status in ('Delivered', 'Delayed', 'In Transit', 'Out for Delivery', 'Returned', 'Lost')
