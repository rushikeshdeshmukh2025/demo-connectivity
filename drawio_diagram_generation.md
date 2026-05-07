# Draw.io Diagram Generation — Conversation Log

**Repository:** `rushikeshdeshmukh2025/demo-connectivity`  
**Generated:** 2026-05-07  
**Output file:** `terraform_graph_architecture.drawio`

---

## 1. Request

> Generate a Draw.io architecture diagram from the Terraform files in this repository.

---

## 2. Infrastructure Analysed

### Topology Detected

**Azure Virtual WAN hub-and-spoke** — detected via `azurerm_virtual_wan` + `azurerm_virtual_hub`.

### Environments

| Environment | Location | Region Short | Name Prefix | Name Suffix |
|-------------|----------|-------------|-------------|-------------|
| `dev` | germanywestcentral | `gwc` | `rus_dev` | `gwc` |
| `pre` | switzerlandnorth | `szn` | `rus_pre` | `szn` |
| `prod` | germanywestcentral | `gwc` | `rus_prod` | `gwc` |

### Resource Groups

| Resource Group (DEV example) | Purpose |
|------------------------------|---------|
| `rg_rus_dev_connectivity_gwc` | vWAN, vHub, Firewall, VPN Gateway, IP Pool |
| `rg_rus_dev_shd_svc_gwc` | Shared Services VNet, NSGs, Private Endpoints, DNS Zones |
| `rg_rus_dev_storage_gwc` | Storage Account |
| `rg_rus_dev_key_vault_gwc` | Key Vault |
| `rg_rus_dev_bastion_gwc` | Azure Bastion Host |

### IP Address Plan

| Resource | CIDR |
|----------|------|
| IP Pool | `10.0.0.0/16` |
| vWAN Hub | `10.0.0.0/23` |
| Shared Services VNet | `10.0.2.0/23` |
| AzureBastionSubnet | `10.0.2.0/27` |
| Private Endpoint subnet | `10.0.2.32/27` |
| App subnet | `10.0.2.64/27` |

### Terraform Modules → Resources Mapped

| Root `.tf` file | Module | Resource Type |
|-----------------|--------|---------------|
| `vwan.tf` | `module.virtual_wan` | `azurerm_virtual_wan` |
| `vhub.tf` | `module.virtual_wan_hub` | `azurerm_virtual_hub` |
| `ip_pool.tf` | `module.ip_pool` | `azurerm_network_manager_ipam_pool` |
| `fw_policy.tf` | `module.firewall_policy` | `azurerm_firewall_policy` |
| `fw.tf` | `module.firewall` | `azurerm_firewall` (AZFW_Hub, Standard) |
| `vnet_gateway.tf` | direct resource | `azurerm_vpn_gateway` |
| `shd_svc_vnet.tf` | `module.shared_services_vnet` | `azurerm_virtual_network` + 3 subnets |
| `nsg.tf` | `module.network_security_group_*` (×3) | `azurerm_network_security_group` |
| `azure_bastion.tf` | `module.azure_bastion` | `azurerm_bastion_host` |
| `peering.tf` | `module.shared_services_hub_connection` | `azurerm_virtual_hub_connection` |
| `private_endpoints.tf` | `module.private_endpoints` (×2) | `azurerm_private_endpoint` |
| `private_dns_zones.tf` | `module.private_dns_zones` (×2) | `azurerm_private_dns_zone` |
| `storage_account.tf` | `module.storage_account` | `azurerm_storage_account` |
| `key_vault.tf` | `module.key_vault` | `azurerm_key_vault` |

### NSG Rules — Bastion Subnet

**Inbound:**

| Name | Priority | Source | Destination | Port | Protocol |
|------|----------|--------|-------------|------|----------|
| AllowHttpsInbound | 120 | Internet | * | 443 | Tcp |
| AllowGatewayManagerInbound | 130 | GatewayManager | * | 443 | Tcp |
| AllowAzureLoadBalancerInbound | 140 | AzureLoadBalancer | * | 443 | Tcp |
| AllowBastionHostCommunicationInbound8080 | 150 | VirtualNetwork | VirtualNetwork | 8080 | * |
| AllowBastionHostCommunicationInbound5701 | 160 | VirtualNetwork | VirtualNetwork | 5701 | * |
| DenyAllInbound | 4096 | * | * | * | * |

**Outbound:**

| Name | Priority | Source | Destination | Port | Protocol |
|------|----------|--------|-------------|------|----------|
| AllowSshRdpOutbound | 100 | * | VirtualNetwork | 22 | Tcp |
| AllowRdpOutbound | 101 | * | VirtualNetwork | 3389 | Tcp |
| AllowAzureCloudOutbound | 110 | * | AzureCloud | 443 | Tcp |
| AllowBastionCommunicationOutbound8080 | 120 | VirtualNetwork | VirtualNetwork | 8080 | * |
| AllowBastionCommunicationOutbound5701 | 130 | VirtualNetwork | VirtualNetwork | 5701 | * |
| DenyAllOutbound | 4096 | * | Internet | * | * |

