param location string = 'westeurope'
param prefix string = 'az700lab'

// Feature switches (pass through to infra module)
param enableVpnGateway bool = false
param enableAzureFirewall bool = false
param enablePrivateEndpoint bool = false
param enableDnsResolver bool = false
param enableAppGateway bool = false
param enableLoadBalancer bool = false
param enableServiceEndpoint bool = false
param enableFrontDoor bool = false
param enableTrafficManager bool = false

// First deploy network (always). This ensures network outputs are available
// to the infra module without declaring conditional modules in this file.
module networkDeployment 'main-network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    prefix: prefix
  }
}

// Then deploy infrastructure modules (conditionally inside the infra template).
module infraDeployment 'main-infra.bicep' = {
  name: 'infraDeployment'
  params: {
    location: location
    prefix: prefix
    hubVnetId: networkDeployment.outputs.hubVnetId
    spokeDataVnetId: networkDeployment.outputs.spokeDataVnetId
    spokeDataSubnetName: networkDeployment.outputs.spokeDataSubnetName
    enableVpnGateway: enableVpnGateway
    enableAzureFirewall: enableAzureFirewall
    enablePrivateEndpoint: enablePrivateEndpoint
    enableDnsResolver: enableDnsResolver
    enableAppGateway: enableAppGateway
    enableLoadBalancer: enableLoadBalancer
    enableServiceEndpoint: enableServiceEndpoint
    enableFrontDoor: enableFrontDoor
    enableTrafficManager: enableTrafficManager
  }
}

// Export network outputs only. Infra outputs are handled by the infra module
// and can be added there if you want them surfaced from the top-level.
output hubVnetId string = networkDeployment.outputs.hubVnetId
output spokeAppVnetId string = networkDeployment.outputs.spokeAppVnetId
output spokeDataVnetId string = networkDeployment.outputs.spokeDataVnetId
output spokeDataSubnetName string = networkDeployment.outputs.spokeDataSubnetName
