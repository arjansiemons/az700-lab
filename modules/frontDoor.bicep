param location string
param prefix string

var fdName = '${prefix}-fdoor'

// Lightweight Front Door scaffold (minimal, low-cost placeholder)
resource frontDoor 'Microsoft.Network/frontDoors@2021-06-01' = {
  name: fdName
  location: location
  properties: {
    friendlyName: fdName
    frontendEndpoints: []
    backendPools: []
    routingRules: []
  }
}

output frontDoorId string = frontDoor.id
