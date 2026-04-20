# Copilot Instructions – demo-connectivity

## Code Reviews
- Respond in English.
- Apply all checks from `.github/instructions/copilot.instructions.md`.
- Focus on readability; avoid nested ternary operators.

## Architecture

This repository provisions an Azure hub-and-spoke network topology using **Azure Virtual WAN** (vWAN), deployed entirely in **Germany West Central** (`germanywestcentral` / `gwc`).

### Resource Groups
| File | Resource Group | Purpose |
|------|----------------|---------|
| `connectivity_rg.tf` | `rg_rus_<env>_connectivity_gwc` | vWAN, vHub, Firewall, IP pool, VNet gateway |
| `shd_svc_rg.tf` | `rg_rus_<env>_shd_svc_gwc` | Shared services VNet, NSG, Bastion |

### IP Address Plan
- IP pool: `10.0.0.0/16` (managed via `azurerm_network_manager_static_cidr`)
- vWAN Hub: `10.0.0.0/23`
- Shared services VNet: `10.0.2.0/23`
  - `AzureBastionSubnet`: `10.0.2.0/27`
  - Private endpoint subnet: `10.0.2.32/27`
  - App subnet: `10.0.2.64/27`

### Module Topology
All infrastructure is composed through local modules under `./modules/`. Each root `.tf` file instantiates exactly one module and is named after that module instance:

```
vwan.tf           → module "virtual_wan"            (./modules/azure_virtual_wan)
vhub.tf           → module "virtual_wan_hub"         (./modules/azure_virtual_wan_hub)
ip_pool.tf        → module "ip_pool"                 (./modules/ip_pool)
fw_policy.tf      → module "firewall_policy"         (./modules/azure_firewall_policy)
fw.tf             → module "firewall"                (./modules/azure_firewall)
vnet_gateway.tf   → module "vnet_gateway"            (./modules/...)
shd_svc_vnet.tf   → module "shared_services_vnet"    (./modules/azure_virtual_network)
nsg.tf            → module "network_security_group"  (./modules/network_security_group)
azure_bastion.tf  → module "azure_bastion"           (./modules/azure_bastion)
peering.tf        → module "..."                     (./modules/azure_virtual_network_peering)
```

### Global Locals (`locals.tf`)
```hcl
name_prefix = "${company_prefix}_${environment}"   # e.g. "rus_dev"
name_suffix = region_short                          # e.g. "gwc"
```
These drive all resource names. File-scoped locals are declared at the top of the file that uses them.

## Terraform Commands

```bash
# Initialise
terraform init

# Validate syntax
terraform validate

# Format (run before every commit)
terraform fmt -recursive

# Plan / apply against an environment
terraform plan  -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars

# Lint modules
tflint
```

Environments: `dev`, `test`, `pt`, `live`, `global`, `rnd` — each has a corresponding `environments/<env>.tfvars`.

## Naming Conventions

Resource names follow this pattern:
```
<type_prefix>_<company_prefix>_<environment>_<purpose>_<region_short>
```
**Company prefix:** `rus` | **Region short:** `gwc`

Common type prefixes: `rg_`, `vwan_`, `vhub_`, `afw_`, `afwp_`, `vnet_`, `snet_`, `nsg_`, `ippool_`, `bas_`

The `AzureBastionSubnet` subnet name is **fixed** (Azure requirement) — do not apply the standard naming pattern to it.

All resources must carry these tags:
```hcl
tags = {
  environment = var.environment
  managed_by  = "terraform"
}
```

## Key Rules (see `.github/instructions/copilot.instructions.md` for full detail)

- **Never** add `depends_on` — wire resources via attribute references instead.
- **Never** use `data` sources to read resources defined in the same working directory.
- Prefer `for_each` over `count`; use maps/sets, not lists.
- Use human-readable keys for `for_each`, never resource IDs.
- Do **not** use `any` in variable or output type definitions.
- `.terraform.lock.hcl` **is** committed to source control.
- `.tfvars` files **are** committed (the `.gitignore` has those lines commented out).

## Local Module Structure

Every module under `./modules/<name>/` must contain:
- `variables.tf` – typed inputs (no `any`)
- `outputs.tf` – typed outputs
- `terraform.tf` – `required_providers` block
- One or more `*.tf` files for resources

Modules accept only primitive/structured inputs — data readers belong in the root workspace, not inside modules.