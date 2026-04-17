module "virtual_wan_hub" {
  source = "./modules/azure_virtual_wan_hub"

  name                = "vhub_${local.name_prefix}_connectivity_${local.name_suffix}"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = var.location
  virtual_wan_id      = module.virtual_wan.id
  address_prefix      = "10.0.0.0/23"
  sku                 = "Standard"

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
