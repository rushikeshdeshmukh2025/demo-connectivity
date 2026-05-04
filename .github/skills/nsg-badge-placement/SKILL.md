---
name: nsg-badge-placement
description: "Place NSG shield badges overlapping subnet borders in Draw.io and emit NSG rules side-panel tables with dashed connectors. NSG badges are parented to the VNet, not the subnet. USE WHEN: NSG associations detected, nsg badge, subnet border badge, network security group placement, nsg rules table, nsg side panel."
---

# NSG Badge Placement

NSG icons are **small shield badges** that straddle the subnet border — they are **not** regular leaf nodes placed inside the subnet.

## Rules

| Property | Value |
|----------|-------|
| **Parent cell** | The **VNet** container (NOT the subnet, NOT the RG) |
| **Size** | 36 × 36 px (four-zone overview diagrams) · 30 × 30 px (detailed diagrams) |
| **Position x** | `subnet_x + 10` (relative to VNet) |
| **Position y** | `subnet_y − (badge_height / 2)` (relative to VNet) — badge straddles the top border |
| **Font size** | 8 |
| **Edges** | One dashed connector per badge — from badge (right) to its rules table (left). No edge from badge to subnet. |

**Trigger:** Emit one NSG badge for every `azurerm_subnet_network_security_group_association` discovered by the `terraform-parser` skill.

---

## XML Template

```xml
<mxCell id="{env_slug}-nsg-{subnet_name}" value="{resolved_nsg_name}"
  style="image;aspect=fixed;html=1;points=[];align=center;
  imageAlign=center;imageVerticalAlign=middle;verticalAlign=bottom;
  verticalLabelPosition=bottom;labelPosition=center;rounded=1;
  fontSize=8;fontColor=#333333;shadow=0;strokeColor=none;fillColor=none;
  image=img/lib/azure2/networking/Network_Security_Groups.svg;"
  vertex="1" parent="{env_slug}-vnet-{vnet_name}">
  <mxGeometry x="{subnet_x + 10}" y="{subnet_y - 18}" width="36" height="36" as="geometry"/>
</mxCell>
```

Replace:
- `{env_slug}` — environment prefix (e.g. `dev`)
- `{subnet_name}` — Terraform name of the associated subnet (e.g. `bastion`)
- `{resolved_nsg_name}` — concrete NSG name after variable resolution (e.g. `nsg-rus-dev-bastion-gwc`)
- `{vnet_name}` — Terraform name of the parent VNet
- `{subnet_x}`, `{subnet_y}` — position of the subnet container **relative to the VNet**

---

## Example — Three subnets in a VNet

Given a VNet with three subnets at y-offsets 50, 200, 340 respectively, each with an NSG association:

| Subnet | Subnet y (rel. to VNet) | Badge y (rel. to VNet) |
|--------|------------------------|------------------------|
| `AzureBastionSubnet` | 50 | 32 |
| `snet-pep` | 200 | 182 |
| `snet-app` | 340 | 322 |

All three badge cells have `parent="{env_slug}-vnet-sharedservices"`.

---

## NSG Rules Side-Panel Tables

For **every NSG**, emit an HTML rules table to the **right of the VNet container** and a **dashed connector** from the NSG badge to the table. This is required for all diagrams — do not skip even when an NSG has no custom rules.

### Layout rules

- Tables use `parent="1"` (canvas-absolute, not inside any container).
- `x` = VNet right canvas edge + 80 px gap (typically ≈ 1660 for standard layouts).
- `y` = vertically aligned with the subnet the NSG is associated to.
- Stack tables top-to-bottom in the same column, in association order (e.g. bastion → PE → app).
- **NSG with custom rules**: height ≈ `(inbound_count + outbound_count) × 22 + 120` px.
- **NSG with no custom rules**: height = 160 px.
- Width = 380 px.
- Extend `pageWidth` by **440 px** whenever side-panel tables are emitted.

### Table cell style

```
text;html=1;strokeColor=#0078D4;fillColor=#FAFAFA;align=left;
verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;
rotatable=0;fontSize=10;
```

### Table HTML structure

```html
<table border="1" cellpadding="4" cellspacing="0"
  style="border-collapse:collapse;font-size:10px;width:100%;">
  <tr style="background:#0078D4;color:white;">
    <td colspan="6" style="font-weight:bold;padding:6px;">&#x1F6E1; {nsg_name}</td>
  </tr>
  <!-- Inbound -->
  <tr style="background:#E3F2FD;">
    <td colspan="6" style="font-weight:bold;text-align:center;padding:4px;">&#x2193; Inbound Rules</td>
  </tr>
  <tr style="background:#f5f5f5;font-weight:bold;">
    <td>Name</td><td>Priority</td><td>Source</td>
    <td>Destination</td><td>Port</td><td>Protocol</td>
  </tr>
  <!-- One <tr> per inbound rule. Deny rows: style="background:#FFEBEE;" -->
  <!-- No custom rules placeholder: -->
  <tr style="color:#888888;">
    <td colspan="6" style="text-align:center;font-style:italic;">No custom inbound rules (Azure defaults apply)</td>
  </tr>
  <!-- Outbound -->
  <tr style="background:#FFF3E0;">
    <td colspan="6" style="font-weight:bold;text-align:center;padding:4px;">&#x2191; Outbound Rules</td>
  </tr>
  <tr style="background:#f5f5f5;font-weight:bold;">
    <td>Name</td><td>Priority</td><td>Source</td>
    <td>Destination</td><td>Port</td><td>Protocol</td>
  </tr>
  <!-- One <tr> per outbound rule. Deny rows: style="background:#FFEBEE;" -->
</table>
```

### Connector edge (NSG badge → table)

```xml
<mxCell id="{env}-nsg-edge-{subnet}" value=""
  style="endArrow=none;dashed=1;html=1;dashPattern=1 3;strokeWidth=2;
  rounded=0;exitX=1;exitY=0.5;exitDx=0;exitDy=0;
  entryX=0;entryY=0.5;entryDx=0;entryDy=0;"
  edge="1" source="{env}-nsg-{subnet}" target="{env}-nsg-table-{subnet}"
  parent="1">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

### Standard vertical stack — Shared Services VNet (three subnets)

| Table ID | x | y | Width | Height |
|---|---|---|---|---|
| `{env}-nsg-table-bastion` | 1660 | 120 | 380 | 490 (full rules) |
| `{env}-nsg-table-pe` | 1660 | 640 | 380 | 160 (no rules) |
| `{env}-nsg-table-app` | 1660 | 820 | 380 | 160 (no rules) |

Adjust `y` and `height` proportionally when more or fewer custom rules exist.
