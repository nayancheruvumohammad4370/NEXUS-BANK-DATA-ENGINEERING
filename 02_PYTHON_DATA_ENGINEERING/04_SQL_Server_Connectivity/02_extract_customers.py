
import pyodbc
import pandas as pd
from pathlib import Path

# SQL Server connection
connection = pyodbc.connect(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=.\\SQLEXPRESS;"
    "DATABASE=NexusBank_DB;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

# Extract existing customers
query = "SELECT * FROM bank.DimCustomer"

df = pd.read_sql_query(query, connection)

# Close connection
connection.close()

# Save CSV in project data folder
output_path = (
    Path(__file__).resolve().parents[1]
    / "data"
    / "customers"
    / "customers_raw.csv"
)

output_path.parent.mkdir(parents=True, exist_ok=True)
df.to_csv(output_path, index=False)

# Verify extraction
print("Customer extraction successful!")
print("Total rows:", len(df))
print("Columns:", list(df.columns))
print("Saved file:", output_path)
print(df.head())
