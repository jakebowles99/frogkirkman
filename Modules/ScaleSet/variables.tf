variable "scale_set_name"{
    type = string
    description = "The name of the Scale Set"
}

variable "location"{
    type = string
    description = "The location of the Scale Set"
}

variable "rg"{
    type = string
    description = "The name of the resource group"
}

variable "SKU_name"{
    type = string
    description = "SKU name for all VMs in the SS"
}

variable "publisher"{
    type = string
    description = "Publisher of image deployed to the VM"
}

variable "offer"{
    type = string
    description = "Offer of image deployed to VM"
}

variable "image_sku"{
    type = string
    description = "SKU of image deployed to VM"
}
 
variable "disk_sku"{
    type = string
    description = "SKU of the OS disk deployed on the VMs"
}

variable "username"{
    type = string
    description = "Username added to the VM"
}

variable "password"{
    type = string
    description = "Password added to the VM"
}

variable "subnet_id"{
    type = string
    description = "The ID of the subnet the VMs will be deployed to"
}

variable "default_vm"{
    type = number
    description = "Default amount of VMs that will be active"
}

variable "min_vm"{
    type = number
    description = "Minimum amount of VMs that will be active"
}

variable "max_vm"{
    type = number
    description = "Max amount of VMs that will be active"
}

variable "increase_percentage"{
    type = number
    description = "VM Scale Set will increase VM by 1 when threshold is met"
}

variable "decrease_percentage"{
    type = number
    description = "VM Scale Set will decrease VM by 1 when threshold is met"
}

variable "lb_probe_id"{
    type = string
    description = "The probe ID attached to the load balancer"
}

variable "backend_addpool_id"{
    type = string
    description = "ID of backend address pool on the LB"
}

variable "nat_ids"{
    type = list(string)
    description = "List of NAT IDs attached to the LB"
}

variable "tags"{
    type = map
    description = "Tags that get applied to the resource"
}

variable "zones"{
    type = list(string)
    description = "The zones that the scale set is deployed into"
}