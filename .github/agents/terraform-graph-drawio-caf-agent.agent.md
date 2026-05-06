---
name: terraform-graph-drawio-caf
description: "Generate a Draw.io architecture diagram from `terraform graph` DOT output. Uses the pre-computed dependency graph to reduce token consumption while producing the same Azure CAF / Landing Zone style diagram as the full parser agent. USE WHEN: terraform graph to drawio, fast architecture diagram, low-token diagram, terraform visualize graph, quick drawio from terraform."
tools:
  - search/codebase
  - search/fileSearch
  - search/listDirectory
  - read/readFile
  - edit/createFile
  - edit/editFiles
  - drawio/*
---

# Terraform Graph → Draw.io (Azure CAF Style — Low-Token Approach)

This agent generates an Azure CAF-style `.drawio` diagram using **`terraform graph`** DOT output as the primary dependency source. It avoids reading every `.tf` file — instead extracting the full resource graph from Terraform's own planner, then reading only `locals.tf`, `variables.tf`, `environments/*.tfvars`, and NSG rule blocks for labelling.



---

## 0 — Container Hierarchy (Golden Rule)

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

Child cells are **always positioned relative to their parent** — never canvas-absolute.

---

## 1 — Execution Flow (Optimised for Token Efficiency)

### Step 1 — Run `terraform graph`

Execute in the workspace root:

```powershell
terraform graph -type=plan > .terraform-graph.dot
```

If `terraform init` has not been run, run it first (non-interactive):

```powershell
terraform init -input=false -no-color
terraform graph -type=plan > .terraform-graph.dot
```

### Step 2 — Parse DOT output

Read `.terraform-graph.dot`. The DOT format provides:
- **Nodes**: every resource, data source, module, var, local, output, and provider.
- **Edges**: every dependency (`→`) between them.

Extract ONLY resource/module nodes (filter out `provider`, `var`, `local`, `output` nodes):

```
"[root] module.virtual_wan.azurerm_virtual_wan.vwan" -> "[root] module.virtual_wan.var.name"
"[root] module.firewall.azurerm_firewall.firewall" -> "[root] module.firewall.var.firewall_policy_id"
```

Build a map:
- `resource_type` (e.g. `azurerm_virtual_wan`)
- `module_path` (e.g. `module.virtual_wan`)
- `resource_name` (e.g. `vwan`)
- `dependencies` (list of target nodes this resource depends on)

### Step 3 — Detect hub topology from graph

| Condition | Topology |
|-----------|----------|
| Graph contains `azurerm_virtual_wan` + `azurerm_virtual_hub` | **vWAN** |
| Graph contains `azurerm_virtual_network` + `azurerm_virtual_network_peering` (no vWAN) | **Classic hub-spoke** |

### Step 4 — Read Terraform files for labels and placement context

Read these files to resolve names, placement, and resource details:

1. `locals.tf` — extract `name_prefix`, `name_suffix`
2. `variables.tf` — get defaults for labelling
3. Each `environments/*.tfvars` — merge with defaults for per-env resolution
4. **All root `.tf` files** that instantiate modules — scan for `module "..."` blocks to determine:
   - Which `resource_group_name` each module targets (→ RG container placement)
   - Which `subnet_id` each module uses (→ subnet container placement)
   - Which sub-resource references exist (e.g. `private_dns_zone_ids`, `private_connection_resource_id`)
5. NSG module `variables.tf` and the root NSG invocation — extract `security_rules`

**Why root `.tf` files matter:** The DOT graph shows dependency edges but does NOT encode which RG or subnet a resource lives in. The `resource_group_name` and `subnet_id` arguments in root module blocks provide that placement context. Without them, new modules (storage accounts, key vaults, private endpoints, DNS zones) cannot be classified into the correct container.

**Efficiency tip:** You do NOT need to read module internals — only the root-level `module` blocks that pass `resource_group_name`, `subnet_id`, and naming arguments.

### Step 5 — Classify resources into containers (dynamic)

Classification uses **two passes**:

#### Pass 1 — Known module patterns (fast path)

These well-known modules have fixed placement:

| Module path pattern | Container |
|---------------------|-----------|
| `module.virtual_wan.*` | vWAN container inside Connectivity RG |
| `module.virtual_wan_hub.*` | vHub container inside vWAN |
| `module.firewall.*` | Inside vHub |
| `module.firewall_policy.*` | Inside vHub |
| `module.vnet_gateway.*` | Inside vHub |
| `module.ip_pool.*` | Connectivity RG (standalone) |
| `module.shared_services_vnet.*` | VNet container inside Shared Services RG |
| `module.azure_bastion.*` | Inside AzureBastionSubnet |
| `module.network_security_group.*` | NSG badge on VNet |
| `module.*_peering.*` or `module.*virtual_hub_connection.*` | Edge (hub↔spoke) |

#### Pass 2 — Dynamic classification (for any module NOT in Pass 1)

For modules not matched above, determine placement by inspecting their root `module` block arguments (read in Step 4):

| Argument found | Placement rule |
|----------------|----------------|
| `subnet_id = module.<vnet_module>.subnet_ids["<key>"]` | Place inside that subnet container |
| `resource_group_name = azurerm_resource_group.<rg>.name` | Place as direct child of that RG |
| `virtual_network_id = module.<vnet_module>.id` | Place inside that VNet container (not a subnet) |
| `private_connection_resource_id = module.<X>.id` | Place in same subnet as the PE (private endpoint pattern) |
| None of the above | Place as standalone child of the Subscription |

**Examples of dynamic classification:**

| Module | Detected argument | Resulting placement |
|--------|-------------------|--------------------|
| `module.storage_account` | `resource_group_name = azurerm_resource_group.shared_services.name` | Inside Shared Services RG (standalone) |
| `module.key_vault` | `resource_group_name = azurerm_resource_group.shared_services.name` | Inside Shared Services RG (standalone) |
| `module.private_endpoints["storage_blob"]` | `subnet_id = module.shared_services_vnet.subnet_ids["private_endpoint"]` | Inside private_endpoint subnet |
| `module.private_endpoints["key_vault"]` | `subnet_id = module.shared_services_vnet.subnet_ids["private_endpoint"]` | Inside private_endpoint subnet |
| `module.private_dns_zones["blob"]` | `resource_group_name = azurerm_resource_group.shared_services.name` | Inside Shared Services RG (standalone) |
| `module.private_dns_zones["vault"]` | `resource_group_name = azurerm_resource_group.shared_services.name` | Inside Shared Services RG (standalone) |

#### `for_each` modules

When a module uses `for_each`, each instance (e.g. `module.private_endpoints["storage_blob"]`) is a separate node in the DOT graph. Classify each instance independently using the same rules. If all instances share the same `subnet_id` / `resource_group_name`, they all go in the same container.

### Step 6 — Build Draw.io XML

Follow sections 2–8 below for XML generation rules.

### Step 7 — Save

Save as `terraform_graph_architecture.drawio`.

---

## 2 — Core XML Structure

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
        <!-- zones, containers, nodes, edges -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

### Rules
- `html=1` is **MANDATORY** on every `<mxCell>`.
- Labels use `&#xa;` for line breaks — no HTML tags.
- All coordinates are multiples of 10 (grid snap).
- All `mxCell` IDs are prefixed with `{env_slug}-`.

### Adaptive Page Sizing

| Resources | Page | `pageWidth` | `pageHeight` |
|-----------|------|-------------|--------------|
| ≤ 15 | A4 landscape | 1169 | 827 |
| 16–40 | A3 landscape | 1654 | 1169 |
| 40+ | Custom wide | 2400 | 1200 |

Extend `pageWidth` by **820 px** when NSG rules tables are present (two-column layout).

---

## 3 — Container Sizing (bottom-up formula)

```
width  = cols × (child_w + h_gap) - h_gap + 2 × padding
height = title_h + rows × (child_h + v_gap) - v_gap + 2 × padding
```

| Constant | Value |
|----------|-------|
| `icon_w/h` | 50 |
| `h_gap` | 30 |
| `v_gap` | 30 |
| `padding` | 25 |
| `title_h` | 30 |

---

## 4 — Visual Layout — Two-Zone Horizontal

The diagram has exactly **TWO** zone boxes — no sub-divisions. Do NOT emit separate Connectivity, Shared Services, or Landing Zones zone backgrounds.

| Zone | X range | Fill | Stroke | Purpose |
|------|---------|------|--------|---------|
| **On-Premises** | 0–300 | `#f5f0e6` (beige) | `#808080` | On-prem DC, VPN tunnel |
| **Azure** | 320–2400 | `#e8f0fe` (light blue) | `#0078D4` | ALL Azure components — subscriptions, RGs, vWAN, VNets, everything |

### Azure zone style (connectivity-like appearance)
```
rounded=1;arcSize=5;fillColor=#e8f0fe;strokeColor=#0078D4;strokeWidth=2;
container=0;movable=0;resizable=0;selectable=0;opacity=60;
html=1;whiteSpace=wrap;verticalAlign=top;fontStyle=1;fontSize=14;
fontColor=#0078D4;spacingTop=8;spacingLeft=10;
```

### On-Premises zone style
```
rounded=1;arcSize=5;fillColor=#f5f0e6;strokeColor=#808080;strokeWidth=1;
container=0;movable=0;resizable=0;selectable=0;opacity=60;
html=1;whiteSpace=wrap;verticalAlign=top;fontStyle=1;fontSize=14;
fontColor=#333333;spacingTop=8;spacingLeft=10;
```

Zone backgrounds are non-interactive rectangles emitted **first** (lowest z-order). All resource containers (Subscription, RGs, VNets) sit on top with `parent="1"`.

**Explicitly forbidden**: Do NOT create separate background rectangles for "Connectivity", "Shared Services", or "Landing Zones". The single Azure box contains everything.

---

## 5 — Container Styles

### 5.1 Subscription
```
rounded=1;arcSize=3;fillColor=none;strokeColor=#E65100;dashed=1;
dashPattern=8 4;strokeWidth=2;container=1;collapsible=0;
recursiveResize=0;html=1;whiteSpace=wrap;verticalAlign=top;
fontStyle=1;fontSize=13;fontColor=#E65100;spacingTop=5;spacingLeft=10;
```

### 5.2 Resource Group
```
rounded=1;arcSize=5;fillColor=#DAE8FC;strokeColor=#0078D4;strokeWidth=1;
container=1;collapsible=0;recursiveResize=0;html=1;whiteSpace=wrap;
verticalAlign=top;fontStyle=1;fontSize=12;fontColor=#1A237E;
spacingTop=5;spacingLeft=28;align=left;
image=img/lib/azure2/general/Resource_Groups.svg;
imageAlign=left;imageVerticalAlign=top;imageWidth=20;imageHeight=20;
```

### 5.3 vWAN Container
```
shape=swimlane;html=1;horizontal=1;startSize=40;rounded=1;shadow=0;
fillColor=#f3f8fb;strokeColor=#0078d4;fontColor=#0078d4;fontSize=11;
fontStyle=1;collapsible=1;isContainer=1;
image=img/lib/azure2/networking/Virtual_WANs.svg;
imageAlign=left;imageWidth=20;imageHeight=20;spacingLeft=28;
```

### 5.4 vHub Container
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
fontStyle=1;fontSize=12;fontColor=#1A237E;spacingTop=5;spacingLeft=44;align=left;
image=img/lib/azure2/networking/Virtual_Networks.svg;
imageAlign=left;imageVerticalAlign=top;imageWidth=36;imageHeight=36;
```

### 5.6 Subnet
```
rounded=1;arcSize=3;fillColor=#E3F2FD;strokeColor=#808080;dashed=1;
dashPattern=3 3;strokeWidth=1;container=1;collapsible=0;
recursiveResize=0;html=1;whiteSpace=wrap;verticalAlign=top;
fontSize=10;fontColor=#424242;spacingTop=5;spacingLeft=28;align=left;
image=img/lib/azure2/networking/Subnets.svg;
imageAlign=left;imageVerticalAlign=top;imageWidth=20;imageHeight=20;
```

### 5.7 On-Premises Container
```
rounded=1;arcSize=5;fillColor=#F5F5F5;strokeColor=#808080;strokeWidth=1;
container=1;collapsible=0;recursiveResize=0;html=1;whiteSpace=wrap;
verticalAlign=top;fontStyle=1;fontSize=12;fontColor=#333333;
spacingTop=5;spacingLeft=10;
```

---

## 6 — Icon Styles

### 6.1 Standard Leaf Node Style
```
aspect=fixed;html=1;points=[];align=center;image;fontSize=9;
image=img/lib/azure2/{CATEGORY}/{ICON}.svg;
labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;
fillColor=#ffffff;rounded=1;arcSize=10;shadow=1;
strokeColor=#e0e0e0;fontColor=#333333;
```
Size: **50 × 50 px**.

### 6.2 On-Premises / Branch Office Icon — MANDATORY
```
sketch=0;outlineConnect=0;gradientColor=none;fontColor=#545B64;strokeColor=none;
fillColor=#879196;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;
align=center;html=1;fontSize=12;fontStyle=0;aspect=fixed;
shape=mxgraph.aws4.illustration_office_building;pointerEvents=1;
```
Size: **78 × 78 px**. Label: `On-Premises / Branch`.

### 6.3 Icon Map (resource type → path)

| Resource Type | `image=img/lib/azure2/…` |
|---------------|--------------------------|
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
| `azurerm_application_gateway` | `networking/Application_Gateways.svg` |
| `azurerm_frontdoor` | `networking/Front_Doors.svg` |
| `azurerm_cdn_frontdoor_profile` | `networking/Front_Doors.svg` |
| `azurerm_linux_virtual_machine` | `compute/Virtual_Machine.svg` |
| `azurerm_windows_virtual_machine` | `compute/Virtual_Machine.svg` |
| `azurerm_kubernetes_cluster` | `compute/Kubernetes_Services.svg` |
| `azurerm_function_app` | `compute/Function_Apps.svg` |
| `azurerm_container_registry` | `containers/Container_Registries.svg` |
| `azurerm_storage_account` | `storage/Storage_Accounts.svg` |
| `azurerm_key_vault` | `security/Key_Vaults.svg` |
| `azurerm_mssql_server` | `databases/SQL_Server.svg` |
| `azurerm_cosmosdb_account` | `databases/Azure_Cosmos_DB.svg` |
| `azurerm_user_assigned_identity` | `identity/Managed_Identities.svg` |
| `azurerm_log_analytics_workspace` | `management_governance/Log_Analytics_Workspaces.svg` |
| `azurerm_application_security_group` | `security/Application_Security_Groups.svg` |
| `azurerm_private_dns_zone` | `networking/DNS_Zones.svg` |
| `azurerm_private_dns_zone_virtual_network_link` | `networking/DNS_Zones.svg` |

Unmapped resources use:
```
rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;
fontSize=10;fontColor=#333333;
```

---

## 7 — NSG Badge Placement

NSG icons are **shield badges** on the subnet's **right border** — NOT regular leaf nodes.

| Property | Value |
|----------|-------|
| **Parent** | VNet container (NOT subnet, NOT RG) |
| **Size** | 36 × 36 px |
| **x** | `subnet_x + subnet_width − 18` (relative to VNet) — right border |
| **y** | `subnet_y − 18` (relative to VNet) — straddles top border |
| **Font** | 8 |

### NSG Rules Side-Panel — No Connectors

NSG rules tables are placed **outside the Azure zone box** (to its right) as legend-style panels in a **two-column grid layout** with no connector edges to the NSG badges. The badge on the subnet border is self-explanatory — no line needed.

**Layout rules:**
- Tables are placed **canvas-absolute** (`parent="1"`), to the **right of the Azure zone background**.
- `x` origin: Azure zone right edge + 40 px (i.e. outside the blue box boundary).
- Arrange tables in **two columns**, filling top-to-bottom then left-to-right:
  - Column 1: `x` = Azure zone right edge + 40 px
  - Column 2: `x` = Column 1 x + table width + 20 px
- Stack vertically within each column with **10 px gaps**.
- Table width: **380 px**.
- Table height: NSG with rules = `row_count × 22 + 120` px; no custom rules = 160 px.
- Extend `pageWidth` by **820 px** (two columns × 400 + gaps).

**Explicitly forbidden:**
- Do NOT place NSG tables inside the Azure zone box.

**Table cell style:**
```
text;html=1;strokeColor=#0078D4;fillColor=#FAFAFA;align=left;
verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;
rotatable=0;fontSize=10;rounded=1;arcSize=5;
```

**Also explicitly forbidden:**
- Do NOT emit any connector edge between NSG badges and NSG tables.
- Do NOT use an outer swimlane container (`{env}-nsg-panel` is NOT needed).
- Each table is an independent cell with `parent="1"`.

### NSG Table HTML

```html
<table border="1" cellpadding="4" cellspacing="0"
  style="border-collapse:collapse;font-size:10px;width:100%;">
  <tr style="background:#0078D4;color:white;">
    <td colspan="6" style="font-weight:bold;padding:6px;">&#x1F6E1; {nsg_name}</td>
  </tr>
  <tr style="background:#E3F2FD;">
    <td colspan="6" style="font-weight:bold;text-align:center;">&#x2193; Inbound Rules</td>
  </tr>
  <tr style="background:#f5f5f5;font-weight:bold;">
    <td>Name</td><td>Priority</td><td>Source</td><td>Dest</td><td>Port</td><td>Proto</td>
  </tr>
  <!-- rows; deny rows: style="background:#FFEBEE;" -->
  <tr style="background:#FFF3E0;">
    <td colspan="6" style="font-weight:bold;text-align:center;">&#x2191; Outbound Rules</td>
  </tr>
  <!-- rows -->
</table>
```

---

## 8 — Edge Styles

**Every edge MUST include `flowAnimation=1`.** No exceptions.

| Relationship | Style |
|:--|:--|
| **Hub ↔ Spoke** | `rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;startArrow=block;endFill=1;startFill=1;strokeColor=#0078D4;strokeWidth=2;flowAnimation=1;html=1;fontSize=9;` |
| **On-Prem → VPN GW** (straight line) | `edgeStyle=none;html=1;dashed=1;endArrow=open;endFill=0;strokeColor=#8d6e32;strokeWidth=2;flowAnimation=1;fontSize=9;exitX=1;exitY=0.5;exitPerimeter=0;entryX=0;entryY=0.5;entryPerimeter=0;` |

**Horizontal alignment rule**: The On-Premises leaf icon centre and the VPN/ER Gateway (or ExpressRoute / SD-WAN appliance) icon centre **must share the same canvas-absolute Y**. Position the On-Premises container so its interior icon's Y centre equals the VPN Gateway's canvas Y centre (sum of all parent offsets). This guarantees the straight line is perfectly horizontal. A diagonal line is a validation failure.

| **Property ref (.id)** | `rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;endFill=1;strokeColor=#0078D4;flowAnimation=1;html=1;fontSize=9;` |
| **Module param (dotted grey)** | `rounded=1;orthogonalLoop=1;jettySize=auto;dashed=1;dashPattern=1 4;endArrow=open;endFill=0;strokeColor=#999999;flowAnimation=1;html=1;fontSize=9;` |
| **VNet Peering (classic)** | `rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;startArrow=block;endFill=1;startFill=1;strokeColor=#0078D4;strokeWidth=2;flowAnimation=1;html=1;fontSize=9;` |

### Edge Classification from DOT Graph

Map graph edges to styles using resource type:

| DOT edge pattern | Style to apply |
|--|--|
| `azurerm_virtual_hub_connection` → `azurerm_virtual_network` | Hub ↔ Spoke |
| `azurerm_virtual_network_peering` → `azurerm_virtual_network` | VNet Peering |
| `var.firewall_policy_id` / `*.firewall_policy_id` | Property ref |
| `var.ip_pool_id` / module param refs | Module param |
| On-Prem node → VPN/ER Gateway | On-Prem → VPN GW |

---

## 9 — Connections Legend

Place an HTML legend table (id `{env}-legend`, `parent="1"`) **below the On-Premises zone box** (outside it). Position: `x = On-Premises zone x`, `y = On-Premises zone bottom edge + 20 px`, width=280.

**Explicitly forbidden:** Do NOT place the legend inside the On-Premises zone background.

```html
<table border="1" cellpadding="4" cellspacing="0"
  style="border-collapse:collapse;font-size:9px;width:100%;">
  <tr style="background:#0078D4;color:white;">
    <td colspan="2" style="font-weight:bold;padding:6px;text-align:center;">Connection Legend</td>
  </tr>
  <tr style="background:#f5f5f5;font-weight:bold;">
    <td style="width:55%;">Line Style</td><td>Meaning</td>
  </tr>
  <tr>
    <td style="color:#8d6e32;font-weight:bold;">──→ (brown straight)</td>
    <td>VPN Tunnel (On-Prem ↔ VPN GW)</td>
  </tr>
  <tr>
    <td style="color:#0078D4;font-weight:bold;">◀──▶ (blue bidir)</td>
    <td>vHub Connection / VNet Peering</td>
  </tr>
  <tr>
    <td style="color:#0078D4;">──▶ (solid blue)</td>
    <td>Property ref (firewall_policy_id)</td>
  </tr>
  <tr>
    <td style="color:#999999;">· · → (grey dotted)</td>
    <td>Module param (ip_pool_id)</td>
  </tr>
  <tr>
    <td style="color:#0078D4;">- - (thin dashed)</td>
    <td>NSG association (badge → rules)</td>
  </tr>
</table>
```

---

## 10 — Multi-Environment Tabs

1. List `environments/*.tfvars`, sort alphabetically.
2. One `<diagram>` per file. Tab name = stem UPPER CASE. ID = `env-{stem}`.
3. All `mxCell` IDs prefixed with `{env_slug}-`.
4. Merge `.tfvars` with `variables.tf` defaults for label resolution.

---

## 11 — Naming Convention

Names follow: `<type>_<company>_<env>_<purpose>_<region>`

Resolve from `locals.tf`:
```hcl
name_prefix = "${company_prefix}_${environment}"  # e.g. "rus_dev"
name_suffix = region_short                         # e.g. "gwc"
```

---

## 12 — Placement Rules

### On-Premises zone (x = 10–290)

**Y-alignment**: The On-Premises container Y must be calculated so that its interior icon's vertical centre equals the VPN Gateway icon's canvas-absolute vertical centre. Use: `onprem_y = vpngw_canvas_centre_y − (onprem_h / 2)`. Do NOT hardcode Y — always derive from VPN Gateway position.

| Element | x | y | w | h |
|---------|---|---|---|---|
| On-Premises box | 30 | *derived* | 230 | 120 |

### Azure zone (x = 320 onwards)
| Element | x | y | w | h | Parent |
|---------|---|---|---|---|--------|
| Subscription | 330 | 40 | 1920 | 700 | `1` |
| Connectivity RG | 20 | 60 | 620 | 580 | sub |
| Shared Services RG | 680 | 60 | 460 | 580 | sub |
| vWAN | 20 | 150 | 580 | 380 | conn_rg |
| vHub | 20 | 50 | 540 | 290 | vwan |
| VNet | 20 | 50 | 420 | 470 | shd_rg |

---

## 13 — Quality Checklist

Before delivery, verify ALL:

- [ ] `terraform graph` was run and `.terraform-graph.dot` was parsed
- [ ] **All root `.tf` module blocks** were read for `resource_group_name` / `subnet_id` placement context
- [ ] Dynamic classification (Pass 2) was applied to any module not in the known-pattern table
- [ ] Every `<mxCell>` has `html=1`
- [ ] Children positioned relative to parent (not canvas)
- [ ] All coordinates multiples of 10
- [ ] No overlapping shapes at same level
- [ ] Container hierarchy: Subscription → RG → vWAN → vHub → VNet → Subnet → leaf
- [ ] Connectors use `source` and `target` attributes
- [ ] `flowAnimation=1` on ALL edges
- [ ] Icon sizes: 50×50 (leaf), 78×78 (On-Premises building)
- [ ] On-Premises node uses `shape=mxgraph.aws4.illustration_office_building`
- [ ] On-Prem → VPN GW edge uses `edgeStyle=none` (straight line)
- [ ] On-Premises icon and VPN GW icon share the same canvas-absolute Y centre (horizontal alignment)
- [ ] RG containers include `imageVerticalAlign=top`
- [ ] vWAN/vHub swimlane icons: `imageWidth=20;imageHeight=20;spacingLeft=28` (same size as RG)
- [ ] VNet container icon: `imageWidth=36;imageHeight=36` (larger, constrained proportions)
- [ ] NSG badges: parent = VNet, x = right border (`subnet_x + subnet_width − 18`)
- [ ] NSG rules tables placed canvas-absolute (`parent="1"`) outside Azure zone box (to its right) in two-column layout
- [ ] NO connector edges between NSG badges and NSG rules tables
- [ ] No `{env}-nsg-panel` outer container — tables are independent cells
- [ ] `pageWidth` extended by 820 px when NSG tables present (two-column layout)
- [ ] Exactly 2 zone backgrounds exist (On-Premises + single Azure box) — no sub-zone backgrounds
- [ ] Azure zone uses connectivity-like blue styling (`fillColor=#e8f0fe;strokeColor=#0078D4;strokeWidth=2`)
- [ ] vHub ↔ Spoke edges labelled `vHub Connection [internet_security=true]`
- [ ] Connections Legend table exists (`{env}-legend`) and is placed below (outside) the On-Premises zone box
- [ ] `<mxfile>` wrapper present
- [ ] File saved as `terraform_graph_architecture.drawio`
- [ ] `.terraform-graph.dot` cleaned up after diagram generation
