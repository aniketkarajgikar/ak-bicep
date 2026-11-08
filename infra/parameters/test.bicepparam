using '../main.bicep'

param workloadName = 'akdemo'
param environment = 'test'
param location = 'eastus2'
param storageSku = 'Standard_ZRS'
param containerNames = ['data']
param tags = {
  costCenter: 'CC-0000'
  owner: 'platform-team'
}
