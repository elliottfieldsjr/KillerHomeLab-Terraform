terraform {
  backend "azurerm" {
    resource_group_name  = "TerraForm-Infra"
    storage_account_name = "khlterraform"
    container_name       = "terraformstate"
    key                  = "restartdc1.tfstate"
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

variable "artifactsLocation" {
  type        = string
  description = "The location of resources, such as templates and DSC modules, that the template depends on"
}

variable "artifactsLocationSasToken" {
  type        = string
  sensitive   = true
  description = "The location of resources, such as templates and DSC modules, that the template depends on"
}

locals {
  dc1name            = "${var.NamingConvention}-dc-01"  
  ModulesUrl = format("%s%s%s", var.artifactsLocation, "DSC/RESTARTVM.zip", var.artifactsLocationSasToken)
}

data "azurerm_virtual_machine" "dc1" {
  name                = local.dc1name
  resource_group_name = var.ResourceGroupName1
}

resource "azurerm_virtual_machine_extension" "dsc" {
  name                       = "Microsoft.Powershell.DSC"
  virtual_machine_id         = data.azurerm_virtual_machine.dc1.id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.83"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
        "ModulesUrl": "${local.ModulesUrl}",
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