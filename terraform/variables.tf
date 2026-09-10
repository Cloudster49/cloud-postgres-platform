variable "resource_group_name" {
  description = "Name of the existing Azure resource group"
  type        = string
  default     = "rg-cloud-postgres-platform"
}

variable "resource_group_location" {
  description = "Azure region of the existing resource group"
  type        = string
  default     = "eastus"
}

variable "location" {
  description = "Azure region where the project infrastructure is deployed"
  type        = string
  default     = "centralus"
}

variable "vnet_name" {
  description = "Name of the existing Azure virtual network"
  type        = string
  default     = "rg-cloud-postgres-platform"
}

variable "vnet_address_space" {
  description = "Address space of the existing virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "application_subnet_name" {
  description = "Application subnet name"
  type        = string
  default     = "snet-application"
}

variable "application_subnet_prefix" {
  description = "Application subnet address prefix"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "postgresql_subnet_name" {
  description = "PostgreSQL subnet name"
  type        = string
  default     = "snet-PostgreSQL"
}

variable "postgresql_subnet_prefix" {
  description = "PostgreSQL subnet address prefix"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "bastion_subnet_prefix" {
  description = "Azure Bastion subnet address prefix"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

variable "vm_public_key" {
  description = "Existing SSH public key for the Azure Linux VM"
  type        = string
}

variable "vm_name" {
  description = "Name of the Azure Linux virtual machine"
  type        = string
  default     = "az-linux-vm"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_DC1s_v3"
}

variable "vm_admin_username" {
  description = "Administrator username for the Azure Linux VM"
  type        = string
  default     = "azureuser"
}

variable "vm_zone" {
  description = "Availability zone for the Azure Linux VM"
  type        = string
  default     = "1"
}

variable "vm_os_disk_size_gb" {
  description = "Operating system disk size in GB"
  type        = number
  default     = 30
}

variable "vm_os_disk_storage_account_type" {
  description = "Storage account type for the VM OS disk"
  type        = string
  default     = "Premium_LRS"
}

variable "vm_os_disk_caching" {
  description = "Caching mode for the VM OS disk"
  type        = string
  default     = "ReadWrite"
}

variable "vm_image_publisher" {
  description = "Publisher of the VM operating system image"
  type        = string
  default     = "canonical"
}

variable "vm_image_offer" {
  description = "Offer of the VM operating system image"
  type        = string
  default     = "ubuntu-24_04-lts"
}

variable "vm_image_sku" {
  description = "SKU of the VM operating system image"
  type        = string
  default     = "server"
}

variable "vm_image_version" {
  description = "Version of the VM operating system image"
  type        = string
  default     = "latest"
}