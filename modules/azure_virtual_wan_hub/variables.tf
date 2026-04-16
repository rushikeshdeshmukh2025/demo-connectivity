variable "name" {
  description = "Name of the Virtual WAN Hub."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Virtual WAN Hub."
  type        = string
}

variable "virtual_wan_id" {
  description = "Resource ID of the parent Virtual WAN."
  type        = string
}

variable "address_prefix" {
  description = "The CIDR address prefix (/23) for the Virtual WAN Hub."
  type        = string
}

variable "sku" {
  description = "The SKU of the Virtual WAN Hub. Allowed values: Basic, Standard."
  type        = string
  default     = "Standard"
}

variable "tags" {
  description = "Tags to apply to the Virtual WAN Hub."
  type        = map(string)
  default     = {}
}
