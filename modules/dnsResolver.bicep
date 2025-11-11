param location string
param prefix string
param vnetId string
param subnetName string
param forwarders array = []

var dnsResolverName = '${prefix}-dnsr'
var outboundEndpointName = '${prefix}-dnsr-out'
var rulesetName = '${prefix}-dnsr-ruleset'

resource dnsResolver 'Microsoft.Network/dnsResolvers@2025-05-01' = {
  name: dnsResolverName
  location: location
  properties: {
    virtualNetwork: { id: vnetId }
  }
}

resource outboundEndpoint 'Microsoft.Network/dnsResolvers/outboundEndpoints@2025-05-01' = {
  parent: dnsResolver
  name: outboundEndpointName
  location: location
  properties: {
    subnet: { id: '${vnetId}/subnets/${subnetName}' }
  }
}

resource ruleset 'Microsoft.Network/dnsForwardingRulesets@2025-05-01' = {
  name: rulesetName
  location: location
  properties: {
    // Associate the outbound endpoint(s) so the ruleset is linked to the resolver
    dnsResolverOutboundEndpoints: [ { id: outboundEndpoint.id } ]
  }
}

// Create a forwardingRules child for each configured forwarder.
// The provider exposes 'dnsForwardingRulesets/forwardingRules' as the child resource type.
resource forwardingRules 'Microsoft.Network/dnsForwardingRulesets/forwardingRules@2025-05-01' = [for f in forwarders: {
  name: f.name
  parent: ruleset
  properties: {
    domainName: f.domainName
    targetDnsServers: [ { ipAddress: f.ipAddress } ]
  }
}]

output dnsResolverId string = dnsResolver.id
output outboundEndpointId string = outboundEndpoint.id
output rulesetId string = ruleset.id
