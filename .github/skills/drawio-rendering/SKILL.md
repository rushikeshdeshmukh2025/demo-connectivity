---
name: drawio-rendering
description: "Build and validate Draw.io Azure CAF diagrams: XML wrapper, page sizing, two-zone layout, container styles, coordinate system, sizing formula, and quality checklist. USE WHEN: building draw.io layout, page sizing, zone coordinates, container sizing, positioning resources, validating drawio xml, quality checklist, container styles."
---

# Draw.io Rendering — Layout, Styles & Validation

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
</mxfile>
```

**Mandatory rules for every `<mxCell>`:**
- `html=1` is **required** on every cell — containers, icons, and edges.
- Labels use `&#xa;` for line breaks. Never use `<br>` or other HTML tags.
- Cell `id="0"` = invisible root. Cell `id="1"` = default layer.

---

## 2 — Adaptive Page Sizing

| Complexity | Condition | `pageWidth` | `pageHeight` |
|------------|-----------|-------------|--------------|
| A4 landscape | ≤ 15 resources | 1169 | 827 |
| A3 landscape | 16–40 resources | 1654 | 1169 |
| Custom wide | 41+ resources | 2400 | 1200 |

---

## 3 — Two-Zone Horizontal Layout

Emit exactly **TWO zone background rectangles** (lowest z-order, `parent="1"`).

**FORBIDDEN:** Do NOT create separate zones for "Connectivity", "Shared Services", or "Landing Zones".

| Zone | X range | Fill | Stroke | Purpose |
|------|---------|------|--------|---------|
| **On-Premises** | 0–300 | `#f5f0e6` | `#808080` | On-prem DC, VPN tunnel |
| **Azure** | 320–pageWidth | `#e8f0fe` | `#0078D4` | ALL Azure components |

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

---

## 4 — Container Styles

All containers require `html=1`. Apply these styles exactly.

### Subscription (outermost)
```
rounded=1;arcSize=3;fillColor=none;strokeColor=#E65100;dashed=1;
dashPattern=8 4;strokeWidth=2;container=1;collapsible=0;
recursiveResize=0;html=1;whiteSpace=wrap;verticalAlign=top;
fontStyle=1;fontSize=13;fontColor=#E65100;spacingTop=5;spacingLeft=10;
```

### Resource Group
```
rounded=1;arcSize=5;fillColor=#DAE8FC;strokeColor=#0078D4;strokeWidth=1;
container=1;collapsible=0;recursiveResize=0;html=1;whiteSpace=wrap;
verticalAlign=top;fontStyle=1;fontSize=12;fontColor=#1A237E;
spacingTop=5;spacingLeft=28;align=left;imageVerticalAlign=top;
image=img/lib/azure2/general/Resource_Groups.svg;
imageAlign=left;imageWidth=20;imageHeight=20;
```

### vWAN Container
```
shape=swimlane;html=1;horizontal=1;startSize=40;rounded=1;shadow=0;
fillColor=#f3f8fb;strokeColor=#0078d4;fontColor=#0078d4;fontSize=11;
fontStyle=1;collapsible=1;isContainer=1;
image=img/lib/azure2/networking/Virtual_WANs.svg;
imageAlign=left;imageWidth=20;imageHeight=20;spacingLeft=28;
```

### vHub Container
```
shape=swimlane;html=1;horizontal=1;startSize=40;rounded=1;shadow=0;
fillColor=#f3f8fb;strokeColor=#0078d4;fontColor=#0078d4;fontSize=11;
fontStyle=1;collapsible=1;isContainer=1;
image=img/lib/azure2/networking/Virtual_WAN_Hub.svg;
imageAlign=left;imageWidth=20;imageHeight=20;spacingLeft=28;
```

### Virtual Network
```
rounded=1;arcSize=5;fillColor=#FFFFFF;strokeColor=#0078D4;dashed=1;
dashPattern=5 5;strokeWidth=1;container=1;collapsible=0;
recursiveResize=0;html=1;whiteSpace=wrap;verticalAlign=top;
fontStyle=1;fontSize=12;fontColor=#1A237E;spacingTop=5;spacingLeft=44;align=left;
image=img/lib/azure2/networking/Virtual_Networks.svg;
imageAlign=left;imageVerticalAlign=top;imageWidth=36;imageHeight=36;
```

### Subnet
```
rounded=1;arcSize=3;fillColor=#E3F2FD;strokeColor=#808080;dashed=1;
dashPattern=3 3;strokeWidth=1;container=1;collapsible=0;
recursiveResize=0;html=1;whiteSpace=wrap;verticalAlign=top;
fontSize=10;fontColor=#424242;spacingTop=5;spacingLeft=28;align=left;
image=img/lib/azure2/networking/Subnets.svg;
imageAlign=left;imageVerticalAlign=top;imageWidth=20;imageHeight=20;
```

### On-Premises Container
```
rounded=1;arcSize=5;fillColor=#F5F5F5;strokeColor=#808080;strokeWidth=1;
container=1;collapsible=0;recursiveResize=0;html=1;whiteSpace=wrap;
verticalAlign=top;fontStyle=1;fontSize=12;fontColor=#333333;
spacingTop=5;spacingLeft=10;
image=img/lib/azure2/networking/Local_Network_Gateways.svg;
imageAlign=left;imageWidth=24;imageHeight=24;spacingLeft=34;
```

