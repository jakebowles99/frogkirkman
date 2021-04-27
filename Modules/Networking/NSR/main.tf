resource "azurerm_network_security_rule" "servers" {
    name                          = var.nsr_name
    network_security_group_name   = var.nsg_name
    source_address_prefix         = var.nsr_source_address
    source_port_range             = var.nsr_source_port
    destination_address_prefix    = var.nsr_destination_address
    destination_port_ranges       = var.nsr_destination_ports
    protocol                      = var.nsr_protocol
    access                        = var.nsr_access
    priority                      = var.nsr_priority
    direction                     = var.nsr_direction
    description                   = var.nsr_description
    resource_group_name           = var.nsg_resourcegroup
  }
