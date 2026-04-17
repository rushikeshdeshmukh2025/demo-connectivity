module "virtual_wan" {
  source = "./modules/azure_virtual_wan"

  name                           = "vwan_${local.name_prefix}_connectivity_${local.name_suffix}"
  resource_group_name            = azurerm_resource_group.connectivity.name
  location                       = var.location
  type                           = "Standard"
  allow_branch_to_branch_traffic = true

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
