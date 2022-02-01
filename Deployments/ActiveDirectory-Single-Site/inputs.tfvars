ResourceGroupName1        = "ActiveDirectory-Single-Site-TF-eastus"
Location1                 = "eastus"
TimeZone1                 = "Eastern Standard Time"
adminUsername             = "dom-admin"
adminPasswordName         = "adminPassword"
WindowsServerLicenseType  = "Windows_Server"
WindowsClientLicenseType  = "Windows_Client"
NamingConvention          = "khl"
SubDNSDomain              = ""
SubDNSBaseDN              = ""
NetBiosDomain             = "killerhomelab"
InternalDomain            = "killerhomelab"
InternalTLD               = "com"
vnet1ID                   = "10.1"
DC1OSVersion              = "2022-Datacenter"
dc1vmsize                 = "Standard_D2s_v3"
artifactsLocation         = "https://raw.githubusercontent.com/elliottfieldsjr/KillerHomeLab-Terraform/main/Deployments/ActiveDirectory-Single-Site/Modules/Compute/VirtualMachines/"
artifactsLocationSasToken = ""
KeyVaultName              = "KHL-TerraForm-KeyVault1"
KeyVaultResourceId        = "/subscriptions/7d42fc1c-e7b8-49ec-85c4-403308e76d0b/resourceGroups/TerraForm-Intra/providers/Microsoft.KeyVault/vaults/KHL-Terraform-KeyVault"
