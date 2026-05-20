# Azure Cost Report — demo-connectivity (dev)

**Generated:** 18 May 2026  
**Environment:** `dev`  
**Region:** Germany West Central (`germanywestcentral`)  
**Subscription:** `92490899-c949-4374-b0ce-4bdd62e8c4dd`  
**Pricing source:** Azure Retail Pricing API (real-time, as of report date)  
**Currency:** € (EUR) — converted from USD at 1 USD = 0.92 EUR *(approximate; rate sourced at report time)*  
**Billing model:** Pay-as-you-go (hourly consumption), 730 hours/month assumed  

---

## Assumptions

| # | Assumption |
|---|-----------|
| 1 | 730 hours/month (full calendar month) |
| 2 | Azure Firewall: minimum 1 Capacity Unit; 100 GB data processed/month |
| 3 | Azure Bastion Standard: 1 gateway instance, no scale-out; no outbound data transfer costs shown (first 5 GB free) |
| 4 | VPN Gateway (vWAN): 1 VPN S2S Scale Unit (500 Mbps), no active S2S connections yet |
| 5 | Storage Account: 10 GB stored (block blob, hot tier); minimal operations |
| 6 | Key Vault Standard: ~10,000 operations/month |
| 7 | Private Endpoints: 2 endpoints (storage blob + key vault); minimal data transfer |
| 8 | Private DNS Zones: 2 zones (blob + vault); minimal queries |
| 9 | USD → EUR at 0.92 |

---

## Resource Inventory

| Resource | Terraform Module / Resource | SKU / Tier | Name |
|---|---|---|---|
| Virtual WAN | `module.virtual_wan` | Standard | `vwan_rus_dev_connectivity_gwc` |
| Virtual WAN Hub | `module.virtual_wan_hub` | Standard | `vhub_rus_dev_connectivity_gwc` |
| Azure Firewall | `module.firewall` | Standard (Secured vHub) | `afw_rus_dev_connectivity_gwc` |
| Firewall Policy | `module.firewall_policy` | Standard | — |
| VPN Gateway | `azurerm_vpn_gateway` | vWAN Scale Unit | `vpng_rus_dev_connectivity_gwc` |
| Azure Bastion | `module.azure_bastion` | Standard | `bas_rus_dev_connectivity_gwc` |
| Storage Account | `module.storage_account` | Standard LRS | `strusdevshd gwc` |
| Key Vault | `module.key_vault` | Standard | `kv-rus-dev-shd-gwc` |
| Private Endpoint | `module.private_endpoints["storage_blob"]` | — | `pep_rus_dev_storage_blob_gwc` |
| Private Endpoint | `module.private_endpoints["key_vault"]` | — | `pep_rus_dev_key_vault_gwc` |
| Private DNS Zone | `module.private_dns_zones["blob"]` | — | `privatelink.blob.core.windows.net` |
| Private DNS Zone | `module.private_dns_zones["vault"]` | — | `privatelink.vaultcore.azure.net` |

---

## Detailed Cost Breakdown

### 1. Azure Virtual WAN Hub (Standard)

| Meter | Unit Price (USD) | Units/Month | Monthly (USD) | Monthly (EUR) |
|---|---|---|---|---|
| Standard Hub Unit | $0.25 / hr | 730 hrs | $182.50 | €167.90 |
| Routing Infrastructure Unit | $0.10 / hr | 730 hrs | $73.00 | €67.16 |
| Standard Hub Data Processed *(variable)* | $0.02 / GB | 0 GB *(assumed)* | $0.00 | €0.00 |
| **Subtotal** | | | **$255.50** | **€235.06** |

> The Virtual WAN resource itself has no separate charge; cost is attributed to the hub.

---

### 2. Azure Firewall (Standard Secured Virtual Hub)

