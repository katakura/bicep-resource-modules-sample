# bicep-resource-modules-sample
Sample code for Azure ResourceModules (https://github.com/Azure/ResourceModules)

## Steps

### create any directory

```bash
$ mkdir ~/bicep-resource-modules
$ cd ~/bicep-resource-modules
```

### clone from ResourceModules

```bash
$ git clone git@github.com:Azure/ResourceModules.git
```

### clone from this repository

```bash
$ git clone git@github.com:katakura/bicep-resource-modules-sample.git
```

### login Azure subscription

```bash
$ az logout
$ az account clear
$ az login
$ az account set -s <your subscription id>
```

### deploy sample template

```bash
$ cd ~/bicep-resource-modules-sample
$ az deployment sub create -l japaneast --template-file main.bicep --parameters resourceGroupName=<target resource group name> adminPassword=<password>
```

### list created resources

```bash
$ az resource list -g 20220105-test-rg -o table
Name                  ResourceGroup     Location    Type                                     Status
--------------------  ----------------  ----------  ---------------------------------------  --------
testvm-nsg            20220105-test-rg  japaneast   Microsoft.Network/networkSecurityGroups
testvm-vnet           20220105-test-rg  japaneast   Microsoft.Network/virtualNetworks
testvm-vm-pip01       20220105-test-rg  japaneast   Microsoft.Network/publicIPAddresses
testvm-vm-nic01       20220105-test-rg  japaneast   Microsoft.Network/networkInterfaces
testvm-vm             20220105-test-rg  japaneast   Microsoft.Compute/virtualMachines
testvm-vm-disk-os-01  20220105-TEST-RG  japaneast   Microsoft.Compute/disks
```

### check public ip address and connect

```bash
$ az network public-ip show -g 20220105-test-rg -n testvm-vm-pip01 --query 'ipAddress' -o tsv
40.115.192.xx
$ ssh azureuser@40.115.192.xx
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-1022-azure x86_64)

(snip)

azureuser@testvm-vm:~$ 
```
