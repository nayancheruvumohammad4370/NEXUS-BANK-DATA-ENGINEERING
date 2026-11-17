
-- =====================================================
-- NEXUS BANK - TEMPORARY TABLE ANALYSIS
-- =====================================================

-- 1. Create a local temporary table
DROP TABLE IF EXISTS #CustomerSummary;

CREATE TABLE #CustomerSummary (
    CustomerID INT,
    CustomerName VARCHAR(120),
    TotalAccounts INT,
    TotalBalance DECIMAL(18,2)
);


-- 2. Insert customer account summary
INSERT INTO #CustomerSummary
SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName),
    COUNT(a.AccountID),
    COALESCE(SUM(a.Balance), 0)
FROM bank.DimCustomer c
LEFT JOIN bank.DimAccount a
    ON c.CustomerID = a.CustomerID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName;


-- 3. View temporary table data
SELECT *
FROM #CustomerSummary
ORDER BY TotalBalance DESC;


-- 4. Update temporary table
UPDATE #CustomerSummary
SET CustomerName = UPPER(CustomerName)
WHERE TotalBalance > 100000;


-- 5. Filter high-balance customers
SELECT *
FROM #CustomerSummary
WHERE TotalBalance > 100000
ORDER BY TotalBalance DESC;


-- 6. Join temporary table with customer dimension
SELECT
    cs.CustomerID,
    cs.CustomerName,
    cs.TotalAccounts,
    cs.TotalBalance,
    c.CustomerSegment
FROM #CustomerSummary cs
INNER JOIN bank.DimCustomer c
    ON cs.CustomerID = c.CustomerID
ORDER BY cs.TotalBalance DESC;


-- 7. Temporary table aggregation
SELECT
    COUNT(*) AS TotalCustomers,
    SUM(TotalAccounts) AS TotalAccounts,
    SUM(TotalBalance) AS TotalBalance,
    AVG(TotalBalance) AS AverageCustomerBalance
FROM #CustomerSummary;


-- 8. Drop temporary table
DROP TABLE IF EXISTS #CustomerSummary;


-- 9. Verify it no longer exists
SELECT OBJECT_ID('tempdb..#CustomerSummary') AS TempTableObjectID;
