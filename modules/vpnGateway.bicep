param location string
param hubVnetId string
param gatewaySubnetName string
param prefix string

var publicIpName = '${prefix}-vpn-pip'
var vnetGatewayName = '${prefix}-vpngw'

resource pip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIpName
  location: location
  sku: { name: 'Basic' }
  properties: { publicIPAllocationMethod: 'Dynamic' }
}

resource vnetGateway 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  name: vnetGatewayName
  location: location
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    sku: { name: 'VpnGw1', tier: 'VpnGw1' }
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: { id: '${hubVnetId}/subnets/${gatewaySubnetName}' }
          publicIPAddress: { id: pip.id }
        }
      }
    ]
  }
  // implicit dependency on pip via publicIPAddress id; explicit dependsOn not required
}

output publicIpAddress string = pip.properties.ipAddress
output gatewayId string = vnetGateway.id
