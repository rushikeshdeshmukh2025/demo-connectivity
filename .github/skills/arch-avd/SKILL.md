---
name: arch-avd
description: "Azure Virtual Desktop landing zone diagram patterns: host pools, session hosts, workspace, FSLogix storage, and network topology. USE WHEN: azurerm_virtual_desktop_host_pool detected, AVD spoke VNet, virtual desktop workload, session host subnet, FSLogix profile storage."
---

# AVD Landing Zone — Diagram Pattern

Apply when `azurerm_virtual_desktop_host_pool` or `azurerm_virtual_desktop_workspace` is detected in the Terraform graph.

## Container Hierarchy

```
Landing Zone Subscription
 └── AVD Resource Group
      ├── VNet (AVD spoke)
      │    ├── snet-avd-session (session host VMs)
      │    ├── snet-avd-mgmt (management / jump boxes)
      │    └── snet-pep (private endpoints)
      ├── Host Pool (standalone in RG)
      ├── Application Group (standalone)
      ├── Workspace (standalone)
      ├── Session Host VMs (icons inside snet-avd-session)
      ├── Storage Account — FSLogix (standalone or in RG)
      ├── Key Vault (standalone)
      └── Log Analytics Workspace (standalone)
```

## Subnet Layout

| Subnet purpose | Typical CIDR | Contains |
|----------------|-------------|----------|
| Session hosts | /23 or /24 | VM scale set or VM icons |
| Management | /27 | Jump box VM icon |
| Private endpoints | /27 | PE icons (storage, Key Vault) |

Stack subnets vertically, 20 px gap.

## Icon Mapping

| Resource | Icon path |
|----------|-----------|
| `azurerm_virtual_desktop_host_pool` | `compute/AVD_Host_Pool.svg` |
| `azurerm_virtual_desktop_workspace` | `compute/Workspaces.svg` |
| `azurerm_virtual_desktop_application_group` | `compute/Workspaces.svg` |
| Session host (VMSS or VM) | `compute/Virtual_Machine.svg` |
| FSLogix storage | `storage/Storage_Accounts.svg` |
| Azure Files share | `storage/Storage_Accounts.svg` |

> If `compute/AVD_Host_Pool.svg` is not available in the Draw.io library, fall back to `compute/Virtual_Machine.svg` with label `Host Pool`.

## Edge Patterns

| From | To | Style | Label |
|------|----|-------|-------|
| Workspace | Application Group | Property ref | `application_group_id` |
| Application Group | Host Pool | Property ref | `host_pool_id` |
| Host Pool | Session Host VMs | Standard data flow | `registration` |
| Session Host VMs | FSLogix storage | Module param (dotted grey) | `profile_container` |
| Session Host VMs | Key Vault | Module param (dotted grey) | `secrets` |
| vHub | AVD VNet | Hub ↔ Spoke | `vHub Connection` |

## FSLogix Profile Storage

When `azurerm_storage_account` with `azurerm_storage_share` is detected alongside AVD resources:
- Place storage icon as standalone in RG
- Add PE icon in `snet-pep` with edge to storage (label `file`)
- Add Private DNS Zone icon (`privatelink.file.core.windows.net`)

## Scaling Plan

When `azurerm_virtual_desktop_scaling_plan` is detected:
- Place as standalone icon in RG
- Edge from Scaling Plan to Host Pool (property ref, label `host_pool_id`)

## Identity & Conditional Access

Show Entra ID / domain join as an external reference box (outside subscription) with a dashed edge:
- Label: `Entra ID / AD DS`
- Edge style: Module param (dotted grey)
- Direction: Session Host VMs → Entra ID box
