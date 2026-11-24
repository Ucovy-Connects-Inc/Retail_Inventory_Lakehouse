# Handover Report: Prompt 1 (Bronze Ingestion into PostgreSQL)

## 1. Bronze Table Names and Row Counts

All 5 raw CSV sources have been loaded into PostgreSQL under the `bronze` schema without data transformation or data dropping:

| Source File | PostgreSQL Table | Raw CSV Rows | Database Rows | Match Status | Audit Columns Verified |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `data/raw/sales_data.csv` | `bronze.bronze_sales` | 76,000 | 76,000 | MATCH | `_ingest_date`, `_source_file` |
| `data/raw/supply_chain/suppliers.csv` | `bronze.bronze_suppliers` | 500 | 500 | MATCH | `_ingest_date`, `_source_file` |
| `data/raw/supply_chain/shipment.csv` | `bronze.bronze_shipments` | 15,000 | 15,000 | MATCH | `_ingest_date`, `_source_file` |
| `data/raw/supply_chain/orders.csv` | `bronze.bronze_orders` | 15,000 | 15,000 | MATCH | `_ingest_date`, `_source_file` |
| `data/raw/supply_chain/inventory.csv` | `bronze.bronze_inventory` | 25,000 | 25,000 | MATCH | `_ingest_date`, `_source_file` |
| **Total** | | **131,500** | **131,500** | **100% MATCH** | |

## 2. Ingestion Details and Handling of Source Files
- **File Loading**: All 5 files loaded cleanly with zero data drops.
- **Handling Parameter Bounds**: To ensure stability and prevent PostgreSQL 65,535 query parameter limits from being exceeded during multi-row inserts on wide tables (`bronze_sales` with 18 columns), chunks were set to 2,000 rows.
- **Exact Headers Preserved**: Space-containing column headers (such as `Store ID`, `Units Sold`, `subtotal `) were preserved exactly as read from raw CSVs using SQLAlchemy column quoting.
- **Audit Metadata**: Added `_ingest_date` (UTC timestamp) and `_source_file` (origin filename) to each table for lineage tracking.
- **No Cleaning Applied**: Nulls, raw data types, and values remain unchanged in Bronze; cleaning and validation are reserved for Silver via dbt.

## 3. Exact Commands Used

1. **Bronze Ingestion Command**:
   ```bash
   python pipelines/load_bronze.py
   ```
   (Executed using the workspace virtual environment: `.\.venv\Scripts\python -u pipelines\load_bronze.py`)

2. **Row Count and Audit Verification Command**:
   ```bash
   python pipelines/check_counts.py
   ```
   (Executed using: `.\.venv\Scripts\python pipelines\check_counts.py`)
