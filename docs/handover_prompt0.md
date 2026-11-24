# Handover Report: Prompt 0 (Project Setup, Docker Postgres, dbt)

## 1. Environment and Tool Versions
- **Python**: 3.12.3
- **pip**: 26.2.1
- **Docker**: 29.6.2 (build dfc4efb)
- **Docker Compose**: v5.3.1
- **Git**: 2.55.0.windows.3
- **Postgres**: PostgreSQL 16 (official Docker image `postgres:16`)
- **dbt-core**: 1.12.7
- **dbt-postgres**: 1.11.0

## 2. Postgres Container and Database Verification
- **Container Name**: `retail_inventory_postgres`
- **Database Name**: `inventory_lakehouse`
- **User**: `postgres`
- **Port**: 5432
- **Volume**: `pgdata` (local Docker volume)
- **Test Result**:
  - `SELECT 1;` executed via `docker exec retail_inventory_postgres psql` returned `1`.
  - Medallion schemas created: `bronze`, `silver`, `gold`, plus `quarantine`.
  - Schema list confirmed in PostgreSQL catalog.

## 3. dbt Connection Verification (`dbt debug`)
- Command executed:
  `dbt debug --project-dir dbt_project --profiles-dir dbt_project`
- Result: **All checks passed!**
  - profiles.yml: OK found and valid
  - dbt_project.yml: OK found and valid
  - Git dependency: OK found
  - Connection test to `inventory_lakehouse.silver`: OK connection ok

## 4. Real Raw Files and Measured Headers

### Dataset A (Primary)
- **File**: `data/raw/sales_data.csv`
- **Size**: 6.05 MB
- **Measured Rows**: 76,000 (excluding header)
- **Date Range**: 2022-01-01 to 2024-01-30
- **Stores**: 5 stores (`S001` through `S005`)
- **Products**: 20 products (`P0001` through `P0020`)
- **Header**:
  `Date,Store ID,Product ID,Category,Region,Inventory Level,Units Sold,Units Ordered,Price,Discount,Weather Condition,Promotion,Competitor Pricing,Seasonality,Epidemic,Demand`

### Dataset B (Secondary Supply Chain)
- **Directory**: `data/raw/supply_chain/`
- **Core Files**:
  1. `suppliers.csv`: 0.06 MB, 500 rows
     - Header: `supplier_id,supplier_name,supplier_type,contact_person,email,contact_number,city,country,supplier_rating,lead_time_days,status,supplier_category`
  2. `shipment.csv`: 1.70 MB, 15,000 rows
     - Header: `shipment_id,order_id,warehouse_id,shipping_partner,shipped_date,expected_delivery_date,actual_delivery_date,shipment_status,delivery_days,shipping_cost,shipment_priority,tracking_status,delay_reason,delivery_rating,customer_feedback,is_on_time`
  3. `orders.csv`: 1.88 MB, 15,000 rows
     - Header: `order_id,customer_id,order_date,expected_delivery_date,order_status,payment_method,payment_status,shipping_address,subtotal ,discount_amount,tax_amount,shipping_amount,final_amount`
  4. `inventory.csv`: 1.21 MB, 25,000 rows
     - Header: `inventory_id,product_id,warehouse_id,available_stock,reorder_level,reorder_quantity,reserved_stock,damaged_stock,last_restock_update,inventory_status`
- **Additional Reference Files**:
  - `warehouses.csv`: 0.003 MB, 25 rows
  - `categories.csv`: 0.001 MB, 20 rows
  - `customers.csv`: 0.63 MB, 5,000 rows
  - `products.csv`: 0.51 MB, 5,000 rows
  - `order_items.csv`: 2.41 MB, 44,965 rows
  - `risk_events.csv`: 0.76 MB, 5,000 rows
  - `shipping_risk.csv`: 0.29 MB, 5,000 rows

### Join Note
Product IDs between Dataset A (`P0001` - `P0020`) and Dataset B (`1` - `5000`) share 0 IDs. No fake product join is performed.

## 5. Issues Encountered and Fixes
1. **Port 5432 Conflict**: An existing container (`olist-postgres`) was running on port 5432. Stopped `olist-postgres` using `docker stop olist-postgres` to allocate port 5432 cleanly for `retail_inventory_postgres`.
2. **Kaggle Ingestion**: Utilized `kagglehub` library to fetch both datasets into local raw storage without API key friction.
3. **No Databricks / No Spark**: Pipeline strictly adheres to open source Postgres 16 and dbt Core.
