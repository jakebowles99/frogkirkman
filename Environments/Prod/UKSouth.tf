#Default values to make value easy to change in multiple places.

variable "default_tags_UKS" {
  type = map(any)
  default = {
    application = "intranet"
    environment = "Production"
    site        = "London"
  }
  description = "List of default tags added in azure. This makes it easier to add universal tags."
}

resource "azurerm_resource_group" "UKSouth" {
  name     = "rg-uks-prod-01"
  location = "uksouth"
}

module "SQL_UKS" {
  source   = "../../modules/SQL"
  name     = "mssql-uks-prod-01"
  admin    = "admin123"
  password = "asdafevVVdcva!@&^&%&^%%&"
  sku      = "GP_Gen5_2"
  size     = 5120
  location = azurerm_resource_group.UKSouth.location
  rg       = azurerm_resource_group.UKSouth.name
  tags     = merge({create-type = "Master", region = "UKS"}, var.default_tags)

}

module "vnet_UKS" {
  source        = "../../modules/networking/VNET"
  name          = "vnet-uks-prod-01"
  address_space = ["10.1.0.0/16"]
  tags          = merge({peering = "SEA", region = "UKS"}, var.default_tags)
  location      = azurerm_resource_group.UKSouth.location
  rg            = azurerm_resource_group.UKSouth.name
}

resource "azurerm_virtual_network_peering" "UKS2SEA" {
  name                      = "UKS2SEA"
  resource_group_name       = azurerm_resource_group.UKSouth.name
  virtual_network_name      = module.vnet_UKS.vnet_name
  remote_virtual_network_id = module.vnet_SEA.vnet_id
}

module "subnet_gateway_UKS" {
  source         = "../../modules/networking/Subnet"
  name           = "GatewaySubnet"
  address_prefix = ["10.1.0.0/24"]
  vnet_name      = module.vnet_UKS.vnet_name
  rg             = azurerm_resource_group.UKSouth.name
}

module "subnet_vm_UKS" {
  source         = "../../modules/networking/Subnet"
  name           = "snet-uks-prod-vm-01"
  address_prefix = ["10.1.1.0/24"]
  vnet_name      = module.vnet_UKS.vnet_name
  rg             = azurerm_resource_group.UKSouth.name
  nsg_id         = azurerm_network_security_group.vm_UKS.id
}

module "ScaleSet_UKS" {
  source              = "../../modules/ScaleSet"
  scale_set_name      = "vmssuksprod"
  zones               = ["1", "2", "3"]
  SKU_name            = "standard_d2s_v3"
  publisher           = "Canonical"
  offer               = "UbuntuServer"
  image_sku           = "16.04-lts"
  disk_sku            = "standardssd_lrs"
  username            = "adminj"
  password            = "passworD12£"
  default_vm          = 2
  min_vm              = 2
  max_vm              = 10
  increase_percentage = 75
  decrease_percentage = 25
  tags                = merge({max = "10", min = "2", region = "UKS"}, var.default_tags)
  subnet_id           = module.subnet_vm_UKS.snet_id
  location            = azurerm_resource_group.UKSouth.location
  rg                  = azurerm_resource_group.UKSouth.name
  backend_addpool_id  = module.LoadBalancer_UKS.lb_bap_id
  nat_ids             = [module.LoadBalancer_UKS.http_nat_id, module.LoadBalancer_UKS.https_nat_id]
  lb_probe_id         = module.LoadBalancer_UKS.probe_id
}

module "LoadBalancer_UKS" {
  source       = "../../modules/LoadBalancer"
  name         = "vnet-uks-prod-01"
  private_ip   = "10.1.1.4"
  website_path = "/hello-world.html"
  tags         = merge({pool = "ScaleSet", region = "UKS"}, var.default_tags)
  location     = azurerm_resource_group.UKSouth.location
  rg           = azurerm_resource_group.UKSouth.name
  snet_id      = module.subnet_vm_UKS.snet_id
}

module "Gateway_UKS" {
  source     = "../../Modules/Networking/Gateway"
  shared_key = "G?cpCc[CQ57qWR>]Yg=T%Hg"
  #Virtual Network Gateway variables
  vnetgw_name           = "vnetgw-uks-dev-01"
  vnetgw_vpn_type       = "RouteBased"
  vnetgw_gw_type        = "VPN"
  vnetgw_sku            = "Standard"
  pip_name              = "pip-uks-dev-gw-01"
  pip_sku               = "basic"
  snet_id               = module.subnet_gateway_UKS.snet_id
  vnetgw_resource_group = azurerm_resource_group.UKSouth.name
  vnetgw_location       = azurerm_resource_group.UKSouth.location
  vnetgw_vnet           = module.vnet_UKS.vnet_id
  vnetgw_subnet         = module.subnet_gateway_UKS.snet_id

  #Local Network Gateway Variables
  lng_name              = "lngw-uks-dev-01"
  lng_resource_group    = azurerm_resource_group.UKSouth.name
  lng_location          = azurerm_resource_group.UKSouth.location
  #Fake on prem environment values
  lng_ip_address        = "123.234.123.0"
  lng_ip_address_prefix = ["123.234.123.0/24"]

  #VPN connection variables
  vpncon_name            = "vpncon-uks-dev-01"
  vpncon_connection_type = "IPsec"
  vpncon_resource_group  = azurerm_resource_group.UKSouth.name
  vpncon_location        = azurerm_resource_group.UKSouth.location

  #Virtual Network Gateway Tags variables
  vnetgw_tags = merge({role = "Site2Site", vnet = module.vnet_SEA.vnet_id, region = "UKS"}, var.default_tags)

  pip_tags    = merge({role = "Site2Site", region = "UKS"}, var.default_tags)

  #Local Network Gateway Tags variables
  lng_tags = merge({role = "Site2Site", region = "UKS"}, var.default_tags)

  #VPN connection tags variables
  vpncon_tags = merge({role = "Site2Site", region = "UKS"}, var.default_tags)
}

resource "azurerm_network_security_group" "vm_UKS" {
  name                = "nsg-uks-prod-vm-01"
  location            = azurerm_resource_group.UKSouth.location
  resource_group_name = azurerm_resource_group.UKSouth.name
  tags                = merge({subnet-name = "VM", region = "UKS"}, var.default_tags)
}

module "nsr_in_on_prem_UKS" {
  source                  = "../../Modules/Networking/NSR"
  nsr_name                = "nsr-uks-prod-in-lb-01"
  nsg_name                = azurerm_network_security_group.vm_UKS.name
  nsg_resourcegroup       = azurerm_resource_group.UKSouth.name
  nsr_description         = "Allows any traffic on HTTP/S to the Load balancer on the VM lb"
  nsr_priority            = 1000
  #Fake on prem environment values
  nsr_source_address      = "123.234.123.0/32"
  nsr_destination_address = "10.1.1.4/32"
  nsr_source_port         = "*"
  nsr_destination_ports   = ["80", "443"]
  nsr_access              = "allow"
  nsr_protocol            = "TCP"
  nsr_direction           = "inbound"
}
