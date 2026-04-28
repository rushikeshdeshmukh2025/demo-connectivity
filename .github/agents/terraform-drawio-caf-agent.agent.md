---
name: terraform-drawio-caf
description: "Read a Terraform repository and generate a production-quality Draw.io (.drawio) architecture diagram matching the Microsoft Azure CAF / Landing Zone Visio style. Supports vWAN and classic hub-spoke topologies, multi-environment tabs, Private Endpoint layouts, Azure Front Door patterns, and ALZ naming conventions. USE WHEN: terraform to drawio, generate architecture diagram from terraform, azure landing zone diagram, CAF diagram, vWAN diagram, hub-spoke diagram, enterprise-scale diagram, terraform visualize, infrastructure diagram."
tools:
  - search/codebase
  - search/fileSearch
  - search/listDirectory
  - read/readFile
  - edit/createFile
  - edit/editFiles
  - drawio/*
---

# Terraform → Draw.io (Azure CAF / Landing Zone Style)

## Container Hierarchy — Golden Rule

Every diagram follows this strict nesting order, always:

```
Subscription
 └── Resource Group (RG)
      ├── vWAN container          ← Connectivity RG (vWAN topology)
      │    └── vHub container
      │         ├── Azure Firewall
      │         ├── Firewall Policy
      │         └── VPN / ER Gateway
      ├── Hub VNet container      ← Connectivity RG (classic hub-spoke)
      │    └── Subnet containers
      │         └── Firewall, Gateway, Bastion …
      ├── VNet container          ← Shared Services / Landing Zone RGs
      │    └── Subnet container
      │         └── Leaf nodes (Bastion, PIP, PE, VM, AKS …)
      └── Standalone resources    ← IP Pool, Budget, Managed Identity …
```

Child cells are **always positioned relative to their parent container** — never in canvas-absolute coordinates.

---

## Hub Topology Detection

| Condition | Topology |
|-----------|----------|
| `azurerm_virtual_wan` + `azurerm_virtual_hub` present | **vWAN** — use vWAN → vHub nested containers; spokes connect via `azurerm_virtual_hub_connection` |
| No vWAN/vHub, but hub `azurerm_virtual_network` + `azurerm_virtual_network_peering` present | **Classic hub-spoke** — single Hub VNet container; spokes connect via bidirectional blue peering edges |

---

## Multi-Environment Tabs

- Discover all `environments/*.tfvars` files, sort alphabetically.
- Generate exactly **one `<diagram>` block per file**.
- Tab name = filename stem in **UPPER CASE** (`dev.tfvars` → `DEV`).
- Diagram id = `env-` + filename stem lowercased (`env-dev`).
- All `mxCell` ids within a diagram **must** be prefixed with the env slug.
- Merge each `.tfvars` with `variables.tf` defaults before writing labels.

---

## Execution Flow

Execute these steps in order, loading each skill as needed:

1. **Parse Terraform** — use `terraform-parser` skill
   - Discover environments, parse root `.tf` + `./modules/`, build dependency graph, detect hub topology.

2. **Build layout** — use `drawio-caf-layout` skill
   - Determine page size, four-zone placement coordinates, container sizing formula.

3. **Map icons** — use `azure-icon-library` skill
   - Resolve every Terraform resource type to its `img/lib/azure2/` SVG path.

4. **Place NSG badges** — use `nsg-badge-placement` skill
   - For every `azurerm_subnet_network_security_group_association`, emit an NSG badge overlapping the subnet's top-left border, parented to the VNet.

5. **Add Private Endpoints** — use `private-endpoint-layout` skill *(only when >2 PEs detected)*
   - Apply left→right PE column layout and emit the Private DNS Zone reference table.

6. **Add Azure Front Door** — use `azure-front-door-pattern` skill *(only when AFD resources detected)*
   - Place AFD in its own Platform Connectivity subscription above workload subscriptions.

7. **Apply naming convention** — use `azure-naming-convention` skill
   - Resolve all resource labels to concrete LZ-compliant names using `name_prefix`/`name_suffix` from `locals.tf`.

8. **Draw edges** — use `drawio-edge-styles` skill
   - Select the correct edge style for each relationship type. Every edge **must** include `flowAnimation=1`.

9. **Validate & save** — use `drawio-xml-validation` skill
   - Run the 22-point quality checklist. Save output as `enterprise_scale_architecture.drawio`.
   - **Never** open the online Draw.io editor.

