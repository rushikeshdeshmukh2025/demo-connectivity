variable "name" {
  description = "Name of the Virtual Network."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Virtual Network."
  type        = string
}

variable "address_space" {
  description = "List of CIDR address spaces for the Virtual Network."
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnets to create. Key is the subnet logical name used as index."
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  default = {}
}

variable "ip_pool_id" {
  description = "Resource ID of the Network Manager IP pool from which this VNet's address space is allocated. Used for traceability."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the Virtual Network."
  type        = map(string)
  default     = {}
}
