
import pyodbc

server = r".\SQLEXPRESS"
database = "NexusBank_DB"
driver = "ODBC Driver 18 for SQL Server"

connection_string = (
    f"DRIVER={{{driver}}};"
    f"SERVER={server};"
    f"DATABASE={database};"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

try:
    connection = pyodbc.connect(connection_string)
    cursor = connection.cursor()

    cursor.execute("SELECT DB_NAME(), @@SERVERNAME")
    result = cursor.fetchone()

    print("SQL Server connection successful!")
    print("Database:", result[0])
    print("Server:", result[1])

    cursor.close()
    connection.close()

except Exception as error:
    print("Connection failed:", error)
