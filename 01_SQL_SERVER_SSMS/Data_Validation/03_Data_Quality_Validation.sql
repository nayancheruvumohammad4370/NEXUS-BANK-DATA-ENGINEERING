
-- =====================================================
-- NEXUS BANK
-- DATA QUALITY VALIDATION
-- =====================================================

-- 1. Customer NULL checks
SELECT
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN Email IS NULL THEN 1 ELSE 0 END) AS NullEmails,
    SUM(CASE WHEN Phone IS NULL THEN 1 ELSE 0 END) AS NullPhones,
    SUM(CASE WHEN CustomerStatus IS NULL THEN 1 ELSE 0 END) AS NullStatuses
FROM bank.DimCustomer;


-- 2. Duplicate customer emails
SELECT
    LOWER(LTRIM(RTRIM(Email))) AS Email,
    COUNT(*) AS DuplicateCount
FROM bank.DimCustomer
WHERE Email IS NOT NULL
GROUP BY LOWER(LTRIM(RTRIM(Email)))
HAVING COUNT(*) > 1;


-- 3. Invalid email formats
SELECT CustomerID, Email
FROM bank.DimCustomer
WHERE Email IS NOT NULL
  AND Email NOT LIKE '%_@_%._%';


-- 4. Inconsistent customer statuses
SELECT
    CustomerStatus,
    COUNT(*) AS TotalCustomers
FROM bank.DimCustomer
GROUP BY CustomerStatus
ORDER BY TotalCustomers DESC;


-- 5. Negative account balances
SELECT
    AccountID,
    CustomerID,
    Balance
FROM bank.DimAccount
WHERE Balance < 0;


-- 6. Invalid transaction amounts
SELECT
    TransactionID,
    AccountID,
    Amount,
    TransactionStatus
FROM bank.FactTransaction
WHERE Amount <= 0 OR Amount IS NULL;


-- 7. Missing transaction dates
SELECT COUNT(*) AS MissingTransactionDates
FROM bank.FactTransaction
WHERE TransactionDate IS NULL;


-- 8. Duplicate transaction reference numbers
SELECT
    ReferenceNumber,
    COUNT(*) AS DuplicateCount
FROM bank.FactTransaction
WHERE ReferenceNumber IS NOT NULL
GROUP BY ReferenceNumber
HAVING COUNT(*) > 1;
