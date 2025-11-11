param location string
param prefix string
param vnetId string
param subnetName string

var publicIpName = '${prefix}-appgw-pip'
var appGwName = '${prefix}-appgw'
var appGwResId = resourceId('Microsoft.Network/applicationGateways', appGwName)

resource pip 'Microsoft.Network/publicIPAddresses@2024-10-01' = {
  name: publicIpName
  location: location
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Dynamic' }
}

resource appgw 'Microsoft.Network/applicationGateways@2024-10-01' = {
  name: appGwName
  location: location
  properties: {
    sku: { name: 'Standard_v2', tier: 'Standard_v2', capacity: 1 }
    gatewayIPConfigurations: [ { name: 'appGwIpConfig', properties: { subnet: { id: '${vnetId}/subnets/${subnetName}' } } } ]
    frontendIPConfigurations: [ { name: 'appGwFrontend', properties: { publicIPAddress: { id: pip.id } } } ]
    frontendPorts: [ { name: 'port80', properties: { port: 80 } } ]
    backendAddressPools: [ { name: 'backendPool' } ]
    httpListeners: [
      {
        name: 'listener'
        properties: {
          frontendIPConfiguration: { id: '${appGwResId}/frontendIPConfigurations/appGwFrontend' }
          frontendPort: { id: '${appGwResId}/frontendPorts/port80' }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: { id: '${appGwResId}/httpListeners/listener' }
          backendAddressPool: { id: '${appGwResId}/backendAddressPools/backendPool' }
        }
      }
    ]
  }
  // implicit dependency on pip via publicIPAddress id; explicit dependsOn not required
}

output frontendPublicIp string = pip.properties.ipAddress
output appGatewayId string = appgw.id
