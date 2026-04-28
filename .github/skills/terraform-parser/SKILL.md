---
name: terraform-parser
description: "Parse Terraform workspaces to discover resources, modules, variables, locals, and environments. Detects hub topology (vWAN vs classic hub-spoke), merges variable defaults with .tfvars, builds a dependency graph. USE WHEN: parsing terraform, reading .tf files, detecting topology, resolving variables, discovering environments, building dependency graph."
---

# Terraform Parsing Procedure

## Step 1 — Discover Environments

1. List all files matching `environments/*.tfvars`.
2. Sort alphabetically.
3. For each file derive:
   - `env_slug` = filename stem in **lower case** (e.g. `dev.tfvars` → `dev`)
   - `ENV_NAME` = filename stem in **UPPER CASE** (e.g. `DEV`)
4. This ordered list drives the `<diagram>` tab order.

## Step 2 — Parse Root Workspace

Read every `*.tf` file in the workspace root:

| File | What to extract |
|------|-----------------|
| `variables.tf` | Default values for all declared variables |
| `locals.tf` | `name_prefix`, `name_suffix`, and any computed locals |
| `providers.tf` | Required provider versions (for context only) |
| `*.tf` (resource files) | Every `resource "azurerm_*"` block: type, name, and relevant attributes |
| `*.tf` (module calls) | Every `module "…"` block: source path, and all input arguments |

## Step 3 — Parse Modules

For each unique `source` path found in module calls:

1. Resolve relative path from workspace root (e.g. `./modules/azure_virtual_wan`).
2. Read `variables.tf` → map input variable names to their descriptions.
3. Read main `*.tf` resource file → identify the `azurerm_*` resource(s) created.
4. Read `outputs.tf` → map output names to the `.id` / attribute values they expose.

## Step 4 — Variable Resolution (per environment)

For each environment in the discovery list:

1. Load `variables.tf` defaults as the base map.
2. Overlay the environment's `.tfvars` key-value pairs.
3. Resolve `local.*` values using the merged variable map.
4. Substitute all `var.*` and `local.*` references in resource / module arguments.
5. Result: a concrete map `{resource_label → resolved_attributes}` for that environment.

## Step 5 — Build Dependency Graph

Scan resolved attribute maps for cross-resource references:

| Reference pattern | Edge type |
|-------------------|-----------|
| `module.<name>.id` or `module.<name>.<output>` | Module output reference |
| `azurerm_<type>.<name>.id` | Direct `.id` property reference |
| argument named `ip_pool_id` | IP Pool input parameter |
| argument named `firewall_policy_id` | Firewall Policy association |
| `azurerm_subnet_network_security_group_association` resource | NSG ↔ Subnet binding |
| `azurerm_virtual_hub_connection` resource | vHub ↔ Spoke VNet link |
| `azurerm_virtual_network_peering` resource | Classic hub-spoke peering |

Record each edge as `{from, to, label, type}` for use by the `drawio-edge-styles` skill.

## Step 6 — Hub Topology Detection

After parsing, classify the topology:

| Condition | Result |
|-----------|--------|
| `azurerm_virtual_wan` **and** `azurerm_virtual_hub` resources present | **vWAN topology** |
| No vWAN/vHub, but hub VNet + `azurerm_virtual_network_peering` resources present | **Classic hub-spoke** |
| Neither | No hub — render flat RG layout |

Pass the topology classification to the `drawio-caf-layout` skill.

## Step 7 — Resource Count

Count distinct `azurerm_*` resource instances (after module expansion). Pass this count to `drawio-caf-layout` to select page size.

## Output Contract

Produce a structured summary with:

```
environments: [{env_slug, ENV_NAME, resolved_attrs}]
resources: [{env_slug, tf_type, tf_name, resolved_name, parent_rg, parent_vnet, parent_subnet}]
dependencies: [{from_id, to_id, label, edge_type}]
nsg_associations: [{nsg_id, subnet_id, vnet_id}]
hub_topology: "vwan" | "classic" | "flat"
resource_count: <integer>
```
