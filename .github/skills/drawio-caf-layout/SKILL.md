---
name: drawio-caf-layout
description: "Build the Draw.io page layout for Azure CAF / Landing Zone diagrams: adaptive page sizing, two-zone horizontal layout, container sizing formula, and precise placement coordinates. USE WHEN: building draw.io layout, page sizing, zone coordinates, container sizing, positioning resources."
---

# Draw.io CAF Layout Rules

## 1 — Core XML Wrapper

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="GitHub Copilot" version="24.0.0">
  <diagram name="{ENV_NAME}" id="env-{env_slug}">
    <mxGraphModel dx="1422" dy="1600" grid="1" gridSize="10"
      guides="1" tooltips="1" connect="1" arrows="1" fold="1"
      page="1" pageScale="1" pageWidth="{PAGE_W}" pageHeight="{PAGE_H}"
      math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <!-- zone backgrounds, containers, nodes, edges -->
      </root>
    </mxGraphModel>
  </diagram>
  <!-- repeat <diagram> for each environment -->
</mxfile>
```

**Mandatory rules for every `<mxCell>`:**
- `html=1` is **required** on every cell — containers, icons, and edges.
- Labels use `&#xa;` for line breaks. Never use `<br>` or other HTML tags.
- Cell `id="0"` = invisible root. Cell `id="1"` = default layer (parent for zone backgrounds and top-level containers).

---

## 2 — Adaptive Page Sizing

Select page dimensions based on total resolved resource count:

| Complexity | Condition | `pageWidth` | `pageHeight` |
|------------|-----------|-------------|--------------|
| A4 landscape | ≤ 15 resources | 1169 | 827 |
| A3 landscape | 16–40 resources | 1654 | 1169 |
| Custom wide | 41+ resources (enterprise-scale) | 2400 | 1200 |

---

## 3 — Two-Zone Horizontal Layout

Emit exactly **TWO zone background rectangles first** (lowest z-order, `parent="1"`).

**Explicitly forbidden:** Do NOT create separate background rectangles for "Connectivity", "Shared Services", or "Landing Zones". The single Azure box contains everything.

| Zone | X range | Fill colour | Stroke colour | Purpose |
|------|---------|-------------|---------------|---------|
| **On-Premises** | 0–300 | `#f5f0e6` (beige) | `#808080` | On-prem DC / branch, VPN tunnel |
| **Azure** | 320–pageWidth | `#e8f0fe` (light blue) | `#0078D4` | ALL Azure components — subscriptions, RGs, vWAN, VNets, everything |

Zone height = `pageHeight − 20`.

### On-Premises zone style
```
rounded=1;arcSize=5;fillColor=#f5f0e6;strokeColor=#808080;strokeWidth=1;
container=0;movable=0;resizable=0;selectable=0;opacity=60;
html=1;whiteSpace=wrap;verticalAlign=top;fontStyle=1;fontSize=14;
fontColor=#333333;spacingTop=8;spacingLeft=10;
```

### Azure zone style
```
rounded=1;arcSize=5;fillColor=#e8f0fe;strokeColor=#0078D4;strokeWidth=2;
container=0;movable=0;resizable=0;selectable=0;opacity=60;
html=1;whiteSpace=wrap;verticalAlign=top;fontStyle=1;fontSize=14;
fontColor=#0078D4;spacingTop=8;spacingLeft=10;
```

Zone backgrounds are non-interactive rectangles emitted **first** (lowest z-order). All resource containers (Subscription, RGs, VNets) sit on top with `parent="1"`.

---

## 4 — Coordinate System

- Origin `(0,0)` = top-left of canvas.
- **Children are positioned RELATIVE TO THEIR PARENT container** — not the canvas.
- All coordinates **must be multiples of 10** (grid-snap rule).

**Worked example:**

```
Subscription at canvas (330, 40), size 1920×700
 └─ RG at (20, 60) inside Subscription → canvas (350, 100)
     └─ VNet at (20, 50) inside RG → canvas (370, 150)
          └─ Subnet at (20, 40) inside VNet → canvas (390, 190)
               └─ VM icon at (25, 35) inside Subnet → canvas (415, 225)
```

---

## 5 — Container Sizing Formula (bottom-up)

Always calculate container size from children — **never guess**:

```
width  = cols × (child_w + h_gap) − h_gap + 2 × padding
height = title_h + rows × (child_h + v_gap) − v_gap + 2 × padding
```

