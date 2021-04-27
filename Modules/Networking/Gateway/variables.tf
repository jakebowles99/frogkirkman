#Vnet and Subnet section
variable "vnetgw_vnet" {
    type            = string
    description     = "The name of the vnet to install Virtual Network Gateway"
}

variable "snet_id"{
    type= string
    description = "ID of subnet that VNGW gets attched to"
}

variable "vnetgw_resource_group" {
    type            = string
    description     = "The name of the resource group of vnet gateway."
}

variable "vnetgw_location" {
    type            = string
    default         = "uksouth"
    description     = "The region for vnet gateway"
}

variable "vnetgw_subnet" {
    type            = string
    default         = "GatewaySubnet"
    description     = "The name of the subnet to deploy the gateways. Only accepts Gateway."
}

#Gateway Section
variable "vnetgw_name" {
    type            = string
    description     = "The name of Virtual Network Gateway"
}

variable "pip_name" {
    type            = string
    description     = "The name of the pip"
}

variable "vnetgw_vpn_type" {
    type            = string
    description     = "Virutal Private Network Type"
}

variable "vnetgw_gw_type" {
    type            = string
    description     = "Virtual Network Gateway type"
}

variable "vnetgw_sku" {
    type            = string
    description     = "virtual \network gateway's sku type"
}

variable "pip_sku" {
    type            = string
    description     = "Public Ip address sku type"
}

#Local network gateway vaiables
variable "lng_name" {
    type            = string
    description     = "Local Network Gateway name."
}

variable "lng_location" {
    type            = string
    description     = "Local Network Gateway location."
}

variable "lng_resource_group" {
    type            = string
    description     = "Local Network Gateway resource group."
}

variable "lng_ip_address" {
    type            = string
    description     = "Address space for local Network Gateway."
}

variable "lng_ip_address_prefix" {
    type            = list
    description     = "List of allowed destination networks"
}

#Site-2-site VPN connection section
variable "vpncon_name" {
    type            = string
    description     = "The name of vpn connection."
}

variable "vpncon_resource_group" {
    type            = string
    description     = "Resource Group of VPN connection."
}

variable "vpncon_location" {
    type            = string
    description     = "Location of VPN connection."
}

variable "vpncon_connection_type" {
    type            = string
    description     = "Type of VPN connection."
}

variable "shared_key" {
    type            = string
    description     = "The shared secret."
}

#Tags section
variable "vnetgw_tags" {
    type            = map
    description     = "List of Virtual Network Gateway Tags."
}

variable "pip_tags" {
    type            = map
    description     = "PIP tags."
}

variable "lng_tags" {
    type            = map
    description     = "List of local Network Gateway Tags."
}

variable "vpncon_tags" {
    type            = map
    description     = "VPN connection tags."
}
