-- NEXUS BANK: Table Row Count Validation

SELECT 'DimCustomer' AS TableName, COUNT(*) AS TotalRows FROM bank.DimCustomer
UNION ALL
SELECT 'DimBranch', COUNT(*) FROM bank.DimBranch
UNION ALL
SELECT 'DimAccount', COUNT(*) FROM bank.DimAccount
UNION ALL
SELECT 'DimCard', COUNT(*) FROM bank.DimCard
UNION ALL
SELECT 'DimMerchant', COUNT(*) FROM bank.DimMerchant
UNION ALL
SELECT 'DimDate', COUNT(*) FROM bank.DimDate
UNION ALL
SELECT 'FactTransaction', COUNT(*) FROM bank.FactTransaction
UNION ALL
SELECT 'FactPayment', COUNT(*) FROM bank.FactPayment
UNION ALL
SELECT 'FactATMWithdrawal', COUNT(*) FROM bank.FactATMWithdrawal
UNION ALL
SELECT 'FactLoginActivity', COUNT(*) FROM bank.FactLoginActivity
UNION ALL
SELECT 'WatermarkTable', COUNT(*) FROM control.WatermarkTable
UNION ALL
SELECT 'IngestionConfig', COUNT(*) FROM control.IngestionConfig
UNION ALL
SELECT 'PipelineAudit', COUNT(*) FROM audit.PipelineAudit;