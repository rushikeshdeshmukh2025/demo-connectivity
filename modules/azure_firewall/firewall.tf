resource "azurerm_firewall" "firewall" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = var.firewall_policy_id
  tags                = var.tags

  virtual_hub {
    virtual_hub_id  = var.virtual_hub_id
    public_ip_count = var.public_ip_count
  }
}
