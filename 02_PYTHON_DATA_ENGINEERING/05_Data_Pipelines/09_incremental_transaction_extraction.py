
import pyodbc
import pandas as pd
import uuid
from pathlib import Path
from datetime import datetime

# Configuration
PIPELINE_NAME = "PY_INCREMENTAL_TRANSACTION_EXTRACTION"
TABLE_NAME = "FactTransaction"

base_path = Path(__file__).resolve().parents[1]
output_folder = base_path / "data" / "transactions"
output_folder.mkdir(parents=True, exist_ok=True)

output_file = output_folder / "incremental_transactions.csv"

run_id = str(uuid.uuid4())
start_time = datetime.now()

rows_read = 0
rows_copied = 0
pipeline_status = "Success"
error_message = None

connection = None

def get_connection():
    return pyodbc.connect(
        "DRIVER={ODBC Driver 18 for SQL Server};"
        "SERVER=.\\SQLEXPRESS;"
        "DATABASE=NexusBank_DB;"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

try:
    print("Pipeline started:", PIPELINE_NAME)
    print("Run ID:", run_id)

    connection = get_connection()

    # 1. Read previous watermark
    watermark_query = """
        SELECT LastWatermarkValue
        FROM control.WatermarkTable
        WHERE TableName = 'FactTransaction'
    """

    watermark_df = pd.read_sql_query(
        watermark_query, connection
    )

    if watermark_df.empty:
        raise RuntimeError("Watermark record not found")

    last_watermark = watermark_df.iloc[0, 0]
    print("Previous watermark:", last_watermark)

    # 2. Extract incremental records
    extraction_query = """
        SELECT *
        FROM bank.FactTransaction
        WHERE TransactionDate > ?
        ORDER BY TransactionDate
    """

    df = pd.read_sql_query(
        extraction_query,
        connection,
        params=[last_watermark]
    )

    rows_read = len(df)
    print("New transactions extracted:", rows_read)

    # 3. Save and update watermark
    if not df.empty:

        df.to_csv(output_file, index=False)
        rows_copied = rows_read

        print("CSV saved:", output_file)

        new_watermark = pd.Timestamp(
            df["TransactionDate"].max()
        ).to_pydatetime()

        cursor = connection.cursor()

        cursor.execute("""
            UPDATE control.WatermarkTable
            SET LastWatermarkValue = ?,
                LastUpdatedDate = SYSDATETIME()
            WHERE TableName = 'FactTransaction'
        """, new_watermark)

        if cursor.rowcount != 1:
            raise RuntimeError("Watermark update failed")

        connection.commit()
        cursor.close()

        print("Watermark updated:", new_watermark)

    else:
        print("No new transactions available.")

except Exception as e:

    pipeline_status = "Failed"
    error_message = str(e)

    if connection is not None:
        connection.rollback()

    print("Pipeline failed:", error_message)

finally:

    end_time = datetime.now()

    # 4. Insert audit record
    if connection is not None:
        try:
            audit_cursor = connection.cursor()

            audit_cursor.execute("""
                INSERT INTO audit.PipelineAudit
                (
                    PipelineName,
                    TableName,
                    RunID,
                    StartTime,
                    EndTime,
                    RowsRead,
                    RowsCopied,
                    PipelineStatus,
                    ErrorMessage
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
                PIPELINE_NAME,
                TABLE_NAME,
                run_id,
                start_time,
                end_time,
                rows_read,
                rows_copied,
                pipeline_status,
                error_message
            )

            connection.commit()
            audit_cursor.close()

            print("Audit record inserted successfully.")

        except Exception as audit_error:
            connection.rollback()
            print("Audit insertion failed:", audit_error)

        finally:
            connection.close()
            print("Database connection closed.")

    print("Final pipeline status:", pipeline_status)
