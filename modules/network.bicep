param prefix string
param location string
param enableServiceEndpoint bool = false

var hubVnetName = '${prefix}-hub-vnet'
var spokeAppVnetName = '${prefix}-spoke-app-vnet'
var spokeDataVnetName = '${prefix}-spoke-data-vnet'

resource hubVnet 'Microsoft.Network/virtualNetworks@2024-10-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ '10.0.0.0/16' ] }
    subnets: [
      { name: 'GatewaySubnet', properties: { addressPrefix: '10.0.1.0/27' } }
      { name: 'AzureFirewallSubnet', properties: { addressPrefix: '10.0.2.0/26' } }
      { name: 'dnsresolver', properties: { addressPrefix: '10.0.3.0/28' } }
      { name: 'appgw-subnet', properties: { addressPrefix: '10.0.4.0/26' } }
    ]
  }
}

resource spokeAppVnet 'Microsoft.Network/virtualNetworks@2024-10-01' = {
  name: spokeAppVnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ '10.1.0.0/16' ] }
    subnets: [ { name: 'app', properties: { addressPrefix: '10.1.1.0/24' } } ]
  }
}

resource spokeDataVnet 'Microsoft.Network/virtualNetworks@2024-10-01' = {
  name: spokeDataVnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ '10.2.0.0/16' ] }
    subnets: [
      {
        name: 'data'
        properties: {
          addressPrefix: '10.2.2.0/24'
          serviceEndpoints: enableServiceEndpoint ? [ { service: 'Microsoft.Storage' } ] : []
        }
      }
    ]
  }
}

// Peerings: Hub <-> Spoke App
resource hubToSpokeAppPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-10-01' = {
  parent: hubVnet
  name: 'Hub-to-SpokeApp'
  properties: {
    remoteVirtualNetwork: { id: spokeAppVnet.id }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
  }
}

resource spokeAppToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-10-01' = {
  parent: spokeAppVnet
  name: 'SpokeApp-to-Hub'
  properties: {
    remoteVirtualNetwork: { id: hubVnet.id }
    allowVirtualNetworkAccess: true
    useRemoteGateways: false
  }
}

// Peerings: Hub <-> Spoke Data
resource hubToSpokeDataPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-10-01' = {
  parent: hubVnet
  name: 'Hub-to-SpokeData'
  properties: {
    remoteVirtualNetwork: { id: spokeDataVnet.id }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
  }
}

resource spokeDataToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-10-01' = {
  parent: spokeDataVnet
  name: 'SpokeData-to-Hub'
  properties: {
    remoteVirtualNetwork: { id: hubVnet.id }
    allowVirtualNetworkAccess: true
    useRemoteGateways: false
  }
}

output hubVnetId string = hubVnet.id
output spokeAppVnetId string = spokeAppVnet.id
output spokeDataVnetId string = spokeDataVnet.id
output spokeDataSubnetName string = 'data'
