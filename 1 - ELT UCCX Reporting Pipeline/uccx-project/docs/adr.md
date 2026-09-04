## 001 - Use PostgreSQL as the ELT warehouse.

## Context
- This is for architecture and build exploration.
- PostgreSQL is the central platform  in the pipeline. Ingestion writes raw data to it, dbt transforms the data within it, and Metabase reads the curated marts for reporting.
- The batch architecture approach I chose is ELT (Extract Load Transform); real-time analysis is not critical, with data ingestion process and therefore the pipeline running only once a month. For transformation within PostgreSQL, I chose to organize the data in a collapsed medallion architecture, with Staging and Marts layers.
- I staged the raw data before performing transformations to ensure the source of truth is always available in the pipeline, to fall back on in the future if the business wants to make changes to the data they require analysis on, for auting purposes, etc.
- The solution is designed to be loosely coupled and modular. This is important as, for example, say there is a requirement to move the solution to the cloud - modifying the system's storage and SQL execution component to replace the PostgreSQL database with AWS RDS would not change the Extract & Load process - this adds flexibility such as the ability to perform the migration in phases, or to only change a single component; the Virtual Machine hosting dbt Core and Metabase could possibly be rehosted on AWS EC2; both Metabase and DBT are supported on RDS.
- The dataset is very small since the datasource is in the form of csv files exported from the relational DB in UCCX. In this project the data spans 3 months - April, May, and June.
- PostgreSQL was selected as the source DB as well as the target DB for DBT transformations. DBT integrates with PostgreSQL through an adapter, and the data transformed by DBT is visualized on Metabase, which integrates with the same PostgreSQL database on the Mart Schema. 
- I chose the tools PostgreSQL, dbt Core, and Metabase as they are common components that can be used across the organisation. For example, using the same architecture, the pipeline might be modified to extract and serve data for a CUCM reporting pipeline use case, or for some Security use cases that have a relational database, etc. This would be beneficial for the organization as a whole.
- The use case is ingesting csv files downloaded from a UCCX Cluster deployed on premises and hosted on VMware. Spinning up a virtual machine on the same VMware infrastructure, for the tools in this solution is simple and cost effective. The assumption here is that there will be available resources in that VMware environment for an additional VM. For this project, PostgreSQL, Metabase, dbt Core and Python environment are hosted and run on my local machine.
- The design ensures there is no requirement to purchase new hardware or licenses, the tools implemented are opensource (PostgreSQL, dbt Core, Metabase) and the location for the implementation is on premises rather than cloud or hybrid, therefore data governance should not pose too much of an issue. The design is optimized for cost and performance, given the scale of the batch workload we are working on.

## Decision
The pipeline uses PostgreSQL as the warehouse.

## Consequences
### Benefits
- Low Cost - only engineering time is required as there are no hardware, subscription, or license costs.
- High performance for the scale of the data processed by the pipeline.
- Minimal Implementation effort.
- Supported integration into chosen BI Tool (Metabase) and Transformation Tool (dbt Core).
- Security and Data Governance.

### Trade-offs
- Horizontal scalability is limited.
- The single-database implementation poses an availability risk.

## Status
Accepted.
