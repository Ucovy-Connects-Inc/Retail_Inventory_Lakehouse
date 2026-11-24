{{ config(materialized='view') }}

select distinct
    cast(supplier_id as integer) as supplier_id,
    trim(supplier_name) as supplier_name,
    trim(supplier_type) as supplier_type,
    trim(contact_person) as contact_person,
    trim(email) as email,
    cast(contact_number as text) as contact_number,
    trim(city) as city,
    trim(country) as country,
    cast(supplier_rating as numeric(3, 2)) as supplier_rating,
    cast(lead_time_days as integer) as lead_time_days,
    trim(status) as status,
    trim(supplier_category) as supplier_category,
    _ingest_date,
    _source_file
from {{ source('bronze', 'bronze_suppliers') }}
