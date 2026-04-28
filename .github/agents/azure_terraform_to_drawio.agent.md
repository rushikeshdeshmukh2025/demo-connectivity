---
name: Azure Style Terraform to drawio architecture
description: Generate an Enterprise-Scale Draw.io diagram from Terraform files.
tools:
  - search/codebase
  - search/fileSearch
  - search/listDirectory
  - read/readFile
  - edit/createFile
  - edit/editFiles
  - drawio/*
---

# Terraform to Draw.io (Enterprise-Scale)

This agent reads one or more Terraform files and generates a Draw.io (`.drawio`) XML diagram that visualises the Azure architecture, resources, and their relationships, specifically formatted to match the Microsoft Azure Enterprise-Scale (Landing Zone) visual topology.

## Guidelines

### Hierarchical Containers (Nesting)

Unlike flat diagrams, Enterprise-Scale architectures require strict visual nesting. You must map the infrastructure into nested containers. Use the `parent` attribute in Draw.io `<mxCell>` tags to establish this hierarchy:

1. **Management Groups** (`azurerm_management_group`) -> *Top Level Container*
2. **Subscriptions** (`azurerm_subscription`) -> *Nested inside Management Groups*
3. **Resource Groups** (`azurerm_resource_group`) -> *Nested inside Subscriptions (Optional/As needed)*
4. **Virtual Networks** (`azurerm_virtual_network`) -> *Nested inside Subscriptions or RGs*
5. **Subnets** (`azurerm_subnet`) -> *Nested inside Virtual Networks*
6. **Resources** -> *Nested inside Subnets, VNets, or RGs as appropriate*

### Icon Path Reference

| Resource Type (Terraform) | `image=img/lib/azure2/…` value |
| :--- | :--- |
| **Structure & Governance (Containers)** | |
| `azurerm_management_group` | `management_governance/Management_Groups.svg` |
| `azurerm_subscription` | `general/Subscriptions.svg` |
| `azurerm_resource_group` | `general/Resource_Groups.svg` |
| **Networking** | |
| `azurerm_virtual_network` | `networking/Virtual_Networks.svg` |
| `azurerm_subnet` | `networking/Subnet.svg` |
| `azurerm_network_security_group` | `networking/Network_Security_Groups.svg` |
| `azurerm_application_gateway` | `networking/Application_Gateways.svg` |
| `azurerm_firewall` | `networking/Firewalls.svg` |
| `azurerm_firewall_policy` | `networking/Azure_Firewall_Policy.svg` |
| `azurerm_public_ip` | `networking/Public_IP_Addresses.svg` |
| `azurerm_bastion_host` | `networking/Bastions.svg` |
| `azurerm_private_endpoint` | `networking/Private_Endpoint.svg` |
| `azurerm_virtual_wan` | `networking/Virtual_WANs.svg` |
| `azurerm_virtual_hub` | `networking/Virtual_WAN_Hub.svg` |
| `azurerm_route_table` | `networking/Route_Tables.svg` |
| `azurerm_nat_gateway` | `networking/NAT.svg` |
| `azurerm_network_interface` | `networking/Network_Interfaces.svg` |
| `azurerm_express_route_circuit` | `networking/ExpressRoute_Circuits.svg` |
| `azurerm_virtual_network_gateway` | `networking/Virtual_Network_Gateways.svg` |
| `azurerm_vpn_gateway` | `networking/Virtual_Network_Gateways.svg` |
| `azurerm_virtual_network_peering` | *(Use Edge/Arrow, see styling below)* |
| **Compute** | |
| `azurerm_linux_virtual_machine` | `compute/Virtual_Machine.svg` |
| `azurerm_windows_virtual_machine` | `compute/Virtual_Machine.svg` |
| `azurerm_virtual_machine_scale_set` | `compute/VM_Scale_Sets.svg` |
| `azurerm_kubernetes_cluster` | `compute/Kubernetes_Services.svg` |
| `azurerm_function_app` | `compute/Function_Apps.svg` |
| `azurerm_app_service` | `app_services/App_Services.svg` |
| `azurerm_service_plan` | `app_services/App_Service_Plans.svg` |
| **Storage & Databases** | |
| `azurerm_storage_account` | `storage/Storage_Accounts.svg` |
| `azurerm_mssql_server` | `databases/SQL_Server.svg` |
| `azurerm_mssql_database` | `databases/SQL_Database.svg` |
| `azurerm_cosmosdb_account` | `databases/Azure_Cosmos_DB.svg` |
| `azurerm_redis_cache` | `databases/Cache_Redis.svg` |
| `azurerm_data_factory` | `databases/Data_Factory.svg` |
| **Security & Identity** | |
| `azurerm_key_vault` | `security/Key_Vaults.svg` |
| `azurerm_user_assigned_identity` | `identity/Managed_Identities.svg` |
| **Management & Monitoring** | |
| `azurerm_log_analytics_workspace` | `management_governance/Log_Analytics_Workspaces.svg` |
| `azurerm_application_insights` | `management_governance/Application_Insights.svg` |

*(Note: Expand table with other resources as needed, maintaining `img/lib/azure2/` paths).*

### Node & Container Styling

**1. Leaf Nodes (Individual Resources)**
- White background: `fillColor=#ffffff`
- Rounded corners: `rounded=1;arcSize=10`
- Icon centered on top, label below: `shape=image;imageAlign=center;imageVerticalAlign=top;verticalAlign=bottom;`
- Subtle shadow: `shadow=1`
- Border: `strokeColor=#e0e0e0`
- Font: `fontSize=11;fontColor=#333333`

**2. Containers (Management Groups, Subscriptions, VNets, Subnets)**
To replicate the Azure Enterprise-Scale aesthetic, containers must act as bounding boxes with a top header containing the icon and title.
- Base style: `shape=swimlane;horizontal=1;startSize=40;rounded=1;shadow=0;glass=0;`
- **Management Groups:** `fillColor=#f8f9fa;strokeColor=#6c757d;dashed=1;dashPattern=1 4;fontColor=#333333;`
- **Subscriptions:** `fillColor=#ffffff;strokeColor=#d2d6dc;dashed=0;fontColor=#333333;` (Ensure key icon is placed in the header).
- **Virtual Networks:** `fillColor=#f3f8fb;strokeColor=#0078d4;dashed=0;fontColor=#0078d4;`
- **Subnets:** `fillColor=#ffffff;strokeColor=#0078d4;dashed=1;fontColor=#0078d4;`

**Crucial Note on Containers:** Set `isContainer="1"` and `collapsible="1"` on all `<mxCell>` container definitions.
**HTML Requirement:** `html=1` is mandatory on every `<mxCell>` (nodes, containers, and edges).

### Label format

- Node and container labels must use **plain text** with line breaks encoded as `&#xa;` (XML newline entity). Do **not** use HTML tags such as `<b>`, `<br>`, or `<i>`.
- Correct: `value="Connectivity Subscription&#xa;00000000-0000-0000-0000-000000000000"`

### Unmapped resource types

- If a Terraform resource type does **not** appear in the Icon Path Reference table, do **not** use an unrelated icon.
- Render it as a plain labelled rounded rectangle with a yellow-cream background:
  `rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;fontSize=10;fontColor=#333333;`

### Arrow styling

Every edge **must** include `flowAnimation=1` in its style string so that Draw.io renders the animated flow dots at runtime.

| Relationship type | Draw.io edge style |
| :--- | :--- |
| `dependsOn` (dashed) | `rounded=1;orthogonalLoop=1;jettySize=auto;dashed=1;endArrow=open;endFill=0;strokeColor=#666666;flowAnimation=1;html=1;` |
| `.id` / property ref (solid) | `rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;endFill=1;strokeColor=#0078D4;flowAnimation=1;html=1;` |
| VNet Peering | `rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;startArrow=block;endFill=1;startFill=1;strokeColor=#0078D4;flowAnimation=1;html=1;` |

## Execution steps

1. **Parse the Terraform file(s)**
   - Identify all resources, data sources, and modules.
   - Extract hierarchy points (e.g., VNet -> Subnet ID references, Subscription ID assignments, Provider aliases).

2. **Build the Nested Dependency Graph**
   - Resolve the structural hierarchy (which resource belongs in which Subnet/VNet/Subscription).
   - Detect operational dependencies (`dependsOn`, property references).

3. **Generate Nested Draw.io XML**
   - **Order of creation is critical:** Create top-level containers (Management Groups) first, then Subscriptions, then VNets, then Subnets, and finally Leaf Nodes.
   - Map elements to their parent container using the `parent="[ID_OF_PARENT_MXCELL]"` attribute.
   - Apply specific Container styling vs. Leaf Node styling.
   - Add edges (arrows) for peering and dependencies using `flowAnimation=1`.

4. **Write the output file**
   - Save as `Azure_styled_architecture.drawio`.
   - Validate that the XML is well-formed.
   - NEVER EVER open the online version of DrawIO.