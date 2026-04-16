variable "name" {
  description = "Name of the Virtual WAN."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Virtual WAN."
  type        = string
}

variable "type" {
  description = "Type of the Virtual WAN. Allowed values: Basic, Standard."
  type        = string
  default     = "Standard"
}

variable "disable_vpn_encryption" {
  description = "Whether to disable VPN encryption."
  type        = bool
  default     = false
}

variable "allow_branch_to_branch_traffic" {
  description = "Whether to allow branch-to-branch traffic."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the Virtual WAN."
  type        = map(string)
  default     = {}
}