---

## 5 — Coordinate System

- Origin `(0,0)` = top-left of canvas.
- **Children positioned RELATIVE TO PARENT** — not the canvas.
- All coordinates **multiples of 10** (grid-snap).

**Worked example:**
```
Subscription at canvas (330, 40), size 1920×700
 └─ RG at (20, 60) inside Subscription → canvas (350, 100)
     └─ VNet at (20, 50) inside RG → canvas (370, 150)
          └─ Subnet at (20, 40) inside VNet → canvas (390, 190)
               └─ VM icon at (25, 35) inside Subnet → canvas (415, 225)
```

---

## 6 — Container Sizing Formula (bottom-up)

```
width  = cols × (child_w + h_gap) − h_gap + 2 × padding
height = title_h + rows × (child_h + v_gap) − v_gap + 2 × padding
```

| Constant | Value |
|----------|-------|
| `icon_w` / `icon_h` | 50 |
| `h_gap` | 30 |
| `v_gap` | 30 |
| `padding` | 25 |
| `title_h` | 30 |

### Spacing Between Containers

| Gap between | Value |
|-------------|-------|
| Icons same group | 30 px |
| Subnet containers | 20 px |
| VNet / RG containers | 40 px |
| Subscription containers | 60 px |
| External to diagram edge | 80 px |

---

## 7 — Placement Coordinates

### 7.1 On-Premises Zone (x = 10–290)
Y-alignment: derive from VPN Gateway so On-Prem → VPN GW edge is horizontal.

### 7.2 Azure Zone — Subscription and Resource Groups
All RGs inside a single Subscription container.

| Element | x | y | w | h | Parent |
|---------|---|---|---|---|--------|
| Subscription | 330 | 40 | 1920 | 700 | `1` |
| Connectivity RG | 20 | 60 | 620 | 580 | subscription |
| Shared Services RG | 680 | 60 | 460 | 580 | subscription |

### 7.3 Connectivity RG Contents

| Element | x | y | w | h | Parent |
|---------|---|---|---|---|--------|
| IP Pool node | 20 | 50 | 180 | 70 | `conn_rg` |
| vWAN container | 20 | 150 | 580 | 380 | `conn_rg` |
| vHub container | 20 | 50 | 540 | 290 | `vwan` |
| Firewall Policy | 20 | 60 | 160 | 80 | `vhub` |
| Azure Firewall | 200 | 60 | 160 | 80 | `vhub` |
| VPN Gateway | 380 | 60 | 140 | 80 | `vhub` |

### 7.4 Shared Services RG Contents

| Element | x | y | w | h | Parent |
|---------|---|---|---|---|--------|
| VNet container | 20 | 50 | 420 | 470 | `shd_rg` |
| AzureBastionSubnet | 20 | 50 | 380 | 130 | `vnet` |
| Private Endpoint subnet | 20 | 200 | 380 | 120 | `vnet` |
| App subnet | 20 | 340 | 380 | 120 | `vnet` |

Standalone resources (Storage, Key Vault, DNS Zones) placed below VNet as direct RG children.

### 7.5 Landing Zone Spokes
Additional RGs placed to the right of Shared Services RG (40 px gap), inside Subscription.

---

## 8 — Quality Checklist (22 points)

Before saving, verify **every** item:

- [ ] Every `<mxCell>` has `html=1`
- [ ] Children have correct `parent` attribute
- [ ] Children positioned relative to parent (not canvas-absolute)
- [ ] All coordinates multiples of 10
- [ ] No overlapping shapes at same nesting level
- [ ] Containers sized for all children + padding (formula verified)
- [ ] Hierarchy: Subscription → RG → vWAN → vHub / VNet → Subnet → Resources
- [ ] Every connector has `source` and `target` attributes
- [ ] Labels use `&#xa;` — no raw HTML tags
- [ ] `flowAnimation=1` on ALL edges
- [ ] Service icons are 50 × 50 px
- [ ] Every `<diagram>` has unique `id`
- [ ] No duplicate `mxCell` IDs within a diagram
- [ ] Exactly TWO zone backgrounds: On-Premises + Azure
- [ ] Hub ↔ Spoke edge for every spoke VNet
- [ ] On-Prem → VPN/ER GW edge is perfectly horizontal (Y-aligned)
- [ ] NSG badges: parent=VNet, 36×36, right border of subnet
- [ ] NSG rules tables outside Azure zone, `parent="1"`, two-column grid
- [ ] NO connector edges between NSG badges and tables
- [ ] `pageWidth` extended 820 px when NSG tables present
- [ ] Page size matches resource count (A4/A3/custom)
- [ ] IP CIDRs in VNet/subnet labels
- [ ] `<mxfile host="GitHub Copilot" version="24.0.0">` wrapper present
- [ ] Connections Legend below On-Premises zone (not inside it)
- [ ] Output saved as `terraform_graph_architecture.drawio`

---

## Save Rule

Output file: **`terraform_graph_architecture.drawio`**
Use `edit/createFile` to write to workspace root.
