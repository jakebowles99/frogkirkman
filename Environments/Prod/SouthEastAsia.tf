provider "azurerm" {
  version = "=2.56.0"
  features {}
}

variable "default_tags_SEA" {
  type = map(any)
  default = {
    application = "intranet"
    environment = "Production"
    site        = "Kuala Lumpur"
  }
  description = "List of default tags added in azure. This makes it easier to add universal tags."
}

resource "azurerm_resource_group" "EastAsia" {
  name     = "rg-sea-prod-01"
  location = "eastasia"
  tags     = merge({region = "SEA"}, var.default_tags)
}

module "SQL_SEA" {
  source           = "../../modules/SQL"
  name             = "mssql-sea-prod-01"
  admin            = "admin123"
  password         = "asdafevVVdcva!@&^&%&^%%&"
  sku              = "GP_Gen5_8"
  size             = 5120
  create_mode      = "Replica"
  create_source_id = module.SQL_UKS.id
  location         = azurerm_resource_group.EastAsia.location
  rg               = azurerm_resource_group.EastAsia.name
  tags             = merge({create-type = "Replica", region = "SEA"}, var.default_tags)

}

module "vnet_SEA" {
  source        = "../../modules/networking/VNET"
  name          = "vnet-sea-prod-01"
  address_space = ["10.2.0.0/16"]
  tags          = merge({peering = "UKS", region = "SEA"}, var.default_tags)
  location      = azurerm_resource_group.EastAsia.location
  rg            = azurerm_resource_group.EastAsia.name
}

resource "azurerm_virtual_network_peering" "SEA2UKS" {
  name                      = "SEA2UKS"
  resource_group_name       = azurerm_resource_group.EastAsia.name
  virtual_network_name      = module.vnet_SEA.vnet_name
  remote_virtual_network_id = module.vnet_UKS.vnet_id
}

module "subnet_gateway_SEA" {
  source         = "../../modules/networking/Subnet"
  name           = "GatewaySubnet"
  address_prefix = ["10.2.0.0/24"]
  vnet_name      = module.vnet_SEA.vnet_name
  rg             = azurerm_resource_group.EastAsia.name
}

module "subnet_vm_SEA" {
  source         = "../../modules/networking/Subnet"
  name           = "snet-sea-prod-vm-01"
  address_prefix = ["10.2.1.0/24"]
  vnet_name      = module.vnet_SEA.vnet_name
  rg             = azurerm_resource_group.EastAsia.name
  nsg_id         = azurerm_network_security_group.vm_SEA.id
}

module "ScaleSet_SEA" {
  source              = "../../modules/ScaleSet"
  scale_set_name      = "vmsseaprod"
  zones               = ["1", "2", "3"]
  SKU_name            = "Standard_F4s_v2"
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
  tags                = merge({max = "10", min = "2", region = "SEA"}, var.default_tags)
  subnet_id           = module.subnet_vm_SEA.snet_id
  location            = azurerm_resource_group.EastAsia.location
  rg                  = azurerm_resource_group.EastAsia.name
  backend_addpool_id  = module.LoadBalancer_SEA.lb_bap_id
  nat_ids             = [module.LoadBalancer_SEA.http_nat_id, module.LoadBalancer_SEA.https_nat_id]
  lb_probe_id         = module.LoadBalancer_SEA.probe_id
}

module "LoadBalancer_SEA" {
  source       = "../../modules/LoadBalancer"
  name         = "lb-sea-prod-01"
  private_ip   = "10.2.1.4"
  website_path = "/hello-world.html"
  tags         = merge({pool = "ScaleSet", region = "SEA"}, var.default_tags)
  location     = azurerm_resource_group.EastAsia.location
  rg           = azurerm_resource_group.EastAsia.name
  snet_id      = module.subnet_vm_SEA.snet_id

}

module "Gateway_SEA" {
  source     = "../../Modules/Networking/Gateway"
  shared_key = "G?cpCc[CQ57qWR>]Yg=T%Hg"
  #Virtual Network Gateway variables
  vnetgw_name           = "vnetgw-sea-dev-01"

  vnetgw_vpn_type       = "RouteBased"
  vnetgw_gw_type        = "VPN"
  vnetgw_sku            = "Standard"
  pip_name              = "pip-sea-dev-gw-01"
  pip_sku               = "basic"
  snet_id               = module.subnet_gateway_SEA.snet_id
  vnetgw_resource_group = azurerm_resource_group.EastAsia.name
  vnetgw_location       = azurerm_resource_group.EastAsia.location
  vnetgw_vnet           = module.vnet_SEA.vnet_id
  vnetgw_subnet         = module.subnet_gateway_SEA.snet_id

  #Local Network Gateway Variables
  lng_name              = "lngw-sea-dev-01"
  lng_resource_group    = azurerm_resource_group.EastAsia.name
  lng_location          = azurerm_resource_group.EastAsia.location
  #Fake on premise environment values
  lng_ip_address        = "123.234.123.0"
  lng_ip_address_prefix = ["123.234.123.0/24"]

  #VPN connection variables
  vpncon_name            = "vpncon-sea-dev-01"
  vpncon_connection_type = "IPsec"
  vpncon_resource_group  = azurerm_resource_group.EastAsia.name
  vpncon_location        = azurerm_resource_group.EastAsia.location


  #Virtual Network Gateway Tags variables
  vnetgw_tags = merge({role = "Site2Site", vnet = module.vnet_SEA.vnet_id, region = "UKS"}, var.default_tags)

  pip_tags    = merge({role = "Site2Site", region = "SEA"}, var.default_tags)

  #Local Network Gateway Tags variables
  lng_tags = merge({role = "Site2Site", region = "SEA"}, var.default_tags)

  #VPN connection tags variables
  vpncon_tags = merge({role = "Site2Site", region = "SEA"}, var.default_tags)
}

resource "azurerm_network_security_group" "vm_SEA" {
  name                = "nsg-sea-prod-vm-01"
  location            = azurerm_resource_group.EastAsia.location
  resource_group_name = azurerm_resource_group.EastAsia.name
  tags                = merge({subnet-name = "VM", region = "SEA"}, var.default_tags)
}

module "nsr_in_on_prem_SEA" {
  source                  = "../../Modules/Networking/NSR"
  nsr_name                = "nsr-sea-prod-in-lb-01"
  nsr_description         = "Allows any traffic on HTTP/S to the Load balancer on the VM LB"
  nsr_priority            = 1000
  #Fake on prem environment values
  nsr_source_address      = "123.234.123.0/32"
  nsr_destination_address = "10.2.1.4/32"
  nsr_source_port         = "*"
  nsr_destination_ports   = ["80", "443"]
  nsr_access              = "allow"
  nsr_protocol            = "TCP"
  nsr_direction           = "inbound"

  nsg_name          = azurerm_network_security_group.vm_SEA.name
  nsg_resourcegroup = azurerm_resource_group.EastAsia.name

}
