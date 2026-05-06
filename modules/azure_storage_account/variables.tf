variable "name" {
  description = "Name of the Storage Account. Must be globally unique, 3–24 lowercase alphanumeric characters."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the Storage Account."
  type        = string
}

variable "location" {
  description = "Azure region for the Storage Account."
  type        = string
}

variable "account_tier" {
  description = "Storage account tier. Valid values: Standard, Premium."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage account replication type. Valid values: LRS, GRS, RAGRS, ZRS."
  type        = string
  default     = "LRS"
}

variable "tags" {
  description = "Tags to apply to the Storage Account."
  type        = map(string)
  default     = {}
}
