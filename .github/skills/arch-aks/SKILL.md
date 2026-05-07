---
name: arch-aks
description: "AKS workload landing zone diagram patterns: cluster placement, node pool subnets, ACR integration, ingress controllers, and CNI overlay networking. USE WHEN: azurerm_kubernetes_cluster detected, AKS spoke VNet, AKS landing zone, container workload, node pools, ingress subnet."
---

# AKS Landing Zone — Diagram Pattern

Apply when `azurerm_kubernetes_cluster` is detected in the Terraform graph.

## Container Hierarchy

```
Landing Zone Subscription
 └── AKS Resource Group
      ├── VNet (AKS spoke)
      │    ├── snet-aks-system (system node pool)
      │    ├── snet-aks-user (user node pools)
      │    ├── snet-aks-ingress (internal LB / App GW)
      │    ├── snet-aks-apiserver (API server VNet integration)
      │    └── snet-pep (private endpoints)
      ├── AKS Cluster (icon inside snet-aks-system)
      ├── ACR (standalone in RG or separate RG)
      ├── Key Vault (standalone)
      └── Managed Identity (standalone)
```

## Subnet Layout

| Subnet purpose | Typical CIDR | Contains |
|----------------|-------------|----------|
| System node pool | /24 | AKS cluster icon |
| User node pool | /23 | (empty or VMSS icon) |
| Ingress | /27 | App GW or Internal LB icon |
| API server | /28 | (only if API server VNet integration enabled) |
| Private endpoints | /27 | PE icons for ACR, Key Vault |

Stack subnets **vertically** inside the VNet container, 20 px gap between each.

## Icon Mapping

| Resource | Icon path |
|----------|-----------|
| `azurerm_kubernetes_cluster` | `compute/Kubernetes_Services.svg` |
| `azurerm_container_registry` | `containers/Container_Registries.svg` |
| `azurerm_application_gateway` | `networking/Application_Gateways.svg` |
| `azurerm_user_assigned_identity` | `identity/Managed_Identities.svg` |
| Node pool (VMSS) | `compute/VM_Scale_Sets.svg` |

## Edge Patterns

| From | To | Style | Label |
|------|----|-------|-------|
| AKS cluster | ACR | Property ref | `acr_id` |
| AKS cluster | Key Vault | Module param (dotted grey) | `key_vault_secrets_provider` |
| AKS cluster | Managed Identity | Property ref | `identity` |
| App GW / LB | AKS cluster | Standard data flow | `backend_pool` |
| vHub | AKS VNet | Hub ↔ Spoke | `vHub Connection` |

## CNI Overlay vs Kubenet

| Mode | Visual cue |
|------|-----------|
| Azure CNI Overlay | Single system subnet, label includes `(CNI Overlay)` |
| Azure CNI (pod subnet) | Extra `snet-aks-pods` subnet shown |
| Kubenet | Label system subnet as `(kubenet — NAT required)` |

Detect from Terraform: `network_profile.network_plugin` value in the module block.

## Private Cluster

When `private_cluster_enabled = true`:
- Show API server PE icon inside `snet-aks-apiserver` or `snet-pep`
- Add Private DNS Zone icon (`privatelink.<region>.azmk8s.io`) as standalone in RG
- Edge from PE to AKS cluster (property ref, label `private_dns_zone_id`)
