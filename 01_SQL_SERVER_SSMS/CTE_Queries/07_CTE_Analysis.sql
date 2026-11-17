
-- =====================================================
-- NEXUS BANK - CTE ANALYSIS
-- =====================================================

-- 1. Basic CTE: Customers by segment
WITH CustomerSegments AS (
    SELECT
        CustomerSegment,
        COUNT(*) AS TotalCustomers
    FROM bank.DimCustomer
    GROUP BY CustomerSegment
)
SELECT *
FROM CustomerSegments
ORDER BY TotalCustomers DESC;


-- 2. Multiple CTEs: Customer and account summary
WITH CustomerCounts AS (
    SELECT
        CustomerID,
        COUNT(*) AS TotalAccounts
    FROM bank.DimAccount
    GROUP BY CustomerID
),
BalanceSummary AS (
    SELECT
        CustomerID,
        SUM(Balance) AS TotalBalance
    FROM bank.DimAccount
    GROUP BY CustomerID
)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    cc.TotalAccounts,
    bs.TotalBalance
FROM bank.DimCustomer c
LEFT JOIN CustomerCounts cc
    ON c.CustomerID = cc.CustomerID
LEFT JOIN BalanceSummary bs
    ON c.CustomerID = bs.CustomerID
ORDER BY bs.TotalBalance DESC;


-- 3. CTE with aggregation: Monthly transactions
WITH MonthlySummary AS (
    SELECT
        YEAR(TransactionDate) AS TransactionYear,
        MONTH(TransactionDate) AS TransactionMonth,
        COUNT(*) AS TotalTransactions,
        SUM(Amount) AS TotalAmount
    FROM bank.FactTransaction
    WHERE TransactionDate IS NOT NULL
    GROUP BY
        YEAR(TransactionDate),
        MONTH(TransactionDate)
)
SELECT *
FROM MonthlySummary
ORDER BY TransactionYear, TransactionMonth;


-- 4. CTE with ranking: Top 3 customers by balance
WITH CustomerBalance AS (
    SELECT
        CustomerID,
        SUM(Balance) AS TotalBalance
    FROM bank.DimAccount
    GROUP BY CustomerID
),
RankedCustomers AS (
    SELECT
        CustomerID,
        TotalBalance,
        DENSE_RANK() OVER (
            ORDER BY TotalBalance DESC
        ) AS CustomerRank
    FROM CustomerBalance
)
SELECT *
FROM RankedCustomers
WHERE CustomerRank <= 3
ORDER BY CustomerRank;


-- 5. Identify customers without accounts
WITH CustomerAccountSummary AS (
    SELECT
        c.CustomerID,
        c.FirstName,
        c.LastName,
        COUNT(a.AccountID) AS TotalAccounts
    FROM bank.DimCustomer c
    LEFT JOIN bank.DimAccount a
        ON c.CustomerID = a.CustomerID
    GROUP BY
        c.CustomerID,
        c.FirstName,
        c.LastName
)
SELECT *
FROM CustomerAccountSummary
WHERE TotalAccounts = 0;


-- 6. Identify customers without successful transactions
WITH SuccessfulActivity AS (
    SELECT DISTINCT a.CustomerID
    FROM bank.FactTransaction t
    INNER JOIN bank.DimAccount a
        ON t.AccountID = a.AccountID
    WHERE UPPER(LTRIM(RTRIM(t.TransactionStatus)))
          IN ('SUCCESS', 'SUCCESSFUL')
)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName
FROM bank.DimCustomer c
LEFT JOIN SuccessfulActivity s
    ON c.CustomerID = s.CustomerID
WHERE s.CustomerID IS NULL;


-- 7. Recursive CTE: Generate numbers from 1 to 12
WITH MonthNumbers AS (
    SELECT 1 AS MonthNumber

    UNION ALL

    SELECT MonthNumber + 1
    FROM MonthNumbers
    WHERE MonthNumber < 12
)
SELECT MonthNumber
FROM MonthNumbers
OPTION (MAXRECURSION 12);
