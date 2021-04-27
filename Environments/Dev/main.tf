provider "azurerm" {
  version = "=2.56.0"
  features {}
}

variable "default_tags" {
  type = map(any)
  default = {
    application = "intranet"
    environment = "Production"
    site        = "London"
  }
  description = "List of default tags added in azure. This makes it easier to add universal tags."
}

#Default values to make value easy to change in multiple places.

resource "azurerm_resource_group" "UKS" {
  name     = "rg-uks-dev-01"
  location = "uksouth"
  tags     = merge({region = "UKS"}, var.default_tags)

}

resource "azurerm_resource_group" "UKW" {
  name     = "rg-ukw-dev-01"
  location = "ukwest"
  tags     = merge({region = "UKW"}, var.default_tags)

}

module "SQL" {
  source   = "../../modules/SQL"
  name     = "mssql-uks-dev-01"
  admin    = "admin123"
  password = "asdafevVVdcva!@&^&%&^%%&"
  sku      = "B_Gen5_1"
  size     = 5120
  tags     = merge({create-type = "Master", region = "UKS"}, var.default_tags)
  location = azurerm_resource_group.UKS.location
  rg       = azurerm_resource_group.UKS.name
}

module "vnet" {
  source        = "../../modules/networking/VNET"
  name          = "vnet-uks-dev-01"
  address_space = ["10.0.0.0/16"]
  tags          = merge({peering = "N/A", region = "UKS"}, var.default_tags)
  location      = azurerm_resource_group.UKS.location
  rg            = azurerm_resource_group.UKS.name
}

module "subnet_gateway" {
  source         = "../../modules/networking/Subnet"
  name           = "GatewaySubnet"
  vnet_name      = module.vnet.vnet_name
  rg             = azurerm_resource_group.UKS.name
  address_prefix = ["10.0.0.0/24"]
}

module "subnet_vm" {
  source         = "../../modules/networking/Subnet"
  name           = "snet-uks-dev-vm-01"
  vnet_name      = module.vnet.vnet_name
  rg             = azurerm_resource_group.UKS.name
  address_prefix = ["10.0.1.0/24"]
  nsg_id         = azurerm_network_security_group.vm_UKS.id

}

module "VM" {
  source                = "../../modules/VM"
  nic_privateip_address = "10.0.1.4"
  nic_tags              = { environment = "Production" }
  vm_name               = "vmuksdev01"
  vm_size               = "Standard_A4_v2"
  vm_username           = "jbadmin"
  vm_password           = "password123***&"
  av_zone               = "1"
  disk_type             = "StandardSSD_LRS"
  os_disk_cache         = "ReadWrite"
  os_disk_size          = 100
  VM_tags               = merge({role = "WebSvr", region = "UKS"}, var.default_tags)
  location              = azurerm_resource_group.UKS.location
  rg                    = azurerm_resource_group.UKS.name
  snet_id               = module.subnet_vm.snet_id
}

module "ASR" {
  source = "../../modules/ASR"

  #Worth noting that if more than one VM is wanted to be added to failover, then logic would have to be reworked. 

  rsv_name     = "rsv-ukw-dev-01"
  rsv_sku      = "standard"
  rsv_location = azurerm_resource_group.UKS.location
  tags                  = merge({role = "ASR", region = "UKW"}, var.default_tags)


  #Sets up resource group parameters
  rg_primary_name     = azurerm_resource_group.UKS.name
  rg_primary_location = azurerm_resource_group.UKS.location
  rg_second_name      = azurerm_resource_group.UKW.name
  rg_second_location  = azurerm_resource_group.UKW.location
  rg_second_id        = azurerm_resource_group.UKW.id

  #Sets up a primary and secondary fabric. This represents an Azure region.
  primary_fabric_name   = "fab-prim-dev-01"
  secondary_fabric_name = "fab-sec-dev-01"

  #The protection container is a container used to group replicated items within a fabric.  
  primary_protection_container   = "cont-prim-dev-01"
  secondary_protection_container = "cont-sec-dev-01"

  #A target VNET is needed for VMs to fail to.
  secondary_vnet_name          = "vnet-ukw-dev-01"
  secondary_vnet_address_space = ["10.0.0.0/16"]

  #Mimic subnets on the primary side
  secondary_vnet_subnet1         = "snet-ukw-dev-01"
  secondary_subnet_address_space = ["10.0.1.0/24"]

  #If/When ASR is used. This will be the name of the VM is the secondary region.
  replicated_vm_name = "vmukwdev01asr"

  source_vm_id = module.VM.vm_id
  os_disk_id   = module.VM.os_disk_id
  nic_id       = module.VM.nic_id

}

module "Gateway" {
  source     = "../../Modules/Networking/Gateway"
  shared_key = "G?cpCc[CQ57qWR>]Yg=T%Hg"

  #Virtual Network Gateway variables
  vnetgw_name           = "vnetgw-uks-dev-01"
  vnetgw_vpn_type       = "RouteBased"
  vnetgw_gw_type        = "VPN"
  vnetgw_sku            = "Standard"
  pip_name              = "pip-uks-dev-gw-01"
  pip_sku               = "Basic"
  vnetgw_resource_group = azurerm_resource_group.UKS.name
  vnetgw_location       = azurerm_resource_group.UKS.location
  vnetgw_vnet           = module.vnet.vnet_id
  snet_id               = module.subnet_gateway.snet_id

  #Local Network Gateway Variables
  lng_name              = "lngw-uks-dev-01"
  #Fake on prem environment values
  lng_ip_address        = "123.234.123.0/24"
  lng_ip_address_prefix = ["123.234.123.0/16"]
  lng_resource_group    = azurerm_resource_group.UKS.name
  lng_location          = azurerm_resource_group.UKS.location

  #VPN connection variables
  vpncon_name            = "vpncon-uks-dev-01"
  vpncon_connection_type = "IPsec"
  vpncon_resource_group  = azurerm_resource_group.UKS.name
  vpncon_location        = azurerm_resource_group.UKS.location

  #Virtual Network Gateway Tags variables
  vnetgw_tags = merge({role = "Site2Site", vnet = module.vnet.vnet_id, region = "UKS"}, var.default_tags)

  pip_tags    = merge({role = "Site2Site", region = "UKS"}, var.default_tags)

  #Local Network Gateway Tags variables
  lng_tags = merge({role = "Site2Site", region = "UKS"}, var.default_tags)

  #VPN connection tags variables
  vpncon_tags = merge({role = "Site2Site", region = "UKS"}, var.default_tags)
}

resource "azurerm_network_security_group" "vm_UKS" {
  name                = "nsg-uks-dev-vm-01"
  location            = azurerm_resource_group.UKS.location
  resource_group_name = azurerm_resource_group.UKS.name
  tags                = merge({subnet-name = "VM", region = "UKS"}, var.default_tags)
}

module "nsr_in_on_prem_SEA" {
  source                  = "../../Modules/Networking/NSR"
  nsr_name                = "nsr-uks-dev-in-vm-01"
  nsr_description         = "Allows web traffic on HTTP/S to the VM"
  nsr_priority            = 1000
  #Fake on prem environment values
  nsr_source_address      = "123.234.123.0/32"
  nsr_destination_address = "10.0.1.4/32"
  nsr_source_port         = "*"
  nsr_destination_ports   = ["80", "443"]
  nsr_access              = "allow"
  nsr_protocol            = "TCP"
  nsr_direction           = "inbound"
  nsg_name          = azurerm_network_security_group.vm_UKS.name
  nsg_resourcegroup = azurerm_resource_group.UKS.name

}