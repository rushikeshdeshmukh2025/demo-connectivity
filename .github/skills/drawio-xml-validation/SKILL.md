---
name: drawio-xml-validation
description: "Validate Draw.io XML against the 22-point CAF quality checklist and apply correct container styles for all Azure topology elements. USE WHEN: validating drawio xml, quality checklist, container styles, subscription style, resource group style, vwan style, vhub style, vnet style, subnet style."
---

# Draw.io XML Validation

## Container Styles

Apply these styles exactly. All containers require `html=1`.

### Subscription (outermost)

```
rounded=1;arcSize=3;fillColor=none;strokeColor=#E65100;dashed=1;
dashPattern=8 4;strokeWidth=2;container=1;collapsible=0;
recursiveResize=0;html=1;whiteSpace=wrap;verticalAlign=top;
fontStyle=1;fontSize=13;fontColor=#E65100;spacingTop=5;spacingLeft=10;
```

Orange dashed border, transparent fill.

### Resource Group

```
rounded=1;arcSize=5;fillColor=#DAE8FC;strokeColor=#0078D4;strokeWidth=1;
container=1;collapsible=0;recursiveResize=0;html=1;whiteSpace=wrap;
verticalAlign=top;fontStyle=1;fontSize=12;fontColor=#1A237E;
spacingTop=5;spacingLeft=10;
image=img/lib/azure2/general/Resource_Groups.svg;
imageAlign=left;imageWidth=20;imageHeight=20;spacingLeft=28;
```

Blue fill, solid border, RG icon top-left.

### vWAN Container (inside Connectivity RG)

```
shape=swimlane;html=1;horizontal=1;startSize=40;rounded=1;shadow=0;
fillColor=#f3f8fb;strokeColor=#0078d4;fontColor=#0078d4;fontSize=11;
fontStyle=1;collapsible=1;isContainer=1;
image=img/lib/azure2/networking/Virtual_WANs.svg;
imageAlign=left;imageWidth=20;imageHeight=20;spacingLeft=28;
```

### vHub Container (inside vWAN)

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
fontStyle=1;fontSize=12;fontColor=#1A237E;spacingTop=5;spacingLeft=10;
image=img/lib/azure2/networking/Virtual_Networks.svg;
imageAlign=left;imageWidth=20;imageHeight=20;spacingLeft=28;
```

White fill, blue dashed border.

### Subnet

```
rounded=1;arcSize=3;fillColor=#E3F2FD;strokeColor=#808080;dashed=1;
dashPattern=3 3;strokeWidth=1;container=1;collapsible=0;
recursiveResize=0;html=1;whiteSpace=wrap;verticalAlign=top;
fontSize=10;fontColor=#424242;spacingTop=5;spacingLeft=8;
```

Light blue fill, grey dashed border.

### Connectivity Area / Platform Landing Zone Subscription

```
rounded=1;arcSize=5;fillColor=#FFF8E1;strokeColor=#D4A843;strokeWidth=2;
container=1;collapsible=0;recursiveResize=0;html=1;whiteSpace=wrap;
verticalAlign=top;fontStyle=1;fontSize=13;fontColor=#7B5B00;
spacingTop=5;spacingLeft=10;
```

Gold/amber border — visually distinct from workload subscriptions.

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

## 22-Point Quality Checklist

Before delivering the `.drawio` file, verify **every** item:

- [ ] Every `<mxCell>` has `html=1` in its style string
- [ ] All child cells have the correct `parent` attribute set to their container's `id`
- [ ] Children are positioned **relative to their parent** — not in canvas-absolute coordinates
- [ ] All coordinates are **multiples of 10** (grid-aligned)
- [ ] No overlapping shapes exist at the same nesting level
- [ ] Containers are large enough for all children + padding (sizing formula verified)
- [ ] Container hierarchy is correct: Subscription → RG → vWAN → vHub → Subnet → Resources
- [ ] Every connector uses `source` and `target` attributes (no free-floating edges)
- [ ] Labels use `&#xa;` for line breaks — no raw HTML tags (`<br>`, `<b>`, etc.)
- [ ] `flowAnimation=1` is present on **all** edges
- [ ] All service icons are **50 × 50 px**
- [ ] Every `<diagram>` block has a unique `id` attribute
- [ ] No `mxCell id` is duplicated within its diagram
- [ ] Four zone background rectangles exist in every tab (On-Prem, Connectivity, Shared Services, Landing Zones)
- [ ] A Hub ↔ Spoke edge exists for every spoke VNet
- [ ] An On-Prem → VPN/ER GW edge exists (if on-prem resources are detected)
- [ ] Every NSG badge: `parent` = VNet container (not subnet), size = 36 × 36 px (or 30 × 30 px for detail view)
- [ ] NSG badges overlap the **top-left border** of their associated subnet
- [ ] Landing zone spoke VNets are placed inside the Landing Zones zone (x ≥ 1520)
- [ ] Page size matches resource count (A4 for ≤15 · A3 for 16–40 · custom 2400×1200 for 41+)
- [ ] IP address ranges / CIDRs are included in VNet and subnet labels where architecturally relevant
- [ ] Output file is saved as `enterprise_scale_architecture.drawio` — **never** opened in the online Draw.io editor

---

## Save Rule

Output file name: **`enterprise_scale_architecture.drawio`**

Use `edit/createFile` to write the file to the workspace root. Do not open any online editor.
