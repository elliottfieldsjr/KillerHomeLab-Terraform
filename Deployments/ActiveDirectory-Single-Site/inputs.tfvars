ResourceGroupName1        = "ActiveDirectory-Single-Site-TF-EU6"
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
KeyVaultName              = "KHL-Terraform-KeyVault1"
KeyVaultResourceId        = "/subscriptions/6bdf26a8-4bbb-4fcf-be0a-7f3f912e7705/resourceGroups/TerraForm-Infra/providers/Microsoft.KeyVault/vaults/KHL-Terraform-KeyVault1"
