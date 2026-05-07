---
name: terraform-drawio-skills
description: "Generate a Draw.io Azure CAF architecture diagram from Terraform. Uses terraform graph for dependency detection and delegates rendering to modular skills. USE WHEN: terraform to drawio, architecture diagram, visualize terraform, CAF diagram, landing zone diagram."
tools:
  - search/codebase
  - search/fileSearch
  - search/listDirectory
  - read/readFile
  - edit/createFile
  - edit/editFiles
  - drawio/*
---

# Terraform → Draw.io (Azure CAF Style — Lean Orchestrator)

Output file: `terraform_graph_architecture.drawio`

---

## Execution Flow

### Step 1 — Run terraform graph

```powershell
terraform init -input=false -no-color 2>$null
terraform graph -type=plan > .terraform-graph.dot
```

### Step 2 — Parse DOT graph

Read `.terraform-graph.dot`. Extract resource/module nodes and dependency edges.
Filter out `provider`, `var`, `local`, `output` prefix nodes.

### Step 3 — Detect topology

| Condition | Topology |
|-----------|----------|
| `azurerm_virtual_wan` + `azurerm_virtual_hub` | vWAN |
| Hub VNet + peering (no vWAN) | Classic hub-spoke |
| Neither | Flat |

### Step 4 — Read context files

Read ONLY:
1. `locals.tf` — `name_prefix`, `name_suffix`
2. `variables.tf` — defaults
3. `environments/*.tfvars` — per-env values
4. Root `.tf` files with `module "..."` blocks — `resource_group_name`, `subnet_id`, naming args

**Do NOT read module internals.**

### Step 5 — Classify resources into containers

Read `resource_group_name` from each root module block to determine RG placement.

**Pass 1 — Known patterns:**

| Module path | Container |
|-------------|-----------|
| `module.virtual_wan.*` | vWAN → Connectivity RG |
| `module.virtual_wan_hub.*` | vHub → inside vWAN |
| `module.firewall.*` / `module.firewall_policy.*` | Inside vHub |
| `module.vnet_gateway.*` | Inside vHub |
| `module.ip_pool.*` | Connectivity RG (standalone) |
| `module.*_vnet.*` / `module.*virtual_network.*` | VNet → owning RG |
| `module.azure_bastion.*` | Inside AzureBastionSubnet |
| `module.network_security_group*` | NSG badge on VNet |
| `module.*_peering.*` / `module.*hub_connection.*` | Edge |

**Pass 2 — Dynamic:** Inspect `resource_group_name`, `subnet_id`, `virtual_network_id` to place remaining resources.

### Step 6 — Activate conditional skills

| Detection | Skill |
|-----------|-------|
| `azurerm_kubernetes_cluster` | `arch-aks` |
| `azurerm_virtual_desktop_host_pool` | `arch-avd` |
| `azurerm_api_management` | `arch-apim` |
| `azurerm_synapse_workspace` / `azurerm_data_factory` | `arch-data-platform` |
| `azurerm_private_endpoint` (>2) | `private-endpoint-layout` |
| `azurerm_network_security_group` | `nsg-badge-placement` |

### Step 7 — Build Draw.io XML

Load and apply skills in this order:
1. **`drawio-rendering`** — page sizing, zones, container styles, coordinates, sizing formula
2. **`azure-naming-convention`** — resolve all labels
3. **`azure-icon-library`** — map resource types to icon paths
4. **`drawio-edge-styles`** — edge style per relationship type
5. **Conditional skills** (Step 6) — pattern-specific rules
6. Validate against **`drawio-rendering`** quality checklist (§8)

### Step 8 — Save & clean up

**MANDATORY: Write ONE environment at a time. NEVER generate all tabs in a single tool call.**

1. Build the XML for the **first** environment tab only.
2. `edit/createFile` with `<mxfile>` containing that single `<diagram>...</diagram>` and closing `</mxfile>`.
3. For **each subsequent** environment:
   - Build that tab's `<diagram>...</diagram>` XML.
   - `edit/editFiles` to insert it before `</mxfile>`.
4. After all tabs are written, clean up.

> **Why:** A 3-env diagram with NSG tables exceeds output token limits and causes `file_text: Required` errors. Writing incrementally avoids this.

After saving:
```powershell
Remove-Item .terraform-graph.dot -ErrorAction SilentlyContinue
```

---

## Multi-Environment Tabs

1. List `environments/*.tfvars`, sort alphabetically.
2. One `<diagram>` tab per env. Tab name = stem UPPER CASE.
3. `mxCell` IDs prefixed with `{env_slug}-`.
4. Merge `.tfvars` with `variables.tf` defaults for labels.

---

## Critical Rules (override skills if conflicting)

- **Two zones only:** On-Premises + Azure. No separate Connectivity/Shared Services zones.
- **RG classification:** Read actual `resource_group_name` — never assume by type.
- **On-Prem → VPN GW:** Must be perfectly horizontal (same canvas Y).
- **NSG:** No connectors between badges and tables. Ever.
- **Connections Legend:** Below On-Premises zone, not inside it.
