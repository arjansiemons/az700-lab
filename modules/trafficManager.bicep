param tmLocation string = 'global'
param prefix string

var tmName = '${prefix}-tm'

resource tmProfile 'Microsoft.Network/trafficManagerProfiles@2022-04-01' = {
  name: tmName
  location: tmLocation
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Performance'
    dnsConfig: { relativeName: tmName, ttl: 30 }
    monitorConfig: {
      protocol: 'HTTP'
      port: 80
      path: '/'
    }
    endpoints: []
  }
}

output trafficManagerId string = tmProfile.id
