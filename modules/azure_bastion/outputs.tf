output "id" {
  description = "The resource ID of the Azure Bastion host."
  value       = azurerm_bastion_host.bastion.id
}

output "dns_name" {
  description = "The FQDN DNS name of the Azure Bastion host."
  value       = azurerm_bastion_host.bastion.dns_name
}

output "public_ip_address" {
  description = "The public IP address of the Azure Bastion host."
  value       = azurerm_public_ip.bastion_pip.ip_address
}
