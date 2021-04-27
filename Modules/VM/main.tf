resource "azurerm_network_interface" "nic" {
  name                            = "nic-${var.vm_name}-01"
  location                        = var.location
  resource_group_name             = var.rg
  enable_accelerated_networking   = true

  ip_configuration {
    name                          = "IPConfig1"
    subnet_id                     = var.snet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.nic_privateip_address

  }
  tags                            = var.nic_tags
}

resource "azurerm_virtual_machine" "main" {
 
  name                            = var.vm_name
  resource_group_name             = var.rg
  location                        = var.location
  vm_size                         = var.vm_size
  
  network_interface_ids           = [azurerm_network_interface.nic.id]
  zones                           = [var.av_zone]

  os_profile {
    computer_name                 = var.vm_name
    admin_username                = var.vm_username
    admin_password                = var.vm_password
  }

  storage_image_reference {
    publisher                     = "Canonical"
    offer                         = "UbuntuServer"
    sku                           = "16.04-LTS"
    version                       = "latest"
  }

  storage_os_disk {
    name                          = "disk-${var.vm_name}-01"
    managed_disk_type             = var.disk_type
    caching                       = var.os_disk_cache
    disk_size_gb                  = var.os_disk_size
    create_option                 = "FromImage"
  }  

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags                            = var.VM_tags
}