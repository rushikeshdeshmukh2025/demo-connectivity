resource "azurerm_key_vault" "key_vault" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tenant_id                  = var.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = var.soft_delete_retention_days

  # Disable public network access — connectivity via private endpoint only
  public_network_access_enabled = false

  tags = var.tags
}
