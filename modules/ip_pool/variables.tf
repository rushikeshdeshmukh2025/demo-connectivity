variable "name" {
  description = "Name of the IP pool (Network Manager Static CIDR)."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the IP pool."
  type        = string
}

variable "address_prefixes" {
  description = "List of CIDR address prefixes allocated to this pool."
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the IP pool resource."
  type        = map(string)
  default     = {}
}
