# Retail Inventory Lakehouse (Postgres and dbt Version)

A free, local Medallion Lakehouse pipeline built using PostgreSQL 16 and dbt Core.

**Architecture Note**: This implementation runs entirely on free open source tools inside VS Code and Docker. No Databricks, no Apache Spark, no Delta Lake, and no paid cloud services are used.

## Architecture and Stack
- **Database**: PostgreSQL 16 (running via Docker Compose)
- **Transformation Engine**: dbt Core (v1.12+) with `dbt-postgres` adapter
- **Ingestion**: Python scripts (pandas, SQLAlchemy, psycopg2-binary)
- **Data Layers**:
  - `bronze`: Raw table ingestion with audit metadata
  - `silver`: Cleaned and validated staging models
  - `gold`: Business marts and aggregations
  - `quarantine`: Records failing data quality checks
- **Reporting**: Power BI Desktop (free local edition)

## Datasets
1. **Dataset A (Primary)**: [Retail Store Inventory and Demand Forecasting (Kaggle)](https://www.kaggle.com/datasets/atomicd/retail-store-inventory-and-demand-forecasting)
   - File: `sales_data.csv` (76,000 rows, 5 stores, 20 products, Jan 2022 to Jan 2024).
   - Core driver for store inventory, demand, and stockout analysis.
2. **Dataset B (Secondary)**: [End to End Supply Chain Dataset (Kaggle)](https://www.kaggle.com/datasets/shivangirathore28/end-to-end-supply-chain-dataset)
   - Files: `suppliers.csv`, `shipment.csv`, `orders.csv`, `inventory.csv`, etc.
   - Used for supplier lead time, warehouse logistics, and shipping performance metrics.

## How to Run

### 1. Prerequisites and Setup
1. Copy `.env.example` to `.env` and set your database password:
   ```bash
   cp .env.example .env
   ```
2. Start the Postgres container:
   ```bash
   docker compose up -d postgres
   ```
3. Create and activate a Python virtual environment:
   ```bash
   python -m venv .venv
   .\.venv\Scripts\activate   # Windows
   pip install -r requirements.txt
   ```

### 2. Verify Database Connection
Run dbt debug from the project root:
```bash
.\.venv\Scripts\dbt debug --project-dir dbt_project --profiles-dir dbt_project
```
All checks should report OK.
