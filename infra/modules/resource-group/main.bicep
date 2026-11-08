targetScope = 'subscription'

@description('Resource group name.')
param name string

@description('Resource group location.')
param location string

@description('Tags to apply.')
param tags object = {}

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: name
  location: location
  tags: tags
}

output name string = rg.name
output id string = rg.id
