resource "azurerm_virtual_network" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg
  address_space       = var.address_space
  tags                = var.tags
}

