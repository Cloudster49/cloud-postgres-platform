# Cloud-Ready PostgreSQL Production Platform

A production-style PostgreSQL platform demonstrating database administration, performance engineering, security, backup and recovery, Azure infrastructure, Infrastructure as Code, CI/CD, and cloud cost optimization.

The project began as a local PostgreSQL environment and evolved into an Azure-hosted platform managed with Terraform and automated through GitHub Actions using Microsoft Entra ID OIDC authentication.

## Project Highlights

* PostgreSQL database containing **1M+ transactions**
* SQL performance analysis and indexing using `EXPLAIN ANALYZE`
* Table partitioning for transaction data
* Database security and restricted-access testing
* Automated PostgreSQL backup and restore workflows
* Disaster-recovery validation using a separate restore database
* Azure Virtual Network and subnet architecture
* Azure Database for PostgreSQL Flexible Server
* Azure Linux VM for application/administrative workloads
* Azure Bastion for private administrative access
* Terraform Infrastructure as Code
* Remote Terraform state stored in Azure Storage
* GitHub Actions CI/CD
* Microsoft Entra ID OIDC authentication
* Azure RBAC least-privilege review
* Public SSH access removed from the VM
* Azure cost monitoring and compute lifecycle optimization

## Project Objectives

The project was designed to demonstrate practical skills across:

* PostgreSQL administration
* Relational database design
* SQL performance optimization
* Python and Bash automation
* Linux and Docker administration
* Backup and recovery
* Disaster recovery testing
* Database monitoring
* Azure networking and infrastructure
* Infrastructure as Code
* CI/CD automation
* Cloud security and identity
* Cost-aware cloud operations

## Technology Stack

* **Database:** PostgreSQL 16
* **Languages:** SQL, Python, Bash
* **Containers:** Docker
* **Cloud:** Microsoft Azure
* **Infrastructure as Code:** Terraform
* **CI/CD:** GitHub Actions
* **Identity:** Microsoft Entra ID / OIDC
* **Version Control:** Git / GitHub
* **Operating Systems:** Linux / Windows / WSL

## Architecture

The platform uses Azure networking to separate application, database, and management components.

```
                         GitHub
                           │
                           │ OIDC
                           ▼
                  Microsoft Entra ID
                           │
                           ▼
                  GitHub Actions
                           │
                           │ Terraform
                           ▼
                    Azure Resources
                           │
             ┌─────────────┴─────────────┐
             │                           │
       Virtual Network              Remote State
          10.0.0.0/16             Azure Storage
             │
     ┌───────┼────────┬────────────────┐
     │       │        │                │
 Application PostgreSQL Default      Bastion
   Subnet      Subnet   Subnet        Subnet
     │          │
     ▼          ▼
 Azure Linux   PostgreSQL
     VM        Flexible Server
```

Administrative access is designed around private/Bastion connectivity rather than unrestricted public SSH access.

## Database

The primary database is `cloud_platform`.

The dataset contains:

| Table        | Approximate Rows |
| ------------ | ---------------: |
| customers    |           10,000 |
| accounts     |              100 |
| merchants    |              100 |
| transactions |        1,001,001 |

The transaction workload provides a realistic dataset for indexing, query analysis, partitioning, monitoring, backup, and recovery exercises.

## Performance Engineering

Database performance was evaluated using PostgreSQL execution plans and `EXPLAIN ANALYZE`.

The project includes:

* Index design and validation
* Query performance analysis
* Composite indexing
* Query-plan inspection
* Transaction-table optimization
* Partitioning experiments
* PostgreSQL statistics and monitoring

The goal was not simply to create indexes, but to verify their effect on query execution and understand the tradeoffs between query performance, storage, and maintenance.

## Backup & Recovery

The database uses PostgreSQL custom-format backups created with `pg_dump`.

Recovery is performed using `pg_restore`.

The restore workflow was validated by restoring the production-style database into a separate test database:

```
cloud_platform
      │
      │ pg_dump
      ▼
Custom-format backup
      │
      │ pg_restore
      ▼
cloud_platform_restore_test
```

The restored database was validated through object and row-count checks.

A formal RTO/RPO measurement was not established because the project focused on validating the backup and recovery procedure rather than defining a production service-level agreement.

See [`docs/disaster_recovery.md`](docs/disaster_recovery.md).

## Infrastructure as Code

Azure infrastructure is managed with Terraform.

The Terraform configuration manages the core project infrastructure, including:

* Resource group
* Virtual network
* Subnets
* Network security group
* Network interface
* Public IP
* Linux VM
* SSH public key

Terraform state is stored remotely in an Azure Storage Account rather than committed to Git.

The remote backend is bootstrapped separately under `terraform-bootstrap/`.

## CI/CD and OIDC

GitHub Actions validates the Terraform configuration and generates an infrastructure plan.

Authentication uses Microsoft Entra ID workload identity federation rather than storing an Azure client secret in GitHub.

```
GitHub Actions
      │
      │ OIDC token
      ▼
Microsoft Entra ID
      │
      ▼
github-actions-cloud-postgres
      │
      ├── Contributor
      │     └── Project Resource Group
      │
      └── Storage Blob Data Contributor
            └── Terraform State Storage
```

The workflow performs:

1. Repository checkout
2. Azure authentication
3. Terraform setup
4. Terraform format validation
5. Terraform initialization
6. Terraform validation
7. Terraform plan

The final workflow successfully authenticated through OIDC and completed the Terraform validation and planning process.

## Security Hardening

Security improvements included:

* Removal of unrestricted public SSH access
* SSH key authentication
* Disabled password authentication on the Linux VM
* Secure boot and vTPM enabled on the VM
* Private PostgreSQL networking
* Private Terraform state container
* TLS 1.2 minimum for Terraform state storage
* Azure RBAC review
* Removal of excessive subscription-level permissions from the GitHub Actions identity
* Scoped GitHub Actions permissions to the project resource group and Terraform state storage

During the RBAC hardening process, an access issue was discovered after removing an overly broad role. Temporary administrative elevation was used to restore the user's normal project-level Contributor access, after which the temporary elevation was removed.

This provided an additional practical lesson in least-privilege administration: broad permissions should be removed only after confirming that an appropriate human administrator retains access.

## Cost Optimization

Azure cost was monitored throughout the cloud deployment.

The measured baseline was:

* **Total accumulated Azure cost:** $54.06
* **Remaining project credit:** $145.94
* **VM + PostgreSQL share of cost:** approximately 93.5%

Because compute resources represented the majority of project spending, the platform was tested using a stop/deallocate lifecycle rather than deleting infrastructure.

When the environment was not being used:

* Azure Linux VM → **Deallocated**
* PostgreSQL Flexible Server → **Stopped**

Supporting resources remained provisioned so the environment could be restarted without rebuilding the platform.

This demonstrated practical cloud cost management while preserving infrastructure reproducibility.

## Project Documentation

Additional documentation:

* [`docs/azure_architecture.md`](docs/azure_architecture.md)
* [`docs/azure_resources.md`](docs/azure_resources.md)
* [`docs/disaster_recovery.md`](docs/disaster_recovery.md)
* [`docs/monitoring.md`](docs/monitoring.md)
* [`performance/phase_4_performance_report.md`](performance/phase_4_performance_report.md)

## Project Status

The core implementation is complete.

The project now demonstrates an end-to-end workflow covering:

**Database → Performance → Security → Backup/Recovery → Azure → Terraform → CI/CD → OIDC → RBAC → Cost Optimization**

The remaining work consists primarily of documentation refinement, screenshots, and final portfolio presentation.
