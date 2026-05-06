data "azurerm_client_config" "current" {}

module "key_vault" {
  source = "./modules/azure_key_vault"

  # Key vault names must be 3–24 alphanumeric characters and hyphens
  name                       = "kv-${replace(local.name_prefix, "_", "-")}-shd-${local.name_suffix}"
  resource_group_name        = azurerm_resource_group.shared_services.name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
