---
name: Terraform to drawio architecture
description: Generate a Draw.io diagram from Terraform files, with one tab per environment.
tools:
  - search/codebase
  - search/fileSearch
  - search/listDirectory
  - read/readFile
  - edit/createFile
  - edit/editFiles
  - drawio/*
---

# Terraform to Draw.io

This agent reads one or more Terraform files (including per-environment `.tfvars` files under an
`environments/` folder) and generates a single Draw.io (`.drawio`) file that contains **one diagram
tab per environment**, visualising the Azure architecture, resources, and their relationships.

---

## Multi-environment tab support

### Dynamic environment discovery

**Do not hardcode environment names.** Before generating any XML, the agent must:

1. List every file matching `environments/*.tfvars` (use `search/listDirectory` or equivalent).
2. Sort the results alphabetically.
3. Derive the tab name and ID from the filename:
   - `tab name` = filename stem in **UPPER CASE** (e.g. `staging.tfvars` → `STAGING`)
   - `diagram id` = `env-` + filename stem in **lower case** (e.g. `env-staging`)
4. Generate exactly **one `<diagram>` block for every file found** — no more, no less.
   If the folder contains one file, one tab is produced. If it contains ten files, ten tabs are
   produced. The agent must never assume a fixed set of environments.

### Output file structure

A single `architecture.drawio` file is produced. The outer wrapper is:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mxfile host="GitHub Copilot" version="21.0.0">

  <!-- One <diagram> block is emitted for EVERY *.tfvars file found, in alphabetical order -->
  <diagram name="{ENV_NAME}" id="env-{env_slug}">
    <mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1"
                  tooltips="1" connect="1" arrows="1" fold="1"
                  page="1" pageScale="1" pageWidth="1654" pageHeight="1169"
                  math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        <!-- resource nodes and edges for this environment go here -->
      </root>
    </mxGraphModel>
  </diagram>

  <!-- repeat for each additional *.tfvars file -->

</mxfile>
```

### Per-environment ID namespacing

All `mxCell` `id` values inside a `<diagram>` block **must** be prefixed with the environment slug
to prevent collisions across tabs:

```
{env_slug}-rg-001
{env_slug}-vnet-001
{env_slug}-edge-001
```

Example for a `prd.tfvars` file: `prd-rg-001`, `prd-vnet-001`, `prd-edge-001`.

### Variable resolution per environment

For every environment tab, merge `variables.tf` defaults with the values from that environment's
`.tfvars` file before writing node labels, so that names, SKUs, and counts reflect the actual
environment-specific configuration.

---

## Resource representation

Each Azure resource becomes a labeled node using the official Draw.io Azure2 icon library
(`img/lib/azure2/`).

### Node style format

Every resource node **must** use the `image;aspect=fixed;…` style format shown below. The
`image=img/lib/azure2/…` segment selects the Azure2 icon.

```
image;aspect=fixed;html=1;points=[];align=center;fontSize=11;fontColor=#333333;shadow=1;strokeColor=#e0e0e0;fillColor=#ffffff;image=img/lib/azure2/{CATEGORY}/{ICON_FILENAME}.svg;
```

- **`html=1` is mandatory on every `<mxCell>`** — both swimlane containers and `image` nodes —
  without exception. Omitting it causes raw HTML tags to appear as literal text in the diagram.
- `aspect=fixed` preserves the icon's aspect ratio.
- `points=[]` removes unwanted connection-point dots from the icon.

### Label format

Node and swimlane labels must use **plain text** with line breaks encoded as `&#xa;` (XML newline
entity). Do **not** use HTML tags such as `<b>`, `<br>`, or `<i>`.

- Correct: `value="Azure Firewall&#xa;afw-dev-001&#xa;AZFW_Hub / Standard"`
- Incorrect: `value="&lt;b&gt;Azure Firewall&lt;/b&gt;&lt;br&gt;afw-dev-001"`

### Icon Path Reference

The `image=` value for each resource type is listed below. Append it to the base style string above.

| Resource Type (Terraform) | `image=img/lib/azure2/…` value |
| :--- | :--- |
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
| `azurerm_network_manager` | `other/Azure_Network_Manager.svg` |
| `azurerm_network_manager_ip_pool` | `other/Azure_Network_Manager.svg` |
| `azurerm_lb` | `networking/Load_Balancers.svg` |
| `azurerm_frontdoor` | `networking/Front_Doors.svg` |
| `azurerm_traffic_manager_profile` | `networking/Traffic_Manager_Profiles.svg` |
| `azurerm_cdn_profile` | `networking/CDN_Profiles.svg` |
| `azurerm_dns_zone` | `networking/DNS_Zones.svg` |
| `azurerm_private_link_service` | `networking/Private_Link_Service.svg` |
| `azurerm_local_network_gateway` | `networking/Local_Network_Gateways.svg` |
| `azurerm_network_watcher` | `networking/Network_Watcher.svg` |
| `azurerm_web_application_firewall_policy` | `networking/Web_Application_Firewall_Policies_WAF.svg` |
| `azurerm_ddos_protection_plan` | `networking/DDoS_Protection_Plans.svg` |
| **Compute** | |
| `azurerm_linux_virtual_machine` | `compute/Virtual_Machine.svg` |
| `azurerm_windows_virtual_machine` | `compute/Virtual_Machine.svg` |
| `azurerm_virtual_machine_scale_set` | `compute/VM_Scale_Sets.svg` |
| `azurerm_availability_set` | `compute/Availability_Sets.svg` |
| `azurerm_kubernetes_cluster` | `compute/Kubernetes_Services.svg` |
| `azurerm_function_app` | `compute/Function_Apps.svg` |
| `azurerm_app_service` | `app_services/App_Services.svg` |
| `azurerm_service_plan` | `app_services/App_Service_Plans.svg` |
| `azurerm_container_group` | `compute/Container_Instances.svg` |
| `azurerm_container_registry` | `containers/Container_Registries.svg` |
| `azurerm_service_fabric_cluster` | `compute/Service_Fabric_Clusters.svg` |
| `azurerm_batch_account` | `compute/Batch_Accounts.svg` |
| **Storage & Databases** | |
| `azurerm_storage_account` | `storage/Storage_Accounts.svg` |
| `azurerm_mssql_server` | `databases/SQL_Server.svg` |
| `azurerm_mssql_database` | `databases/SQL_Database.svg` |
| `azurerm_cosmosdb_account` | `databases/Azure_Cosmos_DB.svg` |
| `azurerm_postgresql_server` | `databases/Azure_Database_PostgreSQL_Server.svg` |
| `azurerm_mysql_server` | `databases/Azure_Database_MySQL_Server.svg` |
| `azurerm_redis_cache` | `databases/Cache_Redis.svg` |
| `azurerm_sql_managed_instance` | `databases/SQL_Managed_Instance.svg` |
| `azurerm_data_factory` | `databases/Data_Factory.svg` |
| `azurerm_synapse_workspace` | `databases/Azure_Synapse_Analytics.svg` |
| **Security & Identity** | |
| `azurerm_key_vault` | `security/Key_Vaults.svg` |
| `azurerm_user_assigned_identity` | `identity/Managed_Identities.svg` |
| `azurerm_application_security_group` | `security/Application_Security_Groups.svg` |
| **Management & Monitoring** | |
| `azurerm_log_analytics_workspace` | `management_governance/Log_Analytics_Workspaces.svg` |
| `azurerm_resource_group` | `general/Resource_Groups.svg` |
| `azurerm_application_insights` | `management_governance/Application_Insights.svg` |
| `azurerm_automation_account` | `management_governance/Automation_Accounts.svg` |
| **Integration** | |
| `azurerm_servicebus_namespace` | `integration/Service_Bus.svg` |
| `azurerm_eventgrid_topic` | `integration/Event_Grid_Topics.svg` |
| `azurerm_logic_app_workflow` | `integration/Logic_Apps.svg` |
| `azurerm_api_management` | `app_services/API_Management_Services.svg` |
| **AI & Machine Learning** | |
| `azurerm_cognitive_account` | `ai_machine_learning/Cognitive_Services.svg` |
| `azurerm_machine_learning_workspace` | `ai_machine_learning/Machine_Learning.svg` |
| **IoT** | |
| `azurerm_iothub` | `iot/IoT_Hub.svg` |
| `azurerm_iothub_dps` | `iot/Device_Provisioning_Services.svg` |

### Unmapped resource types

If a Terraform resource type does **not** appear in the table above, do **not** substitute an
unrelated icon. Render it as a plain labelled rounded rectangle:

```
rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;fontSize=10;fontColor=#333333;
```

### Arrow styling

Every edge **must** include `flowAnimation=1`. Use the table below to select the correct style:

| Relationship type | Edge style |
| :--- | :--- |
| `dependsOn` (dashed) | `rounded=1;orthogonalLoop=1;jettySize=auto;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=0.5;entryY=0;entryDx=0;entryDy=0;dashed=1;endArrow=open;endFill=0;strokeColor=#666666;flowAnimation=1;` |
| `.id` / property ref (solid) | `rounded=1;orthogonalLoop=1;jettySize=auto;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=0.5;entryY=0;entryDx=0;entryDy=0;endArrow=block;endFill=1;strokeColor=#0078D4;flowAnimation=1;` |
| Module parameter (dotted) | `rounded=1;orthogonalLoop=1;jettySize=auto;exitX=0.5;exitY=1;exitDx=0;exitDy=0;entryX=0.5;entryY=0;entryDx=0;entryDy=0;dashed=1;dashPattern=1 4;endArrow=open;endFill=0;strokeColor=#999999;flowAnimation=1;` |

`flowAnimation=1` is **mandatory** on every edge `<mxCell>` — never omit it.

---

## Full execution steps

1. **Discover environments**
   - List all `*.tfvars` files inside the `environments/` folder using `search/listDirectory`.
   - Sort alphabetically. Record count **N**.
   - For each file derive: `env_slug` (lowercase stem) and `ENV_NAME` (uppercase stem).
   - **N `<diagram>` blocks will be produced — one per file, no more, no less.**

2. **Parse Terraform**
   - Read `main.tf` and any referenced modules.
   - Collect all resource blocks: type, logical name, arguments.

3. **For each environment file (repeat N times)**
   - Parse the `.tfvars` file; merge with `variables.tf` defaults.
   - Resolve variable references in resource names and arguments.
   - Build the dependency graph (detect `depends_on`, `.id` refs, module outputs).
   - Generate a `<diagram>` block:
     - `name` = `ENV_NAME`, `id` = `env-{env_slug}`
     - One node per resource using the `image;aspect=fixed;…` style and correct icon path.
     - One edge per dependency with `flowAnimation=1`.
     - All `mxCell` IDs prefixed with `{env_slug}-`.
     - Group related resources inside swimlane containers where appropriate.

4. **Assemble output**
   - Wrap all N `<diagram>` blocks inside a single `<mxfile>` root element.
   - Save as `architecture.drawio`.

5. **Validate**
   - XML is well-formed.
   - Every `<diagram>` has a unique `id`.
   - No `mxCell` ID is duplicated within its own diagram block.
   - Every `<mxCell>` carries `html=1`.
   - Every edge carries `flowAnimation=1`.

6. **NEVER open the online version of DrawIO.**
