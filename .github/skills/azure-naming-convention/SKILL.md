---
name: azure-naming-convention
description: "Resolve Azure Landing Zone resource labels using org naming conventions. Derives all resource names from locals.tf name_prefix/name_suffix and .tfvars variable values. USE WHEN: generating resource labels, naming conventions, LZ naming, name_prefix, name_suffix, locals.tf, label resolution."
---

# Azure Landing Zone Naming Convention

## CRITICAL: Use Actual Terraform Code as Source of Truth

Do NOT invent names from generic patterns. **Read the `name` argument from each module/resource block in the root `.tf` files** and substitute the environment variables to resolve the final label.

---

## Core Variables (from `locals.tf`)

```hcl
name_prefix = "${var.company_prefix}_${var.environment}"   # e.g. "rus_dev"
name_suffix = var.region_short                              # e.g. "gwc"
```

## Environment Values (from `environments/*.tfvars`)

| Env | `company_prefix` | `environment` | `region_short` | `location` | `name_prefix` | `name_suffix` |
|-----|-------------------|---------------|----------------|------------|---------------|---------------|
| DEV | `rus` | `dev` | `gwc` | germanywestcentral | `rus_dev` | `gwc` |
| PRE | `rus` | `pre` | `szn` | switzerlandnorth | `rus_pre` | `szn` |
| PROD | `rus` | `prod` | `gwc` | germanywestcentral | `rus_prod` | `gwc` |

---

## Resolved Resource Names (Pre-Computed)

### Resource Groups

| Resource | Formula | DEV | PRE | PROD |
|----------|---------|-----|-----|------|
| Connectivity RG | `rg_${prefix}_connectivity_${suffix}` | `rg_rus_dev_connectivity_gwc` | `rg_rus_pre_connectivity_szn` | `rg_rus_prod_connectivity_gwc` |
| Shared Services RG | `rg_${prefix}_shd_svc_${suffix}` | `rg_rus_dev_shd_svc_gwc` | `rg_rus_pre_shd_svc_szn` | `rg_rus_prod_shd_svc_gwc` |
| Storage RG | `rg_${prefix}_storage_${suffix}` | `rg_rus_dev_storage_gwc` | `rg_rus_pre_storage_szn` | `rg_rus_prod_storage_gwc` |
| Key Vault RG | `rg_${prefix}_key_vault_${suffix}` | `rg_rus_dev_key_vault_gwc` | `rg_rus_pre_key_vault_szn` | `rg_rus_prod_key_vault_gwc` |
| Bastion RG | `rg_${prefix}_bastion_${suffix}` | `rg_rus_dev_bastion_gwc` | `rg_rus_pre_bastion_szn` | `rg_rus_prod_bastion_gwc` |

### Networking

| Resource | Formula | DEV | PRE | PROD |
|----------|---------|-----|-----|------|
| Virtual WAN | `vwan_${prefix}_connectivity_${suffix}` | `vwan_rus_dev_connectivity_gwc` | `vwan_rus_pre_connectivity_szn` | `vwan_rus_prod_connectivity_gwc` |
| Virtual Hub | `vhub_${prefix}_${suffix}` | `vhub_rus_dev_gwc` | `vhub_rus_pre_szn` | `vhub_rus_prod_gwc` |
| VPN Gateway | `vpngw_${prefix}_${suffix}` | `vpngw_rus_dev_gwc` | `vpngw_rus_pre_szn` | `vpngw_rus_prod_gwc` |
| Firewall | `afw_${prefix}_connectivity_${suffix}` | `afw_rus_dev_connectivity_gwc` | `afw_rus_pre_connectivity_szn` | `afw_rus_prod_connectivity_gwc` |
| Firewall Policy | `afwp_${prefix}_connectivity_${suffix}` | `afwp_rus_dev_connectivity_gwc` | `afwp_rus_pre_connectivity_szn` | `afwp_rus_prod_connectivity_gwc` |
| IP Pool | `ippool_${prefix}_${suffix}` | `ippool_rus_dev_gwc` | `ippool_rus_pre_szn` | `ippool_rus_prod_gwc` |
| Shared Svc VNet | `vnet_${prefix}_shared_services_${suffix}` | `vnet_rus_dev_shared_services_gwc` | `vnet_rus_pre_shared_services_szn` | `vnet_rus_prod_shared_services_gwc` |
| Hub Connection | `vhc_${prefix}_shared_services_${suffix}` | `vhc_rus_dev_shared_services_gwc` | `vhc_rus_pre_shared_services_szn` | `vhc_rus_prod_shared_services_gwc` |

### Subnets

