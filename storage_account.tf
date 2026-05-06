module "storage_account" {
  source = "./modules/azure_storage_account"

  # Storage account names must be 3–24 lowercase alphanumeric characters (no underscores/hyphens)
  name                     = "st${replace(local.name_prefix, "_", "")}shd${local.name_suffix}"
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
