output "resource_group_name" {
  description = "Name of the project resource group"
  value       = azurerm_resource_group.project.name
}

output "vnet_name" {
  description = "Name of the project virtual network"
  value       = azurerm_virtual_network.project.name
}

output "application_subnet_id" {
  description = "Resource ID of the application subnet"
  value       = azurerm_subnet.application.id
}

output "postgresql_subnet_id" {
  description = "Resource ID of the PostgreSQL subnet"
  value       = azurerm_subnet.postgresql.id
}

output "vm_name" {
  description = "Name of the Azure Linux virtual machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_private_ip" {
  description = "private IP address of the Azure Linux virtual machine"
  value       = azurerm_network_interface.vm.private_ip_address
}

output "vm_public_ip" {
  description = "Public IP address of the Azure Linux virtual machine"
  value       = azurerm_public_ip.vm.ip_address
}