| Subnet | Name (fixed/formula) |
|--------|---------------------|
| AzureBastionSubnet | `AzureBastionSubnet` (Azure-fixed, never rename) |
| Private Endpoint | `snet_${prefix}_private_endpoint_${suffix}` |
| App | `snet_${prefix}_app_${suffix}` |

### Security

| Resource | Formula | DEV | PRE | PROD |
|----------|---------|-----|-----|------|
| NSG (Bastion) | `nsg_${prefix}_bastion_${suffix}` | `nsg_rus_dev_bastion_gwc` | `nsg_rus_pre_bastion_szn` | `nsg_rus_prod_bastion_gwc` |
| NSG (PE) | `nsg_${prefix}_private_endpoint_${suffix}` | `nsg_rus_dev_private_endpoint_gwc` | `nsg_rus_pre_private_endpoint_szn` | `nsg_rus_prod_private_endpoint_gwc` |
| NSG (App) | `nsg_${prefix}_app_${suffix}` | `nsg_rus_dev_app_gwc` | `nsg_rus_pre_app_szn` | `nsg_rus_prod_app_gwc` |

### Special Naming (no underscores/hyphens allowed)

| Resource | Formula | DEV | PRE | PROD |
|----------|---------|-----|-----|------|
| Storage Account | `"st" + replace(prefix,"_","") + "shd" + suffix` | `strusdevshdgwc` | `struspreshdszn` | `strusprodshdgwc` |

> **Storage account construction:** `"st"` + `name_prefix` with underscores removed + `"shd"` + `name_suffix`.
> Example for PRE: `"st"` + `"ruspre"` + `"shd"` + `"szn"` = `struspreshdszn` (14 chars).

### Hyphen-Separated Names

| Resource | Formula | DEV | PRE | PROD |
|----------|---------|-----|-----|------|
| Key Vault | `"kv-" + replace(prefix,"_","-") + "-shd-" + suffix` | `kv-rus-dev-shd-gwc` | `kv-rus-pre-shd-szn` | `kv-rus-prod-shd-gwc` |

### Bastion and PIP

| Resource | Formula | DEV | PRE | PROD |
|----------|---------|-----|-----|------|
| Bastion Host | `bas_${prefix}_connectivity_${suffix}` | `bas_rus_dev_connectivity_gwc` | `bas_rus_pre_connectivity_szn` | `bas_rus_prod_connectivity_gwc` |
| Bastion PIP | `pip_bas_${prefix}_connectivity_${suffix}` | `pip_bas_rus_dev_connectivity_gwc` | `pip_bas_rus_pre_connectivity_szn` | `pip_bas_rus_prod_connectivity_gwc` |

### Private Endpoints and DNS Zones

| Resource | Formula | DEV | PRE | PROD |
|----------|---------|-----|-----|------|
| PE (Storage Blob) | `pep_${prefix}_storage_blob_${suffix}` | `pep_rus_dev_storage_blob_gwc` | `pep_rus_pre_storage_blob_szn` | `pep_rus_prod_storage_blob_gwc` |
| PE (Key Vault) | `pep_${prefix}_key_vault_${suffix}` | `pep_rus_dev_key_vault_gwc` | `pep_rus_pre_key_vault_szn` | `pep_rus_prod_key_vault_gwc` |
| DNS (Blob) | `privatelink.blob.core.windows.net` | (same all envs) | | |
| DNS (Vault) | `privatelink.vaultcore.azure.net` | (same all envs) | | |

---

## Diagram Label Format

Use this format for container and icon labels in Draw.io:

- **Resource Groups:** `{resolved_name}` (e.g. `rg_rus_dev_connectivity_gwc`)
- **VNets:** `{resolved_name}&#xa;{cidr}` (e.g. `vnet_rus_dev_shared_services_gwc&#xa;10.0.2.0/23`)
- **Subnets:** `{resolved_name}&#xa;{cidr}` (e.g. `AzureBastionSubnet&#xa;10.0.2.0/27`)
- **Icons:** `{resolved_name}` single line
- **On-Premises:** `On-Premises&#xa;VPN Device`

Use `&#xa;` for line breaks. Never use `<br>` or other HTML tags.

---

## Special Cases

- **`AzureBastionSubnet`** -- Azure-fixed name. Never apply naming pattern.
- **Storage accounts** -- alphanumeric only, no underscores or hyphens (max 24 chars).
- **Key Vaults** -- alphanumeric and hyphens only, no underscores (max 24 chars).

---

## How to Resolve Unknown Resources

If a resource is not listed above, read its `name` argument from the root `.tf` file that instantiates it. Apply `name_prefix` and `name_suffix` substitution using the environment variable values. Do NOT guess or invent names.
