param vnetId string
param subnetName string

// Informational module: return the subnet id and a note
output subnetId string = '${vnetId}/subnets/${subnetName}'
output note string = 'If service endpoints are required, enable Microsoft.Storage on the subnet at creation time or via CLI.'
