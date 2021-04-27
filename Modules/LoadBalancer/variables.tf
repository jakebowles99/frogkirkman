variable "name"{
    type = string
    description = "Name of the Load Balancer"
}

variable "location"{
    type = string
    description = "The location/region of the LB"
}

variable "rg"{
    type = string
    description = "The resource group that the LB will be placed in"
}

variable "private_ip"{
    type = string
    description = "private IP address of the LB"
}

variable "snet_id"{
    type = string
    description = "The ID of the subnet that the LB will be attached to"
}

variable "website_path"{
    type = string
    description = "The address that the server will host. I.e http://<server><path>"
}

variable "tags"{
    type = map
    description = "Tags that get applied to the resource"
}