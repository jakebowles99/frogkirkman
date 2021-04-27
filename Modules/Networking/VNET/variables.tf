variable "name"{
    type = string
    description = "The name of the VNET"
}

variable "location"{
    type = string
    description = "The location of the VNET"
}

variable "rg"{
    type = string
    description = "The rg of the VNET"
}

variable "address_space"{
    type = list(string)
    description = "The address range of the vnet"
}

variable "tags"{
    type = map
    description = "Tags for the VNET"
}
