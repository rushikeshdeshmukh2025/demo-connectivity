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

### On-Premises / Branch Office Icon — MANDATORY OVERRIDE

The **On-Premises / Branch** node (inside the On-Premises zone) **must** use the following style instead of the standard azure2 SVG template. This overrides any icon defined in the `drawio-xml-validation` skill for the On-Premises container's interior child node:

```
sketch=0;outlineConnect=0;gradientColor=none;fontColor=#545B64;strokeColor=none;
fillColor=#879196;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;
align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;
shape=mxgraph.aws4.illustration_office_building;pointerEvents=1;
```

Size: **78 × 78 px**. Label: `On-Premises / Branch`. This replaces any azure2 `Local_Network_Gateways.svg` icon on the On-Premises node leaf.

### Resource Group Container Icon — MANDATORY OVERRIDE

The Resource Group container style **must** include `imageVerticalAlign=top` to pin the icon to the top-left corner. Without it the icon floats vertically to the center of the container. Always use:

```
rounded=1;arcSize=5;fillColor=#DAE8FC;strokeColor=#0078D4;strokeWidth=1;
container=1;collapsible=0;recursiveResize=0;html=1;whiteSpace=wrap;
verticalAlign=top;fontStyle=1;fontSize=12;fontColor=#1A237E;
spacingTop=5;spacingLeft=28;align=left;
image=img/lib/azure2/general/Resource_Groups.svg;
imageAlign=left;imageVerticalAlign=top;imageWidth=20;imageHeight=20;
```

This overrides the RG style in the `drawio-xml-validation` skill — `imageVerticalAlign=top` is **REQUIRED**.

```
aspect=fixed;html=1;points=[];align=center;image;fontSize=9;
image=img/lib/azure2/{CATEGORY}/{ICON}.svg;
labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;
fillColor=#ffffff;rounded=1;arcSize=10;shadow=1;
strokeColor=#e0e0e0;fontColor=#333333;
```

- Standard icon size: **50 × 50 px**.
- vWAN and vHub **swimlane header icons**: `imageWidth=36;imageHeight=36;spacingLeft=48` — larger than default 20×20 to match Resource Group visual weight.
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

- NSG associations are shown as **shield badges** on the subnet border **AND** as rules tables inside a single outer **"NSG Rules" container** to the right of the VNet.
- The outer container is a titled swimlane (`shape=swimlane;startSize=36;fillColor=#E8F0FE;strokeColor=#0078D4;strokeWidth=2;fontColor=#0078D4;fontSize=12;fontStyle=1;collapsible=0;isContainer=1`) labelled `NSG Rules`, placed canvas-absolute (`parent="1"`), id `{env}-nsg-panel`.
- Each per-NSG table cell is a **child of the outer container** (`parent="{env}-nsg-panel"`), positioned relatively (x=10, stacked vertically with 10 px gaps, first table y=46).
- Each badge is **parented to the VNet container**, not the subnet and not the RG.
- Badge straddles the subnet's **top-right border**: `badge_y = subnet_y − 18` (relative to VNet).
- Badge `x = subnet_x + subnet_width − 18` (relative to VNet) — badges are placed on the **right** side of the VNet, not the left. Badge size: **36 × 36 px**.
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
   - Emit one outer **NSG Rules swimlane container** canvas-right of the VNet (`parent="1"`, x ≈ VNet right edge + 80 px, id `{env}-nsg-panel`, label `NSG Rules`).
   - For each NSG, emit an HTML rules table as a **child of the outer container** (`parent="{env}-nsg-panel"`, relative coordinates: x=10, stacked with 10 px gaps, first y=46).
   - Parse all `security_rules` blocks from the Terraform NSG module instances. Render inbound rows, then outbound rows. Deny rows use `background:#FFEBEE`. NSGs with no custom rules show an italic placeholder row.
   - Extend `pageWidth` by **440 px**.
   - Emit one **dashed connector** edge per NSG (`source` = badge id, `target` = inner table id, `parent="1"`), style: `endArrow=none;dashed=1;dashPattern=1 3;strokeWidth=2;exitX=1;exitY=0.5;entryX=0;entryY=0.5`.

