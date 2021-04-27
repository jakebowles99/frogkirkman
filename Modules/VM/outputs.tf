output "vm_id" {
  value = azurerm_virtual_machine.main.id
}

output "os_disk_id" {
  value = azurerm_virtual_machine.main.storage_os_disk[0].managed_disk_id
}

output "nic_id"{
    value = azurerm_network_interface.nic.id
}