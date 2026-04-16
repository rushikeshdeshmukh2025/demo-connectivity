variable "name" {
  description = "Name of the Network Security Group."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Network Security Group."
  type        = string
}

variable "subnet_ids" {
  description = "Map of subnet logical name to subnet resource ID to associate with the NSG."
  type        = map(string)
  default     = {}
}

variable "security_rules" {
  description = "Map of security rules to add to the NSG."
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = optional(string)
    destination_port_range     = optional(string)
    source_address_prefix      = optional(string)
    destination_address_prefix = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to the Network Security Group."
  type        = map(string)
  default     = {}
}