5c. **Emit Connections Legend** — place an HTML legend table (id `{env}-legend`, `parent="1"`) at bottom-left of the On-Premises zone (`x=10, y≈900, width=280`). The table explains each edge style: VPN Tunnel (brown dashed), vHub Connection (blue bidir), property .id ref (solid blue), module parameter (grey dotted), NSG association (thin dashed). See section 6c of `terraform-drawio-caf-.agent.md` for the full HTML structure.

6. **Add Private Endpoints** — use `private-endpoint-layout` skill *(only when ≥ 2 PEs detected)*
   - Apply the left→right PE column layout inside the PE subnet.
   - Emit the Private DNS Zone reference table below the VNet.

7. **Add Azure Front Door** — use `azure-front-door-pattern` skill *(only when `azurerm_cdn_frontdoor_profile` or `azurerm_frontdoor` detected)*
   - Place AFD in its own Platform Connectivity subscription above all workload subscriptions.

8. **Draw edges** — use `drawio-edge-styles` skill
   - Emit one edge per dependency in the graph built in step 1.
   - Every edge **must** include `flowAnimation=1;html=1;`.
   - **vHub ↔ Spoke edge** (`azurerm_virtual_hub_connection`): this is the vWAN equivalent of VNet peering — always emit it when the resource exists. Label: `vHub Connection [internet_security=true]` when `internet_security_enabled = true`, otherwise `vHub Connection`. Do NOT omit this edge. In classic hub-spoke (no vWAN), use `azurerm_virtual_network_peering` edges instead.
   - Select the correct style per relationship type (hub↔spoke, `.id` reference, VPN tunnel, module parameter).
   - **On-Premises → VPN/ER Gateway edge MUST use a straight line** — override the default `drawio-edge-styles` style for this relationship to remove orthogonal routing:
     ```
     edgeStyle=none;html=1;dashed=1;endArrow=open;endFill=0;
     strokeColor=#8d6e32;strokeWidth=2;flowAnimation=1;fontSize=9;
     exitX=1;exitY=0.5;exitPerimeter=0;entryX=0;entryY=0.5;entryPerimeter=0;
     ```
     Do NOT use `rounded=1;orthogonalLoop=1` for this edge — it must render as a direct horizontal straight line as shown in the reference diagram.
   - **Omit** all NSG→subnet edges — NSG associations are represented by badges only.

9. **Validate & save** — use `drawio-xml-validation` skill
   - Run the full quality checklist.
   - Verify container styles match: Subscription (orange dashed), RG (blue fill `#DAE8FC`), VNet (white, blue dashed), Subnet (light-blue `#E3F2FD`, grey dashed).
   - **RG icon**: Confirm every Resource Group container style includes `imageVerticalAlign=top` — without it the icon floats to the vertical centre of the container.
   - Confirm `<mxfile>` wrapper is present and all `mxCell` ids are prefixed with the env slug.
   - Confirm the outer `{env}-nsg-panel` swimlane container exists and all per-NSG tables are children of it (`parent="{env}-nsg-panel"`).
   - Confirm dashed connector edges run from each NSG badge to its inner table cell.
   - **NSG badge position**: Confirm every NSG badge x-coordinate is `subnet_x + subnet_width − 18` (right border of the VNet) — badges placed at `subnet_x + 10` (left side) are incorrect and must be rejected.
   - **On-Premises node icon**: Confirm the On-Premises leaf node uses `shape=mxgraph.aws4.illustration_office_building` with `fillColor=#879196`. Any azure2 `Local_Network_Gateways.svg` icon on the On-Premises *leaf node* is incorrect and must be replaced.
   - **VPN/ER Gateway edge**: Confirm the On-Premises → VPN/ER Gateway connector uses `edgeStyle=none` (straight line), NOT `orthogonalLoop=1`. A bent/right-angle line here is a validation failure.
   - Confirm the Connections Legend table (`{env}-legend`) exists at bottom-left of the On-Premises zone (x=10, y≈900, width=280).
   - Confirm vHub ↔ Spoke edges use label `vHub Connection [internet_security=true]` (not "hub connection").
   - Confirm vWAN and vHub swimlane icons use `imageWidth=36;imageHeight=36;spacingLeft=48`.
   - Save output as `Azure_styled_architecture.drawio`. **Never** open the online Draw.io editor.

