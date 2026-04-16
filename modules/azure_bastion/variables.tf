variable "name" {
  description = "Name of the Azure Bastion host."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Azure Bastion host."
  type        = string
}

variable "subnet_id" {
  description = "Resource ID of the AzureBastionSubnet."
  type        = string
}

variable "public_ip_name" {
  description = "Name of the public IP address resource for Bastion."
  type        = string
}

variable "sku" {
  description = "SKU of the Azure Bastion host. Allowed values: Basic, Standard, Premium."
  type        = string
  default     = "Standard"
}

variable "tags" {
  description = "Tags to apply to the Azure Bastion host and its public IP."
  type        = map(string)
  default     = {}
}
