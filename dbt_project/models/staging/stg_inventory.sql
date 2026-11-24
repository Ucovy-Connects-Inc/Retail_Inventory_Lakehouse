{{ config(materialized='view') }}

select distinct
    cast(inventory_id as integer) as inventory_id,
    cast(product_id as integer) as product_id,
    cast(warehouse_id as integer) as warehouse_id,
    cast(available_stock as integer) as available_stock,
    cast(reorder_level as integer) as reorder_level,
    cast(reorder_quantity as integer) as reorder_quantity,
    cast(reserved_stock as integer) as reserved_stock,
    cast(damaged_stock as integer) as damaged_stock,
    case
        when trim(last_restock_update) is not null and trim(last_restock_update) != ''
        then to_date(trim(last_restock_update), 'DD-MM-YYYY')
        else null
    end as last_restock_update,
    trim(inventory_status) as inventory_status,
    _ingest_date,
    _source_file
from {{ source('bronze', 'bronze_inventory') }}
