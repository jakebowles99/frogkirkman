#NSG variables
variable "nsg_name" {
  type        = string
  description = "The name of the network security groups"
}

variable "nsg_resourcegroup" {
  type        = string
  description = "The resource group of network security groups"
}

#NSR variables
variable "nsr_name" {
  type        = string
  description = "The name of the network security rule"
}

variable "nsr_description" {
  type        = string
  description = "Description of the network security rule"
}

variable "nsr_priority" {
  type        = string
  description = "Priority of the network security rule"
}

variable "nsr_source_address" {
  type        = string
  description = "Source IP addresses of the network security rule"
}

variable "nsr_destination_address" {
  type        = string
  description = "Destination IP addresses of the network security rule"
}

variable "nsr_source_port" {
  type        = string
  description = "Source port numbers of the network security rule"
}

variable "nsr_destination_ports" {
  type        = list
  description = "Destination port numbers of the network security rule"
}

variable "nsr_access" {
  type        = string
  description = "Access permission of the network security rule"
}

variable "nsr_protocol" {
  type        = string
  description = "Allowed protocols of the network security rule"
}

variable "nsr_direction" {
  type        = string
  description = "Allowed direction (inbound/outbound) of the network security rule"
}