variable "ResourceGroupName" {
  type        = string
  description = "Resource Group Name"
}

variable "computerName" {
  type        = string
  description = "Computer Name"
}

variable "computerIP" {
  type        = string
  description = "Computer IP"
}

variable "Publisher" {
  type        = string
  description = "Image Publisher"
}

variable "Offer" {
  type        = string
  description = "Image Publisher Offer"
}

variable "OSVersion" {
  type        = string
  description = "OS Version"
}

variable "licenseType" {
  type        = string
  description = "License Type (Windows_Server or None)"
}

variable "DataDisk1Name" {
  type        = string
  description = "Name of Data Disk 1"
}

variable "Location" {
  type        = string
  description = "Resource Location"
}

variable "subnet" {
  type        = string
  description = "Subnet Name"
}

variable "vmsize" {
  type        = string
  description = "VM Size"
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

locals {
  NicName            = "${var.computerName}-nic"
  StorageAccountType = "Standard_LRS"
}

resource "azurerm_network_interface" "nic" {
  name                = local.NicName
  location            = var.Location
  resource_group_name = var.ResourceGroupName

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.subnet
    private_ip_address            = var.computerIP
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                = var.computerName
  location            = var.Location
  resource_group_name = var.ResourceGroupName
  vm_size             = var.vmsize
  license_type        = var.licenseType
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  storage_image_reference {
    publisher = var.Publisher
    offer     = var.Offer
    sku       = var.OSVersion
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.computerName}_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = local.StorageAccountType
  }

  os_profile {
    computer_name  = var.computerName
    admin_username = var.adminUsername
    admin_password = var.adminPassword
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}