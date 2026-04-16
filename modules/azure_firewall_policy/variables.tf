variable "name" {
  description = "Name of the Azure Firewall Policy."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Firewall Policy."
  type        = string
}

variable "sku" {
  description = "SKU of the Firewall Policy. Allowed values: Basic, Standard, Premium."
  type        = string
  default     = "Standard"
}

variable "threat_intelligence_mode" {
  description = "Threat intelligence mode. Allowed values: Alert, Deny, Off."
  type        = string
  default     = "Alert"
}

variable "tags" {
  description = "Tags to apply to the Firewall Policy."
  type        = map(string)
  default     = {}
}
