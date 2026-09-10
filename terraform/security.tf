resource "azurerm_network_security_group" "vm" {
  name                = "az-linux-vm-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "ssh" {
  name                       = "SSH"
  priority                   = 300
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.vm.name
}

resource "azurerm_ssh_public_key" "vm" {
  name                = "az-linux-vm_key"
  resource_group_name = "RG-CLOUD-POSTGRES-PLATFORM"
  location            = var.location
  public_key          = var.vm_public_key
}
