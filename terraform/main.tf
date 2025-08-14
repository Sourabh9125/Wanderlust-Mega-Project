resource "azurerm_resource_group" "wanderlust" {
  name     = "${var.env}-wanderlust-resources"
  location = "East US"
}

# Virtual Network Resource
resource "azurerm_virtual_network" "main" {
  name                = "${var.env}-wanderlust-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.wanderlust.location
  resource_group_name = azurerm_resource_group.wanderlust.name
}

# Subnet Resource
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.wanderlust.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_public_ip" "main" {
  name                = "${var.env}-wanderlust-pip"
  location            = azurerm_resource_group.wanderlust.location
  resource_group_name = azurerm_resource_group.wanderlust.name
  allocation_method   = "Static"
  sku = "Standard"

}

# Network Security Group Resource
resource "azurerm_network_security_group" "nsg" {
  name                = "wanderlust-nsg"
  location            = azurerm_resource_group.wanderlust.location
  resource_group_name = azurerm_resource_group.wanderlust.name

  security_rule {
    name                       = "ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "wanderlust-nsg"
  }
}
# Network Interface Resource
resource "azurerm_network_interface" "main" {
  name                = "${var.env}-wanderlust-nic"
  location            = azurerm_resource_group.wanderlust.location
  resource_group_name = azurerm_resource_group.wanderlust.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  
}

#Virtual Machine Resource
resource "azurerm_linux_virtual_machine" "main" {
  name                  = "${var.env}-wanderlust-vm"
  location              = azurerm_resource_group.wanderlust.location
  resource_group_name   = azurerm_resource_group.wanderlust.name
  network_interface_ids = [azurerm_network_interface.main.id]
  size                  = "Standard_B1s"
  admin_username        = "adminuser"

  disable_password_authentication = true

   admin_ssh_key {
    username   = "adminuser"
    public_key = file("${path.module}/wanderlust-key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  
  custom_data = filebase64("${path.module}/install_tools.sh")
   tags = {
    environment = "${var.env}-wanderlust-vm"
  }

}


  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  # storage_image_reference {
  #   publisher = "Canonical"
  #   offer     = "0001-com-ubuntu-server-jammy"
  #   sku       = "22_04-lts"
  #   version   = "latest"
  # }
  # storage_os_disk {
  #   name              = "myosdisk1"
  #   caching           = "ReadWrite"
  #   create_option     = "FromImage"
  #   managed_disk_type = "Standard_LRS"
  # }
  # os_profile {
  #   computer_name  = "hostname"
  #   admin_username = "azureuser"
  #   # admin_password = "Password1234!"
  # }
  # os_profile_linux_config {
  #   disable_password_authentication = true
  #   ssh_keys {
  #     path     = "/home/azureuser/.ssh/authorized_keys"
  #     key_data = file("${path.module}/wanderlust-key.pub")
  #   }
  # }
#   tags = {
#     environment = "${var.env}-wanderlust-vm"
#   }
# }


# resource "azurerm_resource_group" "storage" {
#   name     = "storage-resources"
#   location = "East US"
# }

# resource "azurerm_storage_account" "example" {
#   name                     = "twstest101"
#   resource_group_name      = azurerm_resource_group.storage.name
#   location                 = azurerm_resource_group.storage.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"

#   tags = {
#     environment = "staging"
#   }
# }