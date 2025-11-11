param location string = 'westeurope'
param prefix string = 'az700lab'

// Deploy only network (hub + spokes)
module network 'modules/network.bicep' = {
  name: 'network'
  params: {
    prefix: prefix
    location: location
    enableServiceEndpoint: false
  }
}

output hubVnetId string = network.outputs.hubVnetId
output spokeAppVnetId string = network.outputs.spokeAppVnetId
output spokeDataVnetId string = network.outputs.spokeDataVnetId
output spokeDataSubnetName string = network.outputs.spokeDataSubnetName
