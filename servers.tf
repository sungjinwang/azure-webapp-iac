resource "azurerm_linux_virtual_machine" "vm_bastion" {
  name                  = "bastion-cus"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [ azurerm_network_interface.nic["bastion-nic"].id ]
  size                  = var.vm_size
  
  admin_username = var.vm_admin_username
  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file(var.public_key_path)
  }

  disable_password_authentication = true

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.image_reference.publisher
    offer     = var.image_reference.offer
    sku       = var.image_reference.sku
    version   = var.image_reference.version
  }

  plan {
    name      = var.plan.name
    publisher = var.plan.publisher
    product   = var.plan.product
  }
}

resource "azurerm_linux_virtual_machine" "vm_web1" {
  name                  = "web1-cus"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [ azurerm_network_interface.nic["web1-nic"].id ]
  size                  = var.vm_size
  
  admin_username = var.vm_admin_username
  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file(var.public_key_path)
  }

  disable_password_authentication = true

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.image_reference.publisher
    offer     = var.image_reference.offer
    sku       = var.image_reference.sku
    version   = var.image_reference.version
  }

  plan {
    name      = var.plan.name
    publisher = var.plan.publisher
    product   = var.plan.product
  }

  # Managed Service Identity - Key vault
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_linux_virtual_machine" "vm_web2" {
  name                  = "web2-cus"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [ azurerm_network_interface.nic["web2-nic"].id ]
  size                  = var.vm_size
  
  admin_username = var.vm_admin_username
  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file(var.public_key_path)
  }

  disable_password_authentication = true

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.image_reference.publisher
    offer     = var.image_reference.offer
    sku       = var.image_reference.sku
    version   = var.image_reference.version
  }

  plan {
    name      = var.plan.name
    publisher = var.plan.publisher
    product   = var.plan.product
  }

  # Managed Service Identity - Key vault
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_linux_virtual_machine" "vm_db1" {
  name                  = "db1-cus"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [ azurerm_network_interface.nic["db1-nic"].id ]
  size                  = var.vm_size
  
  admin_username = var.vm_admin_username
  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file(var.public_key_path)
  }

  disable_password_authentication = true

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.image_reference.publisher
    offer     = var.image_reference.offer
    sku       = var.image_reference.sku
    version   = var.image_reference.version
  }

  plan {
    name      = var.plan.name
    publisher = var.plan.publisher
    product   = var.plan.product
  }
}

resource "azurerm_linux_virtual_machine" "vm_db2" {
  name                  = "db2-cus"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [ azurerm_network_interface.nic["db2-nic"].id ]
  size                  = var.vm_size
  
  admin_username = var.vm_admin_username
  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file(var.public_key_path)
  }

  disable_password_authentication = true

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.image_reference.publisher
    offer     = var.image_reference.offer
    sku       = var.image_reference.sku
    version   = var.image_reference.version
  }

  plan {
    name      = var.plan.name
    publisher = var.plan.publisher
    product   = var.plan.product
  }
}