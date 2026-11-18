# NEXUS BANK — Banking Data Engineering Platform

## Project Overview

NEXUS BANK is an end-to-end Azure Data Engineering portfolio project built with simulated banking data. It demonstrates source data preparation, ingestion, orchestration, incremental loading, data quality practice, and a Medallion architecture.

## Architecture

SQL Server → Azure Data Factory → ADLS Gen2 (Bronze) → Azure Databricks / PySpark (Silver and Gold — in progress) → Power BI (planned)

## Technology Stack

| Technology | Purpose |
|---|---|
| SQL Server | Source database, tables, stored procedures and validation |
| Python | Synthetic data generation |
| Azure Data Factory | Ingestion, orchestration and incremental pipelines |
| ADLS Gen2 | Bronze, Silver and Gold storage layers |
| Azure Databricks / PySpark | Lakehouse transformations |
| Delta Lake | Target format for curated lakehouse data |
| Power BI | Planned analytical reporting |
| Git / GitHub | Version control and documentation |

## Current Implementation

Implemented ADF pipelines include:

- `PL_NEXUS_METADATA_DRIVEN_BRONZE` — metadata-driven Bronze ingestion
- `PL_NEXUS_INCREMENTAL_TRANSACTION` — incremental transaction ingestion
- `PL_NEXUS_DIMCUSTOMER_BRONZE` — customer Bronze ingestion
- `PL_NEXUS_MASTER_ORCHESTRATION` — master pipeline orchestration

The project also includes a simulated banking source schema, synthetic datasets with intentional data-quality issues, watermark-based incremental loading, and pipeline audit concepts.

## Medallion Architecture Roadmap

- **Bronze:** Raw source ingestion to ADLS Gen2 — implementation underway.
- **Silver:** Data cleansing, standardization, validation and Delta processing — in progress.
- **Gold:** Curated analytical datasets and dimensional model — planned.
- **Power BI:** Business-facing reports and dashboards — planned.

## Data Quality Practice

Synthetic sample data intentionally includes issues such as inconsistent casing and whitespace, nulls, duplicates, inconsistent categories/statuses, and selected malformed values. These are practice scenarios for cleansing and validation, not real customer information.

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
└── README.md
```

*Project status: actively being developed. Features are documented as implemented, in progress, or planned to keep the project status transparent.*
