{{ config(materialized='view') }}

select distinct
    trim(order_id) as order_id,
    cast(customer_id as integer) as customer_id,
    to_date(trim(order_date), 'DD-MM-YYYY') as order_date,
    to_date(trim(expected_delivery_date), 'DD-MM-YYYY') as expected_delivery_date,
    trim(order_status) as order_status,
    trim(payment_method) as payment_method,
    trim(payment_status) as payment_status,
    trim(shipping_address) as shipping_address,
    cast("subtotal " as numeric(12, 2)) as subtotal,
    cast(discount_amount as numeric(12, 2)) as discount_amount,
    cast(tax_amount as numeric(12, 2)) as tax_amount,
    cast(shipping_amount as numeric(12, 2)) as shipping_amount,
    cast(final_amount as numeric(12, 2)) as final_amount,
    _ingest_date,
    _source_file
from {{ source('bronze', 'bronze_orders') }}
