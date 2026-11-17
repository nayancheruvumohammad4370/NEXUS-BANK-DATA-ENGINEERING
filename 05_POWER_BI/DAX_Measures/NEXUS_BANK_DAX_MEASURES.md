\# NEXUS BANK – POWER BI DAX MEASURES



\## Project

NEXUS BANK – Enterprise Banking Data Intelligence Platform



\## Purpose

This document contains the DAX measures used for banking transaction, customer, account, payment, ATM and login analytics.



\## 1. Transaction KPIs



```dax

Total Transactions =

COUNTROWS(FactTransaction)



Total Transaction Amount =

SUM(FactTransaction\[Amount])



Average Transaction Amount =

AVERAGE(FactTransaction\[Amount])



Maximum Transaction Amount =

MAX(FactTransaction\[Amount])



Minimum Transaction Amount =

MIN(FactTransaction\[Amount])

```



\## 2. Transaction Status



```dax

Successful Transactions =

CALCULATE(

&#x20;   \[Total Transactions],

&#x20;   FactTransaction\[TransactionStatus] = "Success"

)



Failed Transactions =

CALCULATE(

&#x20;   \[Total Transactions],

&#x20;   FactTransaction\[TransactionStatus] = "Failed"

)



Pending Transactions =

CALCULATE(

&#x20;   \[Total Transactions],

&#x20;   FactTransaction\[TransactionStatus] = "Pending"

)



Transaction Success Rate =

DIVIDE(

&#x20;   \[Successful Transactions],

&#x20;   \[Total Transactions],

&#x20;   0

)

```



\## 3. Customer and Account Analytics



```dax

Total Customers =

DISTINCTCOUNT(DimCustomer\[CustomerID])



Total Accounts =

DISTINCTCOUNT(DimAccount\[AccountID])



Total Account Balance =

SUM(DimAccount\[Balance])

```



\## 4. Payment Analytics



```dax

Total Payments =

COUNTROWS(FactPayment)



Total Payment Amount =

SUM(FactPayment\[Amount])



Average Payment Amount =

AVERAGE(FactPayment\[Amount])

```



\## 5. ATM Analytics



```dax

Total ATM Withdrawals =

COUNTROWS(FactATMWithdrawal)



Total ATM Withdrawal Amount =

SUM(FactATMWithdrawal\[Amount])

```



\## 6. Login and Security Monitoring



```dax

Total Login Activities =

COUNTROWS(FactLoginActivity)



Failed Login Activities =

CALCULATE(

&#x20;   \[Total Login Activities],

&#x20;   FactLoginActivity\[LoginStatus] = "Failed"

)

```



\## 7. Model Notes



\- Data source: Azure Data Lake Storage Gen2 – Gold layer.

\- Storage format: Delta tables.

\- Semantic model: Star schema.

\- Dimensions: Customer, Account, Branch, Merchant and Date.

\- Facts: Transaction, Payment, ATM Withdrawal and Login Activity.

\- Relationships: One-to-many with single-direction filtering.



\## Important

These are reference measure definitions. Verify table and column names against the actual Power BI model before using them. Status values may require normalization because the source data contains inconsistent categories.



\## Data Disclaimer

NEXUS BANK uses synthetic data created for learning, portfolio demonstration and interview preparation. No real customer or banking information is included.



