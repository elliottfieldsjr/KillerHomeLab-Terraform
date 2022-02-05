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
  ModulesUrl = format("%s%s%s", var.artifactsLocation, "DSC/FIRSTDC.zip", var.artifactsLocationSasToken)
}

resource "azurerm_virtual_machine_extension" "firstdc" {
  name                       = "firstdc"
  virtual_machine_id         = var.vmID
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.77"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
        "ModulesUrl": "${local.ModulesUrl}",
        "ConfigurationFunction" : "FIRSTDC.ps1\\FIRSTDC",
        "Properties": {
            "TimeZone": "${var.TimeZone}",
            "DomainName": "${var.domainName}",
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
        "AdminPassword": "${var.adminPassword}"
        }
    }
PROTECTED_SETTINGS
}