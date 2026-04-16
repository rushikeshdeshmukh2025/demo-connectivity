variable "name" {
  description = "Name of the Application Security Group."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Application Security Group."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Application Security Group."
  type        = map(string)
  default     = {}
}
