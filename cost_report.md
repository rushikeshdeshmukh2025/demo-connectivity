# Azure Cost Report — demo-connectivity

**Generated:** 2026-05-08  
**Region:** Germany West Central (`germanywestcentral`)  
**Currency:** EUR (€)  
**Pricing Type:** Pay-as-you-go (Consumption)  
**Source:** Azure Retail Pricing API  

---

## Infrastructure Summary

This report covers the hub-and-spoke network topology defined in this repository, provisioned via Terraform using Azure Virtual WAN.

| # | Resource | Type | SKU/Tier |
|---|----------|------|----------|
| 1 | Azure Virtual WAN | `azurerm_virtual_wan` | Standard |
| 2 | Azure Virtual WAN Hub | `azurerm_virtual_hub` | Standard |
| 3 | Azure Firewall Policy | `azurerm_firewall_policy` | Standard |
| 4 | Azure Firewall | `azurerm_firewall` | Standard (Secured Virtual Hub) |
| 5 | VPN Gateway (vWAN S2S) | `azurerm_vpn_gateway` | 1 × S2S Scale Unit |
| 6 | Azure Bastion | `azurerm_bastion_host` | Standard |
| 7 | Shared Services VNet | `azurerm_virtual_network` | — |
| 8 | NSGs (×3) | `azurerm_network_security_group` | — |
| 9 | Storage Account | `azurerm_storage_account` | Standard LRS |
| 10 | Key Vault | `azurerm_key_vault` | Standard |
| 11 | IP Pool (Network Manager) | `azurerm_network_manager_static_cidr` | — |

---

## Assumptions

- **730 hours/month** used for all hourly-billed resources.
- VPN Gateway `scale_unit` defaults to **1** (as not explicitly set in Terraform).
- Data processing costs (Firewall, vWAN hub, Bastion egress) are **variable** and excluded from the fixed total — representative estimates are provided separately.
- Azure Firewall Policy Standard has **no standalone charge** — cost is captured in the Firewall meter.
- Virtual WAN itself (the parent resource) has **no standalone charge** — cost is in the hub.
- Virtual Network, NSGs, and Resource Groups are **free**.
- Azure Network Manager IP Pool (IPAM Static CIDR) is **free** for basic CIDR allocation.
- Storage Account and Key Vault costs are **estimated** for minimal/idle usage.
- A **Routing Infrastructure Unit** (€0.0855/hr) is applicable because the hub is a Secured Virtual Hub with Azure Firewall.
- Firewall Policy rules are assumed minimal — no additional IDPS/threat intelligence premium charges.
- New Azure Firewall capacity-unit pricing (effective Nov 2025) may apply on top of the deployment meter for high-throughput scenarios; minimum 1 capacity unit included.

---

## Resource-Level Cost Breakdown

### Fixed / Hourly-Billed Resources

| Resource | Meter | Rate (EUR) | Unit | Hours/Month | Monthly Cost (€) |
|----------|-------|-----------|------|-------------|-----------------|
| vWAN Hub (Standard) | Standard Hub Unit | €0.2136 | /hr | 730 | **€155.93** |
| vWAN Routing Infrastructure | Routing Infrastructure Unit | €0.0855 | /hr | 730 | **€62.42** |
| Azure Firewall Standard | Standard Secured Virtual Hub Deployment | €1.0682 | /hr | 730 | **€779.79** |
| VPN Gateway (vWAN S2S) | VPN S2S Scale Unit × 1 | €0.3085 | /hr | 730 | **€225.21** |
| Azure Bastion Standard | Standard Gateway | €0.2478 | /hr | 730 | **€180.89** |
| Storage Account (Standard LRS) | Block Blob Storage — estimated | — | /GB | — | **~€5.00** |
| Key Vault (Standard) | Operations — estimated (minimal) | — | /10K ops | — | **~€1.00** |

### Variable / Usage-Based Costs (excluded from totals)

| Resource | Meter | Rate (EUR) | Unit |
|----------|-------|-----------|------|
| Azure Firewall | Data Processed | €0.0137 | /GB |
| vWAN Hub | Standard Hub Data Processed | €0.0171 | /GB |
| Azure Bastion | Standard Data Transfer Out (intra-region) | €0.0427 | /GB |
| Azure Bastion | Standard Data Transfer Out (cross-region) | €0.0743 | /GB |
| VPN Gateway | S2S Connection Unit (per active connection) | €0.0427 | /hr |

