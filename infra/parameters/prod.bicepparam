using '../main.bicep'

param workloadName = 'akdemo'
param environment = 'prod'
param location = 'eastus2'
param storageSku = 'Standard_GZRS'
param containerNames = ['data']
param tags = {
  costCenter: 'CC-0000'
  owner: 'platform-team'
  criticality: 'high'
}
