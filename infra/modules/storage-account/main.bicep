targetScope = 'resourceGroup'

@description('Storage account name (3-24 lowercase alphanumerics).')
@minLength(3)
@maxLength(24)
param name string

@description('Location.')
param location string = resourceGroup().location

@description('SKU name.')
param skuName string = 'Standard_LRS'

@description('Blob containers to create.')
param containerNames array = []

@description('IP ranges allowed through the firewall.')
param allowedIpRanges array = []

@description('Soft-delete retention in days for blobs and containers.')
@minValue(1)
@maxValue(365)
param softDeleteDays int = 7

@description('Tags to apply.')
param tags object = {}

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: skuName
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false // Entra ID (RBAC) auth only
    defaultToOAuthAuthentication: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Enabled' // restricted by firewall below; switch to Disabled when using private endpoints
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipRules: [for ip in allowedIpRanges: {
        value: ip
        action: 'Allow'
      }]
    }
    encryption: {
      requireInfrastructureEncryption: true
      services: {
        blob: { enabled: true }
        file: { enabled: true }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storage
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: softDeleteDays
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: softDeleteDays
    }
  }
}

resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = [for c in containerNames: {
  parent: blobService
  name: c
  properties: {
    publicAccess: 'None'
  }
}]

output name string = storage.name
output id string = storage.id
output primaryBlobEndpoint string = storage.properties.primaryEndpoints.blob
