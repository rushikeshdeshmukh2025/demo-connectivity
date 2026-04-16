variable "subscription_id" {
  description = "The Azure subscription ID to deploy resources into."
  type        = string
}

variable "environment" {
  description = "The deployment environment (dev, test, pt, live, global, rnd)."
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources into."
  type        = string
  default     = "germanywestcentral"
}

variable "company_prefix" {
  description = "Three-letter company prefix used in resource naming."
  type        = string
  default     = "rus"
}

variable "region_short" {
  description = "Short name of the Azure region used in resource naming (e.g. gwc)."
  type        = string
  default     = "gwc"
}
