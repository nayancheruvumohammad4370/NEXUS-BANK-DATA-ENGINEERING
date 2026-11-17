
import pyodbc
import pandas as pd
from pathlib import Path

base_path = Path(__file__).resolve().parents[1]
data_folder = base_path / "data"

tables = {
    "DimAccount": "accounts",
    "DimCard": "cards",
    "DimMerchant": "merchants"
}

def get_connection():
    return pyodbc.connect(
        "DRIVER={ODBC Driver 18 for SQL Server};"
        "SERVER=.\\SQLEXPRESS;"
        "DATABASE=NexusBank_DB;"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

def extract_table(table_name, folder_name, connection):
    query = f"SELECT * FROM bank.{table_name}"
    df = pd.read_sql_query(query, connection)

    output_folder = data_folder / folder_name
    output_folder.mkdir(parents=True, exist_ok=True)

    output_file = output_folder / f"{table_name}.csv"
    df.to_csv(output_file, index=False)

    print(f"{table_name}: {len(df)} records extracted")
    print(f"Saved: {output_file}")

    return len(df)

connection = get_connection()

try:
    total_records = 0

    for table_name, folder_name in tables.items():
        total_records += extract_table(
            table_name, folder_name, connection
        )

    print("\nAll table extractions completed!")
    print("Total records extracted:", total_records)

finally:
    connection.close()
