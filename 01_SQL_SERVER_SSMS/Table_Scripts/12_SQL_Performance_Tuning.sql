
-- =====================================================
-- NEXUS BANK - SQL PERFORMANCE TUNING
-- =====================================================

-- 1. Enable execution statistics
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- 2. Baseline query
SELECT *
FROM bank.FactTransaction
WHERE AccountID = 1;

-- 3. Optimized query: select only required columns
SELECT
    TransactionID,
    AccountID,
    TransactionDate,
    Amount,
    TransactionStatus
FROM bank.FactTransaction
WHERE AccountID = 1;

-- 4. SARGable query: use date range
SELECT
    TransactionID,
    TransactionDate,
    Amount
FROM bank.FactTransaction
WHERE TransactionDate >= '20260101'
  AND TransactionDate < '20270101';

-- 5. Non-SARGable comparison
-- Applying YEAR() to the column can prevent an index seek.
SELECT
    TransactionID,
    TransactionDate,
    Amount
FROM bank.FactTransaction
WHERE YEAR(TransactionDate) = 2026;

-- 6. Compare filtering methods
SELECT
    AccountID,
    COUNT(*) AS TotalTransactions,
    SUM(Amount) AS TotalAmount
FROM bank.FactTransaction
WHERE AccountID = 1
GROUP BY AccountID;

-- 7. Check available indexes
SELECT
    i.name AS IndexName,
    i.type_desc AS IndexType,
    COL_NAME(ic.object_id, ic.column_id) AS ColumnName,
    ic.key_ordinal AS KeyOrdinal,
    ic.is_included_column AS IsIncludedColumn
FROM sys.indexes i
INNER JOIN sys.index_columns ic
    ON i.object_id = ic.object_id
   AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID('bank.FactTransaction')
ORDER BY i.name, ic.key_ordinal;

-- 8. Check table statistics
SELECT
    name AS StatisticsName,
    auto_created,
    user_created,
    has_filter
FROM sys.stats
WHERE object_id = OBJECT_ID('bank.FactTransaction');

-- 9. Reset execution statistics
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
