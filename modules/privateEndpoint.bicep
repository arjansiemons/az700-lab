param location string
param prefix string
param vnetId string
param subnetName string

// Storage account name must be 3-24 lowercase letters/numbers
var storageName = toLower('${prefix}st${uniqueString(resourceGroup().id)}')
var storageNameTrimmed = substring(storageName, 0, min(length(storageName), 24))
var privateEndpointName = '${prefix}-pe-storage'
var privateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageNameTrimmed
  location: location
  sku: { name: 'Standard_V2' }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: { defaultAction: 'Deny', bypass: 'AzureServices' }
  }
}

resource pe 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: { id: '${vnetId}/subnets/${subnetName}' }
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-pls'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [ 'blob' ]
          requestMessage: 'Private endpoint for storage'
        }
      }
    ]
  }
  // Ensure storage exists first by implicit dependency via privateLinkServiceId
}

resource pzone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
}

resource pdnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: pzone
  name: '${prefix}-link'
  properties: {
    virtualNetwork: { id: vnetId }
    registrationEnabled: false
  }
}

output storageAccountName string = storage.name
output privateEndpointId string = pe.id
output privateDnsZone string = pzone.name
