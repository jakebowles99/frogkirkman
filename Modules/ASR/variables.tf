
variable "rsv_name"{
    type        = string
    description = "The given name to the RSV"
}

variable "rsv_location"{
    type        = string
    description = "The location of the RSV"
}

variable "rsv_sku"{
    type = string
    description = "The SKU of the RSV"
}

variable "rg_second_name"{
    type = string
    description = "The name of the second rg"
}

variable "rg_second_location"{
    type = string
    description = "The name of the second location"
}

variable "primary_fabric_name"{
    type = string
    description = "The primary fabric name"
}

variable "rg_primary_name"{
    type = string
    description = "Primary resource group name"
}

variable "rg_primary_location"{
    type = string
    description = "The name of the primary location"
}

variable "secondary_fabric_name"{
    type = string
    description = "The name of the secondary fabric"
}

variable "primary_protection_container"{
    type = string
    description = "The name of the primary container"
}

variable "secondary_protection_container"{
    type = string
    description = "The name of the secondary container"
}

variable "secondary_vnet_name"{
    type = string
    description = "name of the secondary vnet"
}

variable "secondary_vnet_address_space"{
    type = list(string)
    description = "Address space of secondary vnet"
}

variable "secondary_vnet_subnet1"{
    type = string
    description = "name of the secondary vnet first subnet"
}

variable "secondary_subnet_address_space"{
    type = list(string)
    description = "Address space of secondary vnet first subnet"
}

variable "replicated_vm_name"{
    type = string
    description = "name of the VM given when failed over"
}

variable "source_vm_id"{
    type = string
    description = "The ID of the VM in the main region"
}

variable "os_disk_id"{
    type = string
    description = "OS disk ID of source VM"
}

variable "nic_id"{
    type = string
    description = "NIC ID attached to source"
}

variable "rg_second_id"{
    type = string
    default = "Secondary RG ID for the replication"
}

variable "tags"{
    type = map
    description = "Tags that get applied to the resource"
}





