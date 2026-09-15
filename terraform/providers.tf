terraform {
  required_version = ">= 1.16.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatecloudpg2026"
    container_name       = "tfstate"
    key                  = "cloud-postgres-platform.tfstate"
    use_cli              = true
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}
