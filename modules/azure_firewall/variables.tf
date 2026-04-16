variable "name" {
  description = "Name of the Azure Firewall."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Azure Firewall."
  type        = string
}

variable "sku_name" {
  description = "SKU name of the Azure Firewall."
  type        = string
  default     = "AZFW_Hub"
}

variable "sku_tier" {
  description = "SKU tier of the Azure Firewall. Allowed values: Basic, Standard, Premium."
  type        = string
  default     = "Standard"
}

variable "firewall_policy_id" {
  description = "Resource ID of the Firewall Policy to associate."
  type        = string
}

variable "virtual_hub_id" {
  description = "Resource ID of the Virtual Hub to deploy the firewall into."
  type        = string
}

variable "public_ip_count" {
  description = "Number of public IP addresses to associate with the firewall in the hub."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to apply to the Azure Firewall."
  type        = map(string)
  default     = {}
}
