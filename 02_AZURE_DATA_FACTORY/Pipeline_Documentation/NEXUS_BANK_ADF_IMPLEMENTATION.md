\# NEXUS BANK – Azure Data Factory Implementation



\## 1. Project Overview



NEXUS BANK is an enterprise banking data engineering portfolio project.



Azure Data Factory (ADF) is used to orchestrate data ingestion from SQL Server into Azure Data Lake Storage Gen2 (ADLS Gen2).



\*\*Source:\*\* SQL Server – `NexusBank\_DB`  

\*\*Target:\*\* ADLS Gen2 – `nexusbank` container  

\*\*Storage Account:\*\* `stnexusbank2026`  

\*\*ADF Factory:\*\* `adf-nexus-bank`



\## 2. Architecture



SQL Server → Azure Data Factory → ADLS Gen2 Bronze Layer → Databricks Silver/Gold → Power BI



ADF handles source extraction, metadata-driven ingestion, incremental loading, pipeline orchestration and audit logging.



\## 3. ADF Pipelines



\### 3.1 PL\_NEXUS\_METADATA\_DRIVEN\_BRONZE



\*\*Purpose:\*\* Dynamically ingest multiple SQL Server tables into ADLS Bronze.



Activities:

\- Lookup\_Config – reads active configurations from `control.IngestionConfig`.

\- ForEach\_Table – iterates through configured source tables.

\- Copy\_Dynamic\_Table – dynamically copies SQL Server tables into Parquet files.



Key features:

\- Metadata-driven ingestion.

\- Dynamic schema and table parameters.

\- Dynamic target folder and filename.

\- Sequential table processing.



Ten configured tables are ingested:

\- DimCustomer

\- DimBranch

\- DimAccount

\- DimCard

\- DimMerchant

\- DimDate

\- FactTransaction

\- FactPayment

\- FactATMWithdrawal

\- FactLoginActivity



\### 3.2 PL\_NEXUS\_DIMCUSTOMER\_BRONZE



\*\*Purpose:\*\* Copy customer dimension data into the Bronze layer.



Activity:

\- Copy\_DimCustomer\_To\_Bronze



Source: `bank.DimCustomer`  

Target: `bronze/dimcustomer/DimCustomer.parquet`



Uses parameterized SQL and Parquet sink configuration.



\### 3.3 PL\_NEXUS\_INCREMENTAL\_TRANSACTION



\*\*Purpose:\*\* Load only newly inserted or updated transaction records based on the configured watermark.



Activities:

1\. Lookup\_Watermark – reads the last watermark from `control.WatermarkTable`.

2\. Copy\_Incremental\_Transaction – extracts records where TransactionDate is greater than the previous watermark.

3\. SP\_Update\_Transaction\_Watermark – updates the watermark after successful copy.

4\. SP\_Log\_Pipeline\_Success – inserts pipeline execution details into the audit table.



Target:

`bronze/facttransaction/incremental/FactTransaction\_Incremental.parquet`



Key features:

\- Watermark-based incremental extraction.

\- Dynamic SQL query generation.

\- Stored procedure integration.

\- Pipeline execution auditing.



\### 3.4 PL\_NEXUS\_MASTER\_ORCHESTRATION



\*\*Purpose:\*\* Control the execution of the child pipelines.



Execution sequence:



1\. EXE\_METADATA\_DRIVEN\_BRONZE

2\. EXE\_DIMCUSTOMER\_BRONZE

3\. EXE\_INCREMENTAL\_TRANSACTION



Uses Execute Pipeline activities with `waitOnCompletion = true`.



Each subsequent pipeline starts after the previous pipeline succeeds.



\## 4. Linked Services



| Linked Service | Purpose |

|---|---|

| LS\_SQLSERVER\_NEXUSBANK | SQL Server source connectivity |

| LS\_ADLS\_NEXUSBANK | ADLS Gen2 destination connectivity |

| LS\_SQL\_NEXUS\_AUDIT | SQL Server audit connectivity |



Self-hosted Integration Runtime is used for local SQL Server connectivity.



\## 5. Datasets



| Dataset | Purpose |

|---|---|

| DS\_SQL\_IngestionConfig | Reads ingestion configuration |

| DS\_SQL\_DimCustomer | Parameterized SQL Server source |

| DS\_ADLS\_DimCustomer\_Bronze | Parameterized Parquet destination |

| DS\_SQL\_NEXUS\_AUDIT | Pipeline audit destination |



\## 6. Metadata-Driven Framework



The `control.IngestionConfig` table stores:



\- ConfigID

\- SourceSchema

\- SourceTable

\- TargetFolder

\- TargetFileName

\- IsActive



ADF reads active configurations and dynamically processes the configured tables.



This reduces the need to create separate pipelines for every source table.



\## 7. Incremental Loading Framework



The `control.WatermarkTable` stores:



\- TableName

\- WatermarkColumn

\- LastWatermarkValue

\- LastUpdatedDate



ADF reads the previous watermark, extracts newer transactions, and updates the watermark after successful ingestion.



This avoids repeatedly extracting the entire transaction table.



\## 8. Audit Logging



The `audit.PipelineAudit` table captures:



\- PipelineName

\- TableName

\- RunID

\- StartTime

\- EndTime

\- RowsRead

\- RowsCopied

\- PipelineStatus

\- ErrorMessage

\- CreatedDate



The incremental ADF pipeline calls `audit.usp\_InsertPipelineAudit` after successful watermark update.



\## 9. Bronze Layer Structure



```text

nexusbank/

└── bronze/

&#x20;   ├── dimcustomer/

&#x20;   ├── dimbranch/

&#x20;   ├── dimaccount/

&#x20;   ├── dimcard/

&#x20;   ├── dimmerchant/

&#x20;   ├── dimdate/

&#x20;   ├── facttransaction/

&#x20;   │   └── incremental/

&#x20;   ├── factpayment/

&#x20;   ├── factatmwithdrawal/

&#x20;   └── factloginactivity/

```



Source tables are stored in Parquet format.



\## 10. Execution and Validation



The master orchestration pipeline was executed successfully.



Verified pipeline runs:

\- PL\_NEXUS\_METADATA\_DRIVEN\_BRONZE – Succeeded

\- PL\_NEXUS\_DIMCUSTOMER\_BRONZE – Succeeded

\- PL\_NEXUS\_INCREMENTAL\_TRANSACTION – Succeeded

\- PL\_NEXUS\_MASTER\_ORCHESTRATION – Succeeded



ADLS Bronze folders and representative Parquet outputs were verified.



\## 11. Key Azure Data Engineering Concepts Practiced



\- Azure Data Factory pipelines and activities

\- Linked Services and Datasets

\- Self-hosted Integration Runtime

\- Lookup and ForEach

\- Dynamic content and expressions

\- Parameterized datasets

\- Copy Activity

\- Execute Pipeline

\- Stored Procedure Activity

\- Incremental data loading

\- Watermark management

\- Metadata-driven ingestion

\- Pipeline orchestration

\- Audit logging

\- ADLS Gen2 and Parquet



\## 12. Security and Deployment Notes



\- Passwords must be supplied securely during deployment.

\- Never commit passwords, storage keys or access tokens.

\- The published ARM template contains redacted environment-specific Integration Runtime identifiers.

\- Replace placeholders and configure valid linked services and Integration Runtime references before deployment.



\---



\*\*Project:\*\* NEXUS BANK – Enterprise Banking Data Intelligence Platform  

\*\*ADF Responsibility:\*\* SQL Server ingestion, metadata-driven processing, incremental loading, orchestration and Bronze-layer delivery.

