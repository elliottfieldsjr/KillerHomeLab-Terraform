variable "ResourceGroupName" {
  type        = string
  description = "Resource Group Name"
}

variable "computerName" {
  type        = string
  description = "Computer Name"
}

variable "TimeZone" {
  type        = string
  description = "Time Zone"
}

variable "NetBiosDomain" {
  type        = string
  description = "NetBios Domain"
}

variable "domainName" {
  type        = string
  description = "Second-Level Domain"
}

variable "Location" {
  type        = string
  description = "Location or Resources"
}

variable "adminUsername" {
  type        = string
  description = "Admin User Name"
}

variable "adminPassword" {
  type        = string
  sensitive   = true
  description = "Admin User Name"
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
    ModulesUrl  =   concat("${var.artifactsLocation}","DSC/FIRSTDC.zip","${var.artifactsLocationSasToken}")
}

resource "azurerm_virtual_machine_extension" "firstdc" {
  name                 = "firstdc"
  virtual_machine_id   = var.vmID
  publisher            = "Microsoft.Powershell"
  type = "DSC"
  type_handler_version = "2.73"
  auto_upgrade_minor_version = true
  settings = <<SETTINGS
    {
        "ModulesUrl": "${local.ModulesUrl}",
        "ConfigurationFunction" : "FIRSTDC.ps1\\FIRSTDC",
        "Properties": {
            "TimeZone": "${var.TimeZone}",
            "DomainName": "${var.domainName}",
            "NetBiosDomain": "${var.NetBIosDomain}",            
            "AdminCreds": {
                "UserName": "${var.adminUsername}",
                "Password": "${adminPassword}"
            }
        }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "adminPassword": "${var.adminPassword}"
    }
PROTECTED_SETTINGS
}