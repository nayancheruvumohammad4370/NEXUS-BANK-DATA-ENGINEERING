
-- =====================================================
-- NEXUS BANK - CUSTOMER & ACCOUNT ANALYSIS
-- =====================================================

-- 1. Customer distribution by segment
SELECT
    UPPER(LTRIM(RTRIM(CustomerSegment))) AS CustomerSegment,
    COUNT(*) AS TotalCustomers
FROM bank.DimCustomer
GROUP BY UPPER(LTRIM(RTRIM(CustomerSegment)))
ORDER BY TotalCustomers DESC;


-- 2. Customer status analysis
SELECT
    UPPER(LTRIM(RTRIM(CustomerStatus))) AS CustomerStatus,
    COUNT(*) AS TotalCustomers
FROM bank.DimCustomer
GROUP BY UPPER(LTRIM(RTRIM(CustomerStatus)))
ORDER BY TotalCustomers DESC;


-- 3. Customer-wise account count
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(a.AccountID) AS TotalAccounts
FROM bank.DimCustomer c
LEFT JOIN bank.DimAccount a
    ON c.CustomerID = a.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalAccounts DESC;


-- 4. Account type distribution
SELECT
    UPPER(LTRIM(RTRIM(AccountType))) AS AccountType,
    COUNT(*) AS TotalAccounts
FROM bank.DimAccount
GROUP BY UPPER(LTRIM(RTRIM(AccountType)))
ORDER BY TotalAccounts DESC;


-- 5. Total account balance by account type
SELECT
    UPPER(LTRIM(RTRIM(AccountType))) AS AccountType,
    COUNT(*) AS TotalAccounts,
    SUM(Balance) AS TotalBalance,
    AVG(Balance) AS AverageBalance
FROM bank.DimAccount
GROUP BY UPPER(LTRIM(RTRIM(AccountType)))
ORDER BY TotalBalance DESC;


-- 6. Top 10 customers by total account balance
SELECT TOP 10
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(a.AccountID) AS TotalAccounts,
    SUM(a.Balance) AS TotalBalance
FROM bank.DimCustomer c
INNER JOIN bank.DimAccount a
    ON c.CustomerID = a.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalBalance DESC;


-- 7. Customers without accounts
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.CustomerStatus
FROM bank.DimCustomer c
LEFT JOIN bank.DimAccount a
    ON c.CustomerID = a.CustomerID
WHERE a.AccountID IS NULL;


-- 8. Account status analysis
SELECT
    UPPER(LTRIM(RTRIM(AccountStatus))) AS AccountStatus,
    COUNT(*) AS TotalAccounts,
    SUM(Balance) AS TotalBalance
FROM bank.DimAccount
GROUP BY UPPER(LTRIM(RTRIM(AccountStatus)))
ORDER BY TotalAccounts DESC;
