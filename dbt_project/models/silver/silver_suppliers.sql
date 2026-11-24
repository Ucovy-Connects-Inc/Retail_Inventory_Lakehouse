{{ config(
    materialized='table',
    schema='silver'
) }}

select *
from {{ ref('stg_suppliers') }}
where supplier_id is not null
  and status in ('Active', 'Inactive')
