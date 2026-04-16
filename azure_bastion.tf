module "azure_bastion" {
  source = "./modules/azure_bastion"

  name                = "bas_${local.name_prefix}_connectivity_${local.name_suffix}"
  resource_group_name = azurerm_resource_group.shared_services.name
  location            = var.location
  subnet_id           = module.shared_services_vnet.subnet_ids["bastion"]
  public_ip_name      = "pip_bas_${local.name_prefix}_connectivity_${local.name_suffix}"
  sku                 = "Standard"

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
