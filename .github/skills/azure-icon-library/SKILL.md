---
name: azure-icon-library
description: "Map every azurerm_* Terraform resource type to its built-in Draw.io Azure2 SVG icon path and apply the standard node style. USE WHEN: mapping icons, resolving icon paths, azure resource icons, img/lib/azure2 paths, node style template."
---

# Azure Icon Library

All icons use the `img/lib/azure2/` library — built into every Draw.io installation. No external downloads required.

## Node Style Template

Apply this style to every leaf resource icon:

```
aspect=fixed;html=1;points=[];align=center;image;fontSize=9;
image=img/lib/azure2/{CATEGORY}/{ICON}.svg;
labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;
fillColor=#ffffff;rounded=1;arcSize=10;shadow=1;
strokeColor=#e0e0e0;fontColor=#333333;
```

Standard icon size: **50 × 50 px**.

> **fontSize must be 9** — using 11 or larger causes label text to overlap adjacent icons inside subnets.

---

## Full Resource Type → Icon Path Map

### Governance

| Terraform resource type | `image=img/lib/azure2/…` |
|-------------------------|--------------------------|
| `azurerm_management_group` | `management_governance/Management_Groups.svg` |
| `azurerm_subscription` | `general/Subscriptions.svg` |
| `azurerm_resource_group` | `general/Resource_Groups.svg` |

### Networking

| Terraform resource type | `image=img/lib/azure2/…` |
|-------------------------|--------------------------|
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
| `azurerm_application_gateway` | `networking/Application_Gateways.svg` |
| `azurerm_web_application_firewall_policy` | `networking/Web_Application_Firewall_Policies_WAF.svg` |
| `azurerm_frontdoor` | `networking/Front_Doors.svg` |
| `azurerm_cdn_frontdoor_profile` | `networking/Front_Doors.svg` |
| `azurerm_traffic_manager_profile` | `networking/Traffic_Manager_Profiles.svg` |
| `azurerm_cdn_profile` | `networking/CDN_Profiles.svg` |
| `azurerm_network_watcher` | `networking/Network_Watcher.svg` |
| `azurerm_network_interface` | `networking/Network_Interfaces.svg` |

### Compute

| Terraform resource type | `image=img/lib/azure2/…` |
|-------------------------|--------------------------|
| `azurerm_linux_virtual_machine` | `compute/Virtual_Machine.svg` |
| `azurerm_windows_virtual_machine` | `compute/Virtual_Machine.svg` |
| `azurerm_virtual_machine_scale_set` | `compute/VM_Scale_Sets.svg` |
| `azurerm_availability_set` | `compute/Availability_Sets.svg` |
| `azurerm_kubernetes_cluster` | `compute/Kubernetes_Services.svg` |
| `azurerm_function_app` | `compute/Function_Apps.svg` |
| `azurerm_container_group` | `compute/Container_Instances.svg` |
| `azurerm_container_registry` | `containers/Container_Registries.svg` |
| `azurerm_service_fabric_cluster` | `compute/Service_Fabric_Clusters.svg` |
| `azurerm_batch_account` | `compute/Batch_Accounts.svg` |

### App Services & Integration

| Terraform resource type | `image=img/lib/azure2/…` |
|-------------------------|--------------------------|
| `azurerm_app_service` | `app_services/App_Services.svg` |
| `azurerm_service_plan` | `app_services/App_Service_Plans.svg` |
| `azurerm_api_management` | `app_services/API_Management_Services.svg` |
| `azurerm_logic_app_workflow` | `integration/Logic_Apps.svg` |
| `azurerm_servicebus_namespace` | `integration/Service_Bus.svg` |
| `azurerm_eventgrid_topic` | `integration/Event_Grid_Topics.svg` |

### Storage & Databases

| Terraform resource type | `image=img/lib/azure2/…` |
|-------------------------|--------------------------|
| `azurerm_storage_account` | `storage/Storage_Accounts.svg` |
| `azurerm_key_vault` | `security/Key_Vaults.svg` |
| `azurerm_mssql_server` | `databases/SQL_Server.svg` |
| `azurerm_mssql_database` | `databases/SQL_Database.svg` |
| `azurerm_cosmosdb_account` | `databases/Azure_Cosmos_DB.svg` |
| `azurerm_postgresql_server` | `databases/Azure_Database_PostgreSQL_Server.svg` |
| `azurerm_mysql_server` | `databases/Azure_Database_MySQL_Server.svg` |
| `azurerm_redis_cache` | `databases/Cache_Redis.svg` |
| `azurerm_mssql_managed_instance` | `databases/SQL_Managed_Instance.svg` |
| `azurerm_data_factory` | `databases/Data_Factory.svg` |
| `azurerm_synapse_workspace` | `databases/Azure_Synapse_Analytics.svg` |

### Identity

| Terraform resource type | `image=img/lib/azure2/…` |
|-------------------------|--------------------------|
| `azurerm_user_assigned_identity` | `identity/Managed_Identities.svg` |
| `azurerm_application_security_group` | `security/Application_Security_Groups.svg` |

### Monitoring

| Terraform resource type | `image=img/lib/azure2/…` |
|-------------------------|--------------------------|
| `azurerm_log_analytics_workspace` | `management_governance/Log_Analytics_Workspaces.svg` |
| `azurerm_application_insights` | `management_governance/Application_Insights.svg` |
| `azurerm_automation_account` | `management_governance/Automation_Accounts.svg` |

### AI & Machine Learning

| Terraform resource type | `image=img/lib/azure2/…` |
|-------------------------|--------------------------|
| `azurerm_cognitive_account` | `ai_machine_learning/Cognitive_Services.svg` |
| `azurerm_machine_learning_workspace` | `ai_machine_learning/Machine_Learning.svg` |

### IoT

| Terraform resource type | `image=img/lib/azure2/…` |
|-------------------------|--------------------------|
| `azurerm_iothub` | `iot/IoT_Hub.svg` |
| `azurerm_iothub_dps` | `iot/Device_Provisioning_Services.svg` |

---

## Unmapped Resources

For any `azurerm_*` type not in the table above, render as a labelled rounded rectangle:

```
rounded=1;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;
fontSize=10;fontColor=#333333;
```

Size: **80 × 40 px**.
