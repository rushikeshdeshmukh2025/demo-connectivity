resource "azurerm_network_manager" "ip_pool" {
  name                = "${var.name}_nm"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  scope_accesses = ["Connectivity"]

  scope {
    subscription_ids = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_network_manager_ipam_pool" "ip_pool" {
  name               = var.name
  network_manager_id = azurerm_network_manager.ip_pool.id
  location           = var.location
  address_prefixes   = var.address_prefixes
  tags               = var.tags
}
