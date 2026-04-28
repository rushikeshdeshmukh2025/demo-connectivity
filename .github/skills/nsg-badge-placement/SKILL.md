---
name: nsg-badge-placement
description: "Place NSG shield badges overlapping subnet borders in Draw.io. NSG badges are parented to the VNet, not the subnet. USE WHEN: NSG associations detected, nsg badge, subnet border badge, network security group placement."
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
| **Edges** | None — badge presence on the border implies association; no connector lines |

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
