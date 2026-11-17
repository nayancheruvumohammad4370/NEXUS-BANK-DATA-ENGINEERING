
-- =====================================================
-- NEXUS BANK - SQL TRANSACTIONS AND ACID
-- All practical operations use temporary test data.
-- =====================================================

-- 1. BEGIN TRANSACTION + COMMIT
CREATE TABLE #BankTest (
    AccountID INT PRIMARY KEY,
    Balance DECIMAL(18,2)
);

INSERT INTO #BankTest VALUES
(101, 50000),
(102, 30000);

BEGIN TRANSACTION;

UPDATE #BankTest
SET Balance = Balance - 5000
WHERE AccountID = 101;

UPDATE #BankTest
SET Balance = Balance + 5000
WHERE AccountID = 102;

COMMIT TRANSACTION;

SELECT * FROM #BankTest;
-- Expected: Account 101 = 45000, Account 102 = 35000


-- 2. ROLLBACK
BEGIN TRANSACTION;

UPDATE #BankTest
SET Balance = Balance - 10000
WHERE AccountID = 101;

ROLLBACK TRANSACTION;

SELECT * FROM #BankTest;
-- Expected: balances remain 45000 and 35000


-- 3. SAVE TRANSACTION (SAVEPOINT)
BEGIN TRANSACTION;

UPDATE #BankTest
SET Balance = Balance - 2000
WHERE AccountID = 101;

SAVE TRANSACTION BeforeSecondUpdate;

UPDATE #BankTest
SET Balance = Balance + 2000
WHERE AccountID = 102;

ROLLBACK TRANSACTION BeforeSecondUpdate;

COMMIT TRANSACTION;

SELECT * FROM #BankTest;
-- Expected: Account 101 = 43000, Account 102 = 35000


-- 4. TRY...CATCH with transaction handling
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE #BankTest
    SET Balance = Balance - 1000
    WHERE AccountID = 101;

    -- Intentional error for safe error-handling practice
    THROW 50001, 'Simulated banking transaction error.', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        XACT_STATE() AS TransactionState;
END CATCH;

SELECT * FROM #BankTest;
-- Expected: balances remain 43000 and 35000


-- 5. Demonstrate transaction atomicity
BEGIN TRANSACTION;

UPDATE #BankTest
SET Balance = Balance - 500
WHERE AccountID = 101;

UPDATE #BankTest
SET Balance = Balance + 500
WHERE AccountID = 102;

COMMIT TRANSACTION;

SELECT * FROM #BankTest;
-- Expected: Account 101 = 42500, Account 102 = 35500


-- 6. Clean up
DROP TABLE #BankTest;
GO
