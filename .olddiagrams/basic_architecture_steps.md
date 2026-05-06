# Steps: Terraform → Draw.io Architecture Diagram

## 1. Parse Terraform files

Read every root `.tf` file to identify resources and module instances:

| File | Module / Resource | Type |
|------|-------------------|------|
| `connectivity_rg.tf` | `azurerm_resource_group.connectivity` | Resource Group |
| `shd_svc_rg.tf` | `azurerm_resource_group.shared_services` | Resource Group |
| `ip_pool.tf` | `module.ip_pool` | `./modules/ip_pool` → `azurerm_network_manager_ip_pool` |
| `vwan.tf` | `module.virtual_wan` | `./modules/azure_virtual_wan` |
| `vhub.tf` | `module.virtual_wan_hub` | `./modules/azure_virtual_wan_hub` |
| `fw_policy.tf` | `module.firewall_policy` | `./modules/azure_firewall_policy` |
| `fw.tf` | `module.firewall` | `./modules/azure_firewall` |
| `vnet_gateway.tf` | `azurerm_vpn_gateway.virtual_network_gateway` | VPN Gateway |
| `shd_svc_vnet.tf` | `module.shared_services_vnet` | `./modules/azure_virtual_network` |
| `nsg.tf` | `module.network_security_group` | `./modules/network_security_group` |
| `azure_bastion.tf` | `module.azure_bastion` | `./modules/azure_bastion` |
| `peering.tf` | *(commented out — skipped)* | vHub connection |

Resource names resolved from `locals.tf`:

```hcl
name_prefix = "${var.company_prefix}_${var.environment}"  # → rus_dev
name_suffix = var.region_short                            # → gwc
```

---

## 2. Build the dependency graph

Scanned every module/resource block for `.id` attribute references and named input parameters:

| Source | Target | Attribute |
|--------|--------|-----------|
| `module.ip_pool` | `module.virtual_wan_hub` | `ip_pool_id` |
| `module.virtual_wan` | `module.virtual_wan_hub` | `virtual_wan_id` |
| `module.virtual_wan_hub` | `module.firewall` | `virtual_hub_id` |
| `module.virtual_wan_hub` | `azurerm_vpn_gateway` | `virtual_hub_id` |
| `module.firewall_policy` | `module.firewall` | `firewall_policy_id` |
| `module.ip_pool` | `module.shared_services_vnet` | `ip_pool_id` |
| `module.shared_services_vnet` | `module.azure_bastion` | `subnet_ids["bastion"]` |
| `module.shared_services_vnet` | `module.network_security_group` | `subnet_ids` (all 3) |
| `module.azure_bastion` (pip) | `module.azure_bastion` | `public_ip_name` |

---

## 3. Map resources to Azure2 icons

Each resource type was matched to `img/lib/azure2/` paths per the icon reference table:

| Resource | Icon path |
|----------|-----------|
| IP Pool (`azurerm_network_manager_ip_pool`) | `other/Azure_Network_Manager.svg` |
| Virtual WAN | `networking/Virtual_WANs.svg` |
| Virtual WAN Hub | `networking/Virtual_WAN_Hub.svg` |
| Firewall Policy | `networking/Azure_Firewall_Policy.svg` |
| Azure Firewall | `networking/Firewalls.svg` |
| VPN Gateway | `networking/Virtual_Network_Gateways.svg` |
| Virtual Network | `networking/Virtual_Networks.svg` (swimlane container) |
| Subnet | `networking/Subnet.svg` |
| NSG | `networking/Network_Security_Groups.svg` |
| Azure Bastion | `networking/Bastions.svg` |
| Public IP | `networking/Public_IP_Addresses.svg` |

---

## 4. Generate Draw.io XML

### Layout decisions

- Two side-by-side swimlane containers, one per resource group.
- **Left** (`rg_rus_dev_connectivity_gwc`, 720 × 750 px): IP Pool → vWAN → vHub → Firewall Policy / Firewall / VPN Gateway.
- **Right** (`rg_rus_dev_shd_svc_gwc`, 700 × 750 px): nested VNet container with three subnets, NSG, Bastion, Public IP below.

### Node style applied to every resource icon

```
shape=image;html=1;verticalLabelPosition=bottom;verticalAlign=top;align=center;
image=img/lib/azure2/<path>;fillColor=#ffffff;strokeColor=#e0e0e0;
rounded=1;arcSize=10;shadow=1;fontSize=11;fontColor=#333333;
```

### Swimlane styles

| Container | Style |
|-----------|-------|
| Resource Group | `swimlane;startSize=50;fillColor=#f0f0f0;strokeColor=#666666;fontColor=#333333;fontSize=12;fontStyle=1;html=1;arcSize=4;rounded=1;` |
| Virtual Network (nested) | `swimlane;startSize=40;fillColor=#dae8fc;strokeColor=#0078D4;fontColor=#333333;fontSize=11;html=1;arcSize=4;rounded=1;` |

### Edge styles used

| Relationship | Style |
|-------------|-------|
| `.id` / property reference | Solid blue arrow, `endArrow=block;endFill=1;strokeColor=#0078D4;flowAnimation=1;` |
| NSG subnet association | Dashed grey open arrow, `dashed=1;endArrow=open;endFill=0;strokeColor=#666666;flowAnimation=1;` |

All 11 edges include `flowAnimation=1`.

### Containment hierarchy

```
parent="1"
├── rg_conn  (swimlane)
│   ├── n_ip_pool
│   ├── n_vwan
│   ├── n_vhub
│   ├── n_fw_policy
│   ├── n_fw
│   └── n_vpn_gw
├── rg_shd   (swimlane)
│   ├── n_vnet_container  (nested swimlane)
│   │   ├── n_snet_bastion
│   │   ├── n_snet_pe
│   │   └── n_snet_app
│   ├── n_nsg
│   ├── n_bastion
│   └── n_pip_bastion
└── edges e1–e11  (parent="1" for cross-container; parent="rg_conn" for intra-connectivity)
```

---

## 5. Write output file

Saved as `basic_architecture.drawio` in the repository root.

Validation checks performed:
- XML is well-formed (single root `<mxGraphModel>`, all tags closed).
- Every `<mxCell edge="1">` has a `<mxGeometry relative="1" as="geometry"/>` child.
- All `html=1` present on swimlane and image nodes.
- All labels use `&#xa;` for line breaks — no raw HTML tags.
- All edges carry `flowAnimation=1`.

tocken usage

```cmd
  ╭─╮╭─╮   Changes   +101 -0
  ╰─╯╰─╯   Requests  1 Premium (54m 39s)
  █ ▘▝ █   Tokens    ↑ 281.4k • ↓ 21.1k • 201.3k (cached)
   ▔▔▔▔    Resume    copilot --resume=2dc0cfa8-b93e-4b03-8105-65d8ee081009
```
