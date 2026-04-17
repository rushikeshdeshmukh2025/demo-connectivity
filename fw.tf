module "firewall" {
  source = "./modules/azure_firewall"

  name                = "afw_${local.name_prefix}_connectivity_${local.name_suffix}"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = var.location
  sku_name            = "AZFW_Hub"
  sku_tier            = "Standard"
  firewall_policy_id  = module.firewall_policy.id
  virtual_hub_id      = module.virtual_wan_hub.id
  public_ip_count     = 1

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
