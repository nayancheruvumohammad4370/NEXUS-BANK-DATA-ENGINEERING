
import pyodbc
import pandas as pd
from pathlib import Path

# Project paths
base_path = Path(__file__).resolve().parents[1]
output_folder = base_path / "data" / "branches"
output_folder.mkdir(parents=True, exist_ok=True)

# SQL Server connection
def get_connection():
    return pyodbc.connect(
        "DRIVER={ODBC Driver 18 for SQL Server};"
        "SERVER=.\\SQLEXPRESS;"
        "DATABASE=NexusBank_DB;"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

# Reusable extraction function
def extract_table(table_name):

    allowed_tables = ["DimBranch", "DimCustomer"]

    if table_name not in allowed_tables:
        raise ValueError("Table is not allowed")

    connection = get_connection()

    try:
        query = f"SELECT * FROM bank.{table_name}"
        df = pd.read_sql_query(query, connection)

        output_file = output_folder / f"{table_name}.csv"
        df.to_csv(output_file, index=False)

        print(f"Extracted table: {table_name}")
        print("Total records:", len(df))
        print("Saved:", output_file)

        return df

    finally:
        connection.close()

# Execute extraction
branch_df = extract_table("DimBranch")

print("\nFirst 5 records:")
print(branch_df.head())
