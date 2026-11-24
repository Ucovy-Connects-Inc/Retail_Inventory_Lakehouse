"""
pipelines/load_bronze.py

Ingests raw CSV files into the PostgreSQL bronze schema with audit metadata.
No data cleaning is performed in Bronze.
"""

import os
from datetime import datetime, timezone
from pathlib import Path
from dotenv import load_dotenv
import pandas as pd
from sqlalchemy import create_engine, text

# Load environment variables from .env
load_dotenv()

POSTGRES_USER = os.getenv("POSTGRES_USER", "postgres")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
POSTGRES_DB = os.getenv("POSTGRES_DB", "inventory_lakehouse")
POSTGRES_HOST = os.getenv("POSTGRES_HOST", "localhost")
POSTGRES_PORT = os.getenv("POSTGRES_PORT", "5432")

if not POSTGRES_PASSWORD:
    raise ValueError("POSTGRES_PASSWORD environment variable is not set. Check your .env file.")

DATABASE_URL = f"postgresql+psycopg2://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"
engine = create_engine(DATABASE_URL)

TABLES_TO_LOAD = [
    {
        "table_name": "bronze_sales",
        "file_path": Path("data/raw/sales_data.csv"),
    },
    {
        "table_name": "bronze_suppliers",
        "file_path": Path("data/raw/supply_chain/suppliers.csv"),
    },
    {
        "table_name": "bronze_shipments",
        "file_path": Path("data/raw/supply_chain/shipment.csv"),
    },
    {
        "table_name": "bronze_orders",
        "file_path": Path("data/raw/supply_chain/orders.csv"),
    },
    {
        "table_name": "bronze_inventory",
        "file_path": Path("data/raw/supply_chain/inventory.csv"),
    },
]

def load_bronze():
    print("Starting Bronze layer ingestion into PostgreSQL (inventory_lakehouse.bronze)...", flush=True)
    ingest_time = datetime.now(timezone.utc)
    results = []

    with engine.connect() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS bronze;"))
        conn.commit()

    for item in TABLES_TO_LOAD:
        table_name = item["table_name"]
        file_path = item["file_path"]

        if not file_path.exists():
            raise FileNotFoundError(f"Source file not found: {file_path}")

        print(f"\nReading {file_path}...", flush=True)
        df = pd.read_csv(file_path)
        raw_row_count = len(df)

        # Add audit columns
        df["_ingest_date"] = ingest_time
        df["_source_file"] = file_path.name

        print(f"Loading {raw_row_count:,} rows into bronze.{table_name}...", flush=True)
        # Use chunksize=2000 to remain safely under Postgres 65535 parameter limit
        df.to_sql(
            name=table_name,
            con=engine,
            schema="bronze",
            if_exists="replace",
            index=False,
            chunksize=2000,
            method="multi",
        )

        # Verify row count in database
        with engine.connect() as conn:
            db_row_count = conn.execute(text(f'SELECT COUNT(*) FROM bronze."{table_name}"')).scalar()

        print(f"Loaded bronze.{table_name}: CSV rows = {raw_row_count:,}, DB rows = {db_row_count:,}", flush=True)
        match = (raw_row_count == db_row_count)
        results.append({
            "table": f"bronze.{table_name}",
            "file": str(file_path),
            "csv_rows": raw_row_count,
            "db_rows": db_row_count,
            "match": match,
        })
        if not match:
            raise ValueError(f"Row count mismatch for {table_name}: raw {raw_row_count} vs DB {db_row_count}")

    print("\n" + "=" * 70, flush=True)
    print("Bronze Ingestion Summary", flush=True)
    print("=" * 70, flush=True)
    for r in results:
        status = "MATCH" if r["match"] else "MISMATCH"
        print(f"{r['table']:<25} | CSV: {r['csv_rows']:>7,} | DB: {r['db_rows']:>7,} | Status: {status}", flush=True)
    print("=" * 70, flush=True)

if __name__ == "__main__":
    load_bronze()
