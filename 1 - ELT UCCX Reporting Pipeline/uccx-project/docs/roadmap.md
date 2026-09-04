
The below items are in the Roadmap for future improvements to the solution.
- Introduce a dedicated dbt intermediate layer between staging and marts to centralize reusable business logic.
- Improve data traceability by retaining immutable raw files and adding ingestion metadata such as _loaded_at and _source_file.
- Add automated quality checks: freshness, schema validation, uniqueness, null checks, accepted values, relationships, and deduplication rules.
- Add orchestration for scheduled runs, dependencies, retries, and pipeline monitoring.
- Adapt the architecture for cloud deployment, for example using S3 for raw storage and Redshift as the transformation and analytics warehouse. Moving from on premises to the cloud would add reversibility and flexibility in the architecture decisions that can be made, additional to addressing the horizontal scalability and availability risks that are trade-offs identified in the current design. In this case, we could also add infrastructure automation by using an IaC tool such as Terraform to create the required cloud resources.
