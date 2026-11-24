"""
pipelines/check_counts.py

Queries PostgreSQL to check row counts and audit columns for all Bronze tables.
"""

import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

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

BRONZE_TABLES = [
    "bronze_sales",
    "bronze_suppliers",
    "bronze_shipments",
    "bronze_orders",
    "bronze_inventory",
]

def check_counts():
    print("Checking Bronze table row counts in PostgreSQL (inventory_lakehouse.bronze):\n")
    print(f"{'Table Name':<25} | {'Row Count':>12} | {'Audit Columns Check':<30}")
    print("-" * 75)

    with engine.connect() as conn:
        for tbl in BRONZE_TABLES:
            count = conn.execute(text(f'SELECT COUNT(*) FROM bronze."{tbl}"')).scalar()
            
            # Verify audit columns exist
            cols_query = text("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_schema = 'bronze' AND table_name = :tbl
            """)
            cols = [row[0] for row in conn.execute(cols_query, {"tbl": tbl}).fetchall()]
            has_audit = ("_ingest_date" in cols) and ("_source_file" in cols)
            audit_status = "OK (_ingest_date, _source_file)" if has_audit else "MISSING AUDIT"

            print(f"{'bronze.' + tbl:<25} | {count:>12,} | {audit_status:<30}")
    print("-" * 75)

if __name__ == "__main__":
    check_counts()
