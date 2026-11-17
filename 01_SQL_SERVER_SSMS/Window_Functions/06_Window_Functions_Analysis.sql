
-- =====================================================
-- NEXUS BANK - WINDOW FUNCTIONS ANALYSIS
-- =====================================================

-- 1. ROW_NUMBER: Rank transactions by amount
SELECT
    TransactionID,
    AccountID,
    Amount,
    ROW_NUMBER() OVER (
        ORDER BY Amount DESC
    ) AS RowNum
FROM bank.FactTransaction;


-- 2. RANK: Rank transactions by amount
SELECT
    TransactionID,
    Amount,
    RANK() OVER (
        ORDER BY Amount DESC
    ) AS TransactionRank
FROM bank.FactTransaction;


-- 3. DENSE_RANK: Rank customers by total account balance
WITH CustomerBalances AS (
    SELECT
        CustomerID,
        SUM(Balance) AS TotalBalance
    FROM bank.DimAccount
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    TotalBalance,
    DENSE_RANK() OVER (
        ORDER BY TotalBalance DESC
    ) AS BalanceRank
FROM CustomerBalances;


-- 4. LAG: Compare current transaction with previous transaction
SELECT
    AccountID,
    TransactionDate,
    Amount,
    LAG(Amount) OVER (
        PARTITION BY AccountID
        ORDER BY TransactionDate, TransactionID
    ) AS PreviousTransactionAmount
FROM bank.FactTransaction;


-- 5. LEAD: View next transaction amount
SELECT
    AccountID,
    TransactionDate,
    Amount,
    LEAD(Amount) OVER (
        PARTITION BY AccountID
        ORDER BY TransactionDate, TransactionID
    ) AS NextTransactionAmount
FROM bank.FactTransaction;


-- 6. Running total by account
SELECT
    AccountID,
    TransactionDate,
    Amount,
    SUM(Amount) OVER (
        PARTITION BY AccountID
        ORDER BY TransactionDate, TransactionID
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTransactionAmount
FROM bank.FactTransaction;


-- 7. Monthly transaction amount with previous month comparison
WITH MonthlyTransactions AS (
    SELECT
        YEAR(TransactionDate) AS TransactionYear,
        MONTH(TransactionDate) AS TransactionMonth,
        SUM(Amount) AS MonthlyAmount
    FROM bank.FactTransaction
    WHERE TransactionDate IS NOT NULL
    GROUP BY
        YEAR(TransactionDate),
        MONTH(TransactionDate)
)
SELECT
    TransactionYear,
    TransactionMonth,
    MonthlyAmount,
    LAG(MonthlyAmount) OVER (
        ORDER BY TransactionYear, TransactionMonth
    ) AS PreviousMonthAmount,
    MonthlyAmount -
    LAG(MonthlyAmount) OVER (
        ORDER BY TransactionYear, TransactionMonth
    ) AS AmountDifference
FROM MonthlyTransactions;


-- 8. Top 3 transactions per account
WITH RankedTransactions AS (
    SELECT
        TransactionID,
        AccountID,
        Amount,
        ROW_NUMBER() OVER (
            PARTITION BY AccountID
            ORDER BY Amount DESC
        ) AS TransactionRank
    FROM bank.FactTransaction
)
SELECT
    TransactionID,
    AccountID,
    Amount,
    TransactionRank
FROM RankedTransactions
WHERE TransactionRank <= 3
ORDER BY AccountID, TransactionRank;
