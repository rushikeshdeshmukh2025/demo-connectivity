---
name: azure-naming-convention
description: "Resolve Azure Landing Zone resource labels using org naming conventions. Derives all resource names from locals.tf name_prefix/name_suffix and .tfvars variable values. USE WHEN: generating resource labels, naming conventions, LZ naming, name_prefix, name_suffix, locals.tf, label resolution."
---

# Azure Landing Zone Naming Convention

All resource names are **lowercase**, **hyphen-separated**.

## Variable Reference

| Variable | Description | Examples |
|----------|-------------|---------|
| `{tenant}` | Organisation short code | `rus`, `svs`, `contoso` |
| `{region}` | Azure region abbreviation | `gwc` (germanywestcentral), `we` (westeurope) |
| `{env}` | Environment tier | `dev`, `tst`, `prd`, `pre`, `rnd` |
| `{workload}` | Workload / project name | `connectivity`, `sharedservices` |
| `{seq}` | Sequence number, zero-padded | `001`, `002` |

## locals.tf Derivation

Read `locals.tf` to extract the org-standard `name_prefix` and `name_suffix`:

```hcl
# Example from locals.tf
name_prefix = "${company_prefix}_${environment}"   # e.g. "rus_dev"
name_suffix = region_short                         # e.g. "gwc"
```

Use these to reconstruct the full resolved name for each resource, substituting the Terraform variable values from the current environment's `.tfvars`.

---

## Resource Name Patterns

| Resource Type | Pattern | Example |
|---------------|---------|---------|
| Subscription | `sub-{tenant}-landingzone-{env}-{workload}` | `sub-rus-landingzone-dev-connectivity` |
| Resource Group | `rg-{tenant}-{purpose}-{region}-{seq}` | `rg-rus-connectivity-gwc-001` |
| Virtual Network | `vnet-{tenant}-{workload}-{region}-{seq}` | `vnet-rus-sharedservices-gwc-001` |
| Subnet | `snet-{tenant}-{workload}-{function}-{region}-{seq}` | `snet-rus-shdsvc-bastion-gwc-001` |
| vWAN | `vwan-{tenant}-{env}-{region}-{seq}` | `vwan-rus-dev-gwc-001` |
| vHub | `vhub-{tenant}-{env}-{region}-{seq}` | `vhub-rus-dev-gwc-001` |
| Azure Firewall | `afw-{tenant}-{env}-{workload}-{region}` | `afw-rus-dev-connectivity-gwc` |
| Firewall Policy | `afwp-{tenant}-{env}-{workload}-{region}` | `afwp-rus-dev-connectivity-gwc` |
| VPN Gateway | `vpngw-{tenant}-{env}-{region}-{seq}` | `vpngw-rus-dev-gwc-001` |
| Bastion | `bas-{tenant}-{env}-{region}-{seq}` | `bas-rus-dev-gwc-001` |
| NSG | `nsg-{tenant}-{env}-{subnet}-{region}` | `nsg-rus-dev-bastion-gwc` |
| Route Table | `rt-{tenant}-{workload}-{region}-{seq}` | `rt-rus-shdsvc-gwc-001` |
| IP Pool | `ippool-{tenant}-{env}-{region}-{seq}` | `ippool-rus-dev-gwc-001` |
| Managed Identity | `mi-{tenant}-{env}-{workload}-{seq}` | `mi-rus-dev-devops-001` |
| Budget | `bg-{tenant}-{env}-{workload}` | `bg-rus-dev-chatbot` |
| Public IP | `pip-{tenant}-{env}-{purpose}-{region}-{seq}` | `pip-rus-dev-bastion-gwc-001` |

## Special Cases

- **`AzureBastionSubnet`** — this subnet name is **fixed** by Azure. Do **not** apply the standard pattern. Always label it exactly `AzureBastionSubnet`.
- CIDR ranges from the IP address plan should be included in container labels where architecturally relevant (e.g. VNet: `vnet-rus-shdsvc-gwc-001&#xa;10.0.2.0/23`).
