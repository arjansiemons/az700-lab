param location string
param hubVnetId string
param firewallSubnetName string
param prefix string

var pipName = '${prefix}-azfw-pip'
var fwName = '${prefix}-azfw'

resource pip 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: pipName
  location: location
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Static' }
}

resource azfw 'Microsoft.Network/azureFirewalls@2023-11-01' = {
  name: fwName
  location: location
  properties: {
    sku: { name: 'AZFW_VNet', tier: 'Standard' }
    ipConfigurations: [
      {
        name: 'fwConfig'
        properties: {
          subnet: { id: '${hubVnetId}/subnets/${firewallSubnetName}' }
          publicIPAddress: { id: pip.id }
        }
      }
    ]
  }
}

output firewallId string = azfw.id
output firewallPublicIp string = pip.properties.ipAddress
