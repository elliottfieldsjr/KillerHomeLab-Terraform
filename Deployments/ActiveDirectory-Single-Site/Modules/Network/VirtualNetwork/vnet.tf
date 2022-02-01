variable "vnetName" {
  type        = string
  description = "Virtual Network Name"
}

variable "vnetPrefix" {
  type        = string
  description = "VNet Prefix"
}

variable "subnet1Name" {
  type        = string
  description = "Subnet 1 Name"
}

variable "subnet1Prefix" {
  type        = string
  description = "Subnet 1 Prefix"
}

variable "subnet2Name" {
  type        = string
  description = "Subnet 2 Name"
}

variable "subnet2Prefix" {
  type        = string
  description = "Subnet 2 Prefix"
}

variable "BastionsubnetPrefix" {
  type        = string
  description = "Bastion Subnet Prefix"
}

variable "Location" {
  type        = string
  description = "Resource Location"
}

variable "ResourceGroupName" {
  type        = string
  description = "Resource Group 1 Name"
}

resource "azurerm_virtual_network" "vnet" {
  name = var.vnetName
  address_space = [
    var.vnetPrefix
  ]
  location            = var.Location
  resource_group_name = var.ResourceGroupName

  subnet {
    name           = var.subnet1Name
    address_prefix = var.subnet1Prefix
  }

  subnet {
    name           = var.subnet2Name
    address_prefix = var.subnet2Prefix
  }

  subnet {
    name           = "AzureBastionSubnet"
    address_prefix = var.BastionsubnetPrefix
  }
}

output "subnet1ID" {
  value = azurerm_virtual_network.vnet.subnet.*.id[0]
}

output "subnet2ID" {
  value = azurerm_virtual_network.vnet.subnet.*.id[1]
}

output "subnet3ID" {
  value = azurerm_virtual_network.vnet.subnet.*.id[2]
}