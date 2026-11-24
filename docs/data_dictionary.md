# Data Dictionary: Retail Inventory Lakehouse (Postgres + dbt)

## Project Overview
This data dictionary documents the raw data sources ingested into the retail inventory lakehouse. The project uses a Medallion Architecture implemented locally with PostgreSQL 16 and dbt Core. No Databricks and no Spark are used.

---

## Dataset A: Main Store Sales and Demand (atomicd)
- **Source**: Kaggle `atomicd/retail-store-inventory-and-demand-forecasting`
- **File**: `data/raw/sales_data.csv`
- **File Size**: 6.05 MB
- **Total Rows**: 76,000
- **Date Range**: 2022-01-01 to 2024-01-30 (760 days)
- **Stores Count**: 5 stores (`S001`, `S002`, `S003`, `S004`, `S005`)
- **Products Count**: 20 products (`P0001` through `P0020`)
- **Categories (5)**: Electronics, Clothing, Groceries, Toys, Furniture
- **Regions (4)**: North, South, East, West
- **Grain**: 1 row per store, per product, per day (5 stores * 20 products * 760 days = 76,000 rows)

### Column Specifications (sales_data.csv)
| Column Name | Inferred Type | Sample Values | Description |
| :--- | :--- | :--- | :--- |
| `Date` | DATE | 2022-01-01, 2024-01-30 | Transaction / observation date |
| `Store ID` | VARCHAR(10) | S001, S005 | Store identifier (5 unique stores) |
| `Product ID` | VARCHAR(10) | P0001, P0020 | Product identifier (20 unique products) |
| `Category` | VARCHAR(50) | Electronics, Clothing | Product merchandise category |
| `Region` | VARCHAR(20) | North, South, East, West | Geographic region of the store |
| `Inventory Level` | INTEGER | 195, 117 | Current stock level at store end-of-day |
| `Units Sold` | INTEGER | 102, 114 | Units sold on this date |
| `Units Ordered` | INTEGER | 252, 612 | Units ordered for replenishment |
| `Price` | NUMERIC(10,2) | 72.72, 80.16 | Unit selling price |
| `Discount` | NUMERIC(5,2) | 5.0, 15.0 | Applied discount percentage |
| `Weather Condition` | VARCHAR(30) | Snowy, Rainy, Sunny | Weather observation on date |
| `Promotion` | INTEGER | 0, 1 | Promotion indicator flag (0 or 1) |
| `Competitor Pricing` | NUMERIC(10,2) | 85.73, 92.02 | Benchmark competitor unit price |
| `Seasonality` | VARCHAR(20) | Winter, Summer, Autumn | Seasonal classification tag |
| `Epidemic` | INTEGER | 0, 1 | Public health restriction flag |
| `Demand` | INTEGER | 115, 229 | Measured demand units |

---

## Dataset B: Supply Chain Operations (shivangirathore28)
- **Source**: Kaggle `shivangirathore28/end-to-end-supply-chain-dataset`
- **Location**: `data/raw/supply_chain/`
- **Suppliers Count**: 500 (`suppliers.csv`)
- **Warehouses Count**: 25 (`warehouses.csv`)
- **Products Count**: 5,000 (`products.csv`)
- **Inventory Records**: 25,000 (`inventory.csv`)
- **Orders Records**: 15,000 (`orders.csv`)
- **Shipment Records**: 15,000 (`shipment.csv`)

### 1. suppliers.csv
- **Rows**: 500
- **Size**: 0.06 MB
- **Columns**: `supplier_id`, `supplier_name`, `supplier_type`, `contact_person`, `email`, `contact_number`, `city`, `country`, `supplier_rating`, `lead_time_days`, `status`, `supplier_category`
- **Primary Key**: `supplier_id` (1 to 500)
- **Purpose**: Vendor details, supplier ratings, and vendor lead times (`lead_time_days`).

### 2. shipment.csv
- **Rows**: 15,000
- **Size**: 1.70 MB
- **Columns**: `shipment_id`, `order_id`, `warehouse_id`, `shipping_partner`, `shipped_date`, `expected_delivery_date`, `actual_delivery_date`, `shipment_status`, `delivery_days`, `shipping_cost`, `shipment_priority`, `tracking_status`, `delay_reason`, `delivery_rating`, `customer_feedback`, `is_on_time`
- **Date Range**: 01-01-2025 to 31-12-2025
- **Primary Key**: `shipment_id`
- **Foreign Keys**: `order_id` (links to `orders.csv`), `warehouse_id` (links to `warehouses.csv`)
- **Purpose**: Logistics, carrier delivery metrics, transit lead times, and shipping reliability.

### 3. orders.csv
- **Rows**: 15,000
- **Size**: 1.88 MB
- **Columns**: `order_id`, `customer_id`, `order_date`, `expected_delivery_date`, `order_status`, `payment_method`, `payment_status`, `shipping_address`, `subtotal `, `discount_amount`, `tax_amount`, `shipping_amount`, `final_amount`
- **Date Range**: 01-01-2025 to 31-12-2025
- **Primary Key**: `order_id`
- **Foreign Keys**: `customer_id` (links to `customers.csv`)
- **Purpose**: Order fulfillment dates and financials.

### 4. inventory.csv
- **Rows**: 25,000
- **Size**: 1.21 MB
- **Columns**: `inventory_id`, `product_id`, `warehouse_id`, `available_stock`, `reorder_level`, `reorder_quantity`, `reserved_stock`, `damaged_stock`, `last_restock_update`, `inventory_status`
- **Primary Key**: `inventory_id`
- **Foreign Keys**: `product_id` (1 to 5,000), `warehouse_id` (1 to 25)
- **Purpose**: Warehouse-level stock, reorder levels, available stock, and stock health status.

### 5. Other Supply Chain Reference Files
- `warehouses.csv`: 25 rows, warehouse details, storage capacity, and locations.
- `categories.csv`: 20 rows, category lookup table.
- `customers.csv`: 5,000 rows, customer demographics and tiers.
- `products.csv`: 5,000 rows, catalog items, pricing, profit margin, ratings.
- `order_items.csv`: 44,965 rows, line-item order details.
- `risk_events.csv`: 5,000 rows, supply chain disruption and severity logs.
- `shipping_risk.csv`: 5,000 rows, risk and delay factors.

---

## Join Analysis: Dataset A vs Dataset B
1. **Product ID Overlap**:
   - Dataset A Product IDs are strings: `P0001` through `P0020` (20 distinct values).
   - Dataset B Product IDs are integers: `1` through `5000` (5,000 distinct values).
   - Direct overlap count: **0**.
   - **Rule**: Antigravity will NOT force a join on product ID between Dataset A and Dataset B.

2. **Valid Joining Strategy**:
   - Dataset A remains the primary fact table for store inventory, demand, and stockout forecasting.
   - Dataset B is used independently for supplier lead time analysis (`suppliers.csv`, `shipment.csv`) and warehouse inventory distribution (`inventory.csv`, `warehouses.csv`).
   - Where joined, entities are aligned at the category level (e.g., Electronics, Clothing) or analyzed side-by-side in mart aggregations.
