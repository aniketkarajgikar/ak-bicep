// ---------------------------------------------------------------------------
// Entry point – subscription scope.
// Creates a resource group and a storage account inside it.
// ---------------------------------------------------------------------------
targetScope = 'subscription'

@description('Short workload / application name used in resource names (2-10 lowercase alphanumerics).')
@minLength(2)
@maxLength(10)
param workloadName string

@description('Deployment environment.')
@allowed(['dev', 'test', 'prod'])
param environment string

@description('Azure region for all resources.')
param location string = deployment().location

@description('Storage account SKU.')
@allowed(['Standard_LRS', 'Standard_ZRS', 'Standard_GRS', 'Standard_RAGRS', 'Standard_GZRS'])
param storageSku string = 'Standard_LRS'

@description('Blob containers to create in the storage account.')
param containerNames array = []

@description('Public IPs / CIDRs allowed through the storage firewall. Empty = deny all public access except trusted Azure services.')
param allowedIpRanges array = []

@description('Tags applied to every resource. Merged with deployment-generated tags.')
param tags object = {}

// ----- Naming ---------------------------------------------------------------
var regionShort = {
  eastus: 'eus'
  eastus2: 'eus2'
  westus2: 'wus2'
  westeurope: 'weu'
  northeurope: 'neu'
  uksouth: 'uks'
  centralindia: 'cin'
  southindia: 'sin'
}
var locShort = regionShort[?location] ?? take(location, 4)
var resourceGroupName = 'rg-${workloadName}-${environment}-${locShort}'
// Storage names: 3-24 chars, lowercase alphanumerics, globally unique.
var storageAccountName = take('st${workloadName}${environment}${locShort}${uniqueString(subscription().subscriptionId, resourceGroupName)}', 24)

var commonTags = union(tags, {
  workload: workloadName
  environment: environment
  managedBy: 'bicep'
})

// ----- Resources ------------------------------------------------------------
module rg 'modules/resource-group/main.bicep' = {
  name: 'deploy-${resourceGroupName}'
  params: {
    name: resourceGroupName
    location: location
    tags: commonTags
  }
}

module storage 'modules/storage-account/main.bicep' = {
  name: 'deploy-${storageAccountName}'
  scope: resourceGroup(resourceGroupName)
  dependsOn: [rg]
  params: {
    name: storageAccountName
    location: location
    skuName: storageSku
    containerNames: containerNames
    tags: commonTags
  }
}

// ----- Outputs --------------------------------------------------------------
output resourceGroupName string = rg.outputs.name
output resourceGroupId string = rg.outputs.id
output storageAccountName string = storage.outputs.name
output storageAccountId string = storage.outputs.id
output blobEndpoint string = storage.outputs.primaryBlobEndpoint