| Meter | Unit Price (USD) | Units/Month | Monthly (USD) | Monthly (EUR) |
|---|---|---|---|---|
| Standard Secured Virtual Hub Deployment | $1.25 / hr | 730 hrs | $912.50 | €839.50 |
| Standard Secured Virtual Hub Capacity Unit (min 1) | $0.07 / hr | 730 hrs | $51.10 | €47.01 |
| Standard Secured Virtual Hub Data Processed | $0.016 / GB | 100 GB | $1.60 | €1.47 |
| **Subtotal** | | | **$965.20** | **€887.98** |

> ⚠️ **Major cost driver.** Azure Firewall is the single largest cost item (~52% of total).

---

### 3. VPN Gateway (vWAN S2S Scale Unit)

| Meter | Unit Price (USD) | Units/Month | Monthly (USD) | Monthly (EUR) |
|---|---|---|---|---|
| VPN S2S Scale Unit (1× = 500 Mbps) | $0.361 / hr | 730 hrs | $263.53 | €242.45 |
| S2S Connection Unit *(none active)* | $0.05 / hr | 0 | $0.00 | €0.00 |
| **Subtotal** | | | **$263.53** | **€242.45** |

---

### 4. Azure Bastion (Standard)

| Meter | Unit Price (USD) | Units/Month | Monthly (USD) | Monthly (EUR) |
|---|---|---|---|---|
| Standard Gateway | $0.29 / hr | 730 hrs | $211.70 | €194.76 |
| Standard Data Transfer Out *(first 5 GB free)* | $0.087 / GB | 0 GB *(assumed)* | $0.00 | €0.00 |
| **Subtotal** | | | **$211.70** | **€194.76** |

---

### 5. Storage Account (Standard LRS — General Block Blob)

| Meter | Unit Price (USD) | Units/Month | Monthly (USD) | Monthly (EUR) |
|---|---|---|---|---|
| LRS Data Stored (hot, first 1 TB) | $0.0231 / GB / month | 10 GB | $0.23 | €0.21 |
| Write Operations | $0.00036 / 10K | negligible | ~$0.00 | ~€0.00 |
| **Subtotal** | | | **$0.23** | **€0.21** |

---

### 6. Key Vault (Standard)

| Meter | Unit Price (USD) | Units/Month | Monthly (USD) | Monthly (EUR) |
|---|---|---|---|---|
| Operations (secrets, keys) | $0.03 / 10K | 10K ops | $0.03 | €0.03 |
| Secret / Key Renewals | $1.00 / renewal | 0 | $0.00 | €0.00 |
| **Subtotal** | | | **$0.03** | **€0.03** |

---

### 7. Private Endpoints (×2)

> ⚠️ Private Endpoint pricing is $0.01/hr per endpoint (standard well-known rate; not returned by region-specific API filter but confirmed via Azure Pricing documentation).

| Resource | Unit Price (USD) | Units/Month | Monthly (USD) | Monthly (EUR) |
|---|---|---|---|---|
| PE — storage blob | $0.01 / hr | 730 hrs | $7.30 | €6.72 |
| PE — key vault | $0.01 / hr | 730 hrs | $7.30 | €6.72 |
| Inbound / Outbound Data *(negligible)* | $0.01 / GB | ~0 GB | $0.00 | €0.00 |
| **Subtotal** | | | **$14.60** | **€13.43** |

---

### 8. Private DNS Zones (×2)

| Meter | Unit Price (USD) | Units/Month | Monthly (USD) | Monthly (EUR) |
|---|---|---|---|---|
| DNS Zone (first 25 zones @ $0.90/zone) | $0.90 / zone / month | 2 zones | $1.80 | €1.66 |
| DNS Queries *(negligible)* | $0.60 / 1M queries | ~0 | $0.00 | €0.00 |
| **Subtotal** | | | **$1.80** | **€1.66** |

---

## Monthly Cost Summary

