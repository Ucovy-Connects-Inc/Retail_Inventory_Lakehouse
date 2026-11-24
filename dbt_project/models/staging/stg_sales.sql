{{ config(materialized='view') }}

select distinct
    cast(trim("Date") as date) as date,
    trim("Store ID") as store_id,
    trim("Product ID") as product_id,
    trim("Category") as category,
    trim("Region") as region,
    cast("Inventory Level" as integer) as inventory_level,
    cast("Units Sold" as integer) as units_sold,
    cast("Units Ordered" as integer) as units_ordered,
    cast("Price" as numeric(10, 2)) as price,
    cast("Discount" as numeric(5, 2)) as discount,
    trim("Weather Condition") as weather_condition,
    cast("Promotion" as integer) as promotion,
    cast("Competitor Pricing" as numeric(10, 2)) as competitor_pricing,
    trim("Seasonality") as seasonality,
    cast("Epidemic" as integer) as epidemic,
    cast("Demand" as integer) as demand,
    _ingest_date,
    _source_file
from {{ source('bronze', 'bronze_sales') }}
