variable "name"{
    type = string
    description = "Subnet name"
}

variable "address_prefix"{
    type = list(string)
    description = "Subnet address prefix"
}

variable "rg"{
    type = string
    description = "Subnet name"
}

variable "vnet_name"{
    type = string
    description = "Name of vnet to attach subnet to"
}

variable "nsg_id"{
    type = string
    default = ".."
    description = "The NSG ID that will be attached to the subnet. Default is null."
}