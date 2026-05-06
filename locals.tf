locals {
  name_prefix = "${var.company_prefix}_${var.environment}"
  name_suffix = var.region_short

  connectivity_rg_name    = "rg_${local.name_prefix}_connectivity_${local.name_suffix}"
  shared_services_rg_name = "rg_${local.name_prefix}_shd_svc_${local.name_suffix}"
  storage_rg_name         = "rg_${local.name_prefix}_storage_${local.name_suffix}"
  key_vault_rg_name       = "rg_${local.name_prefix}_key_vault_${local.name_suffix}"
  bastion_rg_name         = "rg_${local.name_prefix}_bastion_${local.name_suffix}"
}
