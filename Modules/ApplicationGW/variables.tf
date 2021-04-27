variable "name"{
    type = string
    description = "Name of the gateway resource"
}

variable "rg"{
    type = string
    description = "Resource Group for the gateway"
}

variable "location"{
    type = string
    description = "Location/Region for the gateway"
}

variable "sku_name"{
    type = string
    description = "SKU name as per Azure documentation"
}

variable "sku_tier"{
    type = string
    description = "SKU tier type. Typically Standard"
}

variable "min_capacity"{
    type = number
    description = "The minimum amount of GWs that will be deployed at any time"
}

variable "max_capacity"{
    type = number
    description = "The maximum amount of GWs that will be deployed at any time"
}

variable "gateway_snet_id"{
    type = string
    description = "The ID of the gateway subnet"
}

variable "ipconf_front_ip"{
    type = string
    description = "IP of the Gateway"
}

variable "website_path"{
    type = string
    description = "The address that the server will host. I.e http://<server><path>"
}

variable "zones"{
    type = list(string)
    description = "list of zones. I.e [1,2,3] (but with quotes around numbers)"
}




