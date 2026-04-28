---
name: drawio-edge-styles
description: "Select the correct Draw.io edge style for each Azure architecture relationship type. Every edge must include flowAnimation=1. USE WHEN: drawing edges, connection styles, flow animation, hub-spoke edges, VPN tunnel edges, peering edges, reference edges."
---

# Draw.io Edge Styles

## Mandatory Rule

**`flowAnimation=1` is required on every edge without exception.** Never emit an edge without it.

Edges always use `source` and `target` attributes referencing cell `id` values — never free-floating connectors.

---

## Edge Style Reference

### Hub ↔ Spoke VNet (most prominent)
Use for `azurerm_virtual_hub_connection` and classic VNet peering between hub and spoke.

```
rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;startArrow=block;
endFill=1;startFill=1;strokeColor=#0078D4;strokeWidth=2;flowAnimation=1;html=1;fontSize=9;
```

### On-Premises → VPN/ER Gateway (site-to-site tunnel)

```
rounded=1;orthogonalLoop=1;jettySize=auto;dashed=1;endArrow=open;endFill=0;
strokeColor=#8d6e32;strokeWidth=2;flowAnimation=1;html=1;fontSize=9;
```

### Property Reference (`.id` / solid blue)
Use for `firewall_policy_id`, `public_ip_address_id`, and other direct `.id` attribute references.

```
rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;endFill=1;
strokeColor=#0078D4;flowAnimation=1;html=1;fontSize=9;
```

### Module Parameter / `ip_pool_id` (dotted grey)
Use for module input arguments like `ip_pool_id`, `hub_id`, etc.

```
rounded=1;orthogonalLoop=1;jettySize=auto;dashed=1;dashPattern=1 4;
endArrow=open;endFill=0;strokeColor=#999999;flowAnimation=1;html=1;fontSize=9;
```

### VNet Peering — Classic Hub-Spoke (bidirectional blue)

```
rounded=1;orthogonalLoop=1;jettySize=auto;endArrow=block;startArrow=block;
endFill=1;startFill=1;strokeColor=#0078D4;strokeWidth=2;flowAnimation=1;html=1;fontSize=9;
```

### Standard Data Flow (solid blue)

```
rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#0078D4;
strokeWidth=2;endArrow=block;endFill=1;flowAnimation=1;
```

### Protected Ingress (solid black)

```
rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#333333;
strokeWidth=2;endArrow=block;endFill=1;flowAnimation=1;
```

### Controlled Egress (dashed orange)

```
rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#E65100;
strokeWidth=2;dashed=1;dashPattern=8 4;endArrow=open;endFill=0;flowAnimation=1;
```

### Encrypted / VPN Tunnel (dashed red bidirectional)

```
rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#DA291C;
strokeWidth=2;dashed=1;dashPattern=8 4;startArrow=block;startFill=1;
endArrow=block;endFill=1;flowAnimation=1;
```

### BGP / Routing (dashed green)

```
rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#4CAF50;
strokeWidth=1;dashed=1;endArrow=open;endFill=0;flowAnimation=1;
```

### VNet Peering Detail (dotted grey diamond)

```
rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#808080;
strokeWidth=1;dashed=1;dashPattern=4 4;startArrow=diamond;startFill=0;
endArrow=diamond;endFill=0;flowAnimation=1;
```

### Management (thin grey)

```
rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#9E9E9E;
strokeWidth=1;endArrow=open;endFill=0;flowAnimation=1;
```

---

## Quick Decision Guide

| Relationship | Style to use |
|-------------|--------------|
| Hub ↔ Spoke VNet (vHubConnection or peering) | Hub ↔ Spoke VNet |
| On-prem to VPN/ER gateway | On-Premises → VPN/ER Gateway |
| Resource `.id` attribute reference | Property Reference |
| Module input argument (`ip_pool_id`, etc.) | Module Parameter |
| Internet ingress through firewall | Protected Ingress |
| Managed outbound traffic to internet | Controlled Egress |
| IPSec / VPN encrypted link | Encrypted / VPN Tunnel |
| BGP route propagation | BGP / Routing |
| Management plane access | Management |
