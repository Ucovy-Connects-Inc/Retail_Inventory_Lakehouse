# Handover Report: Prompt 2 (Silver Cleaning and dbt Testing)

## 1. Silver and Quarantine Table Row Counts

The Silver layer was built using dbt Core against PostgreSQL 16. All staging models and physical Silver tables were materialized into the `silver` schema:

| Layer / Model | Relation Type | Target Relation | Row Count | Quarantine Count |
| :--- | :--- | :--- | :--- | :--- |
| Staging | View | `silver.stg_sales` | 76,000 | 0 |
| Staging | View | `silver.stg_suppliers` | 500 | 0 |
| Staging | View | `silver.stg_shipments` | 15,000 | 0 |
| Staging | View | `silver.stg_orders` | 15,000 | 0 |
| Staging | View | `silver.stg_inventory` | 25,000 | 0 |
| **Silver Mart Feed** | **Table** | `silver.silver_sales` | **76,000** | **0** |
| **Silver Mart Feed** | **Table** | `silver.silver_suppliers` | **500** | **0** |
| **Silver Mart Feed** | **Table** | `silver.silver_shipments` | **15,000** | **0** |
| **Silver Mart Feed** | **Table** | `silver.silver_orders` | **15,000** | **0** |
| **Silver Mart Feed** | **Table** | `silver.silver_inventory` | **25,000** | **0** |
| **Quarantine** | **Table** | `silver.silver_quarantine` | **0** | **0** |

All 131,500 records across the 5 tables satisfied the data quality checks and advanced to Silver. Zero records were quarantined.

## 2. dbt Test Execution Results

Total tests executed: **23**  
Tests passed: **23 (100%)**  
Tests failed: **0 (0%)**  
Warnings: **0**

Detailed test status breakdown:
1. `not_null_stg_sales_date`: **PASS** (76,000 checked)
2. `not_null_stg_sales_store_id`: **PASS** (76,000 checked)
3. `not_null_stg_sales_product_id`: **PASS** (76,000 checked)
4. `not_null_stg_sales_inventory_level`: **PASS** (76,000 checked)
5. `non_negative_stg_sales_inventory_level`: **PASS** (76,000 checked)
6. `non_negative_stg_sales_units_sold`: **PASS** (76,000 checked)
7. `non_negative_stg_sales_units_ordered`: **PASS** (76,000 checked)
8. `positive_stg_sales_price`: **PASS** (76,000 checked)
9. `unique_combination_of_columns_stg_sales_date__store_id__product_id`: **PASS** (76,000 checked)
10. `not_null_stg_suppliers_supplier_id`: **PASS** (500 checked)
11. `unique_stg_suppliers_supplier_id`: **PASS** (500 checked)
12. `accepted_values_stg_suppliers_status`: **PASS** (`Active`, `Inactive`)
13. `not_null_stg_shipments_shipment_id`: **PASS** (15,000 checked)
14. `unique_stg_shipments_shipment_id`: **PASS** (15,000 checked)
15. `accepted_values_stg_shipments_shipment_status`: **PASS** (`Delivered`, `Delayed`, `In Transit`, `Out for Delivery`, `Returned`, `Lost`)
16. `not_null_stg_orders_order_id`: **PASS** (15,000 checked)
17. `unique_stg_orders_order_id`: **PASS** (15,000 checked)
18. `accepted_values_stg_orders_order_status`: **PASS** (`Cancelled`, `Delivered`, `Pending`, `Processing`, `Returned`, `Shipped`)
19. `not_null_stg_inventory_inventory_id`: **PASS** (25,000 checked)
20. `unique_stg_inventory_inventory_id`: **PASS** (25,000 checked)
21. `not_null_stg_inventory_available_stock`: **PASS** (25,000 checked)
22. `non_negative_stg_inventory_available_stock`: **PASS** (25,000 checked)
23. `accepted_values_stg_inventory_inventory_status`: **PASS** (`In Stock`, `Low Stock`, `Out of Stock`, `Overstock`)

## 3. Top Failing Tests
- **Top 1 Failing Test**: None (0 failures)
- **Top 2 Failing Test**: None (0 failures)
- **Top 3 Failing Test**: None (0 failures)

All defined quality expectations passed completely.

## 4. Columns with Greater than 5 Percent Nulls

All nulls were preserved as real null values without fabrication or arbitrary imputation. Only 5 columns across the entire lakehouse have nulls exceeding 5%, all located in `silver_shipments`:

1. `delay_reason`: **14,250 nulls (95.00%)**
   - Legitimate nulls for on-time and delivered shipments without delays.
2. `delivery_rating`: **4,572 nulls (30.48%)**
   - Unrated deliveries where customer rating was omitted.
3. `customer_feedback`: **4,572 nulls (30.48%)**
   - Deliveries where textual comments were omitted.
4. `actual_delivery_date`: **3,972 nulls (26.48%)**
   - Active shipments that are currently in transit, out for delivery, returned, or lost.
5. `delivery_days`: **3,972 nulls (26.48%)**
   - Transit duration uncalculated while shipments remain in transit.

All columns in `silver_sales`, `silver_suppliers`, `silver_orders`, and `silver_inventory` have **0.00% nulls**.

## 5. Technology and Governance Notes
- **DLT Replacement**: Standard dbt data tests and custom schema validation macros were used instead of Delta Live Tables (DLT) expectations.
- **Quarantine Pattern**: A dedicated model `silver.silver_quarantine` was established to intercept and hold non-compliant rows with full payload tracing.
- **Environment**: Local PostgreSQL 16 in Docker, dbt Core 1.12.7, and `dbt-postgres` adapter.
