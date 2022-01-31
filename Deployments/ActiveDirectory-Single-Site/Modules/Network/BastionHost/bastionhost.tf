variable "vnetName" {
  type        = string
  description = "Virtual Network Name"
}

variable "subnetID" {
  type        = string
  description = "Subnet Resource ID"
}

variable "Location" {
  type        = string
  description = "Resource Location"
}

variable "ResourceGroupName" {
  type        = string
  description = "Resource Group 1 Name"
}

resource "azurerm_public_ip" "bastion_pubip" {
  name                = "${var.vnetName}-Bastion-pip"
  location            = var.Location
  resource_group_name = var.ResourceGroupName

  sku                 = "Standard" # Mandatory for Azure Bastion host
  allocation_method   = "Static"
}

resource "azurerm_bastion_host" "bastion" {
  name     = "${var.vnetName}-Bastion"
  location = var.Location

  # Must be in the same rg as VNET
  resource_group_name = var.ResourceGroupName

  ip_configuration {
    name                 = "${var.vnetName}-bastionIPConfig"
    public_ip_address_id = azurerm_public_ip.bastion_pubip.id
    subnet_id            = var.subnetID
  }
}