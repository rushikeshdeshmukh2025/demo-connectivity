---
name: terraform-drawio-caf-skills
description: "Generate or update a Draw.io Azure CAF architecture diagram from Terraform. Uses `terraform graph` for dependency detection and delegates rendering to modular skills. Supports incremental updates to existing diagrams. USE WHEN: terraform to drawio, architecture diagram, update diagram, visualize terraform, CAF diagram, landing zone diagram."
tools:
  - search/codebase
  - search/fileSearch
  - search/listDirectory
  - read/readFile
  - edit/createFile
  - edit/editFiles
  - drawio/*
---

# Terraform → Draw.io (Azure CAF Style — Skill-Based Agent)

Generates or **updates** an Azure CAF-style `.drawio` diagram using `terraform graph` DOT output as the dependency source. Rendering logic is delegated to skills for speed and maintainability.

Output file: `v2_terraform_graph_architecture.drawio`

---

## Execution Modes

| Mode | Trigger | Behaviour |
|------|---------|-----------|
| **Generate** | No existing `.drawio` file or user says "generate" | Full diagram creation |
| **Update** | Existing `v2_terraform_graph_architecture.drawio` present and user says "update" / "refresh" | Diff-based incremental update |

---

## Generate Mode — Execution Flow

### Step 1 — Initialise & run terraform graph

```powershell
terraform init -input=false -no-color 2>$null
terraform graph -type=plan > .terraform-graph.dot
```

### Step 2 — Parse DOT graph

Read `.terraform-graph.dot`. Extract resource/module nodes and dependency edges.
Filter out `provider`, `var`, `local`, `output` prefix nodes.

Build map: `{resource_type, module_path, resource_name, dependencies[]}`

### Step 3 — Detect topology

| Condition | Topology |
|-----------|----------|
| `azurerm_virtual_wan` + `azurerm_virtual_hub` present | vWAN |
| Hub VNet + `azurerm_virtual_network_peering` (no vWAN) | Classic hub-spoke |
| Neither | Flat |

### Step 4 — Read context files

Read **only** these files for labelling and placement:
1. `locals.tf` — `name_prefix`, `name_suffix`
2. `variables.tf` — defaults
3. `environments/*.tfvars` — per-env values
4. Root `.tf` files with `module "..."` blocks — extract `resource_group_name`, `subnet_id`, naming args

**Do NOT read module internals** — only root-level module invocations.

### Step 5 — Classify resources into containers

**Pass 1 — Known patterns (fast path):**

| Module path pattern | Container |
|---------------------|-----------|
| `module.virtual_wan.*` | vWAN → Connectivity RG |
| `module.virtual_wan_hub.*` | vHub → inside vWAN |
| `module.firewall.*` / `module.firewall_policy.*` | Inside vHub |
| `module.vnet_gateway.*` | Inside vHub |
| `module.ip_pool.*` | Connectivity RG (standalone) |
| `module.*_vnet.*` / `module.*virtual_network.*` | VNet → inside owning RG |
| `module.azure_bastion.*` | Inside AzureBastionSubnet |
| `module.network_security_group*` | NSG badge on VNet |
| `module.*_peering.*` / `module.*hub_connection.*` | Edge |

**Pass 2 — Dynamic classification (all other modules):**

Inspect `resource_group_name` and `subnet_id` arguments from root module blocks:

| Argument | Placement |
|----------|-----------|
| `subnet_id = module.<vnet>.subnet_ids["<key>"]` | Inside that subnet |
| `resource_group_name = azurerm_resource_group.<rg>.name` | Child of that RG |
| `virtual_network_id = module.<vnet>.id` | Inside that VNet |
| None matched | Standalone in Subscription |

### Step 6 — Detect workload patterns & activate skills

Scan resource types in the graph and activate **only relevant** architecture skills:

| Detection | Skill to invoke |
|-----------|----------------|
| `azurerm_kubernetes_cluster` | `arch-aks` |
| `azurerm_virtual_desktop_host_pool` | `arch-avd` |
| `azurerm_api_management` | `arch-apim` |
| `azurerm_synapse_workspace` / `azurerm_data_factory` / `azurerm_databricks_workspace` | `arch-data-platform` |
| `azurerm_cdn_frontdoor_profile` / `azurerm_frontdoor` | `azure-front-door-pattern` |
| `azurerm_private_endpoint` (>2 instances) | `private-endpoint-layout` |
| `azurerm_network_security_group` | `nsg-badge-placement` |

Only load and apply skills that match detected resources — skip others entirely.

### Step 7 — Build Draw.io XML

Delegate to skills in this order:
1. **`drawio-caf-layout`** — page sizing, zone backgrounds, coordinate system
2. **`azure-naming-convention`** — resolve all labels
3. **`azure-icon-library`** — map resource types to icon paths
4. **`drawio-edge-styles`** — apply correct edge style per relationship type
5. **Workload skills** (if activated) — apply pattern-specific container/edge rules
6. **`nsg-badge-placement`** — badges and rules tables (if NSGs present)
7. **`private-endpoint-layout`** — PE column layout (if >2 PEs)
8. **`drawio-xml-validation`** — final quality check

### Step 8 — Save & clean up

```powershell
# Save diagram
# (use edit/createFile to write v2_terraform_graph_architecture.drawio)

# Clean up temp file
Remove-Item .terraform-graph.dot -ErrorAction SilentlyContinue
```

---

## Update Mode — Incremental Refresh

When an existing `v2_terraform_graph_architecture.drawio` is detected:

### Step U1 — Regenerate graph & classify

Run Steps 1–6 from Generate mode to get the **current** resource set.

### Step U2 — Parse existing diagram

Read the existing `.drawio` file. Extract:
- All `mxCell` IDs and their `value` (label)
- Container parent relationships
- Edge source/target pairs

### Step U3 — Diff

Compare current Terraform resources vs existing diagram cells:

| Diff type | Action |
|-----------|--------|
| **New resource** (in TF, not in diagram) | Add new `mxCell` in correct container |
| **Removed resource** (in diagram, not in TF) | Remove `mxCell` and any edges referencing it |
| **Moved resource** (different RG/subnet) | Update `parent` attribute and reposition |
| **Renamed resource** | Update `value` (label) attribute |
| **New edges** | Add edge `mxCell` with correct style |
| **Removed edges** | Delete edge `mxCell` |

### Step U4 — Resize containers

After adding/removing cells, recalculate container sizes bottom-up using the sizing formula from `drawio-caf-layout`.

### Step U5 — Save

Write updated XML back to `v2_terraform_graph_architecture.drawio`.

---

## Container Hierarchy (Golden Rule)

```
Subscription
 └── Resource Group
      ├── vWAN → vHub → {Firewall, FW Policy, VPN GW}
      ├── VNet → Subnet → {leaf nodes}
      └── Standalone resources (IP Pool, DNS Zone, Storage, etc.)
```

Children are **always positioned relative to their parent**.

---

## Multi-Environment Tabs

1. List `environments/*.tfvars`, sort alphabetically.
2. One `<diagram>` tab per environment. Tab name = stem UPPER CASE.
3. All `mxCell` IDs prefixed with `{env_slug}-`.
4. Merge `.tfvars` with `variables.tf` defaults for label resolution.

---

## Quality Gate

Before saving, verify against `drawio-xml-validation` skill checklist:
- Every `<mxCell>` has `html=1`
- Children relative to parent, coordinates multiples of 10
- `flowAnimation=1` on all edges
- Container hierarchy correct
- `<mxfile>` wrapper present
- No duplicate IDs
