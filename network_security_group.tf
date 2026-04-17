locals {
  # Subnets associated with the default NSG (all except AzureBastionSubnet which has managed rules)
  # Map keys are static strings so for_each can resolve them at plan time
  nsg_subnet_ids = {
    bastion          = module.shared_services_vnet.subnet_ids["bastion"]
    private_endpoint = module.shared_services_vnet.subnet_ids["private_endpoint"]
    app              = module.shared_services_vnet.subnet_ids["app"]
  }
}

module "network_security_group" {
  source = "./modules/network_security_group"

  name                = "nsg_${local.name_prefix}_default_${local.name_suffix}"
  resource_group_name = azurerm_resource_group.shared_services.name
  location            = var.location
  subnet_ids          = local.nsg_subnet_ids

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
