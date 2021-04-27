variable "name" {
  type        = string
  description = "Name of MySQL server"
}

variable "location" {
  type        = string
  description = "Location of MySQL Server"
}

variable "rg" {
  type        = string
  description = "Resource Group of MySQL Server"
}

variable "admin" {
  type        = string
  description = "Admin Username of MySQL Server"
}

variable "password" {
  type        = string
  description = "Admin Password of MySQL Server"
}

variable "sku" {
  type        = string
  description = "SKU of MySQL Server"
}

variable "size" {
  type        = number
  description = "Size of MySQL Server in MB"
}

variable "create_mode" {
  type        = string
  description = "The method of creation. Default is a fresh build"
  default     = "Default"
}

variable "create_source_id" {
  type        = string
  description = "Creation source of master DB. If not the master a fake null value is passed."
  default     = ".."
}

variable "tags" {
  type        = map(any)
  description = "Tags that get applied to the resource"
}