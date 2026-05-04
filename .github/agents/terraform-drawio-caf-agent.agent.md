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

## Icon Style Rules — MANDATORY

Every leaf resource icon **must** use this exact style. Never use `shape=image` for leaf nodes.

```
aspect=fixed;html=1;points=[];align=center;image;fontSize=9;
image=img/lib/azure2/{CATEGORY}/{ICON}.svg;
labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;
fillColor=#ffffff;rounded=1;arcSize=10;shadow=1;
strokeColor=#e0e0e0;fontColor=#333333;
```

- Standard icon size: **50 × 50 px**.
- Label renders **below** the icon — `verticalLabelPosition=bottom;verticalAlign=top`.
- `labelPosition=center` keeps the label horizontally centred beneath the icon.
- The `shape=image;imageVerticalAlign=top;verticalAlign=bottom` variant is **forbidden** — it causes text overlap.

---

## Subnet Layout Rules — MANDATORY

Subnets inside a VNet are rendered as **wide horizontal rows stacked vertically**, never as tall vertical columns placed side by side.

| Property | Value |
|----------|-------|
| Subnet width | VNet width − 40 px (20 px padding each side) |
| Subnet height | calculated bottom-up (see `drawio-caf-layout` formula; min 130 px) |
| Vertical gap between subnets | 30 px |
| Icon rows inside a subnet | horizontal, left-to-right |

Icons inside a subnet are positioned with their centre at `y = (subnet_height − 50) / 2` (vertically centred).

---

## NSG Badge Rules — MANDATORY

- NSG associations are shown as **shield badges** on the subnet border **AND** as rules tables in a side panel to the right of the VNet.
- Each badge is **parented to the VNet container**, not the subnet and not the RG.
- Badge straddles the subnet's top border: `badge_y = subnet_y − 18` (relative to VNet).
- Badge `x = subnet_x + 10` (relative to VNet). Badge size: **36 × 36 px**.
- No standalone NSG icon is placed anywhere in the diagram (badges only).
- A **dashed connector edge** runs from each NSG badge (right side, `exitX=1;exitY=0.5`) to its rules table (left side, `entryX=0;entryY=0.5`); style: `endArrow=none;dashed=1;dashPattern=1 3;strokeWidth=2`.

---

## XML Wrapper Rule — MANDATORY

Every output file **must** open with the `<mxfile>` wrapper:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="GitHub Copilot" version="24.0.0">
  <diagram name="{TAB_NAME}" id="env-{env_slug}">
    <mxGraphModel ...>
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        ...
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

A bare `<mxGraphModel>` root (without `<mxfile>`) is invalid and will not open in Draw.io.

---

## Execution Flow

Execute these steps **in order**, loading each skill before using it:

1. **Parse Terraform** — use `terraform-parser` skill
   - Discover all `environments/*.tfvars` files (sorted alphabetically).
   - Parse root `.tf` files and every module under `./modules/`.
   - Merge `.tfvars` values with `variables.tf` defaults.
   - Read `locals.tf` to extract `name_prefix` and `name_suffix`.
   - Build the full resource dependency graph and detect hub topology (vWAN vs classic hub-spoke).

2. **Apply naming convention** — use `azure-naming-convention` skill
   - Resolve every resource label to its concrete LZ-compliant name using `name_prefix` / `name_suffix`.
   - Do this **before** placing any cell so every label is final at draw-time.

3. **Build layout** — use `drawio-caf-layout` skill
   - Select page size from the adaptive table (resource count).
   - Emit the four zone background rectangles first (lowest z-order).
   - Calculate all container sizes bottom-up using the sizing formula.
   - Position all containers using zone coordinates; children relative to their parent.
   - Subnets are **horizontal rows stacked vertically** — enforce the Subnet Layout Rules above.

4. **Map icons** — use `azure-icon-library` skill
   - Resolve every `azurerm_*` resource type to its `img/lib/azure2/` SVG path.
   - Apply the **Icon Style** template exactly (`aspect=fixed;…verticalLabelPosition=bottom;verticalAlign=top`).
   - Standard size 50 × 50 px for all leaf icons.

5. **Place NSG badges** — use `nsg-badge-placement` skill
   - For every `azurerm_subnet_network_security_group_association` found by step 1, emit one NSG badge parented to the **VNet** container.
   - Enforce badge coordinates and size from the NSG Badge Rules above.
   - **Do not** add any edge from the NSG badge directly to a subnet.

5b. **Emit NSG rules side-panel** — use `nsg-badge-placement` skill (side-panel section)
   - For each NSG, emit an HTML rules table canvas-right of the VNet (`parent="1"`, x ≈ VNet right edge + 80 px).
   - Stack tables vertically aligned with their subnet: bastion → PE → app.
   - Parse all `security_rules` blocks from the Terraform NSG module instances. Render inbound rows, then outbound rows. Deny rows use `background:#FFEBEE`. NSGs with no custom rules show an italic placeholder row.
   - Extend `pageWidth` by **440 px**.
   - Emit one **dashed connector** edge per NSG (`source` = badge id, `target` = table id), style: `endArrow=none;dashed=1;dashPattern=1 3;strokeWidth=2;exitX=1;exitY=0.5;entryX=0;entryY=0.5`.

6. **Add Private Endpoints** — use `private-endpoint-layout` skill *(only when ≥ 2 PEs detected)*
   - Apply the left→right PE column layout inside the PE subnet.
   - Emit the Private DNS Zone reference table below the VNet.

7. **Add Azure Front Door** — use `azure-front-door-pattern` skill *(only when `azurerm_cdn_frontdoor_profile` or `azurerm_frontdoor` detected)*
   - Place AFD in its own Platform Connectivity subscription above all workload subscriptions.

8. **Draw edges** — use `drawio-edge-styles` skill
   - Emit one edge per dependency in the graph built in step 1.
   - Every edge **must** include `flowAnimation=1;html=1;`.
   - Select the correct style per relationship type (hub↔spoke, `.id` reference, VPN tunnel, module parameter).
   - **Omit** all NSG→subnet edges — NSG associations are represented by badges only.

9. **Validate & save** — use `drawio-xml-validation` skill
   - Run the full quality checklist.
   - Verify container styles match: Subscription (orange dashed), RG (blue fill `#DAE8FC`), VNet (white, blue dashed), Subnet (light-blue `#E3F2FD`, grey dashed).
   - Confirm `<mxfile>` wrapper is present and all `mxCell` ids are prefixed with the env slug.
   - Confirm NSG side-panel tables exist and connector edges are present for every NSG.
   - Save output as `Azure_styled_architecture.drawio`. **Never** open the online Draw.io editor.

