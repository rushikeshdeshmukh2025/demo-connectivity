/*module "shared_services_hub_connection" {
  source = "./modules/azure_virtual_hub_connection"

  name                      = "vhc_${local.name_prefix}_shared_services_${local.name_suffix}"
  virtual_hub_id            = module.virtual_wan_hub.id
  remote_virtual_network_id = module.shared_services_vnet.id
}*/
