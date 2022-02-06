terraform {
  backend "azurerm" {
    resource_group_name  = "TerraForm-Infra"
    storage_account_name = "khlterraform"
    container_name       = "terraformstate"
    key                  = "deployment4.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

variable "ResourceGroupName1" {
  type        = string
  description = "Resource Group 1 Name"
}

variable "TimeZone1" {
  type        = string
  description = "Time Zone or Region 1"
}

variable "adminUsername" {
  type        = string
  description = "Admin User Name"
}

variable "adminPasswordName" {
  type        = string
  sensitive   = true
  description = "Naming Convention for All Resources"
}

variable "WindowsServerLicenseType" {
  type        = string
  description = "Windows Server OS License Type"
}

variable "WindowsClientLicenseType" {
  type        = string
  description = "Windows Client OS License Type"
}

variable "NamingConvention" {
  type        = string
  description = "Naming Convention for All Resources"
}

variable "SubDNSDomain" {
  type        = string
  description = "Sub DNS Domain Name Example:  sub1. must include a DOT AT END"
}

variable "SubDNSBaseDN" {
  type        = string
  description = "Sub DNS BaseDN Example:  DC=sub2,DC=sub1, must include a DOT AT COMMA"
}

variable "NetBiosDomain" {
  type        = string
  description = "NetBios Domain Name"
}

variable "InternalDomain" {
  type        = string
  description = "Second-Level Domain"
}

variable "InternalTLD" {
  type        = string
  description = "Top-Level Domain"
}

variable "Location1" {
  type        = string
  description = "Resource Location"
}

variable "vnet1ID" {
  type        = string
  description = "VNet1 1st 2 Octets"
}

variable "DC1OSVersion" {
  type        = string
  description = "Domain Controller 1 VM Size"
}

variable "dc1vmsize" {
  type        = string
  description = "Domain Controller 1 VM Size"
}

variable "artifactsLocation" {
  type        = string
  description = "The location of resources, such as templates and DSC modules, that the template depends on"
}

variable "artifactsLocationSasToken" {
  type        = string
  sensitive   = true
  description = "The location of resources, such as templates and DSC modules, that the template depends on"
}

variable "KeyVaultName" {
  type        = string
  description = "Key Vault Name"
}

variable "KeyVaultResourceId" {
  type        = string
  description = "Key Vault Resource Id"
}

locals {
  StorageAccountType = "Standard_LRS"
  VNet1 = {

    vnet1Name                = "${var.NamingConvention}-VNet1"
    vnet1Prefix              = "${var.vnet1ID}.0.0/16"
    vnet1subnet1Name         = "${var.NamingConvention}-VNet1-Subnet1"
    vnet1subnet1Prefix       = "${var.vnet1ID}.1.0/24"
    vnet1subnet2Name         = "${var.NamingConvention}-VNet1-Subnet2"
    vnet1subnet2Prefix       = "${var.vnet1ID}.2.0/24"
    vnet1BastionsubnetPrefix = "${var.vnet1ID}.253.0/24"

  }
  dc1name            = "${var.NamingConvention}-dc-01"
  dc1IP              = "${var.vnet1ID}.1.101"
  DataDisk1Name      = "NTDS"
  InternalDomainName = format("%s%s%s%s", var.SubDNSDomain, var.InternalDomain, ".", var.InternalTLD)
  FirstDCModulesUrl = format("%s%s%s", var.artifactsLocation, "DSC/FIRSTDC.zip", var.artifactsLocationSasToken)
  RestartVMModulesUrl = format("%s%s%s", var.artifactsLocation, "DSC/RESTARTVM.zip", var.artifactsLocationSasToken)
}

data "azurerm_key_vault_secret" "main" {
  name         = var.adminPasswordName
  key_vault_id = var.KeyVaultResourceId
}

resource "azurerm_resource_group" "RG1" {
  name     = var.ResourceGroupName1
  location = var.Location1
}

module "deployVNet1" {
  source              = "./Modules/Network/VirtualNetwork"
  vnetName            = local.VNet1.vnet1Name
  vnetPrefix          = local.VNet1.vnet1Prefix
  subnet1Name         = local.VNet1.vnet1subnet1Name
  subnet1Prefix       = local.VNet1.vnet1subnet1Prefix
  subnet2Name         = local.VNet1.vnet1subnet2Name
  subnet2Prefix       = local.VNet1.vnet1subnet2Prefix
  BastionsubnetPrefix = local.VNet1.vnet1BastionsubnetPrefix
  Location            = var.Location1
  ResourceGroupName   = var.ResourceGroupName1
  depends_on = [
    azurerm_resource_group.RG1
  ]
}

module "deployBastionHost1" {
  source            = "./Modules/Network/BastionHost"
  vnetName          = local.VNet1.vnet1Name
  subnetID          = module.deployVNet1.subnet3ID
  Location          = var.Location1
  ResourceGroupName = var.ResourceGroupName1
  depends_on = [
    module.deployVNet1
  ]
}

module "deployDC1" {
  source            = "./Modules/Compute/VirtualMachines/1nic-2disk-vm"
  computerName      = local.dc1name
  computerIP        = local.dc1IP
  Publisher         = "MicrosoftWindowsServer"
  Offer             = "WindowsServer"
  OSVersion         = var.DC1OSVersion
  licenseType       = var.WindowsServerLicenseType
  DataDisk1Name     = local.DataDisk1Name
  vmsize            = var.dc1vmsize
  Location          = var.Location1
  ResourceGroupName = var.ResourceGroupName1
  subnet            = module.deployVNet1.subnet1ID
  adminUsername     = var.adminUsername
  adminPassword     = data.azurerm_key_vault_secret.main.value
  depends_on = [
    azurerm_resource_group.RG1,
    module.deployVNet1
  ]

}

module "PromoteDC1" {
  source                    = "./Modules/Compute/VirtualMachines/DSC/FIRSTDC"
  ResourceGroupName         = var.ResourceGroupName1
  computerName              = local.dc1name
  TimeZone                  = var.TimeZone1
  NetBiosDomain             = var.NetBiosDomain
  domainName                = local.InternalDomainName
  Location                  = var.Location1
  adminUsername             = var.adminUsername
  adminPassword             = data.azurerm_key_vault_secret.main.value
  vmID                      = module.deployDC1.vmID
  artifactsLocation         = var.artifactsLocation
  artifactsLocationSasToken = var.artifactsLocationSasToken
  depends_on = [
    azurerm_resource_group.RG1,
    module.deployDC1
  ]

}

resource "azurerm_virtual_machine_extension" "firstdc" {
  name                       = "Microsoft.Powershell.DSC"
  virtual_machine_id         = module.deployDC1.vmID
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.77"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
        "ModulesUrl": "${local.FirstDCModulesUrl}",
        "ConfigurationFunction" : "FIRSTDC.ps1\\FIRSTDC",
        "Properties": {
            "TimeZone": "${var.TimeZone}",
            "DomainName": "${local.InternalDomainName}}",
            "NetBiosDomain": "${var.NetBiosDomain}",            
            "AdminCreds": {
                "UserName": "${var.adminUsername}",
                "Password": "PrivateSettingsRef:AdminPassword"
            }
        }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Items":  {
        "AdminPassword": data.azurerm_key_vault_secret.main.value
        }
    }
PROTECTED_SETTINGS
}

resource "azurerm_virtual_network_dns_servers" "UpdateVNet1_1" {
  virtual_network_id = module.deployVNet1.vnetID
  dns_servers        = [local.dc1IP]
  depends_on = [
    azurerm_virtual_machine_extension.firstdc
  ]  
}

resource "azurerm_virtual_machine_extension" "restartvm" {
  name                       = "Microsoft.Powershell.DSC"
  virtual_machine_id         = module.deployDC1.vmID
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.77"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
        "ModulesUrl": "${local.RestartVMModulesUrl}",
        "ConfigurationFunction" : "RESTARTVM.ps1\\RESTARTVM",
        "Properties": {
        }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
    }
PROTECTED_SETTINGS
}

output "adminUserName" {
  value = var.adminUsername
}