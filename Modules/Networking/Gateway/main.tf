resource "azurerm_local_network_gateway" "onpremise" {
  name                = var.lng_name
  location            = var.lng_location
  resource_group_name = var.lng_resource_group
  gateway_address     = var.lng_ip_address
  address_space       = var.lng_ip_address_prefix
  tags                = var.lng_tags
}

resource "azurerm_virtual_network_gateway" "main" {
  name                            = var.vnetgw_name
  location                        = var.vnetgw_location
  resource_group_name             = var.vnetgw_resource_group
  type                            = var.vnetgw_gw_type
  vpn_type                        = var.vnetgw_vpn_type
  active_active                   = false
  enable_bgp                      = false
  sku                             = var.vnetgw_sku
  
  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.main.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.snet_id
  }

  tags                            = var.vnetgw_tags
}

resource "azurerm_virtual_network_gateway_connection" "onpremise" {
  name                        = var.vpncon_name
  location                    = var.vpncon_location
  resource_group_name         = var.vpncon_resource_group
  type                        = var.vpncon_connection_type
  virtual_network_gateway_id  = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id    = azurerm_local_network_gateway.onpremise.id
  shared_key                  = var.shared_key
  tags                        = var.vpncon_tags
}

resource "azurerm_public_ip" "main" {
  name                  = var.pip_name
  location              = var.vnetgw_location
  resource_group_name   = var.vnetgw_resource_group
  allocation_method     = "Dynamic"
  sku                   = var.pip_sku
  tags                  = var.pip_tags
}