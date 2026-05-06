locals {
  private_dns_zones = {
    blob  = "privatelink.blob.core.windows.net"
    vault = "privatelink.vaultcore.azure.net"
  }
}

module "private_dns_zones" {
  for_each = local.private_dns_zones

  source = "./modules/azure_private_dns_zone"

  name                = each.value
  resource_group_name = azurerm_resource_group.shared_services.name

  virtual_network_links = {
    shared_services = {
      virtual_network_id   = module.shared_services_vnet.id
      registration_enabled = false
    }
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
