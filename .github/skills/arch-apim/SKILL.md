---
name: arch-apim
description: "API Management landing zone diagram patterns: APIM instance placement, internal/external mode, App Gateway integration, backend APIs, and developer portal. USE WHEN: azurerm_api_management detected, APIM spoke VNet, API gateway workload, internal APIM, App GW + APIM pattern."
---

# API Management Landing Zone — Diagram Pattern

Apply when `azurerm_api_management` is detected in the Terraform graph.

## Container Hierarchy

```
Landing Zone Subscription
 └── APIM Resource Group
      ├── VNet (APIM spoke)
      │    ├── snet-apim (APIM instance — internal mode)
      │    ├── snet-appgw (Application Gateway)
      │    ├── snet-backend (backend app services / functions)
      │    └── snet-pep (private endpoints)
      ├── APIM instance (icon inside snet-apim)
      ├── Application Gateway (icon inside snet-appgw)
      ├── App Service / Functions (icon inside snet-backend)
      ├── Key Vault (standalone)
      └── Log Analytics Workspace (standalone)
```

## Deployment Modes

| Mode | Detection | Visual |
|------|-----------|--------|
| External | `virtual_network_type = "External"` | APIM in subnet, public IP shown |
| Internal | `virtual_network_type = "Internal"` | APIM in subnet, no public IP, App GW in front |
| None (consumption) | No VNet config | APIM as standalone icon in RG (no subnet) |

## Internal Mode + App Gateway Pattern

This is the most common enterprise pattern:

```
Internet → [App GW + WAF] → [APIM Internal] → [Backend Services]
              (snet-appgw)      (snet-apim)       (snet-backend or PE)
```

### Edges for this pattern

| From | To | Style | Label |
|------|----|-------|-------|
| App Gateway | APIM | Standard data flow | `backend_pool` |
| APIM | Backend App/Function | Standard data flow | `api_backend` |
| APIM | Key Vault | Module param (dotted grey) | `named_values / certificates` |
| App GW | Public IP | Property ref | `public_ip_address_id` |
| vHub | APIM VNet | Hub ↔ Spoke | `vHub Connection` |

## Icon Mapping

| Resource | Icon path |
|----------|-----------|
| `azurerm_api_management` | `app_services/API_Management_Services.svg` |
| `azurerm_application_gateway` | `networking/Application_Gateways.svg` |
| `azurerm_web_application_firewall_policy` | `networking/Web_Application_Firewall_Policies_WAF.svg` |
| `azurerm_app_service` | `app_services/App_Services.svg` |
| `azurerm_function_app` | `compute/Function_Apps.svg` |
| Developer Portal | `app_services/API_Management_Services.svg` (label: `Developer Portal`) |

## Subnet Layout

| Subnet purpose | Typical CIDR | Contains |
|----------------|-------------|----------|
| APIM | /27 or /26 | APIM icon |
| App Gateway | /27 | App GW + WAF icon |
| Backend | /27 | App Service / Function icons |
| Private endpoints | /27 | PE icons |

Arrange subnets **left-to-right** to show traffic flow direction (ingress → processing → backend).

## Multi-Region APIM

When `additional_location` blocks are detected:
- Show secondary APIM icon in a separate region RG
- Edge between primary and secondary: dashed blue bidirectional, label `geo-replication`

## Custom Domains & Certificates

When `azurerm_api_management_custom_domain` is detected:
- Add edge from Key Vault to APIM (property ref, label `certificate`)
- Label APIM with custom domain name in parentheses
