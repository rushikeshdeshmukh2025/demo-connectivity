---
name: terraform-drawio-caf-v1
description: "Read a Terraform repository and generate a production-quality Draw.io (.drawio) architecture diagram that matches the official Microsoft Azure Cloud Adoption Framework (CAF) and Azure Landing Zone (ALZ) reference architecture Visio style.  Supports vWAN and classic hub-spoke topologies, multi-environment tabs discovered from environments/*.tfvars, Private Endpoint layout patterns, Azure Front Door platform patterns, and full Azure Landing Zone naming conventions. Container hierarchy: Subscription → RG → vWAN → vHub → VNet → Subnet → leaf nodes → Resources. USE WHEN: terraform to drawio, generate architecture diagram from terraform, azure landing zone diagram, CAF diagram,vWAN diagram, hub-spoke diagram, enterprise-scale diagram, terraform visualize, infrastructure diagram."

tools:
  - search/codebase
  - search/fileSearch
  - search/listDirectory
  - read/readFile
  - edit/createFile
  - edit/editFiles
  - drawio/*
  - azure/*
---

# Terraform → Draw.io — Azure CAF / Landing Zone Style

This agent reads a Terraform workspace and produces a single
`.drawio` file whose visual topology matches the Microsoft Azure
Cloud Adoption Framework (CAF) and Enterprise-Scale Landing Zone
reference architecture Visio diagrams.

---

## 0 — Container Hierarchy (Golden Rule)

Every diagram follows this strict nesting order:

```
Subscription
 └── Resource Group (RG)
      ├── vWAN container          ← Connectivity RG only
      │    └── vHub container
      │         ├── Azure Firewall
      │         ├── Firewall Policy
      │         └── VPN / ER Gateway
      ├── VNet container          ← Shared Services / Landing Zone RGs
      │    └── Subnet container
      │         └── Leaf nodes (Bastion, PIP, PE, VM, AKS …)
      └── Standalone resources    ← IP Pool, Budget, Managed Identity …
```

**Classic hub-spoke variant** (no vWAN):

```
Subscription
 └── Resource Group (RG)
      └── Hub VNet container      ← replaces vWAN + vHub
           └── Subnet containers
                └── Firewall, Gateway, Bastion …
```

Child cells are **always positioned relative to their parent** container —
never in canvas-absolute coordinates.

---

## 1 — Core XML Structure

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
  <!-- repeat for each environment -->
</mxfile>
```

### Rules
- Cell `id="0"` = invisible root.  Cell `id="1"` = default layer.
- **`html=1` is MANDATORY on every `<mxCell>`** — containers, icons, edges.
- Labels use `&#xa;` for line breaks. **No HTML tags** (`<br>`, `<b>`).

### Adaptive Page Sizing

| Complexity             | Page size      | `pageWidth` | `pageHeight` |
|------------------------|----------------|-------------|--------------|
| ≤ 15 resources         | A4 landscape   | 1169        | 827          |
| 16–40 resources        | A3 landscape   | 1654        | 1169         |
| Enterprise-scale (40+) | Custom wide    | 2400        | 1200         |

Choose page size based on the number of discovered resources.

---

## 2 — Coordinate System & Positioning

### Absolute vs Relative

- Origin `(0,0)` = top-left of the canvas.
- **Children are positioned RELATIVE TO PARENT — not canvas.**
- All coordinates **MUST be multiples of 10** (grid snap).

### Worked Example

```
Subscription at canvas (20, 20), size 1200×800
 └─ RG at (30, 50) inside Subscription → canvas (50, 70)
     └─ VNet at (20, 40) inside RG → canvas (70, 110)
          └─ Subnet at (20, 40) inside VNet → canvas (90, 150)
               └─ VM icon at (25, 35) inside Subnet → canvas (115, 185)
```

Each nesting level adds its offset to the parent. Think recursively.

---

## 3 — Container Sizing Formula (bottom-up)

Always calculate container size from children — never guess:

```
width  = cols × (child_w + h_gap) - h_gap + 2 × padding
height = title_h + rows × (child_h + v_gap) - v_gap + 2 × padding
```

| Constant   | Value | Notes                                    |
|------------|-------|------------------------------------------|
| `icon_w/h` | 50    | Standard service icon                    |
| `h_gap`    | 30    | Horizontal gap between icons             |
| `v_gap`    | 30    | Vertical gap between icon rows           |
| `padding`  | 25    | Space from container edge to first child |
| `title_h`  | 30    | Reserved height for container label      |

#### Example — Subnet with 3 icons in a row:
```
width  = 3 × (50+30) − 30 + 2×25 = 260
height = 30 + 1 × (50+30) − 30 + 2×25 = 130
```

### Spacing Between Containers

| Between                     | Gap   |
|-----------------------------|-------|
| Icons in same group         | 30 px |
| Subnet containers           | 20 px |
| VNet / RG containers        | 40 px |
| Subscription containers     | 60 px |
| External elements to diagram| 80 px |

---

## 4 — Visual Layout — Two-Zone Horizontal Layout

The diagram is divided into **two vertical zones**, left-to-right:

| Zone            | X range (px) | Fill colour       | Purpose                                                       |
|-----------------|--------------|-------------------|---------------------------------------------------------------|
| **On-Premises** | 0 – 300      | `#f5f0e6` (beige) | On-prem DC / branch, VPN tunnel                              |
| **Azure**       | 320 – 2400   | `#e8f0fe` (blue)  | All Azure resources: subscription(s), RGs, VNets, subnets    |

Zone backgrounds are **non-interactive rectangles** (`movable=0;resizable=0;
selectable=0;opacity=60;`) emitted **first** so they render behind everything.
Resources sit on top (`parent="1"`).

**Subscription label rule**: when the workspace contains exactly one subscription,
show its **name only** (omit the subscription ID) in the container label.

---

## 5 — Container Styles

### 5.1 Subscription (outermost)
```
rounded=1;arcSize=3;fillColor=none;strokeColor=#E65100;dashed=1;
dashPattern=8 4;strokeWidth=2;container=1;collapsible=0;
recursiveResize=0;html=1;whiteSpace=wrap;verticalAlign=top;
fontStyle=1;fontSize=13;fontColor=#E65100;spacingTop=5;spacingLeft=10;
```
Orange dashed border, transparent fill.

### 5.2 Resource Group
```
rounded=1;arcSize=5;fillColor=#DAE8FC;strokeColor=#0078D4;strokeWidth=1;
container=1;collapsible=0;recursiveResize=0;html=1;whiteSpace=wrap;
verticalAlign=top;fontStyle=1;fontSize=12;fontColor=#1A237E;
spacingTop=5;spacingLeft=28;align=left;
image=img/lib/azure2/general/Resource_Groups.svg;
imageAlign=left;imageVerticalAlign=top;imageWidth=20;imageHeight=20;
```
Blue fill, solid border. Icon pinned to **top-left corner** — `imageVerticalAlign=top` is REQUIRED or the icon floats to the vertical centre of the container. `verticalAlign=middle` must NOT appear; use `verticalAlign=top` only.

### 5.3 vWAN container (inside Connectivity RG)
```
shape=swimlane;html=1;horizontal=1;startSize=40;rounded=1;shadow=0;
fillColor=#f3f8fb;strokeColor=#0078d4;fontColor=#0078d4;fontSize=11;
fontStyle=1;collapsible=1;isContainer=1;
image=img/lib/azure2/networking/Virtual_WANs.svg;
imageAlign=left;imageWidth=20;imageHeight=20;spacingLeft=28;
```

### 5.4 vHub container (inside vWAN)
```
shape=swimlane;html=1;horizontal=1;startSize=40;rounded=1;shadow=0;
fillColor=#f3f8fb;strokeColor=#0078d4;fontColor=#0078d4;fontSize=11;
fontStyle=1;collapsible=1;isContainer=1;
image=img/lib/azure2/networking/Virtual_WAN_Hub.svg;
imageAlign=left;imageWidth=20;imageHeight=20;spacingLeft=28;
```

### 5.5 Virtual Network
```
rounded=1;arcSize=5;fillColor=#FFFFFF;strokeColor=#0078D4;dashed=1;
dashPattern=5 5;strokeWidth=1;container=1;collapsible=0;
recursiveResize=0;html=1;whiteSpace=wrap;verticalAlign=top;
fontStyle=1;fontSize=12;fontColor=#1A237E;spacingTop=5;spacingLeft=28;align=left;
image=img/lib/azure2/networking/Virtual_Networks.svg;
imageAlign=left;imageVerticalAlign=top;imageWidth=20;imageHeight=20;
```
White fill, blue dashed border. `imageVerticalAlign=top` is REQUIRED — without it the icon centres vertically.

### 5.6 Subnet
```
rounded=1;arcSize=3;fillColor=#E3F2FD;strokeColor=#808080;dashed=1;
dashPattern=3 3;strokeWidth=1;container=1;collapsible=0;
recursiveResize=0;html=1;whiteSpace=wrap;verticalAlign=top;
fontSize=10;fontColor=#424242;spacingTop=5;spacingLeft=28;align=left;
image=img/lib/azure2/networking/Subnets.svg;
imageAlign=left;imageVerticalAlign=top;imageWidth=20;imageHeight=20;
```
Light blue fill, grey dashed border. Icon pinned to **top-left corner** (`imageVerticalAlign=top` is REQUIRED). Use `imageWidth=20;imageHeight=20` — a larger icon (e.g. 50×50) will be clipped inside a 130 px-tall subnet container and become invisible. `verticalAlign=middle` must NOT appear; always use `verticalAlign=top`.

### 5.7 Connectivity Area (Platform Landing Zone)
```
rounded=1;arcSize=5;fillColor=#FFF8E1;strokeColor=#D4A843;strokeWidth=2;
container=1;collapsible=0;recursiveResize=0;html=1;whiteSpace=wrap;
verticalAlign=top;fontStyle=1;fontSize=13;fontColor=#7B5B00;
spacingTop=5;spacingLeft=10;
```
Gold/amber border — visually distinct from workload subscriptions.

### 5.8 On-Premises
```
rounded=1;arcSize=5;fillColor=#F5F5F5;strokeColor=#808080;strokeWidth=1;
container=1;collapsible=0;recursiveResize=0;html=1;whiteSpace=wrap;
verticalAlign=top;fontStyle=1;fontSize=12;fontColor=#333333;
spacingTop=5;spacingLeft=10;
image=img/lib/azure2/networking/Local_Network_Gateways.svg;
imageAlign=left;imageWidth=24;imageHeight=24;spacingLeft=34;
```

---

## 6 — NSG Badge Placement

NSG icons are **small shield badges** that straddle the subnet border — they
are NOT regular leaf nodes inside the subnet.

- **Parent**: the **VNet** container (NOT the subnet)
- **Size**: 36×36 px (in 4-zone layout) or 30×30 px (in detail diagrams)
- **Position**: overlapping the **top-right border** of the associated subnet
  - `x` = subnet's x-offset + subnet_width − 20 (relative to VNet)
  - `y` = subnet's y-offset − 18 (half NSG height)
- **Font size**: 8
- **No edges** — presence on the border implies association

```xml
<mxCell id="{env}-nsg-bastion" value="nsg-bastion"
  style="image;aspect=fixed;html=1;points=[];align=center;
  imageAlign=center;imageVerticalAlign=middle;verticalAlign=bottom;
  verticalLabelPosition=bottom;labelPosition=center;rounded=1;
  fontSize=8;fontColor=#333333;shadow=0;strokeColor=none;fillColor=none;
  image=img/lib/azure2/networking/Network_Security_Groups.svg;"
  vertex="1" parent="{env}-vnet">
  <mxGeometry x="30" y="32" width="36" height="36" as="geometry"/>
</mxCell>
```

Repeat for every `azurerm_subnet_network_security_group_association`.

---

## 6b — NSG Rules Side-Panel (Table + Connector Pattern)

For **every NSG discovered**, emit an HTML rules table positioned to the
**right of the VNet container** and a **dashed connector** from the NSG
badge icon to the table. This pattern mirrors `sample_vnet.drawio`.

### Layout rules

- Tables are placed at canvas-absolute coordinates (parent = `"1"`).
- `x` = VNet right canvas edge + 80 px gap (≈ 1660 for standard layouts).
- `y` = vertically aligned with the subnet the NSG is associated to.
- Stack tables top-to-bottom in the same column: bastion → PE → app.
- NSG with custom rules (e.g. Bastion): height ≈ row_count × 22 + 120 px.
- NSG with no custom rules: height = 160 px (header + inbound + outbound placeholders).
- Width = 380 px.
- Extend `pageWidth` to `pageWidth_original + 440` to accommodate the side panel.

### Table cell style
```
text;html=1;strokeColor=#0078D4;fillColor=#FAFAFA;align=left;
verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;
rotatable=0;fontSize=10;
```

### Table HTML structure (embedded in `value=` attribute)

```html
<table border="1" cellpadding="4" cellspacing="0"
  style="border-collapse:collapse;font-size:10px;width:100%;">
  <!-- Header row — NSG name -->
  <tr style="background:#0078D4;color:white;">
    <td colspan="6" style="font-weight:bold;padding:6px;">🛡 {nsg_name}</td>
  </tr>
  <!-- Inbound section -->
  <tr style="background:#E3F2FD;">
    <td colspan="6" style="font-weight:bold;text-align:center;padding:4px;">↓ Inbound Rules</td>
  </tr>
  <tr style="background:#f5f5f5;font-weight:bold;">
    <td>Name</td><td>Priority</td><td>Source</td>
    <td>Destination</td><td>Port</td><td>Protocol</td>
  </tr>
  <!-- One <tr> per inbound rule. Deny rows get style="background:#FFEBEE;" -->
  <!-- If no custom rules: -->
  <tr style="color:#888888;">
    <td colspan="6" style="text-align:center;font-style:italic;">
      No custom inbound rules (Azure defaults apply)
    </td>
  </tr>
  <!-- Outbound section -->
  <tr style="background:#FFF3E0;">
    <td colspan="6" style="font-weight:bold;text-align:center;padding:4px;">↑ Outbound Rules</td>
  </tr>
  <tr style="background:#f5f5f5;font-weight:bold;">
    <td>Name</td><td>Priority</td><td>Source</td>
    <td>Destination</td><td>Port</td><td>Protocol</td>
  </tr>
  <!-- One <tr> per outbound rule. Deny rows get style="background:#FFEBEE;" -->
</table>
```

### Connector edge (NSG badge → table)

Use `source` / `target` attribute references so Draw.io routes the edge
automatically. Set exits from the right of the badge, entry to the left of
the table:

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

### Standard vertical stack (Shared Services VNet, three subnets)

| Table ID                     | y offset | Height          | Connected to badge     |
|------------------------------|----------|-----------------|------------------------|
| `{env}-nsg-table-bastion`    | 120      | 490 (full rules)| `{env}-nsg-bastion`    |
| `{env}-nsg-table-pe`         | 640      | 160 (no rules)  | `{env}-nsg-pe`         |
| `{env}-nsg-table-app`        | 820      | 160 (no rules)  | `{env}-nsg-app`        |

Adjust `y` and `height` when more or fewer custom rules exist.

---

## 7 — Icon Path Reference (Azure2 built-in library)

All icons use `img/lib/azure2/` — built into every Draw.io installation.

### Node style template
```
aspect=fixed;html=1;points=[];align=center;image;fontSize=11;
image=img/lib/azure2/{CATEGORY}/{ICON}.svg;
labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;
fillColor=#ffffff;rounded=1;arcSize=10;shadow=1;
strokeColor=#e0e0e0;fontColor=#333333;
```

### Full Icon Map

| Resource Type (Terraform)                   | `image=img/lib/azure2/…`                                    |
|:--------------------------------------------|:------------------------------------------------------------|
| **Governance**                              |                                                             |
| `azurerm_management_group`                  | `management_governance/Management_Groups.svg`               |
| `azurerm_subscription`                      | `general/Subscriptions.svg`                                 |
| `azurerm_resource_group`                    | `general/Resource_Groups.svg`                               |
| **Networking**                              |                                                             |
| `azurerm_virtual_wan`                       | `networking/Virtual_WANs.svg`                               |
| `azurerm_virtual_hub`                       | `networking/Virtual_WAN_Hub.svg`                            |
| `azurerm_virtual_network`                   | `networking/Virtual_Networks.svg`                           |
| `azurerm_subnet`                            | `networking/Subnet.svg`                                     |
| `azurerm_firewall`                          | `networking/Firewalls.svg`                                  |
| `azurerm_firewall_policy`                   | `networking/Azure_Firewall_Policy.svg`                      |
| `azurerm_vpn_gateway`                       | `networking/Virtual_Network_Gateways.svg`                   |
| `azurerm_virtual_network_gateway`           | `networking/Virtual_Network_Gateways.svg`                   |
| `azurerm_express_route_circuit`             | `networking/ExpressRoute_Circuits.svg`                      |
| `azurerm_bastion_host`                      | `networking/Bastions.svg`                                   |
| `azurerm_public_ip`                         | `networking/Public_IP_Addresses.svg`                        |
| `azurerm_network_security_group`            | `networking/Network_Security_Groups.svg`                    |
| `azurerm_private_endpoint`                  | `networking/Private_Endpoint.svg`                           |
| `azurerm_route_table`                       | `networking/Route_Tables.svg`                               |
| `azurerm_nat_gateway`                       | `networking/NAT.svg`                                        |
| `azurerm_network_manager`                   | `other/Azure_Network_Manager.svg`                           |
| `azurerm_network_manager_ipam_pool`         | `other/Azure_Network_Manager.svg`                           |
| `azurerm_lb`                                | `networking/Load_Balancers.svg`                             |
| `azurerm_dns_zone`                          | `networking/DNS_Zones.svg`                                  |
| `azurerm_private_link_service`              | `networking/Private_Link_Service.svg`                       |
| `azurerm_local_network_gateway`             | `networking/Local_Network_Gateways.svg`                     |
| `azurerm_ddos_protection_plan`              | `networking/DDoS_Protection_Plans.svg`                      |
| `azurerm_application_gateway`               | `networking/Application_Gateways.svg`                       |
| `azurerm_web_application_firewall_policy`   | `networking/Web_Application_Firewall_Policies_WAF.svg`      |
| `azurerm_frontdoor`                         | `networking/Front_Doors.svg`                                |
| `azurerm_cdn_frontdoor_profile`             | `networking/Front_Doors.svg`                                |
| `azurerm_traffic_manager_profile`           | `networking/Traffic_Manager_Profiles.svg`                   |
| `azurerm_cdn_profile`                       | `networking/CDN_Profiles.svg`                               |
| `azurerm_network_watcher`                   | `networking/Network_Watcher.svg`                            |
| `azurerm_network_interface`                 | `networking/Network_Interfaces.svg`                         |
| **Compute**                                 |                                                             |
| `azurerm_linux_virtual_machine`             | `compute/Virtual_Machine.svg`                               |
| `azurerm_windows_virtual_machine`           | `compute/Virtual_Machine.svg`                               |
| `azurerm_virtual_machine_scale_set`         | `compute/VM_Scale_Sets.svg`                                 |
| `azurerm_availability_set`                  | `compute/Availability_Sets.svg`                             |
| `azurerm_kubernetes_cluster`                | `compute/Kubernetes_Services.svg`                           |
| `azurerm_function_app`                      | `compute/Function_Apps.svg`                                 |
| `azurerm_container_group`                   | `compute/Container_Instances.svg`                           |
| `azurerm_container_registry`                | `containers/Container_Registries.svg`                       |
| `azurerm_service_fabric_cluster`            | `compute/Service_Fabric_Clusters.svg`                       |
| `azurerm_batch_account`                     | `compute/Batch_Accounts.svg`                                |
| **App Services & Integration**              |                                                             |
| `azurerm_app_service`                       | `app_services/App_Services.svg`                             |
| `azurerm_service_plan`                      | `app_services/App_Service_Plans.svg`                        |
| `azurerm_api_management`                    | `app_services/API_Management_Services.svg`                  |
| `azurerm_logic_app_workflow`                | `integration/Logic_Apps.svg`                                |
| `azurerm_servicebus_namespace`              | `integration/Service_Bus.svg`                               |
| `azurerm_eventgrid_topic`                   | `integration/Event_Grid_Topics.svg`                         |
| **Storage & Databases**                     |                                                             |
| `azurerm_storage_account`                   | `storage/Storage_Accounts.svg`                              |
| `azurerm_key_vault`                         | `security/Key_Vaults.svg`                                   |
| `azurerm_mssql_server`                      | `databases/SQL_Server.svg`                                  |
| `azurerm_mssql_database`                    | `databases/SQL_Database.svg`                                |
| `azurerm_cosmosdb_account`                  | `databases/Azure_Cosmos_DB.svg`                             |
| `azurerm_postgresql_server`                 | `databases/Azure_Database_PostgreSQL_Server.svg`            |
| `azurerm_mysql_server`                      | `databases/Azure_Database_MySQL_Server.svg`                 |
| `azurerm_redis_cache`                       | `databases/Cache_Redis.svg`                                 |
| `azurerm_mssql_managed_instance`            | `databases/SQL_Managed_Instance.svg`                        |
| `azurerm_data_factory`                      | `databases/Data_Factory.svg`                                |
| `azurerm_synapse_workspace`                 | `databases/Azure_Synapse_Analytics.svg`                     |
| **Identity**                                |                                                             |
| `azurerm_user_assigned_identity`            | `identity/Managed_Identities.svg`                           |
| `azurerm_application_security_group`        | `security/Application_Security_Groups.svg`                  |
| **Monitoring**                              |                                                             |
| `azurerm_log_analytics_workspace`           | `management_governance/Log_Analytics_Workspaces.svg`        |
| `azurerm_application_insights`              | `management_governance/Application_Insights.svg`            |
| `azurerm_automation_account`                | `management_governance/Automation_Accounts.svg`             |
| **AI & Machine Learning**                   |                                                             |
| `azurerm_cognitive_account`                 | `ai_machine_learning/Cognitive_Services.svg`                |
| `azurerm_machine_learning_workspace`        | `ai_machine_learning/Machine_Learning.svg`                  |
| **IoT**                                     |                                                             |
| `azurerm_iothub`                            | `iot/IoT_Hub.svg`                                           |
| `azurerm_iothub_dps`                        | `iot/Device_Provisioning_Services.svg`                      |

### Unmapped Resources
Render as a plain labelled rounded rectangle:
```
rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;
fontSize=10;fontColor=#333333;
```

---

## 8 — Edge Styles

**Every edge MUST include `flowAnimation=1`.** Never omit it.

| Relationship                                  | Style |
|:----------------------------------------------|:------|
| **Hub ↔ Spoke VNet** (most prominent)         | `rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;startArrow=block;endFill=1;startFill=1;strokeColor=#0078D4;strokeWidth=2;flowAnimation=1;html=1;fontSize=9;` |
| **On-Prem → VPN GW** (site-to-site tunnel)    | `rounded=1;orthogonalLoop=1;jettySize=auto;dashed=1;endArrow=open;endFill=0;strokeColor=#8d6e32;strokeWidth=2;flowAnimation=1;html=1;fontSize=9;` |
| **Property ref** (`.id` / solid blue)          | `rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;endFill=1;strokeColor=#0078D4;flowAnimation=1;html=1;fontSize=9;` |
| **Module param / ip_pool_id** (dotted grey)    | `rounded=1;orthogonalLoop=1;jettySize=auto;dashed=1;dashPattern=1 4;endArrow=open;endFill=0;strokeColor=#999999;flowAnimation=1;html=1;fontSize=9;` |
| **VNet Peering** (classic hub-spoke)           | `rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;startArrow=block;endFill=1;startFill=1;strokeColor=#0078D4;strokeWidth=2;flowAnimation=1;html=1;fontSize=9;` |
| **Standard data flow** (solid blue)            | `rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#0078D4;strokeWidth=2;endArrow=block;endFill=1;flowAnimation=1;` |
| **Protected ingress** (solid black)            | `rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#333333;strokeWidth=2;endArrow=block;endFill=1;flowAnimation=1;` |
| **Controlled egress** (dashed orange)          | `rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#E65100;strokeWidth=2;dashed=1;dashPattern=8 4;endArrow=open;endFill=0;flowAnimation=1;` |
| **Encrypted / VPN tunnel** (dashed red bidir)  | `rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#DA291C;strokeWidth=2;dashed=1;dashPattern=8 4;startArrow=block;startFill=1;endArrow=block;endFill=1;flowAnimation=1;` |
| **BGP / Routing** (dashed green)               | `rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#4CAF50;strokeWidth=1;dashed=1;endArrow=open;endFill=0;flowAnimation=1;` |
| **VNet Peering detail** (dotted grey diamond)  | `rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#808080;strokeWidth=1;dashed=1;dashPattern=4 4;startArrow=diamond;startFill=0;endArrow=diamond;endFill=0;flowAnimation=1;` |
| **Management** (thin grey)                     | `rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#9E9E9E;strokeWidth=1;endArrow=open;endFill=0;flowAnimation=1;` |

---

## 9 — Multi-Environment Tab Support

### 9.1 Dynamic environment discovery

**Do not hardcode environment names.** Before generating any XML:

1. List every file matching `environments/*.tfvars`.
2. Sort alphabetically.
3. Derive:
   - `tab name` = filename stem in **UPPER CASE** (e.g. `dev.tfvars` → `DEV`).
   - `diagram id` = `env-` + filename stem in **lower case** (e.g. `env-dev`).
4. Generate exactly **one `<diagram>` block per file** — no more, no less.

### 9.2 Per-environment ID namespacing

All `mxCell` `id` values inside a `<diagram>` **must** be prefixed with the
environment slug: `{env_slug}-zone-onprem`, `{env_slug}-vhub-001`, etc.

### 9.3 Variable resolution

For every environment tab, merge `variables.tf` defaults with that `.tfvars`
file before writing node labels. Resource names, SKUs, CIDR ranges must be
resolved to concrete strings.

---

## 10 — Hub Topology Detection

### 10.1 Virtual WAN hub (default)

When `azurerm_virtual_wan` / `azurerm_virtual_hub` resources exist:

- Use vWAN → vHub nested containers (sections 5.3, 5.4).
- Firewall, Firewall Policy, VPN/ER Gateway are leaf nodes inside vHub.
- Spoke VNets connect via `azurerm_virtual_hub_connection` edges.

### 10.2 Classic hub VNet

When **no** vWAN/vHub resources exist but a hub `azurerm_virtual_network`
with `azurerm_virtual_network_peering` resources is present:

- Replace vWAN + vHub containers with a single **Hub VNet container**.
- Firewall, Gateway, Bastion are leaf nodes inside Hub VNet subnets.
- Spoke VNets connect via **VNet peering** edges (bidirectional blue arrows).

---

## 11 — Private Endpoint Layout Pattern

When a diagram contains >2 Private Endpoints, apply this convention:

### Layout (left → right)

1. **RG Network** (VNet, subnets, route tables) — left
2. **Workload RGs** (services, monitoring) — center
3. **snet-pep** (PE vertical column) — right of all RGs
4. **Private Services** (target service icons) — far right

### snet-pep as tall vertical column

PEs stacked vertically, one per row, ~80 px apart.

### Private Services container

Directly right of snet-pep. Contains **only** services that have a PE.
Each PE connects to its service icon with a short horizontal arrow.

### Dual-icon pattern

Services with PEs appear in **two places**:
1. Private Services container (far right) — shows PE → Service relationship.
2. Actual Resource Group (center) — shows ownership and data-flow edges.

No cross-diagram edge between the two icons needed.

### Private Services container style
```
rounded=1;arcSize=5;fillColor=#DAE8FC;strokeColor=#0078D4;strokeWidth=1;
container=1;collapsible=0;recursiveResize=0;html=1;whiteSpace=wrap;
verticalAlign=top;fontStyle=1;fontSize=11;fontColor=#1A237E;spacingTop=4;
spacingLeft=8;
```

---

## 12 — Private DNS Zone Reference Table

When PEs are present, include a table **outside** the subscription container:

| Column           | Description                              |
|------------------|------------------------------------------|
| **Service**      | Azure service name                       |
| **Private DNS Zone** | `privatelink.*` FQDN                |
| **Subresource**  | groupId (e.g. `account`, `blob`, `vault`)|
| **Private IP**   | From PE subnet CIDR or `<assigned>`      |
| **Public FQDN**  | Public endpoint the zone replaces        |

### Common Mappings

| Service            | Private DNS Zone                         | Subresource    |
|--------------------|------------------------------------------|----------------|
| Azure OpenAI       | `privatelink.openai.azure.com`           | `account`      |
| Cosmos DB (NoSQL)  | `privatelink.documents.azure.com`        | `Sql`          |
| AI Search          | `privatelink.search.windows.net`         | `searchService`|
| Storage (Blob)     | `privatelink.blob.core.windows.net`      | `blob`         |
| Storage (Table)    | `privatelink.table.core.windows.net`     | `table`        |
| Key Vault          | `privatelink.vaultcore.azure.net`        | `vault`        |
| App Service        | `privatelink.azurewebsites.net`          | `sites`        |
| SQL Database       | `privatelink.database.windows.net`       | `sqlServer`    |
| ACR                | `privatelink.azurecr.io`                 | `registry`     |

### Table style
```
shape=table;startSize=30;container=1;collapsible=0;childLayout=tableLayout;
fixedRows=1;rowLines=1;fontStyle=1;align=center;resizable=0;html=1;
whiteSpace=wrap;fontSize=9;fillColor=#FAFAFA;strokeColor=#BDBDBD;fontColor=#424242;
```

---

## 13 — Azure Front Door — Central Platform Pattern

When Azure Front Door resources are detected in Terraform:

- Place it in its own **Platform Connectivity subscription** (gold/amber style).
- Position **above** workload subscription(s).
- Inside: Front Door Profile → Endpoints → Origin & Routes → WAF Policy.
- Origin connection lines run from Origin & Routes to backend services in workload subscription(s).
- Use Private Link origin style (`strokeColor=#E65100;dashed=1;dashPattern=5 5;strokeWidth=2`) when Private Link origin is used.

---

## 14 — Azure Landing Zone Naming Convention

All names are **lowercase**, **hyphen-separated**.

| Variable     | Description                   | Examples                        |
|--------------|-------------------------------|---------------------------------|
| `{tenant}`   | Organization short code       | `rus`, `svs`, `contoso`         |
| `{region}`   | Azure region abbreviation     | `gwc` (germanywestcentral), `we`|
| `{env}`      | Environment tier              | `dev`, `tst`, `prd`             |
| `{workload}` | Workload / project name       | `connectivity`, `sharedservices`|
| `{seq}`      | Sequence number, zero-padded  | `001`, `002`                    |

### Resource Name Patterns

| Resource Type        | Pattern                                              | Example                                |
|----------------------|------------------------------------------------------|----------------------------------------|
| Subscription         | `sub-{tenant}-landingzone-{env}-{workload}-{env}`    | `sub-rus-landingzone-dev-connectivity-dev` |
| Resource Group       | `rg-{tenant}-{purpose}-{region}-{seq}`               | `rg-rus-connectivity-gwc-001`          |
| VNet                 | `vnet-{tenant}-{workload}-{region}-{seq}`            | `vnet-rus-sharedservices-gwc-001`      |
| Subnet               | `snet-{tenant}-{workload}-{function}-{region}-{seq}` | `snet-rus-shdsvc-bastion-gwc-001`      |
| vWAN                 | `vwan-{tenant}-{env}-{region}-{seq}`                 | `vwan-rus-dev-gwc-001`                 |
| vHub                 | `vhub-{tenant}-{env}-{region}-{seq}`                 | `vhub-rus-dev-gwc-001`                 |
| Firewall             | `afw-{tenant}-{env}-{workload}-{region}`             | `afw-rus-dev-connectivity-gwc`         |
| Firewall Policy      | `afwp-{tenant}-{env}-{workload}-{region}`            | `afwp-rus-dev-connectivity-gwc`        |
| VPN Gateway          | `vpngw-{tenant}-{env}-{region}-{seq}`                | `vpngw-rus-dev-gwc-001`                |
| Bastion              | `bas-{tenant}-{env}-{region}-{seq}`                  | `bas-rus-dev-gwc-001`                  |
| NSG                  | `nsg-{tenant}-{env}-{subnet}-{region}`               | `nsg-rus-dev-bastion-gwc`              |
| Route Table          | `rt-{tenant}-{workload}-{region}-{seq}`              | `rt-rus-shdsvc-gwc-001`                |
| IP Pool              | `ippool-{tenant}-{env}-{region}-{seq}`               | `ippool-rus-dev-gwc-001`               |
| Managed Identity     | `mi-{tenant}-{env}-{workload}-{seq}`                 | `mi-rus-dev-devops-001`                |
| Budget               | `bg-{tenant}-{env}-{workload}-{env}`                 | `bg-rus-dev-chatbot-dev`               |

---

## 15 — Placement Rules

### 15.1 On-Premises zone (x = 10–290)

| Element          | x  | y   | w   | h  |
|------------------|----|-----|-----|---|
| On-Premises box  | 30 | 120 | 230 | 90 |

### 15.2 Connectivity Hub zone (x = 310–970)

| Element           | x   | y   | w   | h   | Parent  |
|-------------------|-----|-----|-----|-----|---------|
| Connectivity RG   | 330 | 60  | 620 | 620 | `1`     |
| IP Pool node      | 20  | 50  | 180 | 70  | conn_rg |
| vWAN container    | 20  | 150 | 580 | 430 | conn_rg |
| vHub container    | 20  | 50  | 540 | 330 | vwan    |
| Firewall Policy   | 20  | 60  | 160 | 80  | vhub    |
| Azure Firewall    | 200 | 60  | 160 | 80  | vhub    |
| VPN Gateway       | 380 | 60  | 140 | 80  | vhub    |

### 15.3 Azure zone — all resources (x = 320 onwards)

All Azure containers are placed inside the single **Azure** zone.
Start at x = 330 and flow left-to-right with 40 px gaps between RGs.

| Element                 | x    | y   | w   | h   | Parent  |
|-------------------------|------|-----|-----|-----|---------|
| Subscription            | 330  | 40  | 1920| 700 | `1`     |
| Connectivity RG         | 20   | 60  | 620 | 580 | sub     |
| Shared Services RG      | 680  | 60  | 460 | 580 | sub     |
| IP Pool node            | 20   | 50  | 180 | 70  | conn_rg |
| vWAN container          | 20   | 150 | 580 | 380 | conn_rg |
| vHub container          | 20   | 50  | 540 | 290 | vwan    |
| Firewall Policy         | 20   | 60  | 160 | 80  | vhub    |
| Azure Firewall          | 200  | 60  | 160 | 80  | vhub    |
| VPN Gateway             | 380  | 60  | 140 | 80  | vhub    |
| VNet container          | 20   | 50  | 420 | 470 | shd_rg  |
| AzureBastionSubnet      | 20   | 50  | 380 | 130 | vnet    |
| Private Endpoint subnet | 20   | 200 | 380 | 120 | vnet    |
| App subnet              | 20   | 340 | 380 | 120 | vnet    |

### 15.4 Key edges

| From              | To                  | Label                                    | Style            |
|-------------------|---------------------|------------------------------------------|------------------|
| On-Premises box   | VPN Gateway         | `VPN Tunnel`                             | On-Prem → VPN GW |
| IP Pool           | vHub                | `ip_pool_id`                             | Module parameter  |
| IP Pool           | VNet                | `ip_pool_id`                             | Module parameter  |
| Firewall Policy   | Firewall            | `firewall_policy_id`                     | .id ref           |
| vHub              | Spoke VNet          | `hub connection&#xa;internet_security`   | Hub ↔ Spoke       |
| Bastion           | Public IP           | *(empty)*                                | .id ref           |

---

## 16 — Execution Steps

1. **Discover environments**
   - List `environments/*.tfvars`, sort alphabetically.
   - Derive `env_slug` and `ENV_NAME` for each.

2. **Parse Terraform**
   - Read root `.tf` files and `./modules/` files.
   - Identify resource blocks, module instances, locals, variable defaults.
   - Read `locals.tf` for `name_prefix` / `name_suffix` patterns.

3. **For each environment (repeat N times)**
   1. Parse `.tfvars`; merge with `variables.tf` defaults.
   2. Resolve all interpolations to concrete strings.
   3. Build dependency graph (`.id` refs, `ip_pool_id`, hub connections, NSG associations).
   4. **Detect hub topology**: vWAN variant or classic hub-spoke.
   5. **Calculate page size** based on resource count; extend `pageWidth` by 440 px if any NSGs have custom rules (to accommodate side-panel tables).
   6. **Calculate container sizes bottom-up** using the formula.
   7. Emit `<diagram>` block with `name=ENV_NAME`, `id=env-{env_slug}`.
   8. Emit zone backgrounds first (2 rectangles — On-Premises + Azure — lowest z-order).
   9. Emit containers left-to-right:
      On-Prem → Subscription → Connectivity RG → vWAN → vHub →
      Shared Services RG → VNet → Subnets → Landing Zone RGs/VNets.
   10. Emit NSG badges (parent = VNet, overlapping subnet borders).
   11. Emit other leaf nodes inside parent containers.
   12. Emit **NSG rules side-panel tables** (section 6b) to the right of the VNet container, one table per NSG, stacked vertically — parent = `"1"`, canvas-absolute coordinates. Tables include all inbound and outbound rules parsed from the Terraform NSG module instances.
   13. Emit **NSG connector edges** (section 6b) — one dashed edge per NSG badge → its rules table, using `source`/`target` attribute references. Style: `endArrow=none;dashed=1;html=1;dashPattern=1 3;strokeWidth=2;rounded=0;exitX=1;exitY=0.5;exitDx=0;exitDy=0;entryX=0;entryY=0.5;entryDx=0;entryDy=0;`
   14. Emit all other edges — all with `flowAnimation=1`.
   15. All mxCell IDs prefixed with `{env_slug}-`.

4. **Assemble output**
   - Wrap all `<diagram>` blocks in single `<mxfile>`.
   - Save as `SingleAgent_architecture.drawio`.

5. **Validate** (see section 17).

6. **NEVER open the online version of Draw.io.**

---

## 17 — Quality Checklist

Before delivering, verify **every** item:

- [ ] Every `<mxCell>` has `html=1` in its style
- [ ] All child cells have correct `parent` attribute
- [ ] Children are positioned **relative to parent** (not canvas)
- [ ] All coordinates are **multiples of 10** (grid-aligned)
- [ ] No overlapping shapes at the same level
- [ ] Containers are large enough for all children + padding (formula verified)
- [ ] Container hierarchy: Subscription → RG → vWAN → vHub → Subnet → Resources
- [ ] Connectors use `source` and `target` attributes (not free-floating)
- [ ] Labels use `&#xa;` for line breaks — no HTML tags
- [ ] `flowAnimation=1` on **all** edges
- [ ] Consistent icon sizes (50×50 for service icons)
- [ ] Every `<diagram>` has a unique `id`
- [ ] No `mxCell` ID duplicated within its diagram
- [ ] 2 zone backgrounds exist in every tab (On-Premises + Azure)
- [ ] Hub ↔ Spoke edge exists for every spoke VNet
- [ ] On-Prem → VPN/ER GW edge exists
- [ ] Every NSG badge: parent = VNet (not subnet), size = 36×36 or 30×30
- [ ] NSG badges overlap the **top-right** border of associated subnet
- [ ] Every NSG has a rules table in the side panel (section 6b) — one table per NSG
- [ ] NSG rules tables are positioned to the **right** of the VNet container (not below the diagram)
- [ ] Each NSG rules table has a dashed connector edge from the NSG badge icon (source) to the table (target)
- [ ] NSG connector edges use `exitX=1;exitY=0.5` and `entryX=0;entryY=0.5` (right-to-left connection)
- [ ] NSG rules tables correctly list all resolved inbound and outbound rules from Terraform
- [ ] Deny rules rows use `style="background:#FFEBEE;"` (red tint)
- [ ] `pageWidth` is extended by 440 px when NSG side-panel tables are present
- [ ] All Azure resources are inside the Azure zone
- [ ] Single-subscription label shows name only (no subscription ID)
- [ ] Container icons pinned to top-left corner with label inline to the right
- [ ] Page size adapts to resource count (A4 / A3 / custom)
- [ ] IP addresses / CIDRs included where architecturally relevant
- [ ] File saved as `.drawio` — NEVER open online editor
