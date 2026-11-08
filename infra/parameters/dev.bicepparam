using '../main.bicep'

param workloadName = 'akbicep12'
param environment = 'dev'
param location = 'eastus2'
param storageSku = 'Standard_LRS'
param containerNames = ['data']
param allowedIpRanges = []
param tags = {
  costCenter: 'CC-0000'
  owner: 'platform-team'
}
