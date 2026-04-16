resource "azurerm_resource_group" "connectivity" {
  name     = local.connectivity_rg_name
  location = var.location
}
