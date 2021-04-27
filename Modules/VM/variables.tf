variable "location"{
    type = string
    description = "Network Interface Card location"
}

variable "rg"{
    type = string
    description = "Network Interface Card resource group"
}

variable "snet_id"{
    type = string
    description = "Network Interface Card resource group"
}

variable "nic_privateip_address"{
    type = string
    description = "NIC IP address"
}

variable "nic_tags"{
    type = map
    description = "NIC tags"
}

variable "vm_name"{
    type = string
    description = "The VM name (not hostname)"
}

variable "vm_size"{
    type = string
    description = "Size/SKU of the VM"
}

variable "vm_username"{
    type = string
    description = "Username on the VM"
}

variable "vm_password"{
    type = string
    description = "VM password"
}

variable "av_zone"{
    type = number
    description = "Av Zone for VM"
}

variable "disk_type"{
    type = string
    description = "The disk SKU for the OS disk"
}

variable "os_disk_cache"{
    type = string
    description = "The cache mode on the OS disk"
}

variable "os_disk_size"{
    type = string
    description = "The OS disk size"
}

variable "VM_tags"{
    type = map
    description = "The tags displayed on the VM"
}


