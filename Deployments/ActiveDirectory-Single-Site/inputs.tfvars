ResourceGroupName1        = "ActiveDirectory-Single-Site-TF-VA2"
Location1                 = "usgovvirginia"
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
KeyVaultName              = "TerraForm-KeyVault1"
KeyVaultResourceId        = "/subscriptions/04e9b759-cdf3-417a-bd09-77b8f857da6c/resourceGroups/Terraform-Infra/providers/Microsoft.KeyVault/vaults/TerraForm-KeyVault1"
