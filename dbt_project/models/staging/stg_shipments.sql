{{ config(materialized='view') }}

select distinct
    trim(shipment_id) as shipment_id,
    trim(order_id) as order_id,
    cast(warehouse_id as integer) as warehouse_id,
    trim(shipping_partner) as shipping_partner,
    to_date(trim(shipped_date), 'DD-MM-YYYY') as shipped_date,
    to_date(trim(expected_delivery_date), 'DD-MM-YYYY') as expected_delivery_date,
    case
        when trim(actual_delivery_date) is not null and trim(actual_delivery_date) != ''
        then to_date(trim(actual_delivery_date), 'DD-MM-YYYY')
        else null
    end as actual_delivery_date,
    trim(shipment_status) as shipment_status,
    cast(delivery_days as integer) as delivery_days,
    cast(shipping_cost as numeric(10, 2)) as shipping_cost,
    trim(shipment_priority) as shipment_priority,
    trim(tracking_status) as tracking_status,
    case
        when trim(delay_reason) is not null and trim(delay_reason) != ''
        then trim(delay_reason)
        else null
    end as delay_reason,
    cast(delivery_rating as numeric(3, 2)) as delivery_rating,
    case
        when trim(customer_feedback) is not null and trim(customer_feedback) != ''
        then trim(customer_feedback)
        else null
    end as customer_feedback,
    trim(is_on_time) as is_on_time,
    _ingest_date,
    _source_file
from {{ source('bronze', 'bronze_shipments') }}
