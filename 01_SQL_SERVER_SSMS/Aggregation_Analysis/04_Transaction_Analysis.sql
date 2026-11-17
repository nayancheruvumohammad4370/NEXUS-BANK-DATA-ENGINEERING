
-- =====================================================
-- NEXUS BANK - TRANSACTION BUSINESS ANALYSIS
-- =====================================================

-- 1. Overall transaction KPIs
SELECT
    COUNT(*) AS TotalTransactions,
    SUM(Amount) AS TotalTransactionAmount,
    AVG(Amount) AS AverageTransactionAmount,
    MIN(Amount) AS MinimumTransactionAmount,
    MAX(Amount) AS MaximumTransactionAmount
FROM bank.FactTransaction;


-- 2. Transaction status analysis
SELECT
    UPPER(LTRIM(RTRIM(TransactionStatus))) AS TransactionStatus,
    COUNT(*) AS TotalTransactions,
    SUM(Amount) AS TotalAmount
FROM bank.FactTransaction
GROUP BY UPPER(LTRIM(RTRIM(TransactionStatus)))
ORDER BY TotalTransactions DESC;


-- 3. Monthly transaction trends
SELECT
    YEAR(TransactionDate) AS TransactionYear,
    MONTH(TransactionDate) AS TransactionMonth,
    COUNT(*) AS TotalTransactions,
    SUM(Amount) AS TotalTransactionAmount
FROM bank.FactTransaction
WHERE TransactionDate IS NOT NULL
GROUP BY
    YEAR(TransactionDate),
    MONTH(TransactionDate)
ORDER BY TransactionYear, TransactionMonth;


-- 4. Top 10 branches by transaction amount
SELECT TOP 10
    b.BranchID,
    b.BranchName,
    b.City,
    COUNT(*) AS TotalTransactions,
    SUM(t.Amount) AS TotalTransactionAmount
FROM bank.FactTransaction t
INNER JOIN bank.DimAccount a
    ON t.AccountID = a.AccountID
INNER JOIN bank.DimBranch b
    ON a.BranchID = b.BranchID
GROUP BY b.BranchID, b.BranchName, b.City
ORDER BY TotalTransactionAmount DESC;


-- 5. Transaction channel analysis
SELECT
    UPPER(LTRIM(RTRIM(Channel))) AS TransactionChannel,
    COUNT(*) AS TotalTransactions,
    SUM(Amount) AS TotalAmount,
    AVG(Amount) AS AverageAmount
FROM bank.FactTransaction
GROUP BY UPPER(LTRIM(RTRIM(Channel)))
ORDER BY TotalTransactions DESC;


-- 6. Transaction type analysis
SELECT
    UPPER(LTRIM(RTRIM(TransactionType))) AS TransactionType,
    COUNT(*) AS TotalTransactions,
    SUM(Amount) AS TotalAmount
FROM bank.FactTransaction
GROUP BY UPPER(LTRIM(RTRIM(TransactionType)))
ORDER BY TotalAmount DESC;


-- 7. Daily transaction volume
SELECT
    CAST(TransactionDate AS DATE) AS TransactionDate,
    COUNT(*) AS TotalTransactions,
    SUM(Amount) AS TotalAmount
FROM bank.FactTransaction
WHERE TransactionDate IS NOT NULL
GROUP BY CAST(TransactionDate AS DATE)
ORDER BY TransactionDate;


-- 8. Transactions above average amount
SELECT
    TransactionID,
    AccountID,
    TransactionDate,
    Amount,
    TransactionType,
    TransactionStatus
FROM bank.FactTransaction
WHERE Amount > (
    SELECT AVG(Amount)
    FROM bank.FactTransaction
)
ORDER BY Amount DESC;