> NSGs for `private_endpoint` and `app` subnets have **no custom rules** (Azure defaults apply).

### Private DNS Zones

| Key | Zone FQDN | Linked to |
|-----|-----------|-----------|
| `blob` | `privatelink.blob.core.windows.net` | Shared Services VNet |
| `vault` | `privatelink.vaultcore.azure.net` | Shared Services VNet |

---

## 3. Skills Activated

| Skill | Reason |
|-------|--------|
| `drawio-rendering` | Page sizing, zone layout, container styles, coordinate system, quality checklist |
| `azure-naming-convention` | Resolve all resource labels from `locals.tf` + `.tfvars` |
| `azure-icon-library` | Map `azurerm_*` resource types to `img/lib/azure2/` SVG paths |
| `drawio-edge-styles` | Select correct edge style per relationship type (all with `flowAnimation=1`) |
| `nsg-badge-placement` | 3 NSG badges (one per subnet) + NSG rules side-panel tables |

> `private-endpoint-layout` skill was **not** activated — the PE column layout requires **> 2** private endpoints; this workspace has exactly 2.

---

## 4. Diagram Design Decisions

### Page Layout

| Property | Value |
|----------|-------|
| Page size | A3 landscape (2480 × 1169) extended +820 px for NSG tables |
| Final page width | 2480 px |
| Page height | 1169 px |

### Two-Zone Layout

| Zone | X range | Colour | Contents |
|------|---------|--------|----------|
| On-Premises | 0 – 310 | `#f5f0e6` (warm beige) | VPN Device, Connections Legend |
| Microsoft Azure | 320 – 1600 | `#e8f0fe` (light blue) | Subscription + all RGs |
| NSG Tables | 1640 – 2460 | Outside zones (canvas-absolute) | 2-column NSG rules tables |

### Container Hierarchy (per environment tab)

```
On-Premises zone (background)
Azure zone (background)
│
└── Subscription container
    ├── rg_*_connectivity_*
    │   ├── IP Pool icon
    │   └── vWAN swimlane
    │       └── vHub swimlane
    │           ├── Firewall Policy icon
    │           ├── Azure Firewall icon
    │           └── VPN Gateway icon
    ├── rg_*_shd_svc_*
    │   ├── VNet container (dashed blue)
    │   │   ├── AzureBastionSubnet
    │   │   │   └── Azure Bastion icon
    │   │   ├── snet_*_private_endpoint_*
    │   │   │   ├── PE (blob) icon
    │   │   │   └── PE (vault) icon
    │   │   └── snet_*_app_*  (empty)
    │   ├── DNS Zone icon (blob)
    │   └── DNS Zone icon (vault)
    ├── rg_*_storage_*
    │   └── Storage Account icon
    ├── rg_*_key_vault_*
    │   └── Key Vault icon
    └── rg_*_bastion_*  (label only — Bastion icon shown in AzureBastionSubnet)

NSG badges (parent = VNet, NOT subnet)
    ├── nsg_*_bastion_* badge  (top-right of AzureBastionSubnet)
    ├── nsg_*_private_endpoint_* badge  (top-right of PE subnet)
    └── nsg_*_app_* badge  (top-right of App subnet)

NSG rules tables (parent = canvas layer "1", col1 x=1640, col2 x=2040)
    ├── Bastion NSG table (12 rules, h=410)
    ├── PE NSG table (no custom rules, h=160)
    └── App NSG table (no custom rules, h=160)
```

### Edges

| Edge ID suffix | Relationship | Style |
|---------------|--------------|-------|
| `e-vpntunnel` | On-Prem VPN Device → VPN Gateway | Dashed brown (site-to-site tunnel) |
| `e-hubconn` | vHub ↔ Shared Services VNet | Blue bidirectional (hub connection) |
| `e-fwpolicy` | Firewall Policy → Firewall | Blue solid (property reference) |
| `e-ippool-vhub` | IP Pool → vHub | Dotted grey (module parameter `ip_pool_id`) |
| `e-ippool-vnet` | IP Pool → VNet | Dotted grey (module parameter `ip_pool_id`) |
| `e-pe-storage` | PE blob → Storage Account | Blue solid (Private Link) |
| `e-pe-kv` | PE vault → Key Vault | Blue solid (Private Link) |
| `e-dns-blob` | DNS Zone blob → VNet | Thin grey (VNet Link) |
| `e-dns-vault` | DNS Zone vault → VNet | Thin grey (VNet Link) |

