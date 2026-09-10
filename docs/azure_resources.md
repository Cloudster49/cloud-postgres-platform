# Azure Resources

## Planned Resources

- Resource Group
- Azure Database for PostgreSQL Flexible Server
- Virtual Network
- Subnet
- Private connectivity
- Azure Monitor
- Log Analytics workspace
- Storage for backup/export workflows
- Key Vault for secrets

## Deployment Strategy

Initial deployment will be performed manually to understand
the Azure architecture.

The environment will later be recreated using Terraform.

## Database

PostgreSQL will be deployed using Azure Database for PostgreSQL
Flexible Server.

The existing `cloud_platform` schema will serve as the logical
database design baseline.