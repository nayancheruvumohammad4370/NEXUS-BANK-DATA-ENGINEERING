\# NEXUS BANK – POWER BI DATA MODEL



\## 1. Architecture



The Power BI semantic model follows a Star Schema design.



Data flow:



SQL Server → Azure Data Factory → ADLS Gen2 Bronze → Silver → Gold → Power BI



Power BI consumes curated Gold Delta datasets from ADLS Gen2.



\## 2. Dimension Tables



| Dimension | Primary Key | Purpose |

|---|---|---|

| DimCustomer | CustomerID | Customer details and segmentation |

| DimAccount | AccountID | Account information and balances |

| DimBranch | BranchID | Branch-level analysis |

| DimMerchant | MerchantID | Merchant-level transaction analysis |

| DimDate | DateKey | Calendar and time-based analysis |



\## 3. Fact Tables



| Fact Table | Grain / Purpose |

|---|---|

| FactTransaction | Individual banking transactions |

| FactPayment | Individual payment records |

| FactATMWithdrawal | Individual ATM withdrawals |

| FactLoginActivity | Individual login activities |



\## 4. Relationships



All relationships are intended to use one-to-many cardinality and single-direction filtering.



| Dimension | Fact Table | Relationship |

|---|---|---|

| DimCustomer | FactTransaction | CustomerID |

| DimCustomer | FactPayment | CustomerID |

| DimCustomer | FactATMWithdrawal | CustomerID |

| DimCustomer | FactLoginActivity | CustomerID |

| DimAccount | FactTransaction | AccountID |

| DimAccount | FactPayment | AccountID |

| DimAccount | FactATMWithdrawal | AccountID |

| DimBranch | FactTransaction | BranchID |

| DimBranch | FactPayment | BranchID |

| DimBranch | FactATMWithdrawal | BranchID |

| DimDate | All four fact tables | DateKey |

| DimMerchant | FactTransaction | MerchantID |



\## 5. Model Design Principles



\- Dimensions filter fact tables.

\- Use single-direction cross-filtering.

\- Avoid unnecessary many-to-many relationships.

\- Use unique dimension keys.

\- Keep measures separate from source columns where practical.

\- Use DimDate for time intelligence.

\- Use DateKey 0 for unknown dates where applicable.



\## 6. Gold Layer Sources



The model uses curated datasets stored in ADLS Gen2:



\- `gold/star\_schema/`

\- `gold/gold\_atm\_withdrawal\_summary/`

\- `gold/gold\_branch\_transaction\_summary/`

\- `gold/gold\_customer\_account\_summary/`

\- `gold/gold\_customer\_transaction\_summary/`

\- `gold/gold\_login\_activity\_summary/`

\- `gold/gold\_payment\_method\_summary/`

\- `gold/gold\_transaction\_status\_summary/`



\## 7. Business Analysis



The semantic model supports:



1\. Executive Banking Overview

2\. Transaction Analysis

3\. Customer \& Account Analytics

4\. Payments \& ATM Analytics

5\. Login \& Security Monitoring



\## 8. Data Disclaimer



NEXUS BANK uses synthetic data for learning and portfolio demonstration. It does not contain real customer or banking information.



Note: Relationship definitions document the intended model. Verify them against the final Power BI model before treating this document as an exact model export.



