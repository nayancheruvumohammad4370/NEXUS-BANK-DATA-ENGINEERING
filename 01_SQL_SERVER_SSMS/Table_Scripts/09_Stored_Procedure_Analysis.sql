
-- =====================================================
-- NEXUS BANK - STORED PROCEDURE ANALYSIS
-- =====================================================

-- 1. Basic stored procedure
CREATE OR ALTER PROCEDURE bank.usp_GetCustomerCount
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) AS TotalCustomers
    FROM bank.DimCustomer;
END;
GO

EXEC bank.usp_GetCustomerCount;
GO


-- 2. Stored procedure with one input parameter
CREATE OR ALTER PROCEDURE bank.usp_GetCustomerByID
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM bank.DimCustomer
    WHERE CustomerID = @CustomerID;
END;
GO

EXEC bank.usp_GetCustomerByID @CustomerID = 1;
GO


-- 3. Multiple input parameters
CREATE OR ALTER PROCEDURE bank.usp_GetTransactionsByAccount
    @AccountID BIGINT,
    @MinimumAmount DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        TransactionID,
        AccountID,
        TransactionDate,
        TransactionType,
        Amount,
        TransactionStatus
    FROM bank.FactTransaction
    WHERE AccountID = @AccountID
      AND Amount >= @MinimumAmount
    ORDER BY TransactionDate DESC;
END;
GO

-- Replace values with an existing AccountID if needed.
EXEC bank.usp_GetTransactionsByAccount
    @AccountID = 1,
    @MinimumAmount = 1000;
GO


-- 4. Output parameter
CREATE OR ALTER PROCEDURE bank.usp_GetAccountBalance
    @CustomerID INT,
    @TotalBalance DECIMAL(18,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        @TotalBalance = COALESCE(SUM(Balance), 0)
    FROM bank.DimAccount
    WHERE CustomerID = @CustomerID;
END;
GO

DECLARE @Balance DECIMAL(18,2);

EXEC bank.usp_GetAccountBalance
    @CustomerID = 1,
    @TotalBalance = @Balance OUTPUT;

SELECT @Balance AS CustomerTotalBalance;
GO


-- 5. TRY...CATCH error handling
CREATE OR ALTER PROCEDURE bank.usp_GetCustomerSafe
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM bank.DimCustomer
            WHERE CustomerID = @CustomerID
        )
        BEGIN
            THROW 50001, 'Customer ID does not exist.', 1;
        END;

        SELECT *
        FROM bank.DimCustomer
        WHERE CustomerID = @CustomerID;
    END TRY
    BEGIN CATCH
        SELECT
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
GO

EXEC bank.usp_GetCustomerSafe @CustomerID = 1;
EXEC bank.usp_GetCustomerSafe @CustomerID = -1;
GO


-- 6. Practical customer transaction summary
CREATE OR ALTER PROCEDURE bank.usp_CustomerTransactionSummary
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.CustomerID,
        c.FirstName,
        c.LastName,
        COUNT(t.TransactionID) AS TotalTransactions,
        COALESCE(SUM(t.Amount), 0) AS TotalTransactionAmount,
        COALESCE(AVG(t.Amount), 0) AS AverageTransactionAmount
    FROM bank.DimCustomer c
    LEFT JOIN bank.DimAccount a
        ON c.CustomerID = a.CustomerID
    LEFT JOIN bank.FactTransaction t
        ON a.AccountID = t.AccountID
    WHERE c.CustomerID = @CustomerID
    GROUP BY
        c.CustomerID,
        c.FirstName,
        c.LastName;
END;
GO

EXEC bank.usp_CustomerTransactionSummary @CustomerID = 1;
GO
