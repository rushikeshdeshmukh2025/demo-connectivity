variable "name" {
  description = "Name of the Private Endpoint."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the Private Endpoint."
  type        = string
}

variable "location" {
  description = "Azure region for the Private Endpoint."
  type        = string
}

variable "subnet_id" {
  description = "Resource ID of the subnet in which to place the Private Endpoint."
  type        = string
}

variable "private_connection_resource_id" {
  description = "Resource ID of the target resource to connect via private endpoint."
  type        = string
}

variable "subresource_names" {
  description = "List of subresource names for the private endpoint connection (e.g. [\"blob\"], [\"vault\"])."
  type        = list(string)
}

variable "private_dns_zone_ids" {
  description = "List of Private DNS Zone resource IDs to associate with the private endpoint DNS zone group."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the Private Endpoint."
  type        = map(string)
  default     = {}
}
