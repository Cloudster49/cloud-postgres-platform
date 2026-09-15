resource "azurerm_network_security_group" "vm" {
  name                = "az-linux-vm-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_ssh_public_key" "vm" {
  name                = "az-linux-vm_key"
  resource_group_name = "RG-CLOUD-POSTGRES-PLATFORM"
  location            = var.location
  public_key          = var.vm_public_key
}
