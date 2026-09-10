resource "azurerm_public_ip" "vm" {
  name                = "az-linux-vm-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  zones               = ["1"]
}

resource "azurerm_network_interface" "vm" {
  name                = "az-linux-vm196"
  location            = var.location
  resource_group_name = var.resource_group_name

  accelerated_networking_enabled = true
  ip_forwarding_enabled          = false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.application.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = "rg-cloud-postgres-platform"
  location            = "centralus"
  size                = var.vm_size

  zone = var.vm_zone

  admin_username                  = var.vm_admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm.id
  ]

  secure_boot_enabled = true
  vtpm_enabled        = true

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = azurerm_ssh_public_key.vm.public_key
  }

  additional_capabilities {
    hibernation_enabled = false
    ultra_ssd_enabled   = false
  }

  boot_diagnostics {}

  os_disk {
    caching              = var.vm_os_disk_caching
    storage_account_type = var.vm_os_disk_storage_account_type
    disk_size_gb         = var.vm_os_disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }
}
