# AZ-700 Networking Lab (Bicep)

This repository is a compact Bicep scaffold for a personal AZ-700 networking lab in your tenant.

Default resources
- Resource group: `rg-az700-lab`
- Location: `westeurope`

Feature flags
-------------
Feature switches are exposed in `main.bicep` so you can enable or disable components as needed (hub-spoke network, VPN Gateway, Azure Firewall, Private Endpoint, DNS Resolver, Application Gateway, Load Balancer, Service Endpoints, Front Door, Traffic Manager).

Quick start (PowerShell / Azure CLI)
----------------------------------

1) Sign in

```powershell
az login
```

2) Create the resource group

```powershell
az group create -n rg-az700-lab -l westeurope
```

3) Deploy (two-step recommended)

Step 1 — deploy the network (hub + spokes):

```powershell
az deployment group create -g rg-az700-lab --template-file main-network.bicep
```

This deployment outputs `hubVnetId`, `spokeAppVnetId`, `spokeDataVnetId` and `spokeDataSubnetName`.

Step 2 — deploy infrastructure (use the network outputs as parameters):

```powershell
az deployment group create -g rg-az700-lab --template-file main-infra.bicep --parameters \
  hubVnetId='<hubVnetId-from-step1>' \
  spokeDataVnetId='<spokeDataVnetId-from-step1>' \
  spokeDataSubnetName='data' \
  enablePrivateEndpoint=true enableDnsResolver=true
```

If you prefer a single-step deployment, `main.bicep` is still available and supports the same feature flags — note it may show linter warnings when reading outputs from conditionally-declared modules.

Cost tips
---------
- Disable expensive components with the feature flags when not required.
- Use Basic/Standard SKUs and low capacity counts (App GW capacity = 1 in the templates).
- Delete the resource group when done to stop costs.

Subnet names (examples used in templates)
---------------------------------------
- Hub: `GatewaySubnet`, `AzureFirewallSubnet`, `dnsresolver`, `appgw-subnet`
- Spokes: `app` and `data`

Notes
-----
- Modules provide a working lab scaffold. For production use add NSGs, route tables, certificates and hardened defaults.
- API versions target recent non-preview releases (2024/2025 series where appropriate). You may see informational linter warnings (BCP081) for very new API versions; these are non-fatal.
