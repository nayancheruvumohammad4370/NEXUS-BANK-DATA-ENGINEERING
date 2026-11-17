
import pyodbc
import pandas as pd
from pathlib import Path
from datetime import datetime
import uuid
import re

# ==================================================
# 1. CONFIGURATION
# ==================================================

PIPELINE_NAME = "PY_METADATA_DRIVEN_EXTRACTION"

base_path = Path(__file__).resolve().parents[1]
data_folder = base_path / "data"
data_folder.mkdir(parents=True, exist_ok=True)

run_id = str(uuid.uuid4())
start_time = datetime.now()

total_rows = 0
success_count = 0
failure_count = 0

# ==================================================
# 2. DATABASE CONNECTION
# ==================================================

def get_connection():
    return pyodbc.connect(
        "DRIVER={ODBC Driver 18 for SQL Server};"
        "SERVER=.\\SQLEXPRESS;"
        "DATABASE=NexusBank_DB;"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

# ==================================================
# 3. AUDIT FUNCTION
# ==================================================

def write_audit(cursor, table_name, rows_read,
                rows_copied, status, error=None):

    cursor.execute("""
        INSERT INTO audit.PipelineAudit
        (
            PipelineName, TableName, RunID,
            StartTime, EndTime, RowsRead,
            RowsCopied, PipelineStatus, ErrorMessage
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """,
        PIPELINE_NAME,
        table_name,
        run_id,
        start_time,
        datetime.now(),
        rows_read,
        rows_copied,
        status,
        error
    )

# ==================================================
# 4. MAIN PIPELINE
# ==================================================

connection = None

try:

    connection = get_connection()
    cursor = connection.cursor()

    print("\nNEXUS BANK - METADATA EXTRACTION")
    print("Pipeline:", PIPELINE_NAME)
    print("Run ID:", run_id)

    # Read active metadata configurations
    config_query = """
        SELECT ConfigID, SourceSchema, SourceTable,
               TargetFolder, TargetFileName
        FROM control.IngestionConfig
        WHERE IsActive = 1
        ORDER BY ConfigID
    """

    configs = pd.read_sql_query(config_query, connection)

    print("Active tables found:", len(configs))

    # Process each configured table
    for _, config in configs.iterrows():

        schema = str(config["SourceSchema"])
        table = str(config["SourceTable"])
        folder = str(config["TargetFolder"])
        filename = str(config["TargetFileName"])

        rows_read = 0
        rows_copied = 0

        try:

            # Validate metadata identifiers
            if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", schema):
                raise ValueError("Invalid source schema")

            if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", table):
                raise ValueError("Invalid source table")

            if not re.fullmatch(r"[A-Za-z0-9_-]+", folder):
                raise ValueError("Invalid target folder")

            if not re.fullmatch(r"[A-Za-z0-9_.-]+\.parquet", filename):
                raise ValueError("Invalid target filename")

            # Incremental extraction for FactTransaction
            if table == "FactTransaction":

                watermark_df = pd.read_sql_query(
                    """
                    SELECT LastWatermarkValue
                    FROM control.WatermarkTable
                    WHERE TableName = ?
                    """,
                    connection,
                    params=[table]
                )

                if watermark_df.empty:
                    raise ValueError("FactTransaction watermark not found")

                last_watermark = watermark_df.iloc[0, 0]

                query = f"""
                    SELECT *
                    FROM [{schema}].[{table}]
                    WHERE TransactionDate > ?
                    ORDER BY TransactionDate
                """

                df = pd.read_sql_query(
                    query,
                    connection,
                    params=[last_watermark]
                )

            else:

                # Full extraction for other configured tables
                query = f"SELECT * FROM [{schema}].[{table}]"

                df = pd.read_sql_query(query, connection)

            rows_read = len(df)

            # Create target folder
            target_folder = data_folder / folder
            target_folder.mkdir(parents=True, exist_ok=True)

            output_file = target_folder / filename

            # Write Parquet output
            if not df.empty:

                # Append new transaction rows to existing Parquet
                if (
                    table == "FactTransaction"
                    and output_file.exists()
                ):
                    old_df = pd.read_parquet(output_file)

                    combined_df = pd.concat(
                        [old_df, df],
                        ignore_index=True
                    )

                    combined_df.to_parquet(
                        output_file,
                        index=False,
                        engine="pyarrow"
                    )

                else:

                    df.to_parquet(
                        output_file,
                        index=False,
                        engine="pyarrow"
                    )

                rows_copied = rows_read

                # Update watermark after successful file write
                if table == "FactTransaction":

                    new_watermark = pd.Timestamp(
                        df["TransactionDate"].max()
                    ).to_pydatetime()

                    cursor.execute(
                        """
                        UPDATE control.WatermarkTable
                        SET LastWatermarkValue = ?,
                            LastUpdatedDate = SYSDATETIME()
                        WHERE TableName = ?
                        """,
                        new_watermark,
                        table
                    )

                    if cursor.rowcount != 1:
                        raise ValueError("Watermark update failed")

                    connection.commit()

            print(
                f"SUCCESS: {table} | "
                f"Read: {rows_read} | "
                f"Copied: {rows_copied}"
            )

            # Success audit
            write_audit(
                cursor,
                table,
                rows_read,
                rows_copied,
                "Success"
            )

            connection.commit()

            total_rows += rows_copied
            success_count += 1

        except Exception as e:

            connection.rollback()

            print(f"FAILED: {table} | {str(e)}")

            try:
                write_audit(
                    cursor,
                    table,
                    rows_read,
                    rows_copied,
                    "Failed",
                    str(e)
                )

                connection.commit()

            except Exception as audit_error:
                connection.rollback()
                print("Audit logging failed:", audit_error)

            failure_count += 1

    # Final summary
    print("\n================================")
    print("METADATA EXTRACTION SUMMARY")
    print("================================")
    print("Total configured tables:", len(configs))
    print("Successful tables:", success_count)
    print("Failed tables:", failure_count)
    print("Total rows copied:", total_rows)
    print("Run ID:", run_id)
    print("Pipeline completed.")

except Exception as e:

    print("PIPELINE FAILED:", str(e))

finally:

    if connection is not None:
        connection.close()
        print("Database connection closed.")
