# NEXUS BANK – Enterprise Banking Data Intelligence Platform

## Project Overview
NEXUS BANK is an end-to-end Azure Data Engineering portfolio project that demonstrates how banking data can be ingested, processed, transformed, validated, and presented through a modern analytics platform.

The project uses simulated banking data and focuses on data engineering workflows, data quality, incremental ingestion, Medallion Architecture, dimensional modelling, and business intelligence.

## Architecture

SQL Server → Python → Azure Data Factory → Azure Data Lake Storage Gen2
→ Azure Databricks / PySpark → Delta Lake → Star Schema → Power BI

## Technologies Used

| Technology | Purpose |
|---|---|
| SQL Server | Source database, tables, stored procedures and validation |
| Python | Synthetic data generation and data processing |
| Azure Data Factory | Data ingestion, orchestration and incremental pipelines |
| ADLS Gen2 | Bronze, Silver and Gold data storage |
| Azure Databricks | PySpark transformations and data processing |
| Delta Lake | Reliable storage and transactional data management |
| Unity Catalog | Data organization and governance practice |
| Power BI | Data modelling, DAX and dashboards |
| Git / GitHub | Source control and project documentation |

## Data Model

The project includes banking dimensions and fact tables.

### Dimension Tables
- DimCustomer
- DimAccount
- DimBranch
- DimCard
- DimMerchant
- DimDate

### Fact Tables
- FactTransaction
- FactPayment
- FactATMWithdrawal
- FactLoginActivity

## Medallion Architecture

- **Bronze:** Raw data ingested from source systems.
- **Silver:** Cleaned, standardized and validated Delta datasets.
- **Gold:** Business-ready analytical datasets and dimensional star schema.

## Project Implementation Highlights

- Designed a banking database with primary and foreign key relationships.
- Generated synthetic banking datasets with intentional data-quality issues.
- Implemented data ingestion and orchestration using Azure Data Factory.
- Practiced metadata-driven and incremental ingestion patterns.
- Implemented watermark and pipeline audit concepts.
- Processed Silver Delta datasets using Databricks and PySpark.
- Validated primary keys and foreign key relationships.
- Built a dimensional star schema with customer, account, branch, merchant and date dimensions.
- Prepared Gold analytical datasets for Power BI reporting.
- Developed banking analytics measures and dashboard designs.

## Analytical Areas

1. Executive Banking Overview
2. Transaction and Branch Performance
3. Customer and Account Analytics
4. Payments and ATM Analytics
5. Login Activity and Security Monitoring

## Repository Structure

```text
NEXUS-BANK-DATA-ENGINEERING/
├── 01_SQL_SERVER_SSMS/
├── 02_AZURE_DATA_FACTORY/
├── 03_ADLS_GEN2/
├── 04_DATABRICKS/
├── 05_POWER_BI/
├── 06_ARCHITECTURE_DIAGRAMS/
├── 07_PROJECT_DOCUMENTATION/
├── .gitignore
└── README.md
