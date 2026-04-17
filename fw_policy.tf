module "firewall_policy" {
  source = "./modules/azure_firewall_policy"

  name                     = "afwp_${local.name_prefix}_connectivity_${local.name_suffix}"
  resource_group_name      = azurerm_resource_group.connectivity.name
  location                 = var.location
  sku                      = "Standard"
  threat_intelligence_mode = "Alert"

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