> **Example:** 1 TB of Firewall-processed traffic per month = 1,000 × €0.0137 = **€13.70/month** extra.

---

## Cost Totals

| Period | Fixed Costs | Notes |
|--------|------------|-------|
| **Monthly** | **€1,410.24** | Excludes data processing |
| **Quarterly** | **€4,230.72** | ×3 months |
| **Half-Yearly** | **€8,461.44** | ×6 months |
| **Yearly** | **€16,922.88** | ×12 months |

---

## Cost Breakdown by Category

```
Azure Firewall Standard   ████████████████████  55.3%   €779.79/month
VPN Gateway (S2S)         ████████              16.0%   €225.21/month
Azure Bastion Standard    ████████              12.8%   €180.89/month
vWAN Hub (Standard)       █████                 11.1%   €155.93/month
Routing Infrastructure    ██                     4.4%    €62.42/month
Storage + Key Vault       ░                      0.4%    ~€6.00/month
─────────────────────────────────────────────────────────────────────
TOTAL                                          100%   ~€1,410/month
```

---

## Major Cost Drivers

1. 🔥 **Azure Firewall Standard** — €779.79/month (55% of total)  
   The dominant cost driver. Deployed as a Secured Virtual Hub Firewall (`AZFW_Hub`) in the vWAN hub.

2. 🔌 **VPN Gateway (S2S)** — €225.21/month (16%)  
   Running continuously even without active VPN connections. Minimum 1 scale unit.

3. 🖥️ **Azure Bastion Standard** — €180.89/month (13%)  
   Fixed hourly cost regardless of active sessions.

4. 🌐 **vWAN Hub** — €155.93/month + €62.42/month routing = €218.35/month (15%)  
   Hub unit fee plus routing infrastructure unit (required when using Azure Firewall in the secured hub).

---

## Cost Optimization Opportunities

| Opportunity | Potential Saving | Recommendation |
|-------------|----------------|----------------|
| 🔽 **Downgrade Firewall to Basic** | ~52% savings on Firewall (~€406/month) | Consider Azure Firewall **Basic** (€0.3375/hr = €246.38/month) for dev/test environments if advanced threat intelligence is not required |
| ⏹️ **Stop VPN Gateway when not needed** | up to **€225/month** | If no VPN connections are configured, consider deleting the VPN Gateway and re-deploying only when needed |
| 🔽 **Downgrade Bastion to Basic** | ~34% savings on Bastion (~€62/month) | Use Azure Bastion **Basic** (€0.1624/hr = €118.55/month) if native client connections and file transfer features are not required |
| 📅 **Reserved Instance (Firewall)** | Check Azure Reservations portal | Azure Firewall supports 1-year and 3-year reservations for significant discounts (typically 30–40%) |
| 🌙 **Dev environment scheduling** | Up to **100% of compute** | For `dev` environments, automate shutdown of Bastion and VPN Gateway during off-hours |

### Dev Environment Estimated Savings (if optimizations applied)

| Scenario | Monthly Cost | Saving vs. Current |
|----------|-------------|-------------------|
| Current (all Standard, 24/7) | ~€1,410 | — |
| Basic Firewall + Basic Bastion + no VPN GW | ~€549 | **~61% saving** |
| Standard Firewall + Basic Bastion + no VPN GW | ~€1,122 | **~20% saving** |

---

## Notes & Caveats

- Prices retrieved from the **Azure Retail Pricing API** on 2026-05-08 and are subject to change.
- Prices are **list prices** (pay-as-you-go) — negotiated Enterprise Agreement or CSP pricing may differ.
- **Azure Firewall new capacity-unit pricing** (effective Nov 1, 2025) adds €0.0598/hr per capacity unit on top of the deployment meter. Minimum 1 unit is typically included; high-throughput deployments will incur additional capacity unit charges.
- **Private DNS Zones** (if deployed) add a small charge (~€0.60/zone/month) — not included as those resources are optional.
- **Private Endpoints** (if deployed) add ~€0.009/hr each — not included as those resources are optional.
- No **outbound data transfer** costs included — internet egress from the Azure region will add variable costs (first 100 GB/month free, then €0.0709/GB).
