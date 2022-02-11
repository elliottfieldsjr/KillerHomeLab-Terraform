terraform {
  backend "azurerm" {
    resource_group_name  = "TerraForm-Infra"
    storage_account_name = "khlterraform"
    container_name       = "terraformstate"
    key                  = "ad3.tfstate"
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
}

data "azurerm_key_vault_secret" "main" {
  name         = var.adminPasswordName
  key_vault_id = var.KeyVaultResourceId
}

data "azurerm_virtual_network" "vnet1" {
  name = local.VNet1.vnet1Name
  resource_group_name = var.ResourceGroupName1
}

data "azurerm_subnet" "subnet1" {
  name = local.VNet1.vnet1subnet1Name
  virtual_network_name = local.VNet1.vnet1Name
  resource_group_name = var.ResourceGroupName1
  
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
  subnet            = data.azurerm_subnet.subnet1.id
  adminUsername     = var.adminUsername
  adminPassword     = data.azurerm_key_vault_secret.main.value
}

module "PromoteDC1" {
  source                    = "./Modules/FIRSTDC"
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
    module.deployDC1
  ]

}

resource "azurerm_virtual_network_dns_servers" "UpdateVNet1_1" {
  virtual_network_id = data.azurerm_virtual_network.vnet1.id
  dns_servers        = [local.dc1IP]
  depends_on = [
    module.PromoteDC1
  ]  
}

output "adminUserName" {
  value = var.adminUsername
}