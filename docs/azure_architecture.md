# Azure Architecture

## Objective

Deploy the PostgreSQL platform into Azure while preserving the database design, automation, backup, recovery, monitoring, and security capabilities developed during the local implementation.

The final architecture emphasizes private networking, Infrastructure as Code, identity-based CI/CD, least-privilege access, and cost-aware resource management.

## Local Architecture

The original development environment was:

```text
Windows
   ↓
WSL / Kali Linux
   ↓
Docker
   ↓
PostgreSQL 16
   ↓
cloud_platform
```

The local environment was used to build and validate the database before introducing Azure infrastructure.

## Azure Architecture

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
                       Azure Subscription
                              │
                     rg-cloud-postgres-platform
                              │
                    ┌─────────┴─────────┐
                    │                   │
             Virtual Network      PostgreSQL Flexible
               10.0.0.0/16              Server
                    │
        ┌───────────┼───────────┐
        │           │           │
        ▼           ▼           ▼
 Application   PostgreSQL   Azure Bastion
   Subnet        Subnet       Subnet
 10.0.1.0/24   10.0.2.0/24  10.0.3.0/24
        │
        ▼
   Azure Linux VM
    10.0.1.4
```

## Networking

The project Virtual Network uses the address space:


10.0.0.0/16


Important subnets include:

| Subnet               | Address Range | Purpose                     |
| -------------------- | ------------- | --------------------------- |
| `snet-application`   | `10.0.1.0/24` | Azure Linux VM              |
| `snet-PostgreSQL`    | `10.0.2.0/24` | PostgreSQL networking       |
| `default`            | `10.0.0.0/24` | PostgreSQL delegated subnet |
| `AzureBastionSubnet` | `10.0.3.0/24` | Bastion management access   |

The PostgreSQL delegated subnet uses the required Azure PostgreSQL Flexible Server delegation.

A private DNS zone is used for PostgreSQL private connectivity.

## Compute

The Azure Linux VM provides the project's compute and administrative workload environment.

The VM uses:

* Ubuntu 24.04
* `Standard_DC1s_v3`
* Static public IP resource
* SSH key authentication
* Password authentication disabled
* Secure Boot enabled
* vTPM enabled
* Boot diagnostics enabled

Public SSH access through the VM's NSG was initially available for deployment and testing. During security hardening, the unrestricted TCP/22 rule was removed.

The final design favors Bastion/private administrative access rather than leaving SSH publicly accessible.

## Database

The database layer uses Azure Database for PostgreSQL Flexible Server:

```
Server: pg-cloud-platform-2026
Region: centralus
SKU: Standard_B2s
Tier: Burstable
```

The server is integrated with the Azure virtual network using the delegated PostgreSQL subnet and private DNS.

## Infrastructure as Code

Terraform manages the core Azure infrastructure.

The main Terraform configuration is located under:

terraform/

The remote Terraform backend uses:

```
Resource Group: rg-terraform-state
Storage Account: tfstatecloudpg2026
Container: tfstate
State Key: cloud-postgres-platform.tfstate
```

The backend infrastructure is bootstrapped separately under:

```
terraform-bootstrap/
```

This separation prevents the main Terraform state from depending on resources that are themselves defined by that same state.

## CI/CD and Identity

GitHub Actions authenticates to Azure using Microsoft Entra ID workload identity federation.

No long-lived Azure client secret is required by the workflow.

The authentication flow is:

```
GitHub Actions
      │
      │ OIDC assertion
      ▼
Microsoft Entra ID
      │
      │ Federated identity validation
      ▼
github-actions-cloud-postgres
      │
      ├── Contributor
      │     └── rg-cloud-postgres-platform
      │
      └── Storage Blob Data Contributor
            └── tfstatecloudpg2026
```

The workflow performs Terraform format checking, initialization, validation, and planning.

## Security Architecture

Security decisions include:

* Private PostgreSQL connectivity
* SSH key authentication
* Disabled VM password authentication
* Removal of unrestricted public TCP/22 access
* Private Terraform state container
* TLS 1.2 minimum for state storage
* Azure RBAC least privilege
* OIDC authentication instead of long-lived CI/CD credentials

The GitHub Actions identity previously had broader subscription-level access than required. This was identified during an RBAC review and reduced to the permissions required for project deployment and remote state management.

## Administrative Access

Administrative access is designed around private networking and Bastion rather than unrestricted public SSH.

The public SSH NSG rule was removed during Phase 10 security hardening.

This reduces the exposed management surface while preserving administrative access through the Azure networking architecture.

## Cost-Aware Architecture

The environment was designed to remain reproducible without keeping compute resources running continuously.

When development work is complete:

* The Linux VM can be **deallocated**
* PostgreSQL Flexible Server can be **stopped**
* Persistent infrastructure can remain provisioned

This allows the environment to be restarted without rebuilding the entire Azure architecture.

## Design Goals

The final architecture prioritizes:

* Secure database connectivity
* Network segmentation
* Identity-based automation
* Least-privilege access
* Infrastructure reproducibility
* Backup and recovery
* Operational monitoring
* Cost awareness
* Clear separation between application, database, and management responsibilities
