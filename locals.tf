locals {
  name_prefix = "${var.company_prefix}_${var.environment}"
  name_suffix = var.region_short

  connectivity_rg_name = "rg_${local.name_prefix}_connectivity_${local.name_suffix}"
}
