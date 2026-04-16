resource "azurerm_resource_group" "shared_services" {
  name     = local.shared_services_rg_name
  location = var.location
}