> All edges include `flowAnimation=1`.

### NSG Badge Placement Formula

```
badge_x (rel. to VNet) = subnet_x + subnet_width - 18
badge_y (rel. to VNet) = subnet_y - 18
badge size = 36 × 36 px
parent = VNet container (NOT subnet, NOT RG)
```

| Subnet | badge_x | badge_y |
|--------|---------|---------|
| AzureBastionSubnet (y=55) | 422 | 37 |
| snet-pe (y=205) | 422 | 187 |
| snet-app (y=355) | 422 | 337 |

---

## 5. Resolved Resource Names

### DEV (name_prefix=`rus_dev`, name_suffix=`gwc`)

| Resource | Resolved Name |
|----------|--------------|
| Connectivity RG | `rg_rus_dev_connectivity_gwc` |
| Shared Services RG | `rg_rus_dev_shd_svc_gwc` |
| Storage RG | `rg_rus_dev_storage_gwc` |
| Key Vault RG | `rg_rus_dev_key_vault_gwc` |
| Bastion RG | `rg_rus_dev_bastion_gwc` |
| vWAN | `vwan_rus_dev_connectivity_gwc` |
| vHub | `vhub_rus_dev_connectivity_gwc` |
| Firewall Policy | `afwp_rus_dev_connectivity_gwc` |
| Firewall | `afw_rus_dev_connectivity_gwc` |
| VPN Gateway | `vpng_rus_dev_connectivity_gwc` |
| IP Pool | `ippool_rus_dev_connectivity_gwc` |
| VNet | `vnet_rus_dev_shared_services_gwc` |
| AzureBastionSubnet | `AzureBastionSubnet` (Azure-fixed) |
| PE subnet | `snet_rus_dev_private_endpoint_gwc` |
| App subnet | `snet_rus_dev_app_gwc` |
| NSG Bastion | `nsg_rus_dev_bastion_gwc` |
| NSG PE | `nsg_rus_dev_private_endpoint_gwc` |
| NSG App | `nsg_rus_dev_app_gwc` |
| Azure Bastion | `bas_rus_dev_connectivity_gwc` |
| Hub Connection | `vhc_rus_dev_shared_services_gwc` |
| Storage Account | `strusdevshdgwc` |
| Key Vault | `kv-rus-dev-shd-gwc` |
| PE (blob) | `pep_rus_dev_storage_blob_gwc` |
| PE (vault) | `pep_rus_dev_key_vault_gwc` |
| DNS Zone (blob) | `privatelink.blob.core.windows.net` |
| DNS Zone (vault) | `privatelink.vaultcore.azure.net` |

### PRE (name_prefix=`rus_pre`, name_suffix=`szn`)

Same structure — replace `dev` → `pre`, `gwc` → `szn`.  
Example: `rg_rus_pre_connectivity_szn`, `struspreshtdszn` (storage), `kv-rus-pre-shd-szn`.

### PROD (name_prefix=`rus_prod`, name_suffix=`gwc`)

Same structure — replace `dev` → `prod`.  
Example: `rg_rus_prod_connectivity_gwc`, `strusprodshdgwc` (storage), `kv-rus-prod-shd-gwc`.

---

## 6. Output File

**`terraform_graph_architecture.drawio`** — 3 diagram tabs, ~880 lines of XML.

| Tab | Diagram ID | Environment |
|-----|-----------|-------------|
| `DEV` | `env-dev` | germanywestcentral |
| `PRE` | `env-pre` | switzerlandnorth |
| `PROD` | `env-prod` | germanywestcentral |

All `mxCell` IDs are prefixed with the environment slug (e.g. `dev-vhub`, `pre-vnet`, `prod-storage`) to ensure uniqueness across tabs.

---

## 7. Quality Checklist Verification

| Check | Status |
|-------|--------|
| Every `<mxCell>` has `html=1` | ✅ |
| Children positioned relative to parent | ✅ |
| All coordinates multiples of 10 | ✅ |
| No duplicate IDs within a diagram | ✅ |
| Exactly two zone backgrounds | ✅ |
| Hub ↔ Spoke edge for every spoke VNet | ✅ |
| NSG badges: parent=VNet, 36×36, right border | ✅ |
| NSG tables: `parent="1"`, outside Azure zone | ✅ |
| No connector edges between NSG badges and tables | ✅ |
| `flowAnimation=1` on all edges | ✅ |
| `pageWidth` extended 820 px for NSG tables | ✅ |
| Service icons 50×50 px | ✅ |
| IP CIDRs in VNet/subnet labels | ✅ |
| `<mxfile host="GitHub Copilot" version="24.0.0">` wrapper | ✅ |
| Connections Legend below On-Premises zone | ✅ |
| `mxCell id="0"` and `id="1"` present in each diagram | ✅ |