| Resource | Monthly (USD) | Monthly (EUR) | % of Total |
|---|---|---|---|
| Azure Firewall (Standard Secured vHub) | $965.20 | €887.98 | 52.0% |
| VPN Gateway (vWAN S2S) | $263.53 | €242.45 | 14.2% |
| Virtual WAN Hub (Standard) | $255.50 | €235.06 | 13.8% |
| Azure Bastion (Standard) | $211.70 | €194.76 | 11.4% |
| Private Endpoints (×2) | $14.60 | €13.43 | 0.8% |
| Private DNS Zones (×2) | $1.80 | €1.66 | 0.1% |
| Storage Account (Standard LRS) | $0.23 | €0.21 | 0.0% |
| Key Vault (Standard) | $0.03 | €0.03 | 0.0% |
| **Total** | **$1,712.59** | **$1,575.58** | **100%** |

---

## Projection

| Period | USD | EUR |
|---|---|---|
| Monthly | $1,712.59 | €1,575.58 |
| Quarterly (3 months) | $5,137.77 | €4,726.75 |
| Half-yearly (6 months) | $10,275.54 | €9,453.50 |
| Yearly (12 months) | $20,551.08 | €18,907.00 |

---

## Cost Optimization Opportunities

### 🔴 High Impact

| Opportunity | Potential Saving | Notes |
|---|---|---|
| **Azure Firewall — Reserved Capacity** | Up to 30% | 1-year or 3-year reservations available for Azure Firewall. At 30% saving: ~**€266/month** |
| **VPN Gateway — review if needed** | ~€242/month | If no S2S tunnels are active today, consider deleting or resizing. The gateway runs 24/7 regardless of connections. |
| **Azure Bastion — Basic tier** | ~€110/month | If features like native client, IP-based access, or shareable links are not required, downgrade to Basic ($0.19/hr vs $0.29/hr). |

### 🟡 Medium Impact

| Opportunity | Potential Saving | Notes |
|---|---|---|
| **Azure Firewall — Capacity Units** | Variable | Tune Firewall Policy rules to minimize Capacity Units consumed above the minimum. |
| **Virtual WAN Hub — scale down off-hours** | N/A | vWAN Hubs cannot be stopped/paused; consider evaluating if all hub features are required at this stage. |

### 🟢 Low Impact

| Opportunity | Potential Saving | Notes |
|---|---|---|
| **Storage — Lifecycle Management** | Negligible at 10 GB | Enable lifecycle policies to move blobs to cool/cold/archive when data grows. |
| **Key Vault — Operations** | Negligible | Already in lowest cost tier. |

---

## Reservation Savings Estimate (Azure Firewall + Bastion)

| Resource | Pay-as-you-go (EUR/mo) | 1-Year Reserved (est. -30%) | 3-Year Reserved (est. -50%) |
|---|---|---|---|
| Azure Firewall | €887.98 | €621.59 | €444.00 |
| Azure Bastion | €194.76 | €136.33 | €97.38 |
| **Combined saving/month** | — | **€324.82 saved** | **€541.36 saved** |

---

## Notes & Disclaimers

- Prices are **retail (pay-as-you-go) USD prices** fetched from the Azure Retail Pricing API on **18 May 2026** for the `germanywestcentral` region.
- EUR amounts are converted at **1 USD = 0.92 EUR** (approximate; actual billing may differ based on daily exchange rate).
- **Variable costs** (data processed, operations) are estimated based on assumed baselines. Actual costs will vary with traffic.
- Private Endpoint pricing ($0.01/hr) is based on Azure published documentation pricing as the Retail Pricing API did not return results for this product in the region filter; the rate is consistent across Azure regions.
- This report covers the **`dev` environment only**. Multiply by the number of environments (`dev`, `pre`, `prod`) for total portfolio cost — noting `pre` runs in Switzerland North which may have different pricing.
- Firewall Policy itself has no direct hourly charge; cost is included in the Firewall SKU.
- IP Pool (`azurerm_network_manager_static_cidr`) has no separate cost.
- NSG, VNet, Route Tables, and Peering (within the same region) have no fixed hourly charges.
