locals {
  private_endpoints = {
    storage_blob = {
      name                           = "pep_${local.name_prefix}_storage_blob_${local.name_suffix}"
      private_connection_resource_id = module.storage_account.id
      subresource_names              = ["blob"]
      private_dns_zone_ids           = [module.private_dns_zones["blob"].id]
    }
    key_vault = {
      name                           = "pep_${local.name_prefix}_key_vault_${local.name_suffix}"
      private_connection_resource_id = module.key_vault.id
      subresource_names              = ["vault"]
      private_dns_zone_ids           = [module.private_dns_zones["vault"].id]
    }
  }
}

module "private_endpoints" {
  for_each = local.private_endpoints

  source = "./modules/azure_private_endpoint"

  name                           = each.value.name
  resource_group_name            = azurerm_resource_group.shared_services.name
  location                       = var.location
  subnet_id                      = module.shared_services_vnet.subnet_ids["private_endpoint"]
  private_connection_resource_id = each.value.private_connection_resource_id
  subresource_names              = each.value.subresource_names
  private_dns_zone_ids           = each.value.private_dns_zone_ids

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
