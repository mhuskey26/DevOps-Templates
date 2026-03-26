resource "azurerm_resource_group" "main" {
  name     = "${var.app_name}-${var.environment_name}-rg"
  location = var.location
}

# Network Interfaces
resource "azurerm_network_interface" "instance_1" {
  name                = "${var.app_name}-${var.environment_name}-instance-1-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.instances.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "instance_2" {
  name                = "${var.app_name}-${var.environment_name}-instance-2-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.instances.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "instance_1" {
  network_interface_id      = azurerm_network_interface.instance_1.id
  network_security_group_id = azurerm_network_security_group.instances.id
}

resource "azurerm_network_interface_security_group_association" "instance_2" {
  network_interface_id      = azurerm_network_interface.instance_2.id
  network_security_group_id = azurerm_network_security_group.instances.id
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "instance_1" {
  name                = "${var.app_name}-${var.environment_name}-instance-1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.instance_1.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello, World 1" > index.html
              python3 -m http.server 8080 &
              EOF
  )
}

resource "azurerm_linux_virtual_machine" "instance_2" {
  name                = "${var.app_name}-${var.environment_name}-instance-2"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.instance_2.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello, World 2" > index.html
              python3 -m http.server 8080 &
              EOF
  )
}
