---
name: arch-data-platform
description: "Data platform landing zone diagram patterns: Synapse, Microsoft Fabric, Data Factory, data lake storage, Databricks, and Purview. USE WHEN: azurerm_synapse_workspace detected, azurerm_data_factory detected, data platform spoke VNet, data lakehouse, ETL/ELT pipeline workload, Databricks workspace."
---

# Data Platform Landing Zone — Diagram Pattern

Apply when any of these resources are detected in the Terraform graph:
- `azurerm_synapse_workspace`
- `azurerm_data_factory`
- `azurerm_databricks_workspace`
- `azurerm_purview_account`

## Container Hierarchy

```
Landing Zone Subscription
 └── Data Platform Resource Group
      ├── VNet (data spoke)
      │    ├── snet-synapse (Synapse managed VNet endpoints)
      │    ├── snet-databricks-public (Databricks public subnet)
      │    ├── snet-databricks-private (Databricks private subnet)
      │    ├── snet-integration (Data Factory / SHIR)
      │    └── snet-pep (private endpoints)
      ├── Synapse Workspace (standalone in RG)
      ├── Data Factory (standalone in RG)
      ├── Databricks Workspace (icon in snet-databricks-public)
      ├── Purview Account (standalone in RG)
      ├── Data Lake Storage (ADLS Gen2) (standalone in RG)
      ├── Key Vault (standalone)
      └── Log Analytics Workspace (standalone)
```

## Icon Mapping

| Resource | Icon path |
|----------|-----------|
| `azurerm_synapse_workspace` | `databases/Azure_Synapse_Analytics.svg` |
| `azurerm_synapse_sql_pool` | `databases/SQL_Database.svg` |
| `azurerm_synapse_spark_pool` | `databases/Azure_Synapse_Analytics.svg` |
| `azurerm_data_factory` | `databases/Data_Factory.svg` |
| `azurerm_data_factory_integration_runtime_self_hosted` | `databases/Data_Factory.svg` |
| `azurerm_databricks_workspace` | `databases/Azure_Databricks.svg` |
| `azurerm_purview_account` | `management_governance/Purview_Accounts.svg` |
| Data Lake (ADLS Gen2) | `storage/Data_Lake_Storage.svg` |
| `azurerm_storage_account` (with `is_hns_enabled`) | `storage/Data_Lake_Storage.svg` |
| `azurerm_eventhub_namespace` | `integration/Event_Hubs.svg` |
| Microsoft Fabric (external) | `databases/Azure_Synapse_Analytics.svg` (label: `Microsoft Fabric`) |

> If `storage/Data_Lake_Storage.svg` is not available, fall back to `storage/Storage_Accounts.svg` with label `ADLS Gen2`.
> If `databases/Azure_Databricks.svg` is not available, fall back to `compute/Kubernetes_Services.svg` with label `Databricks`.

## Edge Patterns

| From | To | Style | Label |
|------|----|-------|-------|
| Data Factory | Data Lake | Standard data flow | `linked_service` |
| Data Factory | Synapse | Standard data flow | `pipeline_sink` |
| Data Factory | Key Vault | Module param (dotted grey) | `linked_service_key_vault` |
| Synapse | Data Lake | Standard data flow | `default_storage` |
| Synapse | Key Vault | Module param (dotted grey) | `managed_identity` |
| Databricks | Data Lake | Standard data flow | `mount / Unity Catalog` |
| Purview | Synapse | Module param (dotted grey) | `catalog_scan` |
| Purview | Data Lake | Module param (dotted grey) | `catalog_scan` |
| vHub | Data VNet | Hub ↔ Spoke | `vHub Connection` |

## Synapse Managed VNet

When `managed_virtual_network_enabled = true`:
- Show Synapse inside the RG (standalone), NOT in a subnet
- Add a dashed container labelled `Synapse Managed VNet` inside the RG
- PE icons from Synapse Managed VNet to Data Lake / SQL pools shown as internal edges

## Databricks VNet Injection

When Databricks has `custom_parameters` with `virtual_network_id`:
- Two subnets required: public and private (NSG-protected)
- Databricks icon placed inside `snet-databricks-public`
- Edge between public and private subnets (internal, label `cluster traffic`)
- Both subnets get NSG badges (delegate rules)

## Data Factory Self-Hosted Integration Runtime

When `azurerm_data_factory_integration_runtime_self_hosted` is detected:
- Place a VM icon (or VMSS) in `snet-integration`
- Edge from VM to Data Factory (property ref, label `SHIR registration`)
- Edge from VM to on-premises data source (VPN tunnel style)

## Data Lake Zones Pattern

When multiple ADLS Gen2 storage accounts are detected, arrange them horizontally:

```
[Raw Zone] → [Curated Zone] → [Presentation Zone]
 (straw)       (stbronze)       (stgold)
```

Edges between zones: Standard data flow, labels `ETL/ELT`.

## Microsoft Fabric Integration

When Fabric resources are referenced (external or `azapi_resource` for Fabric capacity):
- Show as external service box outside subscription (similar to Entra ID pattern)
- Edge from Synapse/Data Lake to Fabric box (dashed blue, label `lakehouse shortcut`)
