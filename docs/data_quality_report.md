# Data Quality Report: Retail Inventory Lakehouse

## Bronze Layer Ingestion Report

### 1. Ingestion Execution Summary
- **Execution Timestamp**: 2026-11-24 18:46:10 UTC
- **Ingestion Script**: `pipelines/load_bronze.py`
- **Target Schema**: `inventory_lakehouse.bronze`
- **Storage Engine**: PostgreSQL 16 (Docker)
- **Ingestion Status**: Successful (5 of 5 tables loaded cleanly)

### 2. Table Row Counts and Reconciliation
| Source File | Bronze Table | Raw CSV Rows | Bronze Table Rows | Audit Columns | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `data/raw/sales_data.csv` | `bronze.bronze_sales` | 76,000 | 76,000 | `_ingest_date`, `_source_file` | MATCH |
| `data/raw/supply_chain/suppliers.csv` | `bronze.bronze_suppliers` | 500 | 500 | `_ingest_date`, `_source_file` | MATCH |
| `data/raw/supply_chain/shipment.csv` | `bronze.bronze_shipments` | 15,000 | 15,000 | `_ingest_date`, `_source_file` | MATCH |
| `data/raw/supply_chain/orders.csv` | `bronze.bronze_orders` | 15,000 | 15,000 | `_ingest_date`, `_source_file` | MATCH |
| `data/raw/supply_chain/inventory.csv` | `bronze.bronze_inventory` | 25,000 | 25,000 | `_ingest_date`, `_source_file` | MATCH |
| **Total** | | **131,500** | **131,500** | | **100% MATCH** |

---

## Silver Layer Cleaning and dbt Testing Report

### 1. Silver Model Architecture
- **Staging Models (Views in `silver`)**: `stg_sales`, `stg_suppliers`, `stg_shipments`, `stg_orders`, `stg_inventory`
- **Physical Silver Tables (`silver`)**: `silver_sales`, `silver_suppliers`, `silver_shipments`, `silver_orders`, `silver_inventory`
- **Quarantine Table (`silver.silver_quarantine`)**: Captures failed records across Bronze tables with origin metadata, failure reason, and full JSON payload.
- **Transformation Operations**: Text fields trimmed, dates standardized to ISO `YYYY-MM-DD`, data types cast to appropriate PostgreSQL types, exact duplicates deduplicated.

### 2. Table Row Counts and Quarantine Summary
| Staging Model | Silver Table | Bronze Source Rows | Silver Clean Rows | Quarantine Rows | Pass Rate |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `stg_sales` | `silver.silver_sales` | 76,000 | 76,000 | 0 | 100.0% |
| `stg_suppliers` | `silver.silver_suppliers` | 500 | 500 | 0 | 100.0% |
| `stg_shipments` | `silver.silver_shipments` | 15,000 | 15,000 | 0 | 100.0% |
| `stg_orders` | `silver.silver_orders` | 15,000 | 15,000 | 0 | 100.0% |
| `stg_inventory` | `silver.silver_inventory` | 25,000 | 25,000 | 0 | 100.0% |
| **Quarantine** | `silver.silver_quarantine` | N/A | **0** | **0** | **100.0%** |

### 3. dbt Test Results (23 Data Tests)
All 23 data tests executed via `dbt test` passed with zero errors or warnings:

| Model | Test Name | Target Column / Expression | Pass Count | Fail Count | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `stg_sales` | `not_null` | `date` | 76,000 | 0 | PASS |
| `stg_sales` | `not_null` | `store_id` | 76,000 | 0 | PASS |
| `stg_sales` | `not_null` | `product_id` | 76,000 | 0 | PASS |
| `stg_sales` | `not_null` | `inventory_level` | 76,000 | 0 | PASS |
| `stg_sales` | `non_negative` | `inventory_level >= 0` | 76,000 | 0 | PASS |
| `stg_sales` | `non_negative` | `units_sold >= 0` | 76,000 | 0 | PASS |
| `stg_sales` | `non_negative` | `units_ordered >= 0` | 76,000 | 0 | PASS |
| `stg_sales` | `positive` | `price > 0` | 76,000 | 0 | PASS |
| `stg_sales` | `unique_combination_of_columns` | `date + store_id + product_id` | 76,000 | 0 | PASS |
| `stg_suppliers` | `not_null` | `supplier_id` | 500 | 0 | PASS |
| `stg_suppliers` | `unique` | `supplier_id` | 500 | 0 | PASS |
| `stg_suppliers` | `accepted_values` | `status in ('Active', 'Inactive')` | 500 | 0 | PASS |
| `stg_shipments` | `not_null` | `shipment_id` | 15,000 | 0 | PASS |
| `stg_shipments` | `unique` | `shipment_id` | 15,000 | 0 | PASS |
| `stg_shipments` | `accepted_values` | `shipment_status (6 valid states)` | 15,000 | 0 | PASS |
| `stg_orders` | `not_null` | `order_id` | 15,000 | 0 | PASS |
| `stg_orders` | `unique` | `order_id` | 15,000 | 0 | PASS |
| `stg_orders` | `accepted_values` | `order_status (6 valid states)` | 15,000 | 0 | PASS |
| `stg_inventory` | `not_null` | `inventory_id` | 25,000 | 0 | PASS |
| `stg_inventory` | `unique` | `inventory_id` | 25,000 | 0 | PASS |
| `stg_inventory` | `not_null` | `available_stock` | 25,000 | 0 | PASS |
| `stg_inventory` | `non_negative` | `available_stock >= 0` | 25,000 | 0 | PASS |
| `stg_inventory` | `accepted_values` | `inventory_status (4 valid states)` | 25,000 | 0 | PASS |

### 4. Null Analysis and Columns with > 5% Nulls
In accordance with instructions, no null values were artificially imputed or fabricated with averages. Real nulls are preserved as null.

#### Columns with greater than 5% Null Values:
All occurrences are concentrated in `silver.silver_shipments` and reflect genuine real-world supply chain states:
1. `silver.silver_shipments.delay_reason`: **14,250 nulls (95.00%)**
   - Natural business meaning: Populated only when a shipment encounters a transit delay.
2. `silver.silver_shipments.delivery_rating`: **4,572 nulls (30.48%)**
   - Natural business meaning: Optional customer rating provided upon delivery.
3. `silver.silver_shipments.customer_feedback`: **4,572 nulls (30.48%)**
   - Natural business meaning: Optional customer feedback text provided upon delivery.
4. `silver.silver_shipments.actual_delivery_date`: **3,972 nulls (26.48%)**
   - Natural business meaning: Null for shipments still in transit, out for delivery, returned, or lost.
5. `silver.silver_shipments.delivery_days`: **3,972 nulls (26.48%)**
   - Natural business meaning: Elapsed transit days calculated only after delivery completion.

All other columns across `silver_sales`, `silver_suppliers`, `silver_orders`, and `silver_inventory` have 0 null values (0.00%).
