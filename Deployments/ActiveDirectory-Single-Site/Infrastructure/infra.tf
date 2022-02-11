terraform {
  backend "azurerm" {
    resource_group_name  = "TerraForm-Infra"
    storage_account_name = "khlterraform"
    container_name       = "terraformstate"
    key                  = "infra3.tfstate"
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

variable "NamingConvention" {
  type        = string
  description = "Naming Convention for All Resources"
}

variable "Location1" {
  type        = string
  description = "Resource Location"
}

variable "vnet1ID" {
  type        = string
  description = "VNet1 1st 2 Octets"
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