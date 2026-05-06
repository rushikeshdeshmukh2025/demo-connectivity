variable "name" {
  description = "Name of the Private DNS Zone (e.g. privatelink.blob.core.windows.net)."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the Private DNS Zone."
  type        = string
}

variable "virtual_network_links" {
  description = "Map of virtual network links to associate with the Private DNS Zone. Key is the link logical name."
  type = map(object({
    virtual_network_id   = string
    registration_enabled = optional(bool, false)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to the Private DNS Zone and its virtual network links."
  type        = map(string)
  default     = {}
}
