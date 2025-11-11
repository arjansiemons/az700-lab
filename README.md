# AZ-700 Networking Lab (Bicep)

Deze repository is een compacte Bicep-scaffold voor een persoonlijke AZ-700 lab in je tenant.

Default resources
- Resource group: rg-az700-lab
- Location: westeurope

Feature flags zijn in `main.bicep` opgenomen zodat je onderdelen optioneel kunt aan/uit zetten (hub-spoke, VPN GW, Azure Firewall, Private Endpoint, DNS Resolver, App GW, Load Balancer, Service Endpoints, Front Door, Traffic Manager).

Snelstart (PowerShell / Azure CLI)

1) Login

```powershell
az login
```

2) Maak resource group

```powershell
az group create -n rg-az700-lab -l westeurope
```

3) Deploy (two-step recommended)

Step 1 — deploy network (hub + spokes):

```powershell
az deployment group create -g rg-az700-lab --template-file main-network.bicep
```

This outputs `hubVnetId`, `spokeAppVnetId`, `spokeDataVnetId` and `spokeDataSubnetName`.

Step 2 — deploy infra (use the network outputs as parameters):

```powershell
az deployment group create -g rg-az700-lab --template-file main-infra.bicep --parameters \
  hubVnetId='<hubVnetId-from-step1>' \
  spokeDataVnetId='<spokeDataVnetId-from-step1>' \
  spokeDataSubnetName='data' \
  enablePrivateEndpoint=true enableDnsResolver=true
```

If you prefer a single-step (less recommended for cleaner dependency separation), `main.bicep` is still available and supports feature flags but may show some linter warnings due to conditional module outputs.

Opschonen

Gebruik het cleanup-script (WSL / Git Bash) of de Azure CLI rechtstreeks:

```bash
./cleanup.sh
# of (PowerShell)
az group delete -n rg-az700-lab --yes --no-wait
```

Kostentips
- Schakel dure onderdelen uit met de feature flags (Azure Firewall, App Gateway, VPN Gateway, Front Door, Load Balancer).
- Gebruik Basic/Standard SKUs zoals in de templates en zet capacity/instances laag (appgw capacity=1).
- Controleer public IPs en gateways na deploy; verwijder RG zodra je klaar bent.

Subnetnamen (examengericht)
- Hub: GatewaySubnet, AzureFirewallSubnet, dnsresolver, appgw-subnet
- Spokes: app en data

Opmerkingen
- De modules geven een werkende scaffold; voor productiescenario's moet je NSG's, routing, certificaten en backend resources toevoegen.
- API-versies zijn 2024-06-01 (of nieuwer waar relevant). Test en update indien Azure wijzigingen introduceert.
