# Azure Resources

## Resource Group

The primary project resource group is:

```
rg-cloud-postgres-platform
```

The resource group is located in `eastus`, while the primary infrastructure resources are deployed in `centralus`.

## Networking

### Virtual Network

```
Name: rg-cloud-postgres-platform
Address Space: 10.0.0.0/16
```

### Subnets

| Resource             | Address Range | Purpose                     |
| -------------------- | ------------- | --------------------------- |
| `snet-application`   | `10.0.1.0/24` | Application/VM workloads    |
| `snet-PostgreSQL`    | `10.0.2.0/24` | PostgreSQL networking       |
| `default`            | `10.0.0.0/24` | Delegated PostgreSQL subnet |
| `AzureBastionSubnet` | `10.0.3.0/24` | Bastion management access   |

The `default` subnet is delegated to Azure Database for PostgreSQL Flexible Server.

## Database

### Azure Database for PostgreSQL Flexible Server

```
Name: pg-cloud-platform-2026
Region: centralus
SKU: Standard_B2s
Tier: Burstable
```

The server hosts the cloud version of the project's PostgreSQL platform.

The server uses virtual-network integration and private DNS for connectivity.

## Compute

### Azure Linux VM

```
Name: az-linux-vm
Region: centralus
Size: Standard_DC1s_v3
Private IP: 10.0.1.4
```

The VM runs Ubuntu 24.04 and is configured for SSH key authentication with password authentication disabled.

The VM's public SSH NSG rule was removed during security hardening. Administrative access is intended to use Bastion/private networking.

## Bastion

A separate Bastion resource group was used for the Azure Bastion deployment:

```
rg-cloud-postgres-platform-bastion
```

Bastion provides the intended administrative path after unrestricted public SSH access was removed.

## Private DNS

A PostgreSQL private DNS zone is configured for the Flexible Server:

```
pg-cloud-platform-2026.private.postgres.database.azure.com
```

The private DNS configuration supports private database connectivity within the Azure network.

## Security Resources

The project includes:

* `az-linux-vm-nsg`
* `az-linux-vm_key`
* Network security configuration
* Azure RBAC assignments
* Private DNS configuration

The VM uses an SSH public key resource and does not permit password-based authentication.

## Terraform State

Terraform state is stored remotely using:

```
Resource Group: rg-terraform-state
Storage Account: tfstatecloudpg2026
Container: tfstate
```

The storage account uses:

* Standard performance
* Locally redundant storage
* TLS 1.2 minimum
* Private blob container
* Blob versioning

The bootstrap resources are defined separately in:

```
terraform-bootstrap/main.tf
```

The main project Terraform configuration uses the remote backend.

## Terraform-Managed Resources

The core infrastructure managed by Terraform includes:

* Resource group
* Virtual network
* Application subnet
* PostgreSQL subnet
* Default delegated subnet
* Bastion subnet
* Network security group
* Network interface
* Public IP
* Linux VM
* SSH public key

Some supporting Azure resources were intentionally left outside the main Terraform configuration because they were either created by Azure services or were not necessary to reproduce the project's core infrastructure.

## CI/CD

GitHub Actions manages Terraform validation and planning.

Authentication uses Microsoft Entra ID OIDC.

The GitHub Actions identity has:

```
Contributor
└── rg-cloud-postgres-platform

Storage Blob Data Contributor
└── tfstatecloudpg2026
```

Subscription-level Owner access was identified as excessive and removed during the RBAC hardening phase.

## Cost Baseline

Azure Cost Management was used to establish a project cost baseline.

At the time of measurement:

```
Total accumulated cost: $54.06
Remaining project credit: $145.94
```

The largest cost contributors were:

| Resource                 |   Cost |
| ------------------------ | -----: |
| `az-linux-vm`            | $28.96 |
| `pg-cloud-platform-2026` | $21.59 |
| OS disk                  |  $1.97 |
| Public IP                |  $1.35 |
| Private DNS              |  $0.19 |

The VM and PostgreSQL server represented approximately 93.5% of the accumulated project cost.

## Cost Optimization

To reduce ongoing compute costs while preserving the environment:

```
Azure Linux VM
Running → Deallocated

PostgreSQL Flexible Server
Ready → Stopped
```

The VM was successfully deallocated and the PostgreSQL server was successfully stopped.

Persistent resources were intentionally retained so the environment can be restarted without rebuilding the infrastructure.

## Resource Lifecycle

The intended development lifecycle is:

1. Start the VM and PostgreSQL server when actively working.
2. Perform development, testing, and infrastructure validation.
3. Deallocate the VM when finished.
4. Stop PostgreSQL when finished.
5. Retain persistent networking, storage, and configuration resources.
6. Restart resources when additional work is required.