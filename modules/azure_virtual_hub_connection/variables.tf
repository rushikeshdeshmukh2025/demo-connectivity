variable "name" {
  description = "Name of the Virtual Hub Connection."
  type        = string
}

variable "virtual_hub_id" {
  description = "Resource ID of the Virtual WAN Hub."
  type        = string
}

variable "remote_virtual_network_id" {
  description = "Resource ID of the spoke Virtual Network to connect."
  type        = string
}

variable "internet_security_enabled" {
  description = "Whether internet security is enabled for the connection."
  type        = bool
  default     = false
}
