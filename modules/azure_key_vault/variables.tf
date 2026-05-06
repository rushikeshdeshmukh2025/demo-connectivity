variable "name" {
  description = "Name of the Key Vault. Must be globally unique, 3–24 alphanumeric characters and hyphens."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the Key Vault."
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault."
  type        = string
}

variable "tenant_id" {
  description = "Azure Active Directory tenant ID for the Key Vault."
  type        = string
}

variable "sku_name" {
  description = "SKU of the Key Vault. Valid values: standard, premium."
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted objects. Must be between 7 and 90."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to the Key Vault."
  type        = map(string)
  default     = {}
}
