resource "azurerm_vpn_gateway" "virtual_network_gateway" {
  name                = "vpng_${local.name_prefix}_connectivity_${local.name_suffix}"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = var.location
  virtual_hub_id      = module.virtual_wan_hub.id

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
