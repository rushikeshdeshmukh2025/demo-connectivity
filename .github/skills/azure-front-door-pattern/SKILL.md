---
name: azure-front-door-pattern
description: "Place Azure Front Door in its own Platform Connectivity subscription above workload subscriptions, with endpoints, origins, routes, and WAF policy. USE WHEN: Azure Front Door detected, AFD resources, cdn_frontdoor_profile, front door pattern, platform connectivity."
---

# Azure Front Door — Central Platform Pattern

Apply this pattern **only when** `azurerm_frontdoor` or `azurerm_cdn_frontdoor_profile` resources are detected.

## Placement

- AFD lives in its own **Platform Connectivity subscription** container.
- Use the **Connectivity Area** container style (gold/amber border — see `drawio-xml-validation` skill §5.7).
- Position this subscription **above** workload subscription(s) in the diagram.
- Vertical gap between AFD subscription and workload subscription(s): **60 px**.

## Internal Structure

Inside the Platform Connectivity subscription, nest resources in this order (left → right):

```
[Front Door Profile]
  └── [Endpoints container]
        ├── Endpoint icon(s)
        └── [Origins & Routes container]
              ├── Origin icon(s)
              └── Route icon(s)
  └── [WAF Policy icon]   ← placed alongside, not nested
```

| Element | Icon path |
|---------|-----------|
| Front Door Profile | `img/lib/azure2/networking/Front_Doors.svg` |
| WAF Policy | `img/lib/azure2/networking/Web_Application_Firewall_Policies_WAF.svg` |
| Endpoint | `img/lib/azure2/networking/Front_Doors.svg` (reuse, label differentiates) |

## Origin Connection Edges

Draw edges from **Origin & Routes** icons to the backend service icons in workload subscription(s).

| Origin type | Edge style |
|-------------|-----------|
| Standard public origin | Standard Data Flow edge (`drawio-edge-styles`) |
| Private Link origin | Dashed orange with Private Link label: `rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#E65100;strokeWidth=2;dashed=1;dashPattern=5 5;endArrow=block;endFill=1;flowAnimation=1;` |

Edge label for Private Link origins: `Private Link Origin`.

## WAF Policy Edge

Draw a **Property Reference** edge (solid blue) from **WAF Policy** to **Front Door Profile** with label `security_policy_id`.
