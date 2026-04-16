module "shared_services_vnet" {
  source = "./modules/azure_virtual_network"

  name                = "vnet_${local.name_prefix}_shared_services_${local.name_suffix}"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = var.location
  address_space       = ["10.0.2.0/23"]

  subnets = {
    bastion = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.0.2.0/27"]
    }
    private_endpoint = {
      name             = "snet_${local.name_prefix}_private_endpoint_${local.name_suffix}"
      address_prefixes = ["10.0.2.32/27"]
    }
    app = {
      name             = "snet_${local.name_prefix}_app_${local.name_suffix}"
      address_prefixes = ["10.0.2.64/27"]
    }
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
