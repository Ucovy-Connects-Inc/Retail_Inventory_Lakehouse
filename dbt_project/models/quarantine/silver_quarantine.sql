{{ config(
    materialized='table',
    schema='silver'
) }}

with quarantined_sales as (
    select
        'bronze.bronze_sales' as source_table,
        case
            when "Date" is null then 'date is null'
            when "Store ID" is null then 'store_id is null'
            when "Product ID" is null then 'product_id is null'
            when "Inventory Level" is null or "Inventory Level" < 0 then 'inventory_level < 0 or null'
            when "Units Sold" < 0 then 'units_sold < 0'
            when "Units Ordered" < 0 then 'units_ordered < 0'
            when "Price" is null or "Price" <= 0 then 'price <= 0 or null'
            else 'failed check'
        end as failed_check,
        concat_ws(':', "Date", "Store ID", "Product ID") as record_identifier,
        to_jsonb(s.*) as original_columns,
        _ingest_date
    from {{ source('bronze', 'bronze_sales') }} s
    where "Date" is null
       or "Store ID" is null
       or "Product ID" is null
       or "Inventory Level" is null
       or "Inventory Level" < 0
       or "Units Sold" < 0
       or "Units Ordered" < 0
       or "Price" is null
       or "Price" <= 0
),

quarantined_suppliers as (
    select
        'bronze.bronze_suppliers' as source_table,
        case
            when supplier_id is null then 'supplier_id is null'
            when status not in ('Active', 'Inactive') then 'invalid status: ' || coalesce(status, 'null')
            else 'failed check'
        end as failed_check,
        cast(supplier_id as text) as record_identifier,
        to_jsonb(sp.*) as original_columns,
        _ingest_date
    from {{ source('bronze', 'bronze_suppliers') }} sp
    where supplier_id is null
       or status not in ('Active', 'Inactive')
),

quarantined_shipments as (
    select
        'bronze.bronze_shipments' as source_table,
        case
            when shipment_id is null then 'shipment_id is null'
            when shipment_status not in ('Delivered', 'Delayed', 'In Transit', 'Out for Delivery', 'Returned', 'Lost')
            then 'invalid shipment_status: ' || coalesce(shipment_status, 'null')
            else 'failed check'
        end as failed_check,
        shipment_id as record_identifier,
        to_jsonb(sh.*) as original_columns,
        _ingest_date
    from {{ source('bronze', 'bronze_shipments') }} sh
    where shipment_id is null
       or shipment_status not in ('Delivered', 'Delayed', 'In Transit', 'Out for Delivery', 'Returned', 'Lost')
),

quarantined_orders as (
    select
        'bronze.bronze_orders' as source_table,
        case
            when order_id is null then 'order_id is null'
            when order_status not in ('Cancelled', 'Delivered', 'Pending', 'Processing', 'Returned', 'Shipped')
            then 'invalid order_status: ' || coalesce(order_status, 'null')
            else 'failed check'
        end as failed_check,
        order_id as record_identifier,
        to_jsonb(o.*) as original_columns,
        _ingest_date
    from {{ source('bronze', 'bronze_orders') }} o
    where order_id is null
       or order_status not in ('Cancelled', 'Delivered', 'Pending', 'Processing', 'Returned', 'Shipped')
),

quarantined_inventory as (
    select
        'bronze.bronze_inventory' as source_table,
        case
            when inventory_id is null then 'inventory_id is null'
            when available_stock is null or available_stock < 0 then 'available_stock < 0 or null'
            when inventory_status not in ('In Stock', 'Low Stock', 'Out of Stock', 'Overstock')
            then 'invalid inventory_status: ' || coalesce(inventory_status, 'null')
            else 'failed check'
        end as failed_check,
        cast(inventory_id as text) as record_identifier,
        to_jsonb(i.*) as original_columns,
        _ingest_date
    from {{ source('bronze', 'bronze_inventory') }} i
    where inventory_id is null
       or available_stock is null
       or available_stock < 0
       or inventory_status not in ('In Stock', 'Low Stock', 'Out of Stock', 'Overstock')
)

select * from quarantined_sales
union all
select * from quarantined_suppliers
union all
select * from quarantined_shipments
union all
select * from quarantined_orders
union all
select * from quarantined_inventory
