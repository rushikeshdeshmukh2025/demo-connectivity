---
name: nsg-badge-placement
description: "Place NSG shield badges overlapping subnet borders in Draw.io and emit NSG rules side-panel tables outside the Azure zone. NSG badges are parented to the VNet, not the subnet. No connector edges between badges and tables. USE WHEN: NSG associations detected, nsg badge, subnet border badge, network security group placement, nsg rules table, nsg side panel."
---

# NSG Badge Placement

NSG icons are **small shield badges** that straddle the subnet border — they are **not** regular leaf nodes placed inside the subnet.

## Rules

| Property | Value |
|----------|-------|
| **Parent cell** | The **VNet** container (NOT the subnet, NOT the RG) |
| **Size** | 36 × 36 px |
| **Position x** | `subnet_x + subnet_width − 18` (relative to VNet) — badge straddles the **right** border |
| **Position y** | `subnet_y − 18` (relative to VNet) — badge straddles the top border |
| **Font size** | 8 |
| **Edges** | **NONE** — no connector edges from badge to table. The badge on the subnet border is self-explanatory. |

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
  <mxGeometry x="{subnet_x + subnet_width - 18}" y="{subnet_y - 18}" width="36" height="36" as="geometry"/>
</mxCell>
```

Replace:
- `{env_slug}` — environment prefix (e.g. `dev`)
- `{subnet_name}` — Terraform name of the associated subnet (e.g. `bastion`)
- `{resolved_nsg_name}` — concrete NSG name after variable resolution (e.g. `nsg-rus-dev-bastion-gwc`)
- `{vnet_name}` — Terraform name of the parent VNet
- `{subnet_x}`, `{subnet_y}`, `{subnet_width}` — position and width of the subnet container **relative to the VNet**

---

## Example — Three subnets in a VNet

Given a VNet with three subnets (width=380) at y-offsets 50, 200, 340 respectively, each with an NSG association:

| Subnet | Subnet y (rel. to VNet) | Badge x (rel. to VNet) | Badge y (rel. to VNet) |
|--------|------------------------|------------------------|------------------------|
| `AzureBastionSubnet` | 50 | 362 | 32 |
| `snet-pep` | 200 | 362 | 182 |
| `snet-app` | 340 | 362 | 322 |

All three badge cells have `parent="{env_slug}-vnet-sharedservices"`.

---

## NSG Rules Side-Panel Tables

For **every NSG**, emit an HTML rules table **outside the Azure zone box** (to its right). This is required for all diagrams — do not skip even when an NSG has no custom rules.

**FORBIDDEN:** Do NOT emit any connector edge between NSG badges and tables. The badge on the subnet right border is self-explanatory.

### Layout rules

- Tables use `parent="1"` (canvas-absolute, not inside any container).
- Tables are placed **outside the Azure zone background** (to its right).
- `x` origin: Azure zone right edge + 40 px.
- Arrange tables in **two columns**, filling top-to-bottom then left-to-right:
  - Column 1: `x` = Azure zone right edge + 40 px
  - Column 2: `x` = Column 1 x + table width + 20 px
- Stack vertically within each column with **10 px gaps**.
- **NSG with custom rules**: height ≈ `(inbound_count + outbound_count) × 22 + 120` px.
- **NSG with no custom rules**: height = 160 px.
- Width = 380 px.
- Extend `pageWidth` by **820 px** whenever side-panel tables are emitted (two columns × 400 + gaps).

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

### Standard vertical stack — Shared Services VNet (three subnets)

| Table ID | x | y | Width | Height |
|---|---|---|---|---|
| `{env}-nsg-table-bastion` | col1_x | 40 | 380 | 490 (full rules) |
| `{env}-nsg-table-pe` | col1_x | 540 | 380 | 160 (no rules) |
| `{env}-nsg-table-app` | col2_x | 40 | 380 | 160 (no rules) |

Where `col1_x` = Azure zone right edge + 40, `col2_x` = col1_x + 400.

Adjust `y` and `height` proportionally when more or fewer custom rules exist.
