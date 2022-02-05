variable "ResourceGroupName" {
  type        = string
  description = "Resource Group Name"
}

variable "computerName" {
  type        = string
  description = "Computer Name"
}

variable "Location" {
  type        = string
  description = "Location or Resources"
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

variable "vmID" {
  type        = string
  description = "VM Resource ID"
}

locals {
  ModulesUrl = format("%s%s%s", var.artifactsLocation, "DSC/RESTARTVM.zip", var.artifactsLocationSasToken)
}

resource "azurerm_virtual_machine_extension" "restartvm" {
  name                       = format("%s%s", var.computerName, "/Microsoft.Powershell.DSC")
  virtual_machine_id         = var.vmID
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.77"
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