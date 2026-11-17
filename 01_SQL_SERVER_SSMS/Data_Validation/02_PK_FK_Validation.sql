-- NEXUS BANK: Primary Key and Foreign Key Validation

-- 1. Check primary key duplicates
SELECT 'DimCustomer' AS TableName,
       COUNT(*) - COUNT(DISTINCT CustomerID) AS DuplicatePKs
FROM bank.DimCustomer
UNION ALL
SELECT 'DimAccount',
       COUNT(*) - COUNT(DISTINCT AccountID)
FROM bank.DimAccount
UNION ALL
SELECT 'DimBranch',
       COUNT(*) - COUNT(DISTINCT BranchID)
FROM bank.DimBranch
UNION ALL
SELECT 'DimMerchant',
       COUNT(*) - COUNT(DISTINCT MerchantID)
FROM bank.DimMerchant
UNION ALL
SELECT 'FactTransaction',
       COUNT(*) - COUNT(DISTINCT TransactionID)
FROM bank.FactTransaction;

-- 2. Check foreign key orphan records
SELECT 'Account-Customer' AS Relationship,
       COUNT(*) AS OrphanRecords
FROM bank.DimAccount a
LEFT JOIN bank.DimCustomer c ON a.CustomerID = c.CustomerID
WHERE a.CustomerID IS NOT NULL AND c.CustomerID IS NULL

UNION ALL

SELECT 'Account-Branch',
       COUNT(*)
FROM bank.DimAccount a
LEFT JOIN bank.DimBranch b ON a.BranchID = b.BranchID
WHERE a.BranchID IS NOT NULL AND b.BranchID IS NULL

UNION ALL

SELECT 'Transaction-Account',
       COUNT(*)
FROM bank.FactTransaction t
LEFT JOIN bank.DimAccount a ON t.AccountID = a.AccountID
WHERE t.AccountID IS NOT NULL AND a.AccountID IS NULL

UNION ALL

SELECT 'Transaction-Merchant',
       COUNT(*)
FROM bank.FactTransaction t
LEFT JOIN bank.DimMerchant m ON t.MerchantID = m.MerchantID
WHERE t.MerchantID IS NOT NULL AND m.MerchantID IS NULL;