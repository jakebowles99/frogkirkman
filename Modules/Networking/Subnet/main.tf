resource "azurerm_subnet" "main" {
  name                 = var.name
  resource_group_name  = var.rg
  virtual_network_name = var.vnet_name
  address_prefixes     = var.address_prefix
}

#Commented for testing and demo purposes due to dependencies

// resource "azurerm_subnet_network_security_group_association" "main" {
//   count = var.nsg_id == ".." ? 0  : 1
//   subnet_id                 = azurerm_subnet.main.id
//   network_security_group_id = var.nsg_id 
// }