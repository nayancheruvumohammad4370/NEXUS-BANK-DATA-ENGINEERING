
-- =====================================================
-- NEXUS BANK - VIEWS AND INDEXES
-- =====================================================

-- 1. Create a basic customer view
CREATE OR ALTER VIEW bank.vw_CustomerDetails
AS
SELECT
    CustomerID,
    FirstName,
    LastName,
    Email,
    Phone,
    City,
    State,
    CustomerSegment,
    CustomerStatus
FROM bank.DimCustomer;
GO

SELECT *
FROM bank.vw_CustomerDetails;
GO


-- 2. Create a view using JOIN
CREATE OR ALTER VIEW bank.vw_CustomerAccountSummary
AS
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(a.AccountID) AS TotalAccounts,
    COALESCE(SUM(a.Balance), 0) AS TotalBalance
FROM bank.DimCustomer c
LEFT JOIN bank.DimAccount a
    ON c.CustomerID = a.CustomerID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName;
GO

SELECT *
FROM bank.vw_CustomerAccountSummary
ORDER BY TotalBalance DESC;
GO


-- 3. Create a transaction summary view
CREATE OR ALTER VIEW bank.vw_TransactionSummary
AS
SELECT
    TransactionStatus,
    COUNT(*) AS TotalTransactions,
    SUM(Amount) AS TotalAmount,
    AVG(Amount) AS AverageAmount
FROM bank.FactTransaction
GROUP BY TransactionStatus;
GO

SELECT *
FROM bank.vw_TransactionSummary;
GO


-- 4. Create a nonclustered index
-- Check existing indexes before creating.
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_FactTransaction_AccountID'
      AND object_id = OBJECT_ID('bank.FactTransaction')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_FactTransaction_AccountID
    ON bank.FactTransaction (AccountID);
END;
GO


-- 5. Create a composite nonclustered index
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_FactTransaction_AccountDate'
      AND object_id = OBJECT_ID('bank.FactTransaction')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_FactTransaction_AccountDate
    ON bank.FactTransaction (AccountID, TransactionDate)
    INCLUDE (Amount, TransactionStatus);
END;
GO


-- 6. View index metadata
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique AS IsUnique
FROM sys.indexes i
WHERE i.object_id IN (
    OBJECT_ID('bank.FactTransaction'),
    OBJECT_ID('bank.DimCustomer'),
    OBJECT_ID('bank.DimAccount')
)
AND i.name IS NOT NULL
ORDER BY TableName, IndexName;
GO


-- 7. View index column details
SELECT
    i.name AS IndexName,
    COL_NAME(ic.object_id, ic.column_id) AS ColumnName,
    ic.key_ordinal AS KeyOrdinal,
    ic.is_included_column AS IsIncludedColumn
FROM sys.indexes i
INNER JOIN sys.index_columns ic
    ON i.object_id = ic.object_id
   AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID('bank.FactTransaction')
AND i.name IN (
    'IX_FactTransaction_AccountID',
    'IX_FactTransaction_AccountDate'
)
ORDER BY i.name, ic.key_ordinal;
GO


-- 8. Compare query execution plans
-- In SSMS press Ctrl + M before executing these queries.

SELECT *
FROM bank.FactTransaction
WHERE AccountID = 1;

SELECT *
FROM bank.FactTransaction
WHERE AccountID = 1
  AND TransactionDate >= '2026-01-01';
GO


-- 9. View existing table index usage statistics
SELECT
    OBJECT_NAME(s.object_id) AS TableName,
    i.name AS IndexName,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i
    ON s.object_id = i.object_id
   AND s.index_id = i.index_id
WHERE s.database_id = DB_ID()
  AND s.object_id = OBJECT_ID('bank.FactTransaction');
GO
