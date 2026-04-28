---
name: Enterprise-Scale Terraform to Draw.io
description: Generate a Draw.io diagram that matches the Microsoft Azure Enterprise-Scale  (Landing Zone) reference architecture topology — hub-spoke layout with vWAN at the centre, on-premises at the left, and spoke VNets on the right.  One tab per environment, dynamically discovered from environments/*.tfvars.
tools:
  - search/codebase
  - search/fileSearch
  - search/listDirectory
  - read/readFile
  - edit/createFile
  - edit/editFiles
  - drawio/*
---

# Enterprise-Scale Terraform → Draw.io

This agent reads the Terraform workspace and produces a single
`enterprise_scale_architecture.drawio` file whose visual topology follows the
Microsoft Azure Enterprise-Scale Landing Zone architecture pattern.

The agent auto-detects which hub topology is in use:

- **Virtual WAN hub** — when `azurerm_virtual_wan` / `azurerm_virtual_hub` resources exist.
  Plot the hub as nested vWAN → vHub containers in the Connectivity Hub zone
  with the Firewall, Firewall Policy, and VPN/ER Gateway as leaf nodes inside
  the vHub. Spoke VNets connect via `azurerm_virtual_hub_connection` edges.
- **Classic hub VNet** — when a hub `azurerm_virtual_network` with
  `azurerm_virtual_network_peering` resources exists but no vWAN resources are
  present. Plot the hub as a single Hub VNet container in the Connectivity Hub
  zone with Firewall, Gateway, and Bastion subnets inside it. Spoke VNets
  connect via bidirectional VNet peering edges.

Both variants share the same four-zone horizontal layout. The key visual
difference from a flat or side-by-side diagram is **hub-spoke topology with
horizontal left-to-right traffic flow**:

```
┌───────────────┐   VPN / ER GW   ┌──────────────────┐    ┌──────────────────┐
│  On-Premises  │──────────────────│  Hub (vWAN /     │────│  Shared Services │
└───────────────┘                  │  Hub VNet)       │    │  VNet            │
                                   │   ┌──────────┐   │    └──────────────────┘
                                   │   │ Firewall │   │
                                   │   └──────────┘   │    ┌──────────────────┐
                                   └──────────────────┘────│  App LZ VNet     │
                                                           │  (AKS/APIM/etc.) │
                                                           └──────────────────┘
```

---

## 1 — Visual Layout Specification

### 1.1 Zones (left → right)

The diagram is divided into **four vertical zones**, arranged left-to-right.
Each zone is a light-coloured background rectangle that spans most of the page
height so the reader immediately understands east-west hub-spoke traffic flow.

| Zone | X range (px) | Fill colour | Purpose |
|------|-------------|-------------|---------|
| **On-Premises** | 0–300 | `#f5f0e6` (warm beige) | On-prem DC / branch, VPN tunnel |
| **Connectivity Hub** | 320–980 | `#e8f0fe` (light blue) | vWAN/vHub or Hub VNet, Firewall, IP Pool, VPN GW |
| **Shared Services** | 1000–1500 | `#eaf5ea` (light green) | Shared services VNet, subnets, Bastion |
| **Landing Zones** | 1520–2400 | `#fef9e7` (light yellow) | Application spoke VNets — AKS, APIM, App GW workloads |

These zones are **not** Draw.io containers — they are plain rectangles with
`movable=0;resizable=0;selectable=0;` styled as non-interactive backgrounds.
Resources are placed **on top** of them (parent = `1`).

### 1.2 Lane layout inside each zone

Resources are arranged in horizontal lanes so primary traffic is visually
left-to-right:

- **On-Prem lane:** On-Premises box and VPN/ER marker.
- **Hub lane:** Connectivity RG containing hub resources.
- **Spoke lane:** Shared Services VNet.
- **Landing zone lane:** One or more application spoke VNets (AKS/APIM/etc.).

### 1.3 Hub-spoke connection lines

- A **thick blue bidirectional arrow** connects the vWAN Hub to each spoke VNet
  (hub connection). This is the most prominent edge — use `strokeWidth=2`.
- A **dashed grey arrow** from On-Premises box to VPN Gateway represents the
  site-to-site tunnel.
- IP Pool → vHub and IP Pool → VNet are dotted module-parameter edges.
- Firewall Policy → Firewall is a solid property-reference edge.

---

## 2 — Multi-Environment Tab Support

### 2.1 Dynamic environment discovery

**Do not hardcode environment names.** Before generating any XML:

1. List every file matching `environments/*.tfvars`.
2. Sort alphabetically.
3. Derive:
   - `tab name` = filename stem in **UPPER CASE** (e.g. `dev.tfvars` → `DEV`).
   - `diagram id` = `env-` + filename stem in **lower case** (e.g. `env-dev`).
4. Generate exactly **one `<diagram>` block per file** — no more, no less.

### 2.2 Per-environment ID namespacing

All `mxCell` `id` values inside a `<diagram>` block **must** be prefixed with
the environment slug:

```
{env_slug}-zone-onprem
{env_slug}-zone-hub
{env_slug}-zone-shdsvc
{env_slug}-vhub-001
```

### 2.3 Variable resolution

For every environment tab, merge `variables.tf` defaults with that `.tfvars`
file before writing node labels. Resource names, SKUs, CIDR ranges must be
resolved to concrete strings.

### 2.4 Output file structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="GitHub Copilot" version="21.0.0">
  <diagram name="{ENV_NAME}" id="env-{env_slug}">
    <mxGraphModel dx="1422" dy="1600" grid="1" gridSize="10" guides="1"
                  tooltips="1" connect="1" arrows="1" fold="1"
                  page="1" pageScale="1" pageWidth="2400" pageHeight="1200"
                  math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <!-- zone backgrounds, containers, nodes, edges -->
      </root>
    </mxGraphModel>
  </diagram>
  <!-- repeat for each additional environment -->
</mxfile>
```

**Page width is 2400 px** to accommodate the four left-to-right zones.

---

## 3 — Zone Background Rectangles

Emit **one non-interactive rectangle per zone** using this template. These sit
at the back (`parent="1"`, emitted first so they render behind everything):

```xml
<mxCell id="{env}-zone-onprem" value="On-Premises / Datacentre"
  style="rounded=1;whiteSpace=wrap;html=1;fillColor=#f5f0e6;strokeColor=#c9b98a;
         fontSize=13;fontStyle=1;fontColor=#6b5b3e;verticalAlign=top;
         movable=0;resizable=0;selectable=0;opacity=60;"
  vertex="1" parent="1">
  <mxGeometry x="10" y="10" width="280" height="1160" as="geometry"/>
</mxCell>

<mxCell id="{env}-zone-hub" value="Connectivity Hub"
  style="rounded=1;whiteSpace=wrap;html=1;fillColor=#e8f0fe;strokeColor=#a4c2f4;
         fontSize=13;fontStyle=1;fontColor=#1a56db;verticalAlign=top;
         movable=0;resizable=0;selectable=0;opacity=60;"
  vertex="1" parent="1">
  <mxGeometry x="310" y="10" width="660" height="1160" as="geometry"/>
</mxCell>

<mxCell id="{env}-zone-shdsvc" value="Shared Services Spoke"
  style="rounded=1;whiteSpace=wrap;html=1;fillColor=#eaf5ea;strokeColor=#93c47d;
         fontSize=13;fontStyle=1;fontColor=#274e13;verticalAlign=top;
         movable=0;resizable=0;selectable=0;opacity=60;"
  vertex="1" parent="1">
  <mxGeometry x="980" y="10" width="500" height="1160" as="geometry"/>
</mxCell>

<mxCell id="{env}-zone-lz" value="Landing Zones (future spokes)"
  style="rounded=1;whiteSpace=wrap;html=1;fillColor=#fef9e7;strokeColor=#f1c232;
         fontSize=13;fontStyle=1;fontColor=#7f6000;verticalAlign=top;
         movable=0;resizable=0;selectable=0;opacity=60;dashed=1;"
  vertex="1" parent="1">
  <mxGeometry x="1490" y="10" width="900" height="1160" as="geometry"/>
</mxCell>
```

---

## 4 — Resource Representation

### 4.1 Icon Path Reference

Use the official Draw.io Azure2 icon library (`img/lib/azure2/`).

| Resource Type (Terraform) | `image=img/lib/azure2/…` value |
| :--- | :--- |
| **Governance** | |
| `azurerm_management_group` | `management_governance/Management_Groups.svg` |
| `azurerm_subscription` | `general/Subscriptions.svg` |
| `azurerm_resource_group` | `general/Resource_Groups.svg` |
| **Networking** | |
| `azurerm_virtual_wan` | `networking/Virtual_WANs.svg` |
| `azurerm_virtual_hub` | `networking/Virtual_WAN_Hub.svg` |
| `azurerm_virtual_network` | `networking/Virtual_Networks.svg` |
| `azurerm_subnet` | `networking/Subnet.svg` |
| `azurerm_firewall` | `networking/Firewalls.svg` |
| `azurerm_firewall_policy` | `networking/Azure_Firewall_Policy.svg` |
| `azurerm_vpn_gateway` | `networking/Virtual_Network_Gateways.svg` |
| `azurerm_virtual_network_gateway` | `networking/Virtual_Network_Gateways.svg` |
| `azurerm_express_route_circuit` | `networking/ExpressRoute_Circuits.svg` |
| `azurerm_bastion_host` | `networking/Bastions.svg` |
| `azurerm_public_ip` | `networking/Public_IP_Addresses.svg` |
| `azurerm_network_security_group` | `networking/Network_Security_Groups.svg` |
| `azurerm_private_endpoint` | `networking/Private_Endpoint.svg` |
| `azurerm_route_table` | `networking/Route_Tables.svg` |
| `azurerm_nat_gateway` | `networking/NAT.svg` |
| `azurerm_network_manager` | `other/Azure_Network_Manager.svg` |
| `azurerm_network_manager_ipam_pool` | `other/Azure_Network_Manager.svg` |
| `azurerm_lb` | `networking/Load_Balancers.svg` |
| `azurerm_dns_zone` | `networking/DNS_Zones.svg` |
| `azurerm_private_link_service` | `networking/Private_Link_Service.svg` |
| `azurerm_local_network_gateway` | `networking/Local_Network_Gateways.svg` |
| `azurerm_ddos_protection_plan` | `networking/DDoS_Protection_Plans.svg` |
| **Compute** | |
| `azurerm_linux_virtual_machine` | `compute/Virtual_Machine.svg` |
| `azurerm_windows_virtual_machine` | `compute/Virtual_Machine.svg` |
| `azurerm_kubernetes_cluster` | `compute/Kubernetes_Services.svg` |
| `azurerm_function_app` | `compute/Function_Apps.svg` |
| `azurerm_app_service` | `app_services/App_Services.svg` |
| `azurerm_container_registry` | `containers/Container_Registries.svg` |
| `azurerm_container_group` | `compute/Container_Instances.svg` |
| `azurerm_virtual_machine_scale_set` | `compute/VM_Scale_Sets.svg` |
| **App Services & Integration** | |
| `azurerm_service_plan` | `app_services/App_Service_Plans.svg` |
| `azurerm_api_management` | `app_services/API_Management_Services.svg` |
| `azurerm_application_gateway` | `networking/Application_Gateways.svg` |
| `azurerm_web_application_firewall_policy` | `networking/Web_Application_Firewall_Policies_WAF.svg` |
| **Storage & Databases** | |
| `azurerm_storage_account` | `storage/Storage_Accounts.svg` |
| `azurerm_key_vault` | `security/Key_Vaults.svg` |
| `azurerm_mssql_server` | `databases/SQL_Server.svg` |
| `azurerm_cosmosdb_account` | `databases/Azure_Cosmos_DB.svg` |
| **Identity** | |
| `azurerm_user_assigned_identity` | `identity/Managed_Identities.svg` |
| `azurerm_application_security_group` | `security/Application_Security_Groups.svg` |
| **Monitoring** | |
| `azurerm_log_analytics_workspace` | `management_governance/Log_Analytics_Workspaces.svg` |
| `azurerm_application_insights` | `management_governance/Application_Insights.svg` |

### 4.2 Node style template

```
image;aspect=fixed;html=1;points=[];align=center;imageAlign=center;
imageVerticalAlign=top;verticalAlign=bottom;verticalLabelPosition=bottom;
labelPosition=center;arcSize=10;rounded=1;fontSize=11;fontColor=#333333;
shadow=1;strokeColor=#e0e0e0;fillColor=#ffffff;
image=img/lib/azure2/{CATEGORY}/{ICON}.svg;
```

**`html=1` is mandatory on every `<mxCell>`** — nodes, containers, and edges.

### 4.3 Label format

Plain text only. Line breaks = `&#xa;`. No HTML tags.

- Correct: `value="Azure Firewall&#xa;afw_rus_dev_connectivity_gwc&#xa;AZFW_Hub / Standard"`
- Incorrect: `value="&lt;b&gt;Azure Firewall&lt;/b&gt;&lt;br&gt;…"`

### 4.4 Unmapped resource types

Render as a plain labelled rounded rectangle:
```
rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;fontSize=10;fontColor=#333333;
```

---

## 5 — Container Styles

Containers use `parent` nesting and `isContainer=1;collapsible=1`.

### 5.1 On-Premises box (top zone)

```
rounded=1;whiteSpace=wrap;html=1;fillColor=#f5f0e6;strokeColor=#8d6e32;
fontSize=12;fontStyle=1;fontColor=#5b4a1f;shadow=1;
image=img/lib/azure2/networking/Local_Network_Gateways.svg;
imageAlign=left;imageWidth=24;imageHeight=24;spacingLeft=34;
```

This is a **single fixed node** placed in the On-Premises zone. It represents
the customer datacentre / branch office. Centre it horizontally
(x ≈ 680, y = 40, width = 280, height = 80).

### 5.2 Resource Group containers

```
shape=swimlane;html=1;horizontal=1;startSize=40;rounded=1;shadow=0;
fillColor=#f8f9fa;strokeColor=#6c757d;fontColor=#333333;fontSize=11;
fontStyle=1;collapsible=1;isContainer=1;
image=img/lib/azure2/general/Resource_Groups.svg;
imageAlign=left;imageWidth=20;imageHeight=20;spacingLeft=28;
```

- **Connectivity RG:** placed inside the Hub zone, spanning the width needed for
  IP Pool + vWAN + vHub + FW + VPN GW.
- **Shared Services RG:** placed inside the Shared Services Spoke zone, spanning
  the VNet + subnets.

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

### 5.5 VNet container (inside Shared Services RG)

```
shape=swimlane;html=1;horizontal=1;startSize=40;rounded=1;shadow=0;
fillColor=#f3f8fb;strokeColor=#0078d4;fontColor=#0078d4;fontSize=11;
fontStyle=1;collapsible=1;isContainer=1;
image=img/lib/azure2/networking/Virtual_Networks.svg;
imageAlign=left;imageWidth=20;imageHeight=20;spacingLeft=28;
```

### 5.6 Subnet containers (inside VNet)

```
shape=swimlane;html=1;horizontal=1;startSize=30;rounded=1;shadow=0;
fillColor=#ffffff;strokeColor=#0078d4;dashed=1;fontColor=#0078d4;
fontSize=10;collapsible=1;isContainer=1;
```

### 5.7 NSG badge placement (on the subnet border)

NSG icons **must not** be placed inside the subnet as regular leaf nodes.
Instead, they are rendered as **small shield badges overlapping the top-left
border** of the subnet container they protect, exactly as shown in the Azure
reference architecture diagrams.

**How to achieve this in Draw.io:**

1. The NSG `<mxCell>` has `parent` set to the **VNet** (NOT the subnet). This
   lets it overlap the subnet border freely.
2. Position the NSG icon so it straddles the subnet's top border — half above,
   half below:
   - `y` = subnet's y-offset **minus half the NSG icon height** (e.g. if
     subnet y = 50 relative to VNet, NSG y = 50 − 18 = 32).
   - `x` = subnet's x-offset + a small indent (e.g. subnet x + 10).
3. Use a **smaller icon size** than regular leaf nodes: **36 × 36 px**.
4. Label is placed below the icon, using `fontSize=8`.
5. The NSG icon must have a higher z-order than the subnet container so it
   renders on top.

**NSG badge style:**

```
image;aspect=fixed;html=1;points=[];align=center;imageAlign=center;
imageVerticalAlign=middle;verticalAlign=bottom;verticalLabelPosition=bottom;
labelPosition=center;rounded=1;fontSize=8;fontColor=#333333;
shadow=0;strokeColor=none;fillColor=none;
image=img/lib/azure2/networking/Network_Security_Groups.svg;
```

**NSG badge geometry (36 × 36, overlaps subnet top border):**

```xml
<mxCell id="{env}-nsg-bastion" value="nsg_rus_dev_bastion_gwc"
  style="image;aspect=fixed;html=1;points=[];align=center;imageAlign=center;
         imageVerticalAlign=middle;verticalAlign=bottom;verticalLabelPosition=bottom;
         labelPosition=center;rounded=1;fontSize=8;fontColor=#333333;
         shadow=0;strokeColor=none;fillColor=none;
         image=img/lib/azure2/networking/Network_Security_Groups.svg;"
  vertex="1" parent="{env}-vnet">
  <mxGeometry x="30" y="32" width="36" height="36" as="geometry"/>
</mxCell>
```

Repeat for every subnet that has an NSG association. If a subnet has no NSG,
omit the badge.

### 5.8 Hub topology variants

**Virtual WAN hub (default for this repo):**
Use sections 5.3 and 5.4 (vWAN → vHub nesting). Hub connections appear as
`azurerm_virtual_hub_connection` resources.

**Classic hub VNet (for `hub-spoke-network-topology-architecture.vsdx`):**
If the Terraform workspace contains **no** `azurerm_virtual_wan` or
`azurerm_virtual_hub` resources but **does** contain a hub
`azurerm_virtual_network` with `azurerm_virtual_network_peering` resources,
use the classic hub-spoke layout:

- Replace the vWAN + vHub containers with a single **Hub VNet container**
  using the VNet container style (section 5.5).
- Place Azure Firewall, Firewall Policy, VPN/ER Gateway, and Azure Bastion as
  leaf nodes inside the Hub VNet's subnets.
- Spoke VNets connect via **VNet peering** edges (bidirectional blue arrows).
- The Hub VNet itself sits in the Connectivity Hub zone; spokes go in Shared
  Services and Landing Zones zones.

---

## 6 — Edge Styles

Every edge **must** include `flowAnimation=1`.

| Relationship | Style |
|:---|:---|
| **Hub ↔ Spoke VNet** (hub connection, most prominent) | `rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;startArrow=block;endFill=1;startFill=1;strokeColor=#0078D4;strokeWidth=2;flowAnimation=1;html=1;fontSize=9;` |
| **On-Prem → VPN GW** (site-to-site tunnel) | `rounded=1;orthogonalLoop=1;jettySize=auto;dashed=1;endArrow=open;endFill=0;strokeColor=#8d6e32;strokeWidth=2;flowAnimation=1;html=1;fontSize=9;` |
| `.id` / property ref (solid blue) | `rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;endFill=1;strokeColor=#0078D4;flowAnimation=1;html=1;fontSize=9;` |
| Module parameter / ip_pool_id (dotted grey) | `rounded=1;orthogonalLoop=1;jettySize=auto;dashed=1;dashPattern=1 4;endArrow=open;endFill=0;strokeColor=#999999;flowAnimation=1;html=1;fontSize=9;` |
| VNet Peering (classic hub-spoke) | `rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;startArrow=block;endFill=1;startFill=1;strokeColor=#0078D4;strokeWidth=2;flowAnimation=1;html=1;fontSize=9;` |

**`flowAnimation=1` is the single most important edge attribute. Never omit it.**

---

## 7 — Placement Rules (Enterprise-Scale Topology)

These rules ensure the diagram matches the reference Visio layout.

### 7.1 On-Premises zone (x = 10–290)

| Element | x | y | w | h |
|---------|---|---|---|---|
| On-Premises box | 30 | 120 | 230 | 90 |

### 7.2 Connectivity Hub zone (x = 310–970)

| Element | x | y | w | h | Parent |
|---------|---|---|---|---|--------|
| Connectivity RG | 330 | 60 | 620 | 620 | `1` |
| IP Pool node | 20 | 50 | 180 | 70 | conn_rg |
| vWAN container | 20 | 150 | 580 | 430 | conn_rg |
| vHub container | 20 | 50 | 540 | 330 | vwan |
| Firewall Policy | 20 | 60 | 160 | 80 | vhub |
| Azure Firewall | 200 | 60 | 160 | 80 | vhub |
| VPN Gateway | 380 | 60 | 140 | 80 | vhub |

The IP Pool sits **outside** the vWAN container but **inside** the
Connectivity RG — it is a pool resource, not a hub-internal resource. Dotted
edges connect it to the vHub and the shared services VNet to its right.

### 7.3 Shared Services Spoke zone (x = 980–1480)

| Element | x | y | w | h | Parent |
|---------|---|---|---|---|--------|
| Shared Services RG | 1000 | 120 | 460 | 560 | `1` |
| VNet container | 20 | 50 | 420 | 470 | shd_rg |
| AzureBastionSubnet | 20 | 50 | 380 | 130 | vnet |
| Private Endpoint subnet | 20 | 200 | 380 | 120 | vnet |
| App subnet | 20 | 340 | 380 | 120 | vnet |

NSG icons are **not** placed inside subnets — they are rendered as small badge
icons overlapping each subnet's top-left border (see section 5.7). Other
resources (Bastion + PIP, etc.) remain inside their subnet container.

### 7.4 Landing Zones zone (x = 1490–2390)

This zone holds **application landing zone spoke VNets**. If the Terraform
workspace defines additional spoke VNets beyond the shared services VNet, they
are placed here side-by-side.

Common application landing zone patterns (detect from Terraform resource types):

| Pattern | Key resources | Subnet layout inside spoke VNet |
|---------|---------------|--------------------------------|
| **AKS workload** | `azurerm_kubernetes_cluster`, `azurerm_container_registry` | AKS node subnet, AKS API subnet, ACR PE subnet |
| **APIM + App GW** | `azurerm_api_management`, `azurerm_application_gateway` | APIM subnet, AppGW subnet, backend subnet |
| **Web App** | `azurerm_app_service`, `azurerm_service_plan` | VNet-integrated subnet, PE subnet |
| **VM workload** | `azurerm_linux_virtual_machine` / `azurerm_windows_virtual_machine` | Workload subnet, management subnet |

Each landing zone spoke VNet gets its own **VNet container** inside a **Resource
Group container**, laid out left-to-right (wrap to a 2-row grid when many
spokes) within the Landing Zones zone.
Hub-spoke connection edge (thick blue bidirectional) connects the hub (vWAN Hub
or Hub VNet) to each landing zone VNet.

If no landing zone spokes exist in Terraform yet, render the zone as an empty
dashed rectangle with the label "Landing Zones (future spokes)".

### 7.5 Key edges

| From | To | Label | Style |
|------|----|-------|-------|
| On-Premises box | VPN Gateway | `VPN Tunnel` | On-Prem → VPN GW |
| IP Pool | vHub | `ip_pool_id` | Module parameter |
| IP Pool | VNet | `ip_pool_id` | Module parameter |
| Firewall Policy | Firewall | `firewall_policy_id` | `.id` ref |
| vHub | VNet | `hub connection&#xa;internet_security: enabled` | Hub ↔ Spoke |
| Bastion | Public IP | *(empty)* | `.id` ref |
| Hub | Landing zone spoke VNet | `hub connection` or `peering` | Hub ↔ Spoke |

### 7.6 NSG placement summary

NSGs are **never** leaf nodes inside a subnet. For every
`azurerm_subnet_network_security_group_association` detected:

1. Identify the target subnet container.
2. Emit a 36×36 NSG badge icon as a child of the **VNet** container.
3. Position it overlapping the top-left border of that subnet (see section 5.7
   for exact coordinates).

This matches the reference Visio where NSG shields sit on the subnet boundary
line, visually protecting traffic entering the subnet.

---

## 8 — Execution Steps

1. **Discover environments**
   - List all `*.tfvars` files inside `environments/`.
   - Sort alphabetically. Record count **N**.
   - Derive `env_slug` and `ENV_NAME` for each.

2. **Parse Terraform**
   - Read every root `.tf` file and referenced module files under `./modules/`.
   - Identify all resource blocks, module instances, locals, and variable
     defaults.
   - Read `locals.tf` to understand `name_prefix` and `name_suffix` patterns.

3. **For each environment (repeat N times)**
   1. Parse the `.tfvars` file; merge with `variables.tf` defaults.
   2. Resolve all variable and local interpolations to concrete strings.
   3. Build the dependency graph:
      - `.id` property references and module output usage.
      - `ip_pool_id` parameter wiring between the IP Pool module and vHub /
        VNet modules.
      - Hub connection from `peering.tf`.
      - NSG ↔ subnet associations.
   4. Emit a `<diagram>` block with `name=ENV_NAME`, `id=env-{env_slug}`.
   5. **Detect hub topology:** Check if `azurerm_virtual_wan` /
      `azurerm_virtual_hub` resources exist (→ vWAN variant) or if a hub
      `azurerm_virtual_network` with peerings exists (→ classic hub-spoke).
   6. **Emit zone backgrounds first** (4 rectangles, lowest z-order).
  7. **Emit containers left-to-right:** On-Prem marker → Connectivity RG → Hub
    (vWAN/vHub or Hub VNet) → Shared Services RG/VNet → Landing Zone
    RGs/VNets.
   8. **Emit NSG badges** as 36×36 icons overlapping subnet top-left borders
      (parent = VNet, NOT the subnet). See section 5.7.
   9. **Emit other leaf nodes** inside their parent containers.
  10. **Emit On-Premises box** in the left-most On-Premises zone.
   11. **Emit edges last**, all with `flowAnimation=1`.
   12. All `mxCell` IDs prefixed with `{env_slug}-`.

4. **Assemble output**
   - Wrap all N `<diagram>` blocks in a single `<mxfile>`.
   - Save as `enterprise_scale_architecture.drawio`.

5. **Validate**
   - XML is well-formed.
   - Every `<diagram>` has a unique `id`.
   - No `mxCell` ID duplicated within its diagram.
   - Every `<mxCell>` carries `html=1`.
   - Every edge carries `flowAnimation=1`.
   - The 4 zone backgrounds exist in every tab.
   - Hub ↔ Spoke edge exists for every spoke VNet connected to the hub.
   - On-Prem → VPN/ER GW edge exists.
   - Every NSG badge is parented to the VNet (not the subnet) and is 36×36 px.
   - NSG badges overlap the top-left border of their associated subnet.
   - Landing zone spoke VNets (if any) are placed in the Landing Zones zone.

6. **NEVER open the online version of DrawIO.**
```
