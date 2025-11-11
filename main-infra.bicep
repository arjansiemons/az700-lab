param location string = 'westeurope'
param prefix string = 'az700lab'

// Inputs from network deployment
param hubVnetId string
param spokeDataVnetId string
param spokeDataSubnetName string

// Optional forwarding rules for DNS resolver
param forwarders array = []

// Feature switches
param enableVpnGateway bool = false
param enableAzureFirewall bool = false
param enablePrivateEndpoint bool = false
param enableDnsResolver bool = false
param enableAppGateway bool = false
param enableLoadBalancer bool = false
param enableServiceEndpoint bool = false
param enableFrontDoor bool = false
param enableTrafficManager bool = false

// VPN Gateway
module vpnGateway 'modules/vpnGateway.bicep' = if (enableVpnGateway) {
  name: 'vpnGateway'
  params: {
    location: location
    hubVnetId: hubVnetId
    gatewaySubnetName: 'GatewaySubnet'
    prefix: prefix
  }
}

// Azure Firewall
module azureFirewall 'modules/azureFirewall.bicep' = if (enableAzureFirewall) {
  name: 'azureFirewall'
  params: {
    location: location
    hubVnetId: hubVnetId
    firewallSubnetName: 'AzureFirewallSubnet'
    prefix: prefix
  }
}

// Private Endpoint + Private DNS Zone
module privateEndpoint 'modules/privateEndpoint.bicep' = if (enablePrivateEndpoint) {
  name: 'privateEndpoint'
  params: {
    location: location
    prefix: prefix
    vnetId: spokeDataVnetId
    subnetName: spokeDataSubnetName
  }
}

// DNS Private Resolver
module dnsResolver 'modules/dnsResolver.bicep' = if (enableDnsResolver) {
  name: 'dnsResolver'
  params: {
    location: location
    prefix: prefix
    vnetId: hubVnetId
    subnetName: 'dnsresolver'
    forwarders: forwarders
  }
}

// App Gateway
module appGateway 'modules/appGateway.bicep' = if (enableAppGateway) {
  name: 'appGateway'
  params: {
    location: location
    prefix: prefix
    vnetId: hubVnetId
    subnetName: 'appgw-subnet'
  }
}

// Load Balancer
module loadBalancer 'modules/loadBalancer.bicep' = if (enableLoadBalancer) {
  name: 'loadBalancer'
  params: {
    location: location
    prefix: prefix
  }
}

// Service Endpoint info
module serviceEndpoint 'modules/serviceEndpoint.bicep' = if (enableServiceEndpoint) {
  name: 'serviceEndpoint'
  params: {
    vnetId: spokeDataVnetId
    subnetName: spokeDataSubnetName
  }
}

// Front Door
module frontDoor 'modules/frontDoor.bicep' = if (enableFrontDoor) {
  name: 'frontDoor'
  params: {
    location: location
    prefix: prefix
  }
}

// Traffic Manager
module trafficManager 'modules/trafficManager.bicep' = if (enableTrafficManager) {
  name: 'trafficManager'
  params: {
    tmLocation: location
    prefix: prefix
  }
}


