module "ip_pool" {
  source = "./modules/ip_pool"

  name                = "ippool_${local.name_prefix}_connectivity_${local.name_suffix}"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = var.location
  address_prefixes    = ["10.0.0.0/16"]

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