| Constant | Value | Notes |
|----------|-------|-------|
| `icon_w` / `icon_h` | 50 | Standard service icon |
| `h_gap` | 30 | Horizontal gap between icons |
| `v_gap` | 30 | Vertical gap between icon rows |
| `padding` | 25 | Space from container edge to first child |
| `title_h` | 30 | Reserved height for container label |

**Example — Subnet with 3 icons in one row:**
```
width  = 3 × (50+30) − 30 + 2×25 = 260
height = 30 + 1 × (50+30) − 30 + 2×25 = 130
```

### Spacing Between Containers

| Gap between | Value |
|-------------|-------|
| Icons in the same group | 30 px |
| Subnet containers | 20 px |
| VNet / RG containers | 40 px |
| Subscription containers | 60 px |
| External elements to diagram edge | 80 px |

---

## 6 — Placement Coordinates

All Azure resources are placed **inside the single Azure zone**, organized by Resource Group. RG placement is determined by reading `resource_group_name` from root module blocks.

### 6.1 On-Premises Zone (x = 10–290)

Y-alignment: derive from VPN Gateway position so the On-Prem → VPN GW edge is perfectly horizontal.

| Element | x | y | w | h |
|---------|---|---|---|---|
| On-Premises box | 30 | *derived* | 230 | 120 |

### 6.2 Azure Zone — Subscription and Resource Groups

All RGs sit inside a single Subscription container within the Azure zone.

| Element | x | y | w | h | Parent |
|---------|---|---|---|---|--------|
| Subscription | 330 | 40 | 1920 | 700 | `1` |
| Connectivity RG | 20 | 60 | 620 | 580 | subscription |
| Shared Services RG | 680 | 60 | 460 | 580 | subscription |

Additional RGs (e.g. Landing Zone workloads) are placed to the right of existing RGs, spaced 40 px apart.

### 6.3 Connectivity RG Contents

| Element | x | y | w | h | Parent |
|---------|---|---|---|---|--------|
| IP Pool node | 20 | 50 | 180 | 70 | `conn_rg` |
| vWAN container | 20 | 150 | 580 | 380 | `conn_rg` |
| vHub container | 20 | 50 | 540 | 290 | `vwan` |
| Firewall Policy | 20 | 60 | 160 | 80 | `vhub` |
| Azure Firewall | 200 | 60 | 160 | 80 | `vhub` |
| VPN Gateway | 380 | 60 | 140 | 80 | `vhub` |

### 6.4 Shared Services RG Contents

| Element | x | y | w | h | Parent |
|---------|---|---|---|---|--------|
| VNet container | 20 | 50 | 420 | 470 | `shd_rg` |
| AzureBastionSubnet | 20 | 50 | 380 | 130 | `vnet` |
| Private Endpoint subnet | 20 | 200 | 380 | 120 | `vnet` |
| App subnet | 20 | 340 | 380 | 120 | `vnet` |
| Standalone resources | 20 | 530 | (calculated) | (calculated) | `shd_rg` |

Standalone resources (Storage Account, Key Vault, DNS Zones) that belong to this RG but not to any subnet are placed as direct children of the RG, below the VNet.

### 6.5 Landing Zone Spokes (if present)

Application spoke VNets are placed in additional RGs to the right of Shared Services RG, still inside the Subscription container.

| Pattern | Key resources |
|---------|---------------|
| AKS workload | `azurerm_kubernetes_cluster`, `azurerm_container_registry` |
| APIM + AppGW | `azurerm_api_management`, `azurerm_application_gateway` |
| Web App | `azurerm_app_service`, `azurerm_service_plan` |
| VM workload | `azurerm_linux_virtual_machine` / `azurerm_windows_virtual_machine` |

### 6.6 Key Edges

| From | To | Label | Edge type |
|------|----|-------|-----------|
| On-Premises box | VPN Gateway | `VPN Tunnel` | On-Prem → VPN GW |
| IP Pool | vHub | `ip_pool_id` | Module parameter |
| IP Pool | VNet | `ip_pool_id` | Module parameter |
| Firewall Policy | Firewall | `firewall_policy_id` | `.id` ref |
| vHub | Spoke VNet | `hub connection&#xa;internet_security` | Hub ↔ Spoke |
| Bastion | Public IP | *(empty)* | `.id` ref |
