---
name: drawio-caf-layout
description: "Build the Draw.io page layout for Azure CAF / Landing Zone diagrams: adaptive page sizing, four-zone horizontal layout, container sizing formula, and precise placement coordinates for all zones. USE WHEN: building draw.io layout, page sizing, zone coordinates, container sizing, positioning resources."
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

## 3 — Four-Zone Horizontal Layout

Emit **four zone background rectangles first** (lowest z-order, `parent="1"`).  
Style for all zone backgrounds:

```
rounded=0;whiteSpace=wrap;html=1;movable=0;resizable=0;selectable=0;
opacity=60;strokeWidth=0;
```

| Zone | X start | X end | Fill colour | Hex | Purpose |
|------|---------|-------|-------------|-----|---------|
| **On-Premises** | 0 | 300 | Beige | `#f5f0e6` | On-prem DC / branch, VPN tunnel |
| **Connectivity** | 320 | 980 | Blue | `#e8f0fe` | Subscription, RG, vWAN/vHub or Hub VNet |
| **Shared Services** | 1000 | 1500 | Green | `#eaf5ea` | Shared services spoke VNet, Bastion |
| **Landing Zones** | 1520 | 2400 | Yellow | `#fef9e7` | App spokes — AKS, APIM, App GW |

Zone height = `pageHeight − 20`.

---

## 4 — Coordinate System

- Origin `(0,0)` = top-left of canvas.
- **Children are positioned RELATIVE TO THEIR PARENT container** — not the canvas.
- All coordinates **must be multiples of 10** (grid-snap rule).

**Worked example:**

```
Subscription at canvas (20, 20), size 1200×800
 └─ RG at (30, 50) inside Subscription → canvas (50, 70)
     └─ VNet at (20, 40) inside RG → canvas (70, 110)
          └─ Subnet at (20, 40) inside VNet → canvas (90, 150)
               └─ VM icon at (25, 35) inside Subnet → canvas (115, 185)
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

### 6.1 On-Premises Zone

| Element | x | y | w | h |
|---------|---|---|---|---|
| On-Premises box | 30 | 120 | 230 | 90 |

### 6.2 Connectivity Hub Zone

| Element | x | y | w | h | Parent |
|---------|---|---|---|---|--------|
| Connectivity RG | 330 | 60 | 620 | 620 | `1` |
| IP Pool node | 20 | 50 | 180 | 70 | `conn_rg` |
| vWAN container | 20 | 150 | 580 | 430 | `conn_rg` |
| vHub container | 20 | 50 | 540 | 330 | `vwan` |
| Firewall Policy | 20 | 60 | 160 | 80 | `vhub` |
| Azure Firewall | 200 | 60 | 160 | 80 | `vhub` |
| VPN Gateway | 380 | 60 | 140 | 80 | `vhub` |

### 6.3 Shared Services Zone

| Element | x | y | w | h | Parent |
|---------|---|---|---|---|--------|
| Shared Services RG | 1000 | 120 | 460 | 560 | `1` |
| VNet container | 20 | 50 | 420 | 470 | `shd_rg` |
| AzureBastionSubnet | 20 | 50 | 380 | 130 | `vnet` |
| Private Endpoint subnet | 20 | 200 | 380 | 120 | `vnet` |
| App subnet | 20 | 340 | 380 | 120 | `vnet` |

### 6.4 Landing Zones Zone

Application spoke VNets laid out side-by-side starting at x = 1490, spaced 40 px apart.

| Pattern | Key resources |
|---------|---------------|
| AKS workload | `azurerm_kubernetes_cluster`, `azurerm_container_registry` |
| APIM + AppGW | `azurerm_api_management`, `azurerm_application_gateway` |
| Web App | `azurerm_app_service`, `azurerm_service_plan` |
| VM workload | `azurerm_linux_virtual_machine` / `azurerm_windows_virtual_machine` |

If no landing zone spokes are detected, render zone as an empty dashed rectangle labelled `"Landing Zones (future spokes)"`.

### 6.5 Key Edges

| From | To | Label | Edge type |
|------|----|-------|-----------|
| On-Premises box | VPN Gateway | `VPN Tunnel` | On-Prem → VPN GW |
| IP Pool | vHub | `ip_pool_id` | Module parameter |
| IP Pool | VNet | `ip_pool_id` | Module parameter |
| Firewall Policy | Firewall | `firewall_policy_id` | `.id` ref |
| vHub | Spoke VNet | `hub connection&#xa;internet_security` | Hub ↔ Spoke |
| Bastion | Public IP | *(empty)* | `.id` ref |
