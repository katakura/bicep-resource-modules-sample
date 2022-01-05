targetScope = 'subscription'

// parameters

param baseName string = 'testvm'

param resourceGroupName string = 'resource-module-test-rg'

param location string = deployment().location

@secure()
param adminPassword string

param adminUsername string = 'azureuser'

param vNetAddressPrefixes array = [
  '192.168.0.0/16'
]

param subnets array = [
  {
    name: 'default-snet'
    addressPrefix: '192.168.0.0/24'
  }
  {
    name: 'private-snet'
    addressPrefix: '192.168.1.0/24'
  }
]

// variables

var vmName = '${baseName}-vm'
var nsgName = '${baseName}-nsg'
var vnetName = '${baseName}-vnet'
var vm_nsg = [
  {
    name: 'AllowSshInbound'
    properties: {
      description: 'Allow inbound access on TCP 22'
      protocol: 'TCP'
      sourcePortRange: '*'
      destinationPortRange: '22'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
      sourcePortRanges: []
      destinationPortRanges: []
      sourceAddressPrefixes: []
      destinationAddressPrefixes: []
    }
  }
]

// Resource Group
module rg '../ResourceModules/arm/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: 'module-rg'
  params: {
    name: resourceGroupName
    location: location
  }
}

// Network Security Group
module nsg '../ResourceModules/arm/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: 'module-nsg'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: nsgName
    networkSecurityGroupSecurityRules: vm_nsg
  }
  dependsOn: [
    rg
  ]
}

// Virtual Network
module vnet '../ResourceModules/arm/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  name: 'module-vnet'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: vnetName
    addressPrefixes: vNetAddressPrefixes
    subnets: subnets
  }
  dependsOn: [
    nsg
    rg
  ]
}

// Virtual Machine
module vm '../ResourceModules/arm/Microsoft.Compute/virtualMachines/deploy.bicep' = {
  name: 'module_vm'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: vmName
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: 'Standard_B2s'
    osType: 'Linux'
    imageReference: {
      publisher: 'Canonical'
      offer: '0001-com-ubuntu-server-focal'
      sku: '20_04-lts'
      version: 'latest'
    }
    nicConfigurations: [
      {
        nsgId: nsg.outputs.networkSecurityGroupResourceId
        nicSuffix: '-nic01'
        ipConfigurations: [
          {
            name: 'ipconfig01'
            subnetId: vnet.outputs.subnetResourceIds[0]
            pipConfiguration: {
              publicIpNameSuffix: '-pip01'
              skuName: 'Basic'
            }
          }
        ]
      }
    ]
    osDisk: {
      createOption: 'fromImage'
      diskSizeGB: 30
      managedDisk: {
        storageAccountType: 'StandardSSD_LRS'
      }
    }
  }
}
