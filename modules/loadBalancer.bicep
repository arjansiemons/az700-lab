param location string
param prefix string

var pipName = '${prefix}-lb-pip'
var lbName = '${prefix}-lb'
var lbResId = resourceId('Microsoft.Network/loadBalancers', lbName)

resource pip 'Microsoft.Network/publicIPAddresses@2024-10-01' = {
  name: pipName
  location: location
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Static' }
}

resource lb 'Microsoft.Network/loadBalancers@2024-10-01' = {
  name: lbName
  location: location
  sku: { name: 'Standard' }
  properties: {
    frontendIPConfigurations: [ { name: 'LoadBalancerFrontEnd', properties: { publicIPAddress: { id: pip.id } } } ]
    backendAddressPools: [ { name: 'BackendPool' } ]
    loadBalancingRules: [
      {
        name: 'ruleHTTP'
        properties: {
          frontendIPConfiguration: { id: '${lbResId}/frontendIPConfigurations/LoadBalancerFrontEnd' }
          frontendPort: 80
          backendPort: 80
          protocol: 'Tcp'
          idleTimeoutInMinutes: 4
          backendAddressPool: { id: '${lbResId}/backendAddressPools/BackendPool' }
        }
      }
    ]
  }
  // implicit dependency on pip via publicIPAddress id; explicit dependsOn not required
}

output publicIp string = pip.properties.ipAddress
output loadBalancerId string = lb.id
