variable "name" {
  description = "Name of the Virtual Network Peering."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing the source VNet."
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the source Virtual Network."
  type        = string
}

variable "remote_virtual_network_id" {
  description = "Resource ID of the remote (peer) Virtual Network."
  type        = string
}

variable "allow_virtual_network_access" {
  description = "Whether to allow traffic from the peered VNet."
  type        = bool
  default     = true
}

variable "allow_forwarded_traffic" {
  description = "Whether to allow forwarded traffic from the peered VNet."
  type        = bool
  default     = true
}

variable "allow_gateway_transit" {
  description = "Whether to allow gateway transit for the peering."
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "Whether to use remote gateways for the peering."
  type        = bool
  default     = false
}
