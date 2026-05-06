resource "azurerm_resource_group" "connectivity" {
  name     = local.connectivity_rg_name
  location = var.location
}

resource "azurerm_resource_group" "shared_services" {
  name     = local.shared_services_rg_name
  location = var.location
}

resource "azurerm_resource_group" "storage" {
  name     = local.storage_rg_name
  location = var.location
}

resource "azurerm_resource_group" "key_vault" {
  name     = local.key_vault_rg_name
  location = var.location
}

resource "azurerm_resource_group" "bastion" {
  name     = local.bastion_rg_name
  location = var.location
}
