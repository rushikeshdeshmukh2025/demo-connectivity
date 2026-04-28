---
name: private-endpoint-layout
description: "Apply the left-to-right Private Endpoint column layout when >2 PEs are detected, and emit the Private DNS Zone reference table. USE WHEN: private endpoints detected, PE column, private link, DNS zone table, snet-pep layout."
---

# Private Endpoint Layout Pattern

Apply this layout **only when > 2 Private Endpoints** are detected in the Terraform workspace.

## Left → Right Zone Arrangement

```
[RG Network zone]  [Workload RGs zone]  [snet-pep column]  [Private Services zone]
(VNet, subnets,    (services,            (PE icons,          (target service icons)
 route tables)      monitoring)           stacked vertically)
```

## snet-pep — Tall Vertical Column

- PE icons stacked vertically, **one per row**, **80 px apart**.
- Each PE icon uses the `networking/Private_Endpoint.svg` icon from `azure-icon-library`.
- Parent: the `snet-pep` subnet container.

## Private Services Container

- Positioned directly to the **right** of `snet-pep`.
- Contains **only** service icons that have at least one Private Endpoint.
- Each PE connects to its matching service icon with a short horizontal arrow (standard data flow edge — see `drawio-edge-styles`).

### Container Style

```
rounded=1;arcSize=5;fillColor=#DAE8FC;strokeColor=#0078D4;strokeWidth=1;
container=1;collapsible=0;recursiveResize=0;html=1;whiteSpace=wrap;
verticalAlign=top;fontStyle=1;fontSize=11;fontColor=#1A237E;spacingTop=4;
spacingLeft=8;
```

## Dual-Icon Pattern

Services with PEs appear in **two places**:

1. **Private Services container** (far right) — shows PE → Service relationship.
2. **Actual Resource Group** (centre) — shows ownership and data-flow edges.

No cross-diagram edge between the two icons is needed.

---

## Private DNS Zone Reference Table

When PEs are present, emit a reference table **outside** the subscription container (positioned below or to the right of the diagram).

### Table Columns

| Column | Description |
|--------|-------------|
| **Service** | Azure service name |
| **Private DNS Zone** | `privatelink.*` FQDN |
| **Subresource** | groupId (e.g. `account`, `blob`, `vault`) |
| **Private IP** | From PE subnet CIDR, or `<assigned>` |
| **Public FQDN** | Public endpoint the private zone overrides |

### Common Mappings

| Service | Private DNS Zone | Subresource |
|---------|-----------------|-------------|
| Azure OpenAI | `privatelink.openai.azure.com` | `account` |
| Cosmos DB (NoSQL) | `privatelink.documents.azure.com` | `Sql` |
| AI Search | `privatelink.search.windows.net` | `searchService` |
| Storage (Blob) | `privatelink.blob.core.windows.net` | `blob` |
| Storage (Table) | `privatelink.table.core.windows.net` | `table` |
| Key Vault | `privatelink.vaultcore.azure.net` | `vault` |
| App Service | `privatelink.azurewebsites.net` | `sites` |
| SQL Database | `privatelink.database.windows.net` | `sqlServer` |
| ACR | `privatelink.azurecr.io` | `registry` |

### Table Cell Style

```
shape=table;startSize=30;container=1;collapsible=0;childLayout=tableLayout;
fixedRows=1;rowLines=1;fontStyle=1;align=center;resizable=0;html=1;
whiteSpace=wrap;fontSize=9;fillColor=#FAFAFA;strokeColor=#BDBDBD;fontColor=#424242;
```
